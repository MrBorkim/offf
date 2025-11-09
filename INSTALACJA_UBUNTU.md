# 📦 INSTALACJA NA UBUNTU - KROK PO KROKU

## Wymagania systemowe

- **System:** Ubuntu 22.04 LTS lub 24.04 LTS (świeży)
- **RAM:** Minimum 2 GB (zalecane 4 GB)
- **Dysk:** 5 GB wolnego miejsca
- **CPU:** 2 rdzenie (zalecane 4)
- **Dostęp:** root lub sudo

---

## METODA 1: Automatyczna instalacja (ZALECANA) 🚀

### Krok 1: Pobierz projekt
```bash
# Zaloguj się na serwer Ubuntu przez SSH
ssh user@your-server-ip

# Sklonuj repozytorium (lub prześlij pliki przez SCP/SFTP)
git clone https://github.com/your-repo/ofertowanie.git
cd ofertowanie

# LUB prześlij przez SCP z lokalnego komputera:
# scp -r /Users/maksymiliansiwecki/Documents/GitHub/offf user@your-server-ip:/home/user/
```

### Krok 2: Uruchom skrypt instalacyjny
```bash
# Nadaj uprawnienia wykonywania
chmod +x install_ubuntu.sh

# Uruchom instalator (wymaga sudo)
sudo ./install_ubuntu.sh
```

Skrypt automatycznie:
- ✅ Zaktualizuje system
- ✅ Zainstaluje Python 3.11+
- ✅ Zainstaluje LibreOffice + fonty
- ✅ Zainstaluje wszystkie zależności
- ✅ Utworzy virtualenv
- ✅ Zainstaluje biblioteki Python
- ✅ Skonfiguruje unoserver
- ✅ Utworzy plik .env z losowym SECRET_KEY

### Krok 3: Skopiuj pliki aplikacji
```bash
# Skopiuj wszystkie pliki do /opt/ofertowanie
sudo cp -r * /opt/ofertowanie/
sudo chown -R $USER:$USER /opt/ofertowanie
```

### Krok 4: Uruchom aplikację
```bash
cd /opt/ofertowanie
source venv/bin/activate
python app.py
```

### Krok 5: Testuj
Otwórz przeglądarkę: `http://your-server-ip:40207`

---

## METODA 2: Instalacja ręczna (krok po kroku) 📝

### KROK 1: Aktualizacja systemu
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

**Czas:** ~5 min
**Wynik:** System zaktualizowany

---

### KROK 2: Instalacja Python 3.11+
```bash
# Dodaj repozytorium deadsnakes (jeśli Python < 3.11)
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update

# Zainstaluj Python 3.11
sudo apt-get install -y python3.11 python3.11-venv python3.11-dev python3-pip

# Sprawdź wersję
python3.11 --version
```

**Oczekiwany wynik:**
```
Python 3.11.x
```

---

### KROK 3: Instalacja LibreOffice
```bash
sudo apt-get install -y \
    libreoffice \
    libreoffice-writer \
    libreoffice-calc \
    ttf-mscorefonts-installer \
    fonts-dejavu \
    fonts-dejavu-extra \
    fonts-liberation \
    fonts-liberation2
```

**Czas:** ~10 min
**Wynik:** LibreOffice zainstalowany

**Weryfikacja:**
```bash
libreoffice --version
# Powinno pokazać: LibreOffice 7.x.x
```

---

### KROK 4: Instalacja zależności systemowych
```bash
sudo apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    poppler-utils \
    git \
    curl \
    wget
```

**Czas:** ~5 min

---

### KROK 5: Utworzenie struktury folderów
```bash
# Utwórz folder aplikacji
sudo mkdir -p /opt/ofertowanie
sudo chown -R $USER:$USER /opt/ofertowanie

# Przejdź do folderu
cd /opt/ofertowanie

# Utwórz podfoldery
mkdir -p logs
mkdir -p generated_offers
mkdir -p saved_offers
mkdir -p static/preview_cache
mkdir -p templates
mkdir -p produkty
```

---

### KROK 6: Utworzenie virtualenv
```bash
cd /opt/ofertowanie

# Utwórz środowisko wirtualne
python3.11 -m venv venv

# Aktywuj
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel
```

**Weryfikacja:**
```bash
which python
# Powinno pokazać: /opt/ofertowanie/venv/bin/python

python --version
# Powinno pokazać: Python 3.11.x
```

---

### KROK 7: Instalacja bibliotek Python
```bash
# Upewnij się, że venv jest aktywowany
source /opt/ofertowanie/venv/bin/activate

# Zainstaluj z requirements.txt
pip install -r requirements.txt

# LUB ręcznie:
pip install Flask==3.0.0
pip install python-docx==1.1.0
pip install docxcompose==1.4.0
pip install Werkzeug==3.0.1
pip install Pillow==10.1.0
pip install pdf2image==1.16.3
pip install Flask-SocketIO==5.3.5
pip install python-socketio==5.10.0
pip install Flask-Compress==1.14
pip install pymupdf==1.23.8
pip install unoserver==1.6
pip install python-dotenv==1.0.0
```

**Czas:** ~3 min

**Weryfikacja:**
```bash
pip list | grep Flask
# Flask                     3.0.0
# Flask-Compress            1.14
# Flask-SocketIO            5.3.5
```

---

### KROK 8: Konfiguracja unoserver
```bash
# Utwórz systemd service
sudo nano /etc/systemd/system/unoserver.service
```

Wklej:
```ini
[Unit]
Description=Unoserver - LibreOffice server for document conversion
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/opt/ofertowanie
ExecStart=/opt/ofertowanie/venv/bin/unoserver --interface 127.0.0.1 --port 2003
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**WAŻNE:** Zamień `YOUR_USERNAME` na swojego użytkownika (np. `ubuntu`)

```bash
# Przeładuj systemd
sudo systemctl daemon-reload

# Włącz autostart
sudo systemctl enable unoserver

# Uruchom
sudo systemctl start unoserver

# Sprawdź status
sudo systemctl status unoserver
```

**Oczekiwany wynik:**
```
● unoserver.service - Unoserver
   Active: active (running)
```

---

### KROK 9: Skopiuj pliki aplikacji
```bash
# Z lokalnego komputera (z folderu projektu):
scp -r * user@your-server-ip:/opt/ofertowanie/

# LUB przez git:
cd /opt/ofertowanie
git clone https://github.com/your-repo/ofertowanie.git .
```

**Upewnij się, że masz:**
```
/opt/ofertowanie/
├── app.py
├── app4.py
├── requirements.txt
├── templates/
│   ├── index.html
│   ├── oferta1.docx
│   ├── oferta1.json
│   └── templates.json
├── produkty/
│   ├── 1.docx
│   ├── 2.docx
│   └── ...
└── static/
    ├── css/
    │   └── style.css
    └── js/
        └── app.js
```

---

### KROK 10: Utworzenie pliku .env
```bash
cd /opt/ofertowanie
nano .env
```

Wklej:
```bash
# === KONFIGURACJA SYSTEMU OFERTOWANIA ===

# Flask
SECRET_KEY=WYGENERUJ_LOSOWY_64_ZNAKOWY_STRING
FLASK_ENV=production
DEBUG=False

# Serwer
HOST=0.0.0.0
PORT=40207

# Wydajność
MAX_WORKERS=3
CACHE_TIMEOUT=3600

# Konwersja
DPI=200
JPEG_QUALITY=90

# Unoserver
UNOSERVER_HOST=127.0.0.1
UNOSERVER_PORT=2003
```

**Generowanie SECRET_KEY:**
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

Skopiuj wynik i wklej jako `SECRET_KEY` w .env

---

### KROK 11: Test uruchomienia
```bash
cd /opt/ofertowanie
source venv/bin/activate
python app.py
```

**Oczekiwany wynik:**
```
[STARTUP] 🚀 Inicjalizacja systemu...
[STARTUP] Pre-generowanie produktów...
[STARTUP] Znaleziono 8 produktów
[STARTUP] ✓ 1.docx gotowy
...
[STARTUP] ✅ System gotowy do pracy!
 * Running on http://0.0.0.0:40207
```

**Testuj w przeglądarce:**
```
http://your-server-ip:40207
```

---

## KROK 12: Systemd service dla automatycznego uruchamiania

### Utwórz service
```bash
sudo nano /etc/systemd/system/ofertowanie.service
```

Wklej:
```ini
[Unit]
Description=System Ofertowania Flask App
After=network.target unoserver.service
Requires=unoserver.service

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/opt/ofertowanie
Environment="PATH=/opt/ofertowanie/venv/bin"
ExecStart=/opt/ofertowanie/venv/bin/python app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**WAŻNE:** Zamień `YOUR_USERNAME`

### Włącz i uruchom
```bash
sudo systemctl daemon-reload
sudo systemctl enable ofertowanie
sudo systemctl start ofertowanie
sudo systemctl status ofertowanie
```

### Komendy zarządzania
```bash
# Sprawdź status
sudo systemctl status ofertowanie

# Restart
sudo systemctl restart ofertowanie

# Stop
sudo systemctl stop ofertowanie

# Logi
sudo journalctl -u ofertowanie -f
```

---

## KROK 13: Firewall (opcjonalnie)
```bash
# Jeśli używasz UFW
sudo ufw allow 40207/tcp
sudo ufw status
```

---

## KROK 14: Nginx jako reverse proxy (PRODUKCJA)

### Instalacja Nginx
```bash
sudo apt-get install -y nginx
```

### Konfiguracja
```bash
sudo nano /etc/nginx/sites-available/ofertowanie
```

Wklej:
```nginx
server {
    listen 80;
    server_name your-domain.com;  # Zamień na swoją domenę

    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:40207;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }

    # WebSocket
    location /socket.io {
        proxy_pass http://127.0.0.1:40207/socket.io;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

### Aktywuj konfigurację
```bash
sudo ln -s /etc/nginx/sites-available/ofertowanie /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### SSL/HTTPS z Certbot
```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## KROK 15: Monitoring i logi

### Logi aplikacji
```bash
# Real-time
sudo journalctl -u ofertowanie -f

# Ostatnie 100 linii
sudo journalctl -u ofertowanie -n 100

# Tylko błędy
sudo journalctl -u ofertowanie -p err
```

### Logi Nginx
```bash
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

---

## ROZWIĄZYWANIE PROBLEMÓW 🔧

### Problem: unoserver nie startuje
```bash
# Sprawdź czy LibreOffice jest zainstalowany
libreoffice --version

# Sprawdź logi
sudo journalctl -u unoserver -n 50

# Restart ręcznie
/opt/ofertowanie/venv/bin/unoserver --interface 127.0.0.1 --port 2003
```

### Problem: Brak fontów w PDF
```bash
sudo apt-get install -y \
    fonts-dejavu \
    fonts-liberation \
    ttf-mscorefonts-installer

# Refresh font cache
fc-cache -f -v
```

### Problem: Port 40207 zajęty
```bash
# Sprawdź co zajmuje port
sudo lsof -i :40207

# Zmień port w .env
nano /opt/ofertowanie/.env
# PORT=40208
```

### Problem: Brak uprawnień do zapisu
```bash
sudo chown -R $USER:$USER /opt/ofertowanie
chmod -R 755 /opt/ofertowanie
```

---

## BACKUP I RESTORE 💾

### Backup
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"

mkdir -p $BACKUP_DIR

# Backup danych
tar -czf $BACKUP_DIR/ofertowanie_data_$DATE.tar.gz \
    /opt/ofertowanie/generated_offers \
    /opt/ofertowanie/saved_offers \
    /opt/ofertowanie/produkty \
    /opt/ofertowanie/templates \
    /opt/ofertowanie/.env

echo "Backup utworzony: $BACKUP_DIR/ofertowanie_data_$DATE.tar.gz"
```

### Restore
```bash
tar -xzf /backup/ofertowanie_data_YYYYMMDD_HHMMSS.tar.gz -C /
sudo systemctl restart ofertowanie
```

---

## AKTUALIZACJA APLIKACJI 🔄

```bash
# 1. Zatrzymaj aplikację
sudo systemctl stop ofertowanie

# 2. Backup
./backup.sh

# 3. Aktualizuj kod
cd /opt/ofertowanie
git pull origin main

# 4. Aktualizuj zależności
source venv/bin/activate
pip install -r requirements.txt --upgrade

# 5. Restart
sudo systemctl start ofertowanie
```

---

## CHECKLIST PRODUKCYJNY ✅

Przed uruchomieniem na produkcji sprawdź:

- [ ] SECRET_KEY jest ustawiony i losowy
- [ ] DEBUG=False w .env
- [ ] Firewall skonfigurowany (UFW/iptables)
- [ ] Nginx reverse proxy działa
- [ ] SSL/HTTPS włączone (certbot)
- [ ] Backup skonfigurowany (cron)
- [ ] Monitoring włączony (opcjonalnie: Sentry)
- [ ] Logi rotowane (logrotate)
- [ ] Unoserver działa jako service
- [ ] Aplikacja działa jako service
- [ ] Rate limiting włączony
- [ ] Path validation zaimplementowany

---

## WSPARCIE 📞

W razie problemów:
1. Sprawdź logi: `sudo journalctl -u ofertowanie -f`
2. Sprawdź status: `sudo systemctl status ofertowanie unoserver`
3. Sprawdź konfigurację: `cat /opt/ofertowanie/.env`
4. Sprawdź dysk: `df -h`
5. Sprawdź RAM: `free -h`

---

**Powodzenia! 🚀**
