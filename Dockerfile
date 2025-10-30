FROM python:3.10-slim

WORKDIR /app
COPY . /app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 8070
CMD ["python3", "app.py"]
