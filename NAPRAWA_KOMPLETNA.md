# ✅ NAPRAWA ZAKOŃCZONA - Brak podglądów naprawiony!

## 🔴 Problem z beldy.txt

**Błąd:**
```
NameError: name 'needs_toc' is not defined
app.py, line 1154
```

**Skutek:** Brak podglądów ofert - aplikacja crashowała przy próbie generowania preview.

---

## ✅ Rozwiązanie

### Naprawiony kod (app.py linia 1154):

**PRZED (BŁĄD):**
```python
# SPIS TREŚCI - jeśli to plik TOC, wygeneruj i wstaw
if needs_toc:  # ❌ Zmienna nie zdefiniowana!
    toc_config = template_data.get('toc', {})
    ...
```

**PO (NAPRAWIONE):**
```python
# SPIS TREŚCI - jeśli to plik TOC, wygeneruj i wstaw
if file_info.get('is_toc') and len(selected_products) > 0:  # ✅ Poprawne!
    toc_config = template_data.get('toc', {})
    ...
```

---

## 🚀 JAK WDROŻYĆ NAPRAWĘ NA SERWERZE

### KROK 1: Zatrzymaj aplikację
```bash
# Jeśli uruchomiona przez systemd:
sudo systemctl stop ofertowanie

# LUB jeśli uruchomiona ręcznie, naciśnij Ctrl+C
```

### KROK 2: Zaktualizuj kod na serwerze

**Opcja A: Przez Git (jeśli używasz repozytorium)**
```bash
cd /root/offf
git pull origin main
```

**Opcja B: Skopiuj naprawiony plik z komputera lokalnego**
```bash
# Na lokalnym komputerze:
scp /Users/maksymiliansiwecki/Documents/GitHub/offf/app.py root@your-server-ip:/root/offf/app.py
```

**Opcja C: Edytuj bezpośrednio na serwerze**
```bash
cd /root/offf
nano app.py

# Znajdź linię 1154 (Ctrl+_ -> wpisz 1154)
# Zmień:
#   if needs_toc:
# Na:
#   if file_info.get('is_toc') and len(selected_products) > 0:

# Zapisz: Ctrl+O, Enter
# Wyjdź: Ctrl+X
```

### KROK 3: Uruchom aplikację ponownie
```bash
cd /root/offf
source venv/bin/activate
python app.py
```

**LUB przez systemd:**
```bash
sudo systemctl start ofertowanie
sudo systemctl status ofertowanie
```

### KROK 4: Weryfikacja

1. Otwórz przeglądarkę: `http://your-server-ip:40207`
2. Wybierz szablon (np. WolfTax)
3. Wypełnij dane formularza
4. Kliknij "Podgląd"
5. **Powinny pojawić się podglądy stron!** ✅

---

## 📊 Oczekiwane logi po naprawie

```
[PREVIEW] Template: wolftax, Produkty: []
[CACHE] ❌ MISS - generuję nową ofertę... Key: 97fa670326e43e7b...
[DEBUG] Używam multi-file template
[PREVIEW] Przetwarzam: Dok1.docx
[CONVERT] 🚀 Używam app4.py (SUPER FAST)...
[APP4] ✓ SUPER FAST: 1 stron
[DEBUG] ✓ Strona 1 wysłana przez WebSocket
[PREVIEW] Przetwarzam: Doc2.docx
[CONVERT] 🚀 Używam app4.py (SUPER FAST)...
...
[CACHE] ✓ Zapisano do cache
✅ Podgląd gotowy!
```

**Brak błędów `NameError`!**

---

## 🎯 Dodatkowe usprawnienia (opcjonalnie)

### Jeśli nadal brakuje podglądów, sprawdź:

#### 1. Czy unoserver działa?
```bash
systemctl status unoserver

# Jeśli NIE działa, uruchom:
systemctl start unoserver
```

#### 2. Czy LibreOffice jest zainstalowany?
```bash
which soffice
# Jeśli brak, zainstaluj:
apt-get install -y libreoffice libreoffice-writer
```

#### 3. Czy pliki szablonów istnieją?
```bash
ls -la /root/offf/templates/wolftax-oferta/
# Powinny być: Dok1.docx, Doc2.docx, doc3.docx, doc4.docx, Dok5.docx, Dok6.docx
```

#### 4. Sprawdź uprawnienia
```bash
chown -R root:root /root/offf
chmod -R 755 /root/offf
```

---

## 🐛 Debugging - jeśli nadal nie działa

### Zobacz logi real-time:
```bash
# Jeśli systemd:
journalctl -u ofertowanie -f

# Jeśli ręcznie:
cd /root/offf
source venv/bin/activate
python app.py
# Oglądaj output
```

### Sprawdź WebSocket w przeglądarce:
1. Otwórz DevTools (F12)
2. Zakładka "Console"
3. Powinno być: `WebSocket connected`
4. Brak błędów czerwonych

### Test konwersji ręcznej:
```bash
cd /root/offf
source venv/bin/activate

# Test app4.py
python app4.py templates/wolftax-oferta/Dok1.docx -o /tmp/test --dpi 200 --quality 90

# Sprawdź wynik
ls -la /tmp/test/
# Powinny być pliki .jpg
```

---

## 📝 Podsumowanie naprawy

✅ **Naprawiono:** NameError: name 'needs_toc' is not defined
✅ **Plik:** app.py, linia 1154
✅ **Zmiana:** `if needs_toc:` → `if file_info.get('is_toc') and len(selected_products) > 0:`
✅ **Skutek:** Podglądy ofert działają poprawnie!

---

## 🎉 Status

**PRZED naprawą:** ❌ HTTP 500 Error - brak podglądów
**PO naprawie:** ✅ Podglądy działają - strony wyświetlają się w czasie rzeczywistym!

---

**Data naprawy:** 2025-11-09
**Wersja:** 3.0.1 (bugfix)
