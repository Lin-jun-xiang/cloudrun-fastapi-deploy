#!/bin/bash
chmod +x deploy_art.sh

# Get ENV from config.env
source config_art.env

# Enable GCP services
gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com

# Check if Artifact Registry repository exists
if gcloud artifacts repositories describe $REPOSITORY_NAME --location=$REGION > /dev/null 2>&1; then
    echo "Artifact Registry repository '$REPOSITORY_NAME' already exists."
else
    echo "Creating Artifact Registry repository '$REPOSITORY_NAME'..."
    gcloud artifacts repositories create $REPOSITORY_NAME --repository-format=docker --location=$REGION
fi

# Build image to artifact registry
gcloud builds submit --tag "$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:$IMAGE_TAG" --ignore-file .gcloudignore

# Deploy service to cloud run
# gcloud run deploy --help
gcloud run deploy $SERVICE_NAME --image "$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:$IMAGE_TAG" --platform managed --port "$PORT" --memory "$MEMORY" --timeout="$TIMEOUT" --region="$REGION" --allow-unauthenticated
