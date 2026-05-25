from fastapi import FastAPI, File, UploadFile, HTTPException
from pydantic import BaseModel
from typing import List
from prometheus_client import make_asgi_app
from model import ModelPredictor  # Import your HF predictor

app = FastAPI()
app.mount("/metrics", make_asgi_app())
predictor = ModelPredictor()

# Schema for clean JSON responses
class Prediction(BaseModel):
    class_name: str
    confidence: float

class PredictionResponse(BaseModel):
    predictions: List[dict]
    status: str

@app.get("/health")
async def health_check():
    # Professionals check if the model is actually in memory here
    is_ready = predictor.model is not None
    return {"status": "healthy", "model_loaded": is_ready}

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        image_bytes = await file.read()
        results = predictor.predict(image_bytes)
        return {"status": "success", "predictions": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
