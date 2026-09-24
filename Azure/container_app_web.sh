#!/usr/bin/env bash
set -euo pipefail

# Deploy the luckyweb production image as an Azure Container App.
# Run this script from the Azure directory:
#   source ./container_app_web.sh

RESOURCE_GROUP="luckyliquor"
LOCATION="westus"
ENVIRONMENT_NAME="luckyliquor-env"
APP_NAME="luckyweb"
STORAGE_ACCOUNT_NAME="luckyliquorstorage"
STORAGE_API_VERSION="2025-01-01"
SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
YAML_FILE="container_app_web.yaml"

# Docker Compose loads .env automatically, but shell scripts do not.
if [[ -f ../.env ]]; then
  set -a
  source ../.env
  set +a
fi

# Use an explicitly exported key when present; otherwise use the existing .env name.
RAILS_MASTER_KEY="${RAILS_MASTER_KEY:-${PRODUCTION_RAILS_MASTER_KEY:-}}"
: "${RAILS_MASTER_KEY:?Define PRODUCTION_RAILS_MASTER_KEY in .env before deploying}"

# Get the storage account key without writing it to this file or printing it.
STORAGE_KEY="$(az storage account keys list \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query '[0].value' -o tsv)"

# Register an Azure File share with the Container Apps environment if needed.
ensure_storage() {
  local storage_name="$1"
  local share_name="$2"

  if az containerapp env storage show \
    --name "$ENVIRONMENT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --storage-name "$storage_name" >/dev/null 2>&1; then
    echo "Storage registration exists: $storage_name"
    return
  fi

  az rest --method put \
    --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/managedEnvironments/$ENVIRONMENT_NAME/storages/$storage_name?api-version=$STORAGE_API_VERSION" \
    --body "{\"properties\":{\"azureFile\":{\"accountName\":\"$STORAGE_ACCOUNT_NAME\",\"accountKey\":\"$STORAGE_KEY\",\"shareName\":\"$share_name\",\"accessMode\":\"ReadWrite\"}}}" \
    --query '{name:name,share:properties.azureFile.shareName}' -o table
}

# These registrations map the existing Azure File shares to Container Apps.
ensure_storage "luckyliquor-storage-mount" "lucky-rails-storage"
ensure_storage "luckyliquor-log-mount" "lucky-rails-log"

# Create the app once, or update it on later runs.
if az containerapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then
  az containerapp update \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --yaml "$YAML_FILE"
else
  az containerapp create \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --yaml "$YAML_FILE"
fi

# Replace the bootstrap value with the real Rails key after YAML deployment.
az containerapp secret set \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --secrets rails-master-key="$RAILS_MASTER_KEY"

# Force a new revision so running replicas receive the updated secret value.
az containerapp update \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --set-env-vars "DEPLOYMENT_ID=$(date +%s)"

echo "Container App deployed: $APP_NAME"
az containerapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "properties.configuration.ingress.fqdn" \
  -o tsv
