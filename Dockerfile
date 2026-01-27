FROM python:3.12-slim

WORKDIR /app

# Install system dependencies for image processing
RUN apt-get update && apt-get install -y libgl1 libglx-mesa0 libglib2.0-0 && rm -rf /var/lib/apt/lists/*


COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Use PORT environment variable for Cloud Run (default to 8080)
ENV PORT=8080

# Expose the port FastAPI runs on
EXPOSE 8080

# Use gunicorn with uvicorn workers for production
CMD exec gunicorn -w 1 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:${PORT} main:app