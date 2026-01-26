# Cloud Deployment Guide for CIFAR-10 FastAPI

This guide walks you through deploying the FastAPI CIFAR-10 Image Classification API to Google Cloud Run (recommended) or App Engine.

## Prerequisites

1. **Google Cloud Account** with billing enabled
2. **gcloud CLI** installed and authenticated (`gcloud auth login`)
3. **Docker** installed (for local testing)
4. A Google Cloud project with an active billing account

## Option 1: Deploy to Cloud Run (Recommended - More Generous Free Tier)

Cloud Run is ideal for this use case because:
- **Free tier**: 180,000 vCPU-seconds, 360,000 GiB-seconds per month
- **Auto-scaling**: Starts from 0 instances (save costs)
- **Pay-per-use**: Only charged when handling requests
- **Better for Python/ML workloads**: No memory constraints

### Step 1: Enable Required APIs

```bash
gcloud services enable cloudbuild.googleapis.com run.googleapis.com container.googleapis.com
```

### Step 2: Build and Push Docker Image

Set your project ID and region:
```bash
export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1
export IMAGE_NAME=cifar10-api
```

Build the Docker image:
```bash
gcloud builds submit --tag gcr.io/$PROJECT_ID/$IMAGE_NAME
```

### Step 3: Deploy to Cloud Run

```bash
gcloud run deploy $IMAGE_NAME \
  --image gcr.io/$PROJECT_ID/$IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --memory 2Gi \
  --cpu 1 \
  --timeout 300 \
  --allow-unauthenticated \
  --max-instances 3 \
  --min-instances 0
```

### Step 4: Get Your Public URL

```bash
gcloud run services describe $IMAGE_NAME --region $REGION --format='value(status.url)'
```

The output will be your public API URL like: `https://cifar10-api-abc123-uc.a.run.app`

## Option 2: Deploy to App Engine (Free Tier Available)

App Engine free tier includes:
- 28 hours/day of F1 instance (0.5 GB memory)
- Good for small, simple apps

### Step 1: Ensure Billing is Enabled

This is **required** for App Engine deployment.

### Step 2: Initialize App Engine

```bash
gcloud app create --region=us-central1
```

### Step 3: Deploy

```bash
gcloud app deploy app.yaml
```

### Step 4: Get Your Public URL

```bash
gcloud app browse
```

Or manually construct: `https://<PROJECT_ID>.appspot.com`

## Testing the Deployed API

### 1. Health Check (No Auth Required)

```bash
curl https://<YOUR_API_URL>/health
```

Expected response:
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

### 2. Image Classification

```bash
curl -X POST https://<YOUR_API_URL>/predict \
  -F "file=@/path/to/image.jpg"
```

Expected response:
```json
{
  "status": "success",
  "predictions": [
    {
      "class": "deer",
      "confidence": 0.9982
    },
    {
      "class": "horse",
      "confidence": 0.0011
    },
    {
      "class": "dog",
      "confidence": 0.0004
    }
  ]
}
```

### 3. Interactive API Documentation

Open in your browser:
- Cloud Run: `https://<YOUR_API_URL>/docs`
- App Engine: `https://<PROJECT_ID>.appspot.com/docs`

You can test the endpoints directly from Swagger UI.

## Local Testing

Before deploying to the cloud, test locally:

### Build and Run Docker Container

```bash
docker build -t cifar10-api .

docker run -p 8080:8080 \
  -v $(pwd)/model_cache:/app/model_cache \
  cifar10-api
```

The app will be available at `http://localhost:8080`

### Test Locally

```bash
# Health check
curl http://localhost:8080/health

# Upload an image
curl -X POST http://localhost:8080/predict \
  -F "file=@sample_image.jpg"
```

## Monitoring and Logs

### Cloud Run Logs
```bash
gcloud run logs read $IMAGE_NAME --limit 100 --region $REGION
```

### App Engine Logs
```bash
gcloud app logs read
```

## Cost Estimation

### Cloud Run (Recommended)
- Free tier covers most small/hobby use cases
- ~$0.000015 per vCPU-second, ~$0.0000025 per GB-second
- Typical inference: ~0.5-2 seconds per request

### App Engine
- Free tier: 28 hours/day of F1 instance
- Charged hourly for usage beyond free tier
- F1 instance: ~$0.05/hour

## Troubleshooting

### "Billing must be enabled"
- Go to [Google Cloud Console](https://console.cloud.google.com)
- Select your project
- Go to Billing → Link Billing Account
- Follow the prompts to add payment method

### "Model takes too long to load"
- First deployment may be slow due to model download (~340MB)
- Subsequent requests will be faster
- Cloud Run with min_instances=0 will spin down unused instances

### "Port 8080 already in use"
- Change the port: `docker run -p 9000:8080 cifar10-api`

### "Out of memory errors"
- Cloud Run: Increase memory (`--memory 2Gi` minimum recommended)
- App Engine: Use F2 instance for more memory (costs more)

## Security Notes

- Both Cloud Run and App Engine support authentication
- Current setup uses `--allow-unauthenticated` for simplicity
- For production, consider adding API keys or Cloud IAM

## Next Steps

1. Enable billing on your Google Cloud project
2. Choose Cloud Run or App Engine based on your needs
3. Follow the deployment steps for your chosen platform
4. Test the API with the provided curl commands
5. Share the public URL to start using the API!

## Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [App Engine Documentation](https://cloud.google.com/appengine/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Google Cloud Python Client Libraries](https://cloud.google.com/python/docs)
