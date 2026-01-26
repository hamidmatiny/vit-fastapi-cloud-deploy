# CIFAR-10 Image Classification API 🚀

A high-performance FastAPI service that classifies images into the 10 CIFAR-10 categories (Airplane, Automobile, Bird, Cat, Deer, Dog, Frog, Horse, Ship, Truck). This project evolved from a custom-trained ResNet-18 to a **Vision Transformer (ViT)** using Transfer Learning from Hugging Face.

## 🌟 Evolution of the Project

Initially, this project used a **ResNet-18** architecture trained from scratch on CIFAR-10. While functional, it faced challenges with domain gap (low confidence on real-world high-res images).

The current version utilizes the **`aaraki/vit-base-patch16-224-in21k-finetuned-cifar10`** model. By switching to a Transformer-based architecture, the API now achieves:

* **98%+ Accuracy** on validation data.
* **High Confidence** on real-world, high-resolution uploads.
* **Robust Preprocessing** using the official ViT Image Processor.

---

## 🛠 Tech Stack

* **Framework:** FastAPI (Python 3.12)
* **ML Library:** PyTorch & Hugging Face Transformers
* **Model:** Vision Transformer (ViT)
* **Containerization:** Docker
* **Server:** Uvicorn (ASGI)

---

## 🚀 Getting Started

### 1. Installation & Setup

Clone the repository and install dependencies:

```bash
git clone https://github.com/hamidmatiny/Machine_Learning_API.git
cd Machine_Learning_API
python -m venv venv
source venv/bin/activate  # On Mac/Linux
pip install -r requirements.txt

```

### 2. Running Locally

Start the API using Uvicorn:

```bash
uvicorn main:app --reload

```

Access the interactive documentation (Swagger UI) at: `http://127.0.0.1:8000/docs`

### 3. Running with Docker (Recommended)

This project is optimized for Docker with a persistent model cache:

```bash
# Build the image
docker build -t cifar-api .

# Run with a volume to cache the 340MB model weights on your host machine
docker run -p 8000:8000 -v $(pwd)/model_cache:/app/model_cache cifar-api

```

---

## 📡 API Endpoints

### `GET /health`

Returns the status of the API and confirms if the heavy ML model is loaded into memory.

### `POST /predict`

Upload an image file to get the top 3 class predictions.

* **Request:** `multipart/form-data`
* **Response Body:**

```json
{
  "status": "success",
  "predictions": [
    { "class": "deer", "confidence": 0.9982 },
    { "class": "horse", "confidence": 0.0011 },
    { "class": "dog", "confidence": 0.0004 }
  ]
}

```

---

## 📁 Project Structure

```text
├── main.py            # FastAPI routes and server config
├── model.py           # ModelPredictor class (Hugging Face logic)
├── model_cache/       # Local storage for model weights (git-ignored)
├── requirements.txt   # Project dependencies
├── Dockerfile         # Container configuration
└── .gitignore         # Prevents large models/venvs from being pushed

```

---

## 🧠 Key Features Implemented

* **Local Weight Caching:** The model is saved locally in `model_cache/` to prevent re-downloading on every restart.
* **Health Monitoring:** Dedicated endpoint for deployment readiness checks.
* **Transfer Learning:** Leveraging state-of-the-art weights to solve the domain-gap problem.
* **Error Handling:** Robust validation for image file types and processing errors.

---

## 📝 License

This project is licensed under the MIT License.
