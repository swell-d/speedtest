FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git curl && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN useradd -m -u 1000 appuser
USER appuser

WORKDIR /app
RUN git clone --depth=1 https://github.com/swell-d/speedtest.git /app
RUN python -m venv venv && . /app/venv/bin/activate && pip install --no-cache-dir -r requirements.txt
ENV PATH="/app/venv/bin:${PATH}"

RUN python -m compileall -b -f -q /app
RUN find /app -name "*.py" -delete

EXPOSE 8085
CMD ["gunicorn", "--bind", "0.0.0.0:8085", "--workers", "1", "--threads", "8", "--timeout", "300", "app:app"]
