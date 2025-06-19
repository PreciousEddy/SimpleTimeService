FROM python:3.11-slim

# Create non-root user
RUN useradd -m appuser

# Set working dir
WORKDIR /app

# Copy app code
COPY main.py .

# Install dependencies
RUN pip install flask

# Use non-root user
USER appuser

# Expose and run
EXPOSE 5000
CMD ["python", "main.py"]
