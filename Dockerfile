FROM python:3.10-slim AS base
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    ffmpeg \
    alsa-utils \
    git \
    unzip \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt package.json package-lock.json yarn.lock* ./

RUN if [ -f "requirements.txt" ]; then \
      python -m pip install --upgrade pip setuptools wheel && \
      pip install -r requirements.txt ; \
    fi

RUN if [ -f "package.json" ]; then \
      curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
      apt-get update && apt-get install -y --no-install-recommends nodejs && \
      if [ -f "yarn.lock" ]; then npm install -g yarn; yarn install; else npm ci; fi ; \
    fi

COPY . .

EXPOSE 8000

CMD ["sh", "-c", "\
    if [ -f package.json ] && jq -e '.scripts.start' package.json >/dev/null 2>&1; then \
      npm start ; \
    elif [ -f app.py ]; then \
      python app.py ; \
    elif [ -f main.py ]; then \
      python main.py ; \
    else \
      echo 'No start command detected — dropping to bash'; exec /bin/bash ; \
    fi \
"]
