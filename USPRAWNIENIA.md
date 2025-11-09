# 🚀 PROPOZYCJE USPRAWNIEŃ - System Ofertowania

## 1. BEZPIECZEŃSTWO (KRYTYCZNE) 🔴

### 1.1 Zabezpieczenie SECRET_KEY
**Problem:** Klucz sesji hardcoded w app.py:49
```python
app.config['SECRET_KEY'] = 'secret_key_for_socketio_12345'
```

**Rozwiązanie:**
```python
import os
from dotenv import load_dotenv
load_dotenv()
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', os.urandom(32).hex())
```

### 1.2 Walidacja nazw plików (Path Traversal)
**Problem:** Brak walidacji w download_offer() - możliwy atak "../../../etc/passwd"

**Rozwiązanie:**
```python
from werkzeug.utils import secure_filename

def sanitize_filename(filename):
    """Bezpieczna walidacja nazwy pliku"""
    safe_name = secure_filename(filename)
    if not safe_name.endswith('.docx'):
        raise ValueError("Nieprawidłowe rozszerzenie")
    return safe_name
```

### 1.3 Rate Limiting
**Problem:** Brak ochrony przed spam/DoS

**Rozwiązanie:**
```python
from flask_limiter import Limiter
limiter = Limiter(app, key_func=lambda: request.remote_addr)

@app.route('/api/generate-offer', methods=['POST'])
@limiter.limit("10/minute")  # max 10 ofert na minutę
def generate_offer():
    ...
```

---

## 2. WYDAJNOŚĆ ⚡

### 2.1 Redis Cache zamiast in-memory
**Problem:** Cache w RAM - gubi się przy restarcie, brak współdzielenia między procesami

**Rozwiązanie:**
```python
import redis
from flask_caching import Cache

cache = Cache(app, config={
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_URL': 'redis://localhost:6379/0',
    'CACHE_DEFAULT_TIMEOUT': 3600
})

@cache.memoize(timeout=3600)
def convert_docx_to_images(docx_path, use_cache=True):
    ...
```

### 2.2 LRU Cache z limitem rozmiaru
**Problem:** Nieograniczony cache może zużyć całą pamięć RAM

**Rozwiązanie:**
```python
from functools import lru_cache

# Zamiast dict:
conversion_cache = {}

# Użyj:
from cachetools import LRUCache
conversion_cache = LRUCache(maxsize=100)  # max 100 produktów
```

### 2.3 Cleanup scheduler dla starych plików
**Problem:** generated_offers/ rośnie w nieskończoność

**Rozwiązanie:**
```python
from apscheduler.schedulers.background import BackgroundScheduler

def cleanup_old_files():
    """Usuwa pliki starsze niż 7 dni"""
    cutoff = datetime.now() - timedelta(days=7)
    for f in os.listdir(GENERATED_OFFERS_DIR):
        path = os.path.join(GENERATED_OFFERS_DIR, f)
        if os.path.getmtime(path) < cutoff.timestamp():
            os.remove(path)

scheduler = BackgroundScheduler()
scheduler.add_job(cleanup_old_files, 'interval', hours=24)
scheduler.start()
```

---

## 3. MONITORING I LOGGING 📊

### 3.1 Structured logging
**Problem:** print() statements - trudne do parsowania

**Rozwiązanie:**
```python
import logging
import json

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# Zamiast:
print(f"[CACHE] Cache hit: {key}")

# Użyj:
logger.info("Cache hit", extra={'key': key, 'cache_type': 'product'})
```

### 3.2 Error tracking (Sentry)
```python
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

sentry_sdk.init(
    dsn=os.getenv('SENTRY_DSN'),
    integrations=[FlaskIntegration()],
    traces_sample_rate=0.1
)
```

---

## 4. ARCHITEKTURA 🏗️

### 4.1 Celery dla async tasks
**Problem:** Długie generowanie blokuje request

**Rozwiązanie:**
```python
from celery import Celery

celery = Celery('tasks', broker='redis://localhost:6379/0')

@celery.task
def generate_offer_async(data, selected_products, template_data):
    """Generuj ofertę w tle"""
    return generate_offer_docx(data, selected_products, template_data)

# W endpoint:
@app.route('/api/generate-offer', methods=['POST'])
def generate_offer():
    task = generate_offer_async.delay(data, selected_products, template_data)
    return jsonify({'task_id': task.id})
```

### 4.2 Separate config file
```python
# config.py
import os

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', os.urandom(32).hex())
    MAX_WORKERS = int(os.getenv('MAX_WORKERS', 3))
    CACHE_TIMEOUT = int(os.getenv('CACHE_TIMEOUT', 3600))
    DPI = int(os.getenv('DPI', 200))
    JPEG_QUALITY = int(os.getenv('JPEG_QUALITY', 90))

class ProductionConfig(Config):
    DEBUG = False
    TESTING = False

class DevelopmentConfig(Config):
    DEBUG = True
    TESTING = True
```

---

## 5. NOWE FUNKCJONALNOŚCI 🎯

### 5.1 Webhook po wygenerowaniu oferty
```python
import requests

@app.route('/api/generate-offer', methods=['POST'])
def generate_offer():
    # ... generuj ofertę

    # Webhook
    webhook_url = data.get('webhook_url')
    if webhook_url:
        requests.post(webhook_url, json={
            'status': 'success',
            'filename': output_filename,
            'download_url': f"https://yourdomain.com/api/download-offer/{output_filename}"
        })
```

### 5.2 Email z ofertą
```python
from flask_mail import Mail, Message

mail = Mail(app)

def send_offer_email(recipient, filename):
    msg = Message(
        'Twoja oferta jest gotowa',
        recipients=[recipient],
        body='Oferta została wygenerowana.'
    )
    with app.open_resource(f"generated_offers/{filename}") as fp:
        msg.attach(filename, "application/vnd.openxmlformats-officedocument.wordprocessingml.document", fp.read())
    mail.send(msg)
```

### 5.3 Wersjonowanie szablonów
```python
# templates/
#   oferta1/
#     v1.0/oferta.docx
#     v1.1/oferta.docx
#     v2.0/oferta.docx

def load_template_config(template_name='oferta1', version='latest'):
    if version == 'latest':
        # Znajdź najnowszą wersję
        versions = os.listdir(os.path.join(TEMPLATES_DIR, template_name))
        version = max(versions)

    config_path = os.path.join(TEMPLATES_DIR, template_name, version, 'config.json')
    ...
```

---

## 6. DOCKER & DevOps 🐳

### 6.1 Multi-stage Dockerfile
```dockerfile
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.11-slim
RUN apt-get update && apt-get install -y \
    libreoffice \
    libreoffice-writer \
    fonts-dejavu \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/.local /root/.local
COPY . /app
WORKDIR /app

ENV PATH=/root/.local/bin:$PATH
EXPOSE 40207
CMD ["python", "app.py"]
```

### 6.2 Docker Compose
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "40207:40207"
    environment:
      - SECRET_KEY=${SECRET_KEY}
      - REDIS_URL=redis://redis:6379/0
    volumes:
      - ./generated_offers:/app/generated_offers
      - ./saved_offers:/app/saved_offers
    depends_on:
      - redis
      - unoserver

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  unoserver:
    image: libreofficedocker/libreoffice-unoserver
    ports:
      - "2003:2003"
```

---

## 7. TESTY 🧪

### 7.1 Unit tests
```python
# tests/test_app.py
import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_get_templates(client):
    rv = client.get('/api/templates')
    assert rv.status_code == 200
    data = rv.get_json()
    assert 'templates' in data

def test_generate_offer(client):
    rv = client.post('/api/generate-offer', json={
        'formData': {'KLIENT(NIP)': '1234567890'},
        'selectedProducts': ['1', '2'],
        'templateData': {}
    })
    assert rv.status_code == 200
```

---

## 8. PRIORYTETYZACJA

### ⚡ NATYCHMIASTOWE (Przed wdrożeniem produkcyjnym):
1. Zabezpieczenie SECRET_KEY (.env)
2. Walidacja nazw plików (path traversal)
3. Rate limiting
4. HTTPS (nginx + certbot)

### 🔥 WAŻNE (W ciągu tygodnia):
5. Redis cache
6. Cleanup scheduler
7. Structured logging
8. Error tracking (Sentry)

### 💡 PRZYDATNE (Długoterminowo):
9. Celery async tasks
10. Docker containerization
11. Email notifications
12. Unit tests

---

## SZACUNKOWY CZAS IMPLEMENTACJI

| Usprawnienie | Czas | Priorytet |
|--------------|------|-----------|
| SECRET_KEY + .env | 30 min | 🔴 CRITICAL |
| Path traversal fix | 1h | 🔴 CRITICAL |
| Rate limiting | 1h | 🔴 CRITICAL |
| Redis cache | 3h | 🟠 HIGH |
| Cleanup scheduler | 2h | 🟠 HIGH |
| Logging | 2h | 🟠 HIGH |
| Sentry | 1h | 🟡 MEDIUM |
| Celery | 1 dzień | 🟡 MEDIUM |
| Docker | 4h | 🟡 MEDIUM |
| Testy | 2 dni | 🟢 LOW |

**RAZEM (CRITICAL + HIGH): ~10 godzin**
