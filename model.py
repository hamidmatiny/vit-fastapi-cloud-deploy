import torch
from PIL import Image
import io
from transformers import ViTImageProcessor, ViTForImageClassification
import os

cache_dir = "./model_cache"
os.makedirs(cache_dir, exist_ok=True)

class ModelPredictor:
    def __init__(self):
        
        self.model_name = 'aaraki/vit-base-patch16-224-in21k-finetuned-cifar10'
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        cache_dir = "./model_cache"
        os.makedirs(cache_dir, exist_ok=True)
        
        print(f"Loading REAL CIFAR-10 model: {self.model_name}...")
        self.processor = ViTImageProcessor.from_pretrained(self.model_name, cache_dir=cache_dir)
        self.model = ViTForImageClassification.from_pretrained(self.model_name, cache_dir=cache_dir)
        
        self.model.to(self.device)
        self.model.eval()

    def predict(self, image_bytes):
        # 1. Load Image
        image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        
        # 2. Preprocess (Handles resizing to 224x224 and normalization)
        inputs = self.processor(images=image, return_tensors="pt").to(self.device)
        
        # 3. Inference
        with torch.no_grad():
            outputs = self.model(**inputs)
            logits = outputs.logits
            
            # 4. Convert Logits to Probabilities
            probs = torch.nn.functional.softmax(logits[0], dim=0)
            
            # 5. Get Top 3
            top_probs, top_indices = torch.topk(probs, 3)
            
            predictions = []
            for i in range(3):
                idx = top_indices[i].item()
                # self.model.config.id2label automatically gives the correct class name
                predictions.append({
                    "class": self.model.config.id2label[idx],
                    "confidence": float(top_probs[i])
                })
                
            return predictions
