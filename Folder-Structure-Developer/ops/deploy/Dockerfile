# FastAPI Backend — Dockerfile
# MWP Developer Template
#
# Usage:
#   docker build -f ops/deploy/Dockerfile -t api .
#   docker run -p 8000:8000 --env-file .env api
#
# Expects source code in src/ with entry point at src/main.py (FastAPI app)

FROM python:3.11-slim

# Prevent Python from buffering stdout/stderr
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Install system dependencies (add extras here as needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies separately for layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/

# Expose API port
EXPOSE 8000

# Run the FastAPI app via uvicorn
# Override CMD in docker-compose for dev hot-reload (--reload flag)
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
