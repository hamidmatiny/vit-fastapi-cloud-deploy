import requests
import json
from PIL import Image
import io

def test_api():
    base_url = "http://localhost:8000"
    
    # Test health endpoint
    response = requests.get(f"{base_url}/health")
    print("Health check:", response.json())
    
    # Test model info
    response = requests.get(f"{base_url}/model/info")
    print("Model info:", response.json())
    
    # Create a test image
    test_image = Image.new('RGB', (224, 224), color='red')
    img_bytes = io.BytesIO()
    test_image.save(img_bytes, format='JPEG')
    img_bytes.seek(0)
    
    # Test prediction
    files = {'file': ('test.jpg', img_bytes, 'image/jpeg')}
    response = requests.post(f"{base_url}/predict", files=files)
    
    if response.status_code == 200:
        result = response.json()
        print("Prediction result:")
        for pred in result['predictions']:
            print(f"  {pred['class']}: {pred['confidence']:.4f}")
    else:
        print("Error:", response.text)

if __name__ == "__main__":
    test_api()