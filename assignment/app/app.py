from prometheus_client import start_http_server, Counter, Histogram, Gauge
import time
import random
import os
import psutil

REQUESTS = Counter('demo_app_requests_total', 'Total requests to demo app')
LATENCY = Histogram('demo_app_request_latency_seconds', 'Request latency in seconds')
MEMORY_USAGE = Gauge('demo_app_memory_usage_mb', 'Current memory usage of the app in MB')

def process_request():
    with LATENCY.time():
        time.sleep(random.uniform(0.1, 1.0))  # Simulate variable latency
    REQUESTS.inc()
    # Get current process memory usage in MB
    process = psutil.Process(os.getpid())
    mem_mb = process.memory_info().rss / 1024 / 1024
    MEMORY_USAGE.set(mem_mb)

def main():
    start_http_server(8000)  # Exposes /metrics on port 8000
    while True:
        process_request()
        time.sleep(2)

if __name__ == '__main__':
    main()
