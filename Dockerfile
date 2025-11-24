# Use lightweight Python base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first for caching
COPY fakerestapi/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire application folder
COPY fakerestapi/ .

# Expose Flask port (Gunicorn will bind here)
EXPOSE 8000

# Run using Gunicorn (production ready HTTP server)
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
