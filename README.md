# 🚀 n8n Auto-Installer mit Nginx & SSL

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![n8n](https://img.shields.io/badge/n8n-latest-orange.svg)](https://n8n.io)
[![Docker](https://img.shields.io/badge/Docker-required-blue.svg)](https://docker.com)
[![Nginx](https://img.shields.io/badge/Nginx-SSL-green.svg)](https://nginx.org)

Ein vollautomatisches, interaktives Installations-Script für n8n mit Nginx Reverse Proxy und Let's Encrypt SSL-Zertifikat. Von Null auf Produktion in unter 5 Minuten! 🎯

## ✨ Features

- 🔧 **Vollautomatische Installation** - Installiert alle Abhängigkeiten automatisch
- 🔐 **SSL-Zertifikat** - Automatische Let's Encrypt Integration
- 🐳 **Docker-basiert** - Läuft in isolierter Container-Umgebung
- 🎯 **Interaktiv** - Einfache Schritt-für-Schritt Konfiguration
- 📝 **Sichere Defaults** - Automatische Passwort-Generierung und Verschlüsselung
- 🚦 **Systemd Integration** - Automatischer Start beim Booten
- 📊 **Production-Ready** - Optimierte Nginx-Konfiguration mit WebSocket-Support

## 📋 Voraussetzungen

- Ubuntu/Debian basiertes System (getestet auf Ubuntu 20.04/22.04)
- Root-Zugriff (sudo)
- Eine Domain, die auf Ihren Server zeigt
- Port 80 und 443 müssen offen sein

## 🚀 Schnellstart

```bash
  # Script herunterladen
  wget https://raw.githubusercontent.com/andreashoefler1985/n8n-bashscript/
  install_n8n.sh

  # Ausführbar machen
  chmod +x install_n8n.sh

  # Installation starten
  sudo ./install_n8n.sh
  ```

## 💬 Interaktive Installation

```text
  ╔═══════════════════════════════════════╗
  ║     n8n Installation mit Nginx SSL    ║
  ╚═══════════════════════════════════════╝

  Domain für n8n: n8n.meine-domain.de
  E-Mail-Adresse: admin@meine-domain.de
  Zeitzone (Standard: Europe/Berlin): [Enter]
  Admin-Passwort:
  1) Automatisch generieren (empfohlen)
  2) Selbst eingeben
  Auswahl: 1
  ```


## 📁 Installationsverzeichnis

Alle n8n-Dateien werden in /opt/n8n/ installiert:

```text
/opt/n8n/
├── .env                 # Umgebungsvariablen
├── docker-compose.yml   # Docker Konfiguration
├── n8n_data/           # n8n Daten & Workflows
└── files/              # Datei-Uploads
```

## 🔧 Konfiguration

# Umgebungsvariablen (.env)
Das Script erstellt automatisch eine .env Datei mit:
- Webhook-URL Konfiguration
- SSL/HTTPS Einstellungen
- Basis-Authentifizierung
- Verschlüsselungsschlüssel
- Zeitzone

# Docker Compose
- Verwendet das offizielle n8nio/n8n:latest Image
- Automatische Neustarts bei Fehlern
- Persistente Volumes für Daten
- Isoliertes Netzwerk

# Nginx Konfiguration
- Reverse Proxy auf Port 5678
- WebSocket Support für Echtzeit-Updates
- SSL/TLS mit Let's Encrypt
- Automatische HTTP → HTTPS Weiterleitung
- Optimierte Timeouts für lange Workflows

## 🛠️ Wartung & Verwaltung

# Status prüfen
docker-compose -f /opt/n8n/docker-compose.yml ps

# Logs anzeigen
docker-compose -f /opt/n8n/docker-compose.yml logs -f

# n8n neustarten
docker-compose -f /opt/n8n/docker-compose.yml restart

# n8n aktualisieren
cd /opt/n8n
docker-compose pull
docker-compose up -d

# Backup erstellen
tar -czf n8n-backup-$(date +%Y%m%d).tar.gz /opt/n8n/n8n_data

## 🔐 Sicherheit

✅ Automatische SSL-Verschlüsselung
✅ Sichere Passwort-Generierung (32 Zeichen, Base64)
✅ Verschlüsselte Datenbank
✅ Basis-Authentifizierung aktiviert
✅ Isolierte Docker-Umgebung
✅ Keine externen Telemetrie-Daten

## 📊 Performance

Das Script installiert n8n mit optimalen Einstellungen für:

Kleine bis mittlere Installationen (1-100 gleichzeitige Workflows)
Bei Bedarf können Ressourcen in docker-compose.yml angepasst werden

## 🐛 Fehlerbehebung

# Port 80/443 bereits belegt
```text
sudo lsof -i :80
sudo lsof -i :443
```
# SSL-Zertifikat Fehler
```text
sudo certbot renew --dry-run  # Test
sudo certbot renew            # Erneuern
```
# n8n nicht erreichbar
```text
# Nginx Status prüfen
sudo systemctl status nginx

# Docker Container prüfen
docker ps -a

# Firewall prüfen
sudo ufw status
```

## 📝 Lizenz
- MIT License

## 🙏 Credits
- n8n.io - Workflow Automation Tool
- Let's Encrypt - Kostenlose SSL-Zertifikate


⭐ Wenn dieses Script hilfreich war, vergiss nicht einen Stern zu geben!
