#!/bin/bash
###############################################################################
# QUICK START - uruchom aplikację lokalnie (development)
###############################################################################

set -e

echo "=========================================="
echo "  SYSTEM OFERTOWANIA - QUICK START"
echo "=========================================="
echo ""

# Sprawdź czy jesteś w odpowiednim folderze
if [ ! -f "app.py" ]; then
    echo "BŁĄD: Nie znaleziono app.py. Uruchom skrypt z głównego folderu projektu."
    exit 1
fi

# Sprawdź Python
if ! command -v python3 &> /dev/null; then
    echo "BŁĄD: Python 3 nie jest zainstalowany."
    exit 1
fi

# Sprawdź wersję Python
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "✓ Python: $PYTHON_VERSION"

# Sprawdź czy venv istnieje
if [ ! -d "venv" ]; then
    echo "Tworzę virtualenv..."
    python3 -m venv venv
fi

# Aktywuj venv
echo "Aktywuję virtualenv..."
source venv/bin/activate

# Upgrade pip
echo "Aktualizuję pip..."
pip install --upgrade pip -q

# Zainstaluj zależności
if [ -f "requirements.txt" ]; then
    echo "Instaluję zależności..."
    pip install -r requirements.txt -q
else
    echo "UWAGA: Brak requirements.txt"
fi

# Sprawdź .env
if [ ! -f ".env" ]; then
    echo ""
    echo "UWAGA: Brak pliku .env"
    echo "Kopiuję .env.example → .env..."
    cp .env.example .env

    # Generuj SECRET_KEY
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

    # Zamień w .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/your-secret-key-here-change-this-in-production/$SECRET_KEY/" .env
    else
        # Linux
        sed -i "s/your-secret-key-here-change-this-in-production/$SECRET_KEY/" .env
    fi

    echo "✓ Wygenerowano losowy SECRET_KEY"
    echo ""
    echo "EDYTUJ .env PRZED WDROŻENIEM PRODUKCYJNYM!"
    echo ""
fi

# Sprawdź foldery
echo "Sprawdzam strukturę folderów..."
mkdir -p generated_offers
mkdir -p saved_offers
mkdir -p static/preview_cache
mkdir -p logs

# Sprawdź LibreOffice (opcjonalnie)
if command -v soffice &> /dev/null || command -v libreoffice &> /dev/null; then
    echo "✓ LibreOffice zainstalowane"
else
    echo "⚠️  LibreOffice NIE zainstalowane - konwersja może nie działać"
    echo "   Zainstaluj: sudo apt-get install libreoffice"
fi

# Sprawdź unoserver
if pgrep -f "unoserver" > /dev/null; then
    echo "✓ Unoserver działa"
else
    echo "⚠️  Unoserver NIE działa"
    echo "   Uruchom: unoserver --daemon"
    echo "   (opcjonalne - aplikacja użyje LibreOffice jako fallback)"
fi

echo ""
echo "=========================================="
echo "  URUCHAMIAM APLIKACJĘ..."
echo "=========================================="
echo ""
echo "URL: http://localhost:40207"
echo "Naciśnij Ctrl+C aby zatrzymać"
echo ""
echo "=========================================="
echo ""

# Uruchom aplikację
python app.py
