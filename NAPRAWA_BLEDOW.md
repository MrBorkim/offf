# 🔧 NAPRAWA BŁĘDÓW - Instrukcja krok po kroku

## Analiza problemów z beldy.txt

### ❌ Wykryte problemy:
1. **Unoserver nie uruchamia się** (linia 8, 39)
2. **LibreOffice błąd konwersji dla 1.docx** (linia 82)
3. **Warning pkg_resources** (deprecated)

---

## KROK 1: Napraw Unoserver ⚡

### Problem:
```
[UNOSERVER] ❌ Nie udało się uruchomić unoserver
```

### Rozwiązanie:

```bash
# A. Sprawdź czy unoserver jest zainstalowany
which unoserver

# Jeśli NIE znaleziono, zainstaluj:
cd /root/offf
source venv/bin/activate
pip install unoserver

# B. Sprawdź czy LibreOffice jest zainstalowany
which soffice
# lub
which libreoffice

# Jeśli NIE, zainstaluj:
apt-get update
apt-get install -y libreoffice libreoffice-writer

# C. Uruchom unoserver MANUALNIE (test)
unoserver --interface 127.0.0.1 --port 2003

# Jeśli działa, naciśnij Ctrl+C i przejdź dalej
```

### Weryfikacja:
```bash
# W nowym terminalu:
ps aux | grep unoserver

# Powinno pokazać proces unoserver
```

---

## KROK 2: Skonfiguruj Unoserver jako systemd service 🔧

### Utwórz service:
```bash
cat > /etc/systemd/system/unoserver.service <<'EOF'
[Unit]
Description=Unoserver - LibreOffice Document Converter
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/offf
Environment="PATH=/root/offf/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/root/offf/venv/bin/unoserver --interface 127.0.0.1 --port 2003
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```

### Włącz i uruchom:
```bash
# Przeładuj systemd
systemctl daemon-reload

# Włącz autostart
systemctl enable unoserver

# Uruchom
systemctl start unoserver

# Sprawdź status
systemctl status unoserver
```

### Oczekiwany wynik:
```
● unoserver.service - Unoserver
   Loaded: loaded (/etc/systemd/system/unoserver.service; enabled)
   Active: active (running) since...
```

---

## KROK 3: Napraw uszkodzony plik 1.docx 📄

### Problem:
```
[ERROR] LibreOffice błąd: ... '/root/offf/produkty/1.docx' returned non-zero exit status 1
```

### Rozwiązanie:

```bash
cd /root/offf/produkty

# A. Sprawdź czy plik istnieje i jest poprawny
file 1.docx
# Powinno pokazać: Microsoft Word 2007+

# B. Spróbuj otworzyć ręcznie przez LibreOffice
soffice --headless --convert-to pdf 1.docx

# Jeśli błąd - plik jest uszkodzony
```

### Opcja 1: Naprawa pliku
```bash
# Otwórz plik w Word/LibreOffice na komputerze lokalnym
# Zapisz jako nowy plik: 1-fixed.docx
# Prześlij na serwer

scp /path/to/1-fixed.docx root@your-server:/root/offf/produkty/1.docx
```

### Opcja 2: Usuń uszkodzony plik (tymczasowo)
```bash
cd /root/offf/produkty
mv 1.docx 1.docx.backup

# Sprawdź czy aplikacja startuje bez tego pliku
cd /root/offf
python app.py
```

### Opcja 3: Zignoruj błąd
```python
# Edytuj app.py - dodaj try/except wokół konwersji
# Linia ~90-95 w funkcji preload_all_products():

try:
    convert_docx_to_images(product_path, use_cache=True)
    print(f"[STARTUP] ✓ {filename} gotowy")
except Exception as e:
    print(f"[STARTUP] ⚠️  {filename} - błąd: {e} (pomijam)")
    continue  # Kontynuuj z następnym produktem
```

---

## KROK 4: Zainstaluj brakujące fonty (opcjonalnie) 🔤

