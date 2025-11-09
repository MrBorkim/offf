#!/bin/bash
###############################################################################
# INSTALATOR SYSTEMU OFERTOWANIA - UBUNTU 22.04/24.04
# Autor: System Ofertowania v3.0
# Data: 2025-01-09
###############################################################################

set -e  # Exit on error

echo "=============================================================================="
echo "  INSTALATOR SYSTEMU OFERTOWANIA - UBUNTU"
echo "=============================================================================="
echo ""

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_step() {
    echo -e "${GREEN}[KROK $1/$2]${NC} $3"
}

function print_error() {
    echo -e "${RED}[BŁĄD]${NC} $1"
}

function print_warning() {
    echo -e "${YELLOW}[UWAGA]${NC} $1"
}

###############################################################################
# KROK 1: Aktualizacja systemu
###############################################################################
print_step 1 10 "Aktualizacja systemu Ubuntu..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq

###############################################################################
# KROK 2: Instalacja Python 3.11+
###############################################################################
print_step 2 10 "Instalacja Python 3.11..."

# Sprawdź wersję Pythona
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
REQUIRED_VERSION="3.11"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
    echo "✓ Python $PYTHON_VERSION już zainstalowany"
else
    print_warning "Python $PYTHON_VERSION jest za stary. Instaluję Python 3.11..."
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt-get update -qq
    sudo apt-get install -y python3.11 python3.11-venv python3.11-dev

    # Ustaw Python 3.11 jako domyślny
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
fi

# Instalacja pip
sudo apt-get install -y python3-pip

###############################################################################
# KROK 3: Instalacja LibreOffice
###############################################################################
print_step 3 10 "Instalacja LibreOffice..."
sudo apt-get install -y \
    libreoffice \
    libreoffice-writer \
    libreoffice-calc \
    ttf-mscorefonts-installer \
    fonts-dejavu \
    fonts-dejavu-extra \
    fonts-liberation \
    fonts-liberation2

# Akceptuj licencję Microsoft fonts
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

###############################################################################
# KROK 4: Instalacja zależności systemowych
###############################################################################
print_step 4 10 "Instalacja zależności systemowych..."
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

###############################################################################
# KROK 5: Tworzenie użytkownika aplikacji (opcjonalne)
###############################################################################
print_step 5 10 "Konfiguracja użytkownika aplikacji..."

if id "ofertowanie" &>/dev/null; then
    echo "✓ Użytkownik 'ofertowanie' już istnieje"
else
    print_warning "Czy utworzyć dedykowanego użytkownika 'ofertowanie'? (y/n)"
    read -r CREATE_USER
    if [ "$CREATE_USER" = "y" ]; then
        sudo useradd -m -s /bin/bash ofertowanie
        sudo usermod -aG sudo ofertowanie
        echo "✓ Utworzono użytkownika 'ofertowanie'"
    fi
fi

###############################################################################
# KROK 6: Tworzenie struktury folderów
###############################################################################
print_step 6 10 "Tworzenie struktury folderów..."

APP_DIR="/opt/ofertowanie"
echo "Folder aplikacji: $APP_DIR"

# Jeśli chcesz zainstalować w innym miejscu, zmień tutaj:
# read -p "Podaj ścieżkę instalacji (domyślnie /opt/ofertowanie): " CUSTOM_DIR
# APP_DIR=${CUSTOM_DIR:-/opt/ofertowanie}

sudo mkdir -p $APP_DIR
sudo mkdir -p $APP_DIR/logs
sudo mkdir -p $APP_DIR/generated_offers
sudo mkdir -p $APP_DIR/saved_offers
sudo mkdir -p $APP_DIR/static/preview_cache

# Ustaw uprawnienia
if id "ofertowanie" &>/dev/null; then
    sudo chown -R ofertowanie:ofertowanie $APP_DIR
else
    sudo chown -R $USER:$USER $APP_DIR
fi

###############################################################################
# KROK 7: Utworzenie virtualenv
###############################################################################
print_step 7 10 "Tworzenie środowiska wirtualnego Python..."

cd $APP_DIR
python3 -m venv venv

# Aktywuj venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

###############################################################################
# KROK 8: Instalacja zależności Python
###############################################################################
print_step 8 10 "Instalacja bibliotek Python..."

# Jeśli requirements.txt istnieje w bieżącym katalogu, użyj go
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    # Zainstaluj podstawowe zależności
    pip install \
        Flask==3.0.0 \
        python-docx==1.1.0 \
        docxcompose==1.4.0 \
        Werkzeug==3.0.1 \
        Pillow==10.1.0 \
        pdf2image==1.16.3 \
        Flask-SocketIO==5.3.5 \
        python-socketio==5.10.0 \
        Flask-Compress==1.14 \
        pymupdf==1.23.8 \
        unoserver==1.6 \
        python-dotenv==1.0.0
fi

###############################################################################
# KROK 9: Instalacja i konfiguracja unoserver
###############################################################################
print_step 9 10 "Konfiguracja unoserver..."

# Unoserver już zainstalowany z pip
# Utwórz systemd service
sudo tee /etc/systemd/system/unoserver.service > /dev/null <<EOF
[Unit]
Description=Unoserver - LibreOffice server for document conversion
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/venv/bin/unoserver --interface 127.0.0.1 --port 2003
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Włącz i uruchom unoserver
sudo systemctl daemon-reload
sudo systemctl enable unoserver
sudo systemctl start unoserver

echo "✓ Unoserver uruchomiony jako systemd service"

###############################################################################
# KROK 10: Utworzenie .env (konfiguracja)
###############################################################################
print_step 10 10 "Tworzenie pliku .env..."

if [ ! -f "$APP_DIR/.env" ]; then
    # Generuj losowy SECRET_KEY
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

    cat > $APP_DIR/.env <<EOF
# === KONFIGURACJA SYSTEMU OFERTOWANIA ===

# Flask
SECRET_KEY=$SECRET_KEY
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

# Bezpieczeństwo
ALLOWED_HOSTS=localhost,127.0.0.1

# Opcjonalne: Redis (jeśli zainstalowany)
# REDIS_URL=redis://localhost:6379/0

# Opcjonalne: Sentry (monitoring błędów)
# SENTRY_DSN=https://your-sentry-dsn
EOF

    echo "✓ Utworzono plik .env z losowym SECRET_KEY"
else
    echo "✓ Plik .env już istnieje"
fi

###############################################################################
# FINALIZACJA
###############################################################################
echo ""
echo "=============================================================================="
echo -e "${GREEN}  ✓ INSTALACJA ZAKOŃCZONA POMYŚLNIE!${NC}"
echo "=============================================================================="
echo ""
echo "📁 Lokalizacja aplikacji: $APP_DIR"
echo "🐍 Python venv: $APP_DIR/venv"
echo "🔧 Konfiguracja: $APP_DIR/.env"
echo ""
echo "NASTĘPNE KROKI:"
echo ""
echo "1. Skopiuj pliki aplikacji do $APP_DIR:"
echo "   cd /path/to/your/project"
echo "   sudo cp -r * $APP_DIR/"
echo ""
echo "2. Aktywuj środowisko wirtualne:"
echo "   cd $APP_DIR"
echo "   source venv/bin/activate"
echo ""
echo "3. Uruchom aplikację:"
echo "   python app.py"
echo ""
echo "4. Otwórz w przeglądarce:"
echo "   http://your-server-ip:40207"
echo ""
echo "5. (Opcjonalnie) Skonfiguruj systemd service - patrz: DEPLOY.md"
echo ""
echo "=============================================================================="
echo ""

# Dezaktywuj venv
deactivate

exit 0
