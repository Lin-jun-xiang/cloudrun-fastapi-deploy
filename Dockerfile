FROM python:3.9-slim

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install pipreqs

ENV PYTHONPATH=/recommender

WORKDIR /recommender

COPY main.py .
COPY routers ./routers
COPY config.env .

ENV FASTAPI=main.py

# Load environment variables from config.env
ENV $(grep -v '^#' config.env | xargs)
ENV PROJECT_ID=${PROJECT_ID}

EXPOSE ${PORT}

CMD ["python", "main.py"]
