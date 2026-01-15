
FROM python:3.13-alpine AS base


RUN apk add --no-cache --virtual .build-deps gcc musl-dev && \
    adduser -D appuser && \
    mkdir -p /app /app/cache && \
    chown -R appuser:appuser /app

WORKDIR /app
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH="/home/appuser/.local/bin:$PATH"


FROM base AS builder
USER appuser
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt


FROM base AS final
WORKDIR /app


COPY --from=builder /home/appuser/.local /home/appuser/.local
COPY --chown=appuser:appuser . .   


ENV ENVIRONMENT=production \
    FLASK_APP=app.py \
    FLASK_DEBUG=0  

USER appuser

EXPOSE 5000

CMD ["flask", "run", "--host", "0.0.0.0", "--port", "5000"]