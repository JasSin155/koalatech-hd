FROM python:3.12-slim

# Apply Debian security updates published after the python:3.12-slim base
# image was last rebuilt. Added in Task 10.3HD after the Docker Scout gate
# blocked every backend image on CVE-2026-84782 (openssl 3.5.7-1~deb13u2,
# fixed in 3.5.7-1~deb13u3). Fixes the root cause instead of loosening the gate.
RUN apt-get update \
    && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    --root-user-action=ignore \
    -r requirements.txt

COPY . .

RUN useradd -m appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]