#!/usr/bin/env bash

# NOTE this does not build luckytasks or apply yml changes to either file by default, only renames the luckyweb image. 
# Changes to the yml file require 
# execution of container_app_job.sh or container_app_web.sh

set -euo pipefail

# Build and publish the production web and task images used by Azure.
# Docker Hub credentials must already be available to Docker.
# Run this script from the Azure directory:
#   source ./build_and_push_images.sh

IMAGE_OWNER="himilou"
IMAGE_TAG="Prod1"
PROJECT_ROOT=".."

# Both images use the same Rails application code and Dockerfile.
docker build \
  --tag "$IMAGE_OWNER/luckyweb:$IMAGE_TAG" \
  "$PROJECT_ROOT"

docker tag "$IMAGE_OWNER/luckyweb:$IMAGE_TAG" "$IMAGE_OWNER/luckytasks:$IMAGE_TAG"

#docker push "$IMAGE_OWNER/luckyweb:$IMAGE_TAG"
docker push "$IMAGE_OWNER/luckytasks:$IMAGE_TAG"

#echo "Published $IMAGE_OWNER/luckyweb:$IMAGE_TAG"
echo "Published $IMAGE_OWNER/luckytasks:$IMAGE_TAG"
