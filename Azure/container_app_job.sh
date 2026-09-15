


# # Register namespaces and update extensions
# az extension add --name containerapp --upgrade
# az provider register --namespace Microsoft.App
# az provider register --namespace Microsoft.Storage


# # Step 1
# az containerapp env create \
#   --name $ENVIRONMENT_NAME \
#   --resource-group $RESOURCE_GROUP \
#   --location $LOCATION

# # Step 2
# az containerapp env storage set \
#   --name $ENVIRONMENT_NAME \
#   --resource-group $RESOURCE_GROUP \
#   --storage-name "luckyliquor-public-assets-mount" \
#   --azure-file-account-name $STORAGE_ACCOUNT_NAME \
#   --azure-file-account-key $STORAGE_KEY \
#   --azure-file-share-name $SHARE_NAME \
#   --access-mode "ReadWrite"

# Define configurations
RESOURCE_GROUP="luckyliquor"
LOCATION="westus"
ENVIRONMENT_NAME="luckyliquor-env"
JOB_NAME="luckyliquor-rake-tasks"
STORAGE_ACCOUNT_NAME="luckyliquorstorage" # Must be globally unique
SHARE_NAME="lucky-rails-public-assets" # Existing SMB File Share
STORAGE_API_VERSION="2025-01-01"
SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

# Docker Compose loads .env automatically, but shell scripts do not.
if [[ -f ../.env ]]; then
  set -a
  source ../.env
  set +a
fi

# Prefer an explicitly exported key, then use PRODUCTION_RAILS_MASTER_KEY from .env.
RAILS_MASTER_KEY="${RAILS_MASTER_KEY:-${PRODUCTION_RAILS_MASTER_KEY:-}}"
: "${RAILS_MASTER_KEY:?Define PRODUCTION_RAILS_MASTER_KEY in .env before deploying}"

# Register the existing log share with Container Apps if it is not registered yet.
if ! az containerapp env storage show \
  --name "$ENVIRONMENT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --storage-name luckyliquor-log-mount >/dev/null 2>&1; then
  STORAGE_KEY="$(az storage account keys list \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query '[0].value' -o tsv)"
  az rest --method put \
    --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/managedEnvironments/$ENVIRONMENT_NAME/storages/luckyliquor-log-mount?api-version=$STORAGE_API_VERSION" \
    --body "{\"properties\":{\"azureFile\":{\"accountName\":\"$STORAGE_ACCOUNT_NAME\",\"accountKey\":\"$STORAGE_KEY\",\"shareName\":\"lucky-rails-log\",\"accessMode\":\"ReadWrite\"}}}" \
    --query '{name:name,share:properties.azureFile.shareName}' -o table
fi


if az containerapp job show --name $JOB_NAME --resource-group $RESOURCE_GROUP >/dev/null 2>&1; then
  az containerapp job update \
    --name $JOB_NAME \
    --resource-group $RESOURCE_GROUP \
    --yaml container_app_job.yaml
else
  az containerapp job create \
    --name $JOB_NAME \
    --resource-group $RESOURCE_GROUP \
    --yaml container_app_job.yaml
fi

az containerapp job secret set \
  --name $JOB_NAME \
  --resource-group $RESOURCE_GROUP \
  --secrets rails-master-key="$RAILS_MASTER_KEY"

az containerapp job start \
  --name $JOB_NAME \
  --resource-group $RESOURCE_GROUP


