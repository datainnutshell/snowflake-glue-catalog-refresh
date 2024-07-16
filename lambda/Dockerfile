# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set working directory inside the container
WORKDIR /app

# Install zip utility (if not already installed)
RUN apt-get update && apt-get install -y zip

# Install any necessary dependencies
# Copy your Python script and any other necessary files into the container
COPY main.py /app/
COPY requirements.txt /app/

# Install Python dependencies from requirements.txt
RUN pip install -r requirements.txt -t .

# Zip all necessary files including dependencies
RUN zip -r lambda_function.zip *

# Keep the container running with bash
CMD ["/bin/bash"]