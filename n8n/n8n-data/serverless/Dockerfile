# Dockerfile for image popopopony/lab3-n8n-python-serverless

FROM python:3.10-slim

WORKDIR /usr/src/app/n8n-data/serverless

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .


CMD ["python", "main.py"]