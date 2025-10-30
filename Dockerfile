FROM python:3.10-slim

WORKDIR /app
COPY . /app

RUN pip install --upgrade pip && pip install -r requirements.txt

# Keep the app running
CMD ["python3", "-u", "main.py"]
