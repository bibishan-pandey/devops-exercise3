# Base image with Python 3.10.8
FROM python:3.10.8-slim AS base

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file to install dependencies
COPY ./requirements.txt /app/requirements.txt

# Install the Python dependencies
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the FastAPI app code
COPY . /app

# Expose the port that FastAPI will run on (default is 8000)
EXPOSE 8000

# Command to run FastAPI
CMD ["fastapi", "run"]
