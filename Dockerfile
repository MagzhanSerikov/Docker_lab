FROM python:3.11-alpine

RUN apk update && apk add --no-cache \
    gcc \
    musl-dev \
    linux-headers \
    postgresql-dev \
    build-base

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "pollme.wsgi:application"]
COPY . .

RUN python manage.py collectstatic --noinput

RUN pip cache purge

RUN chown -R appuser:appgroup /app

USER appuser

ENV PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=pollme.settings \
    DATABASE_URL=postgres://user:password@db:5432/dbname

EXPOSE 8000
CMD ["sh", "-c", "python manage.py migrate && gunicorn pollme.wsgi:application --bind 0.0.0.0:8000"]

