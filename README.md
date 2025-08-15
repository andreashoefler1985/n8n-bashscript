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
wget https://raw.githubusercontent.com/andreashoefler1985/n8n-bashscript/install_n8n.sh

# Ausführbar machen
chmod +x install_n8n.sh

# Installation starten
sudo ./install_n8n.sh
