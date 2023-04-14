#!/bin/bash
chmod +x deploy.sh

# Get ENV from config.env
source config.env

# Enable GCP services
gcloud services enable cloudbuild.googleapis.com storage-component.googleapis.com containerregistry.googleapis.com run.googleapis.com

# Build image to container registry
gcloud builds submit --tag "$CONTAINER_HOST/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG" --ignore-file .gcloudignore

# Deploy service to cloud run
# gcloud run deploy --help
gcloud run deploy $SERVICE_NAME --image "$CONTAINER_HOST/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG" --platform managed --port "$PORT" --memory "$MEMORY" --timeout="$TIMEOUT" --region="$REGION" --allow-unauthenticated