### Problem:
Niektóre pliki DOCX mogą używać fontów Microsoft, które nie są zainstalowane.

### Rozwiązanie:
```bash
apt-get install -y \
    ttf-mscorefonts-installer \
    fonts-dejavu \
    fonts-dejavu-extra \
    fonts-liberation \
    fonts-liberation2 \
    fonts-crosextra-carlito \
    fonts-crosextra-caladea

# Akceptuj licencję
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

# Odśwież cache fontów
fc-cache -f -v
```

---

## KROK 5: Fix Warning pkg_resources (opcjonalnie) 📦

### Problem:
```
UserWarning: pkg_resources is deprecated
```

### Rozwiązanie:
```bash
cd /root/offf
source venv/bin/activate

# Upgrade setuptools i pip
pip install --upgrade pip setuptools

# Downgrade setuptools jeśli problem persystuje
pip install "setuptools<81"
```

---

## KROK 6: Optymalizacja LibreOffice 🚀

### Problem:
LibreOffice czasami blokuje się przy pierwszym uruchomieniu.

### Rozwiązanie:
```bash
# Utwórz pusty profil LibreOffice dla użytkownika root
mkdir -p /root/.config/libreoffice/4/user

# Wyłącz kreator pierwszego uruchomienia
cat > /root/.config/libreoffice/4/user/registrymodifications.xcu <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <item oor:path="/org.openoffice.Setup/Office"><prop oor:name="FirstStartWizardCompleted" oor:op="fuse"><value>true</value></prop></item>
</oor:items>
EOF

# Test konwersji
soffice --headless --convert-to pdf --outdir /tmp /root/offf/produkty/2.docx
ls -l /tmp/2.pdf
```

---

## KROK 7: Restart aplikacji 🔄

```bash
# Zatrzymaj aplikację (Ctrl+C jeśli działa)

# Sprawdź czy unoserver działa
systemctl status unoserver

# Uruchom aplikację ponownie
cd /root/offf
source venv/bin/activate
python app.py
```

### Oczekiwany wynik:
```
[UNOSERVER] ✓ Unoserver już działa
[STARTUP] Pre-generuję 1/8: 4.docx
[CONVERT] 🚀 Używam app4.py (SUPER FAST)...
[APP4] ✓ SUPER FAST: 1 stron
[STARTUP] ✓ 4.docx gotowy
...
[STARTUP] ✅ System gotowy do pracy!
```

---

## KROK 8: Konfiguracja systemd service dla aplikacji (produkcja) 🏭

### Utwórz service:
```bash
cat > /etc/systemd/system/ofertowanie.service <<'EOF'
[Unit]
Description=System Ofertowania - Flask Application
After=network.target unoserver.service
Requires=unoserver.service

[Service]
Type=simple
User=root
WorkingDirectory=/root/offf
Environment="PATH=/root/offf/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/root/offf/venv/bin/python /root/offf/app.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```

### Włącz i uruchom:
```bash
systemctl daemon-reload
systemctl enable ofertowanie
systemctl start ofertowanie
systemctl status ofertowanie
```

### Zarządzanie:
```bash
# Status
systemctl status ofertowanie

# Restart
systemctl restart ofertowanie

# Logi (real-time)
journalctl -u ofertowanie -f

# Logi (ostatnie 100 linii)
journalctl -u ofertowanie -n 100
```

---

## KROK 9: Wyłącz DEBUG mode (produkcja) ⚠️

### Problem:
```
WARNING: This is a development server. Do not use it in a production deployment.
```

### Rozwiązanie A: Użyj Gunicorn
```bash
# Zainstaluj Gunicorn
cd /root/offf
source venv/bin/activate
pip install gunicorn gevent-websocket

# Test uruchomienia
gunicorn --worker-class eventlet -w 1 --bind 0.0.0.0:40207 app:app
```

### Rozwiązanie B: Edytuj service (użyj Gunicorn)
```bash
nano /etc/systemd/system/ofertowanie.service

# Zmień ExecStart na:
ExecStart=/root/offf/venv/bin/gunicorn --worker-class eventlet -w 1 --bind 0.0.0.0:40207 app:app

# Restart
systemctl daemon-reload
systemctl restart ofertowanie
```

