# 📄 System Ofertowania v3.0

System do generowania ofert handlowych w formacie DOCX z podglądem real-time w przeglądarce.

## ✨ Funkcje

- 🚀 **Real-time preview** - podgląd oferty w przeglądarce (1:1 jak w Wordzie)
- ⚡ **Streaming** - strony ładują się natychmiastowo (WebSocket)
- 📦 **Multi-template** - wsparcie dla wielu szablonów (AIDROPS, WolfTax)
- 🎯 **Custom fields** - dynamiczne pola w produktach
- 💾 **Cache system** - inteligentne cachowanie (produkty + szablony)
- 🔄 **Parallel processing** - równoległa konwersja produktów (3x szybciej)
- 📊 **Spis treści** - automatyczne generowanie TOC dla WolfTax
- 💡 **SUPER FAST** - konwersja DOCX→JPG przez unoserver + PyMuPDF

## 📊 Wydajność

| Metryka | Wartość |
|---------|---------|
| Time to First Page | **<1s** ⚡⚡⚡ |
| Full generation (4 produkty) | **2-3s** |
| Cache hit | **<0.3s** |
| Transfer reduction | **97%** (JPEG + GZIP) |
| Parallel speedup | **3-4x** |

## 🚀 Szybki start (Ubuntu)

### Automatyczna instalacja
```bash
# 1. Sklonuj projekt
git clone https://github.com/your-repo/ofertowanie.git
cd ofertowanie

# 2. Uruchom instalator
chmod +x install_ubuntu.sh
sudo ./install_ubuntu.sh

# 3. Skopiuj pliki
sudo cp -r * /opt/ofertowanie/

# 4. Uruchom
cd /opt/ofertowanie
source venv/bin/activate
python app.py
```

### Manualna instalacja
Szczegółowe instrukcje: [INSTALACJA_UBUNTU.md](INSTALACJA_UBUNTU.md)

## 📁 Struktura projektu

```
ofertowanie/
├── app.py                  # Backend Flask + WebSocket
├── app4.py                 # DOCX→JPG converter (unoserver)
├── requirements.txt        # Zależności Python
├── .env.example           # Przykładowa konfiguracja
│
├── templates/             # Szablony ofert
│   ├── oferta1.docx      # Szablon AIDROPS
│   ├── oferta1.json      # Konfiguracja
│   ├── templates.json    # Lista szablonów
│   ├── index.html        # Frontend
│   └── wolftax-oferta/   # Szablon WolfTax (multi-file)
│
├── produkty/              # Produkty (.docx)
│   ├── 1.docx
│   ├── 2.docx
│   └── ...
│
├── static/
│   ├── css/style.css     # Styles
│   └── js/app.js         # Frontend logic
│
├── generated_offers/      # Wygenerowane oferty (.docx)
├── saved_offers/          # Zapisane oferty (.json)
│
└── docs/
    ├── INSTALACJA_UBUNTU.md      # Instalacja krok po kroku
    ├── USPRAWNIENIA.md           # Propozycje ulepszeń
    ├── FINAL_REPORT.md           # Raport końcowy
    └── ...
```

## 🔧 Konfiguracja

### 1. Utwórz plik .env
```bash
cp .env.example .env
nano .env
```

### 2. Wygeneruj SECRET_KEY
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### 3. Edytuj .env
```bash
SECRET_KEY=your-generated-secret-key
HOST=0.0.0.0
PORT=40207
DEBUG=False
```

## 🐳 Docker (opcjonalnie)

```bash
# Build
docker build -t ofertowanie:latest .

# Run
docker run -d \
  -p 40207:40207 \
  -v $(pwd)/generated_offers:/app/generated_offers \
  -v $(pwd)/saved_offers:/app/saved_offers \
  --env-file .env \
  --name ofertowanie \
  ofertowanie:latest
```

## 📖 Dokumentacja

- [INSTALACJA_UBUNTU.md](INSTALACJA_UBUNTU.md) - Instalacja krok po kroku na Ubuntu
- [USPRAWNIENIA.md](USPRAWNIENIA.md) - Propozycje ulepszeń
- [FINAL_REPORT.md](FINAL_REPORT.md) - Raport końcowy z wydajnością
- [OPTYMALIZACJE.md](OPTYMALIZACJE.md) - Historia optymalizacji
- [STREAMING_FEATURES.md](STREAMING_FEATURES.md) - Dokumentacja streamingu

## 🛠️ Wymagania

### System
- Ubuntu 22.04/24.04 LTS (lub Debian 11/12)
- Python 3.11+
- LibreOffice 7.x
- 2 GB RAM (zalecane 4 GB)
- 5 GB dysku

### Python packages
Wszystkie w `requirements.txt`:
- Flask 3.0.0
- python-docx 1.1.0
- docxcompose 1.4.0
- Flask-SocketIO 5.3.5
- pymupdf 1.23.8
- unoserver 1.6
- python-dotenv 1.0.0

## 🔐 Bezpieczeństwo

⚠️ **PRZED WDROŻENIEM PRODUKCYJNYM:**

1. **Ustaw SECRET_KEY** w .env (losowy, 64 znaki)
2. **DEBUG=False** w .env
3. **Włącz HTTPS** (nginx + certbot)
4. **Skonfiguruj firewall** (UFW)
5. **Implementuj rate limiting** (Flask-Limiter)
6. **Waliduj nazwy plików** (zapobiegnij path traversal)

Szczegóły: [USPRAWNIENIA.md](USPRAWNIENIA.md)

## 🚦 Status projektu

- ✅ Backend (Flask + WebSocket) - **GOTOWY**
- ✅ Frontend (HTML + JS) - **GOTOWY**
- ✅ DOCX generation - **GOTOWY**
- ✅ Real-time preview - **GOTOWY**
- ✅ Streaming - **GOTOWY**
- ✅ Cache system - **GOTOWY**
- ✅ Multi-template support - **GOTOWY**
- ⚠️ Security hardening - **DO ZROBIENIA**
- ⚠️ Unit tests - **DO ZROBIENIA**

**Ocena:** 8.5/10 ⭐ (9.5/10 po security fixes)

## 📞 Wsparcie

W razie problemów:

1. Sprawdź logi: `sudo journalctl -u ofertowanie -f`
2. Sprawdź status: `sudo systemctl status ofertowanie unoserver`
3. Sprawdź konfigurację: `cat /opt/ofertowanie/.env`
4. Zobacz dokumentację: [INSTALACJA_UBUNTU.md](INSTALACJA_UBUNTU.md)

## 📝 Licencja

Proprietary - All rights reserved

## 👥 Autorzy

- System Ofertowanie v3.0
- Data: 2025-01-09

---

**Enjoy the lightning-fast experience!** ⚡⚡⚡
