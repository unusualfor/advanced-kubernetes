FROM python:3.10-slim
WORKDIR /app
COPY hello_operator.py .
RUN pip install kopf kubernetes
CMD ["kopf", "run", "hello_operator.py"]
