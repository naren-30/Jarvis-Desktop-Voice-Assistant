FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY requirements.txt ./

RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && useradd -m jarvis

COPY . .

USER jarvis

# Change to your actual main python file if different
CMD ["python", "main.py"]
