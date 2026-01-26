# CIFAR-10 FastAPI Cloud Deployment - Quick Start

Your FastAPI application is ready to deploy to Google Cloud! This directory contains everything you need.

## 📋 Files Overview

- **main.py** - FastAPI application with `/health` and `/predict` endpoints
- **model.py** - Vision Transformer model loader (aaraki/vit-base-patch16-224-in21k-finetuned-cifar10)
- **Dockerfile** - Containerized FastAPI app optimized for Cloud Run
- **requirements.txt** - Python dependencies with pinned versions
- **deploy.sh** - Automated deployment script
- **test_deployment.sh** - Script to test your deployed API
- **DEPLOYMENT_GUIDE.md** - Detailed deployment instructions

## 🚀 Quick Start (3 Steps)

### Step 1: Enable Billing on Google Cloud
Your Google Cloud project needs billing enabled first.
```bash
# Visit: https://console.cloud.google.com/billing
# Create/select a billing account and link it to your project
```

### Step 2: Run the Deployment Script
```bash
./deploy.sh
```

This automatically:
- ✓ Checks billing status
- ✓ Enables required APIs (Cloud Build, Cloud Run)
- ✓ Builds Docker image
- ✓ Deploys to Cloud Run
- ✓ Provides public URL

### Step 3: Test Your API
```bash
# Copy the URL from Step 2 output
./test_deployment.sh "https://your-api-url-here.a.run.app"
```

## 📡 API Endpoints

Once deployed, your API provides:

### Health Check
```bash
curl https://your-api-url/health
# Response: {"status": "healthy", "model_loaded": true}
```

### Image Classification
```bash
curl -X POST https://your-api-url/predict \
  -F "file=@image.jpg"
# Response: {"status": "success", "predictions": [...]}
```

### Interactive Documentation
Visit: `https://your-api-url/docs` in your browser for Swagger UI

## 💰 Cost & Free Tier

**Cloud Run (Recommended)**
- **Free tier**: 180,000 vCPU-seconds + 360,000 GiB-seconds/month
- Perfect for hobby/small projects
- Scales to zero when idle (no costs!)

## 🔧 Manual Deployment (Without Script)

If `deploy.sh` doesn't work, follow [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

## 🧪 Local Testing

Test locally before cloud deployment:

```bash
# Build Docker image
docker build -t cifar10-api .

# Run container
docker run -p 8080:8080 \
  -v $(pwd)/model_cache:/app/model_cache \
  cifar10-api

# Test
curl http://localhost:8080/health
curl -X POST http://localhost:8080/predict -F "file=@image.jpg"
```

## 📊 Model Details

- **Model**: Vision Transformer (ViT) from Hugging Face
- **Architecture**: aaraki/vit-base-patch16-224-in21k-finetuned-cifar10
- **Accuracy**: 98%+ on CIFAR-10 validation set
- **Classes**: Airplane, Automobile, Bird, Cat, Deer, Dog, Frog, Horse, Ship, Truck
- **Model Size**: ~340MB (cached locally on first download)

## ⚙️ Configuration

### Memory & CPU (Cloud Run)
- Memory: 2Gi (recommended for this model)
- CPU: 1 vCPU
- Timeout: 300 seconds
- Max instances: 3 (scales down to 0 when idle)

To change these, edit `deploy.sh` before running.

## 🐛 Troubleshooting

### "Billing must be enabled"
→ Enable billing in Google Cloud Console first

### "Permission denied" on deploy.sh
```bash
chmod +x deploy.sh test_deployment.sh
```

### Model takes time to load on first request
→ Normal! First deployment downloads 340MB model. Subsequent requests are faster.

### Model cache takes too much space
→ Cloud Run instance has 2GB ephemeral storage. Should be enough for model + temp files.

## 📚 Documentation

- **Full deployment guide**: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **FastAPI docs**: https://fastapi.tiangolo.com/
- **Cloud Run docs**: https://cloud.google.com/run/docs
- **Vision Transformer model**: https://huggingface.co/aaraki/vit-base-patch16-224-in21k-finetuned-cifar10

## 🎯 What's Next?

1. **Deploy**: Run `./deploy.sh`
2. **Test**: Use `./test_deployment.sh` with the returned URL
3. **Monitor**: Check logs in Cloud Console
4. **Share**: Copy your public API URL and share it!

---

**Status**: ✅ Ready to deploy  
**Last Updated**: January 26, 2026
