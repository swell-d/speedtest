FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git curl && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 appuser
USER appuser

WORKDIR /app
RUN git clone --depth=1 https://github.com/swell-d/speedtest.git /app && rm -rf /app/.git
RUN pip install --no-cache-dir flask gunicorn
ENV PATH="/home/appuser/.local/bin:$PATH"

RUN python -m compileall -b -f -q /app && find /app -name "*.py" -delete

EXPOSE 8085
CMD ["gunicorn", "--no-control-socket", "--bind", "0.0.0.0:8085", "--workers", "1", "--threads", "8", "--timeout", "300", "app:app"]
