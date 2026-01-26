#!/bin/bash

# Automated deployment script for Cloud Run
# This script builds and deploys the FastAPI app to Google Cloud Run
# Prerequisites: gcloud CLI installed, authenticated, and billing enabled

set -e  # Exit on error

echo "=================================================="
echo "CIFAR-10 FastAPI Cloud Run Deployment"
echo "=================================================="
echo ""

# Get project ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    echo "Error: No gcloud project set. Run: gcloud config set project <PROJECT_ID>"
    exit 1
fi

echo "Project ID: $PROJECT_ID"

# Configuration
REGION=${REGION:-"us-central1"}
IMAGE_NAME="cifar10-api"
SERVICE_NAME="cifar10-api"

echo "Region: $REGION"
echo "Image Name: $IMAGE_NAME"
echo ""

# Check billing
echo "[1/5] Checking if billing is enabled..."
BILLING=$(gcloud billing projects describe $PROJECT_ID --format='value(billingAccountName)' 2>/dev/null || echo "")

if [ -z "$BILLING" ] || [ "$BILLING" = "None" ]; then
    echo "❌ Billing is not enabled for this project!"
    echo ""
    echo "To enable billing:"
    echo "  1. Go to: https://console.cloud.google.com/billing"
    echo "  2. Create or select a billing account"
    echo "  3. Link it to project: $PROJECT_ID"
    echo ""
    exit 1
fi

echo "✓ Billing enabled"
echo ""

# Enable APIs
echo "[2/5] Enabling required Google Cloud APIs..."
gcloud services enable cloudbuild.googleapis.com run.googleapis.com container.googleapis.com --quiet

echo "✓ APIs enabled"
echo ""

# Build Docker image
echo "[3/5] Building Docker image..."
echo "Running: gcloud builds submit --tag gcr.io/$PROJECT_ID/$IMAGE_NAME"
echo ""

gcloud builds submit --tag gcr.io/$PROJECT_ID/$IMAGE_NAME

echo ""
echo "✓ Docker image built and pushed to Google Container Registry"
echo ""

# Deploy to Cloud Run
echo "[4/5] Deploying to Cloud Run..."
echo "Running: gcloud run deploy..."
echo ""

gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --memory 2Gi \
  --cpu 1 \
  --timeout 300 \
  --allow-unauthenticated \
  --max-instances 3 \
  --min-instances 0 \
  --quiet

echo ""
echo "✓ Deployment successful!"
echo ""

# Get the service URL
echo "[5/5] Retrieving service URL..."
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --format='value(status.url)')

echo ""
echo "=================================================="
echo "🎉 DEPLOYMENT COMPLETE!"
echo "=================================================="
echo ""
echo "Your FastAPI is now live at:"
echo ""
echo "  🌐 $SERVICE_URL"
echo ""
echo "API Endpoints:"
echo "  • Health check:  GET  $SERVICE_URL/health"
echo "  • Prediction:    POST $SERVICE_URL/predict"
echo "  • Documentation: $SERVICE_URL/docs"
echo ""
echo "Testing:"
echo "  ./test_deployment.sh \"$SERVICE_URL\""
echo ""
echo "Using curl:"
echo "  curl $SERVICE_URL/health"
echo "  curl -X POST $SERVICE_URL/predict -F \"file=@image.jpg\""
echo ""
