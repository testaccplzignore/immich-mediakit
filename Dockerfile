# syntax = docker/dockerfile:1.5

ARG DEVICE=cuda
FROM python:3.11

WORKDIR /app

ARG MKIT_PORT=8086
ENV PORT=${MKIT_PORT}

# Redeclare DEVICE after FROM
ARG DEVICE
ENV DEVICE=${DEVICE}

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libmagic-dev \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements*.txt ./

# Now DEVICE is available inside RUN
RUN if [ "$DEVICE" = "cuda" ]; then \
        pip install --no-cache-dir -r requirements-cuda.txt ; \
    else \
        pip install --no-cache-dir -r requirements.txt ; \
    fi

COPY . .

EXPOSE ${PORT}
HEALTHCHECK CMD curl -f http://127.0.0.1:${PORT} || exit 1

CMD ["python", "-m", "src.app"]
