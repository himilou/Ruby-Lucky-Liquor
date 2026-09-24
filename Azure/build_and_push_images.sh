#!/usr/bin/env bash

# NOTE this builds luckytasks or luckyweb but does not deploy to azure.
# execution of container_app_job.sh or container_app_web.sh is required to push to azure

if [ $# -eq 0 ]; then
    echo "Error: No parameter provided."
    exit 1
fi

# 2. If parameter matches 'x', do X. Else, do Y.
if [ "$1" == "luckyweb" ]; then

echo "building and pushing luckyweb to dockerhub..." 

set -euo pipefail

# Build and publish the production web and task images used by Azure.
# Docker Hub credentials must already be available to Docker.
# Run this script from the Azure directory:
#   source ./build_and_push_images.sh

IMAGE_OWNER="himilou"
IMAGE_TAG="Prod2-1"
PROJECT_ROOT=".."

# Both images use the same Rails application code and Dockerfile.
docker build \
  --tag "$IMAGE_OWNER/luckyweb:$IMAGE_TAG" \
  "$PROJECT_ROOT"

docker push "$IMAGE_OWNER/luckyweb:$IMAGE_TAG"

echo "Published $IMAGE_OWNER/luckyweb:$IMAGE_TAG"
exit 0

elif ["$1" == "luckytasks" ]; then

echo "building and deploying luckytasks to dockerhub .."
set -euo pipefail

# Build and publish the production web and task images used by Azure.
# Docker Hub credentials must already be available to Docker.
# Run this script from the Azure directory:
#   source ./build_and_push_images.sh

IMAGE_OWNER="himilou"
IMAGE_TAG="Prod2-1"
PROJECT_ROOT=".."

# Both images use the same Rails application code and Dockerfile.
docker build \
  --tag "$IMAGE_OWNER/luckyweb:$IMAGE_TAG" \
  "$PROJECT_ROOT"

docker tag "$IMAGE_OWNER/luckyweb:$IMAGE_TAG" "$IMAGE_OWNER/luckytasks:$IMAGE_TAG"

docker push "$IMAGE_OWNER/luckytasks:$IMAGE_TAG"
echo "Published $IMAGE_OWNER/luckytasks:$IMAGE_TAG"
exit 0

else
echo "enter luckyweb or luckytasks to build and deploy..."
exit 1
fi




