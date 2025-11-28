FROM python:3.10-slim
WORKDIR /app
COPY app.py .
RUN pip install prometheus_client psutil
CMD ["python", "app.py"]
