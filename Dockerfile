FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
RUN git clone --depth=1 https://github.com/swell-d/speedtest.git .
RUN pip install --no-cache-dir -r requirements.txt

RUN useradd -m appuser
USER appuser

EXPOSE 8085
CMD ["gunicorn", "--bind", "0.0.0.0:8085", "--workers", "1", "--threads", "8", "--timeout", "300", "app:app"]