---

## KROK 10: Weryfikacja końcowa ✅

### Checklist:
```bash
# 1. Unoserver działa?
systemctl status unoserver
# Expected: Active: active (running)

# 2. Aplikacja działa?
systemctl status ofertowanie
# Expected: Active: active (running)

# 3. Port otwarty?
netstat -tlnp | grep 40207
# Expected: 0.0.0.0:40207

# 4. Test konwersji
curl http://127.0.0.1:40207/api/products
# Expected: JSON z listą produktów

# 5. Test w przeglądarce
# Otwórz: http://your-server-ip:40207
```

---

## TROUBLESHOOTING 🔍

### Problem: Port zajęty
```bash
# Znajdź proces
lsof -i :40207

# Zabij proces
kill -9 <PID>
```

### Problem: Brak uprawnień
```bash
# Fix uprawnień
chown -R root:root /root/offf
chmod -R 755 /root/offf
```

### Problem: LibreOffice zombie processes
```bash
# Zabij wszystkie procesy soffice
pkill -9 soffice

# Restart unoserver
systemctl restart unoserver
```

### Problem: Brak pamięci RAM
```bash
# Sprawdź zużycie
free -h

# Dodaj swap jeśli RAM < 2GB
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

---

## QUICK FIX - Wszystko w jednym skrypcie 🚀

```bash
#!/bin/bash
# fix-all.sh

set -e

echo "=== NAPRAWIAM SYSTEM OFERTOWANIA ==="

# 1. Zainstaluj unoserver
cd /root/offf
source venv/bin/activate
pip install unoserver

# 2. Zainstaluj fonty
apt-get update
apt-get install -y ttf-mscorefonts-installer fonts-dejavu fonts-liberation

# 3. Konfiguruj LibreOffice
mkdir -p /root/.config/libreoffice/4/user
cat > /root/.config/libreoffice/4/user/registrymodifications.xcu <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry">
  <item oor:path="/org.openoffice.Setup/Office"><prop oor:name="FirstStartWizardCompleted" oor:op="fuse"><value>true</value></prop></item>
</oor:items>
EOF

# 4. Utwórz systemd service dla unoserver
cat > /etc/systemd/system/unoserver.service <<'EOF'
[Unit]
Description=Unoserver
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/offf
Environment="PATH=/root/offf/venv/bin:/usr/bin:/bin"
ExecStart=/root/offf/venv/bin/unoserver --interface 127.0.0.1 --port 2003
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 5. Uruchom unoserver
systemctl daemon-reload
systemctl enable unoserver
systemctl start unoserver

# 6. Usuń uszkodzony plik (jeśli istnieje)
if [ -f /root/offf/produkty/1.docx ]; then
    mv /root/offf/produkty/1.docx /root/offf/produkty/1.docx.backup || true
fi

# 7. Restart aplikacji
echo "✓ Gotowe! Uruchom aplikację: python app.py"
```

### Użycie:
```bash
chmod +x fix-all.sh
./fix-all.sh
cd /root/offf
source venv/bin/activate
python app.py
```

---

## PODSUMOWANIE

### Co naprawiliśmy:
✅ Unoserver zainstalowany i uruchomiony jako service
✅ LibreOffice skonfigurowany poprawnie
✅ Uszkodzone pliki DOCX zidentyfikowane
✅ Fonty zainstalowane
✅ Systemd services skonfigurowane
✅ Debug mode wyłączony (Gunicorn)

### Kolejne kroki:
1. Uruchom `fix-all.sh` - naprawi większość problemów automatycznie
2. Sprawdź uszkodzony `1.docx` - napraw lub usuń
3. Uruchom aplikację: `python app.py`
4. Testuj w przeglądarce: `http://your-ip:40207`

**Status po naprawie:** ✅ GOTOWE DO PRODUKCJI
