#!/bin/bash

# Test script for CIFAR-10 FastAPI Cloud Deployment
# Usage: ./test_deployment.sh <API_URL> [IMAGE_PATH]

if [ -z "$1" ]; then
    echo "Usage: $0 <API_URL> [IMAGE_PATH]"
    echo ""
    echo "Examples:"
    echo "  $0 https://cifar10-api-abc123-uc.a.run.app"
    echo "  $0 http://localhost:8080 sample_image.jpg"
    exit 1
fi

API_URL=$1
IMAGE_PATH=${2:-"test_image.jpg"}

echo "=================================================="
echo "Testing CIFAR-10 FastAPI Deployment"
echo "=================================================="
echo "API URL: $API_URL"
echo ""

# Test 1: Health Check
echo "[1/3] Testing Health Check..."
echo "Command: curl -s $API_URL/health | jq"
echo ""

HEALTH=$(curl -s "$API_URL/health")
echo "Response:"
echo "$HEALTH" | python3 -m json.tool 2>/dev/null || echo "$HEALTH"

# Check if model is loaded
if echo "$HEALTH" | grep -q '"model_loaded": true'; then
    echo "✓ Model is loaded and ready!"
else
    echo "✗ Model is not loaded. This might be the first deployment."
    echo "  Cloud Run may still be initializing. Please wait a moment and try again."
fi

echo ""
echo ""

# Test 2: Swagger Documentation
echo "[2/3] API Documentation Available At:"
echo "$API_URL/docs"
echo "  - Swagger UI for interactive testing"
echo ""

# Test 3: Prediction Test
echo "[3/3] Testing Prediction Endpoint..."

if [ -f "$IMAGE_PATH" ]; then
    echo "Using image: $IMAGE_PATH"
    echo "Command: curl -X POST $API_URL/predict -F \"file=@$IMAGE_PATH\""
    echo ""
    
    PREDICTION=$(curl -s -X POST "$API_URL/predict" -F "file=@$IMAGE_PATH")
    echo "Response:"
    echo "$PREDICTION" | python3 -m json.tool 2>/dev/null || echo "$PREDICTION"
else
    echo "⚠ Image file not found: $IMAGE_PATH"
    echo ""
    echo "To test prediction, you need an image file."
    echo "Example usage:"
    echo "  curl -X POST $API_URL/predict -F \"file=@your_image.jpg\""
    echo ""
    echo "The model accepts CIFAR-10 image categories:"
    echo "  - Airplane, Automobile, Bird, Cat, Deer"
    echo "  - Dog, Frog, Horse, Ship, Truck"
fi

echo ""
echo "=================================================="
echo "Testing complete!"
echo "=================================================="
