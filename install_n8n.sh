#!/bin/bash

# ANSI Farben für die Konsole
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Keine Farbe

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║     n8n Installation mit Nginx SSL    ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Funktion zur Überprüfung, ob ein Befehl existiert
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fehlerbehandlung
set -e
trap 'echo -e "${RED}❌ Ein Fehler ist aufgetreten. Installation abgebrochen.${NC}"' ERR

# Root-Check
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Dieses Skript muss als root ausgeführt werden!${NC}"
   echo "Bitte verwenden Sie: sudo $0"
   exit 1
fi

# Voraussetzungen prüfen
echo -e "${YELLOW}📋 Prüfe Voraussetzungen...${NC}"

# Docker installieren falls nicht vorhanden
if ! command_exists docker; then
    echo -e "${YELLOW}Docker wird installiert...${NC}"
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# Docker Compose installieren falls nicht vorhanden
if ! command_exists docker-compose; then
    echo -e "${YELLOW}Docker Compose wird installiert...${NC}"
    apt-get update
    apt-get install -y docker-compose
fi

# Nginx installieren falls nicht vorhanden
if ! command_exists nginx; then
    echo -e "${YELLOW}Nginx wird installiert...${NC}"
    apt-get update
    apt-get install -y nginx
fi

# Certbot installieren falls nicht vorhanden
if ! command_exists certbot; then
    echo -e "${YELLOW}Certbot wird installiert...${NC}"
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi

echo -e "${GREEN}✅ Alle Voraussetzungen erfüllt!${NC}\n"

# Benutzereingaben
echo -e "${BLUE}══════════════════════════════════════════${NC}"
echo -e "${YELLOW}Bitte geben Sie die folgenden Informationen ein:${NC}"
echo -e "${BLUE}══════════════════════════════════════════${NC}\n"

# Domain
read -p "Domain für n8n (z.B. n8n.example.com): " DOMAIN
while [[ -z "$DOMAIN" ]]; do
    echo -e "${RED}Domain darf nicht leer sein!${NC}"
    read -p "Domain für n8n: " DOMAIN
done

# E-Mail für Let's Encrypt
read -p "E-Mail-Adresse für SSL-Zertifikat: " EMAIL
while [[ ! "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; do
    echo -e "${RED}Bitte geben Sie eine gültige E-Mail-Adresse ein!${NC}"
    read -p "E-Mail-Adresse: " EMAIL
done

# Timezone
read -p "Zeitzone (Standard: Europe/Berlin): " TIMEZONE
TIMEZONE=${TIMEZONE:-Europe/Berlin}

# Admin-Passwort generieren oder eingeben
echo -e "\n${YELLOW}Admin-Passwort für n8n:${NC}"
echo "1) Automatisch generieren (empfohlen)"
echo "2) Selbst eingeben"
read -p "Auswahl (1 oder 2): " PASS_CHOICE

if [[ "$PASS_CHOICE" == "2" ]]; then
    read -s -p "Admin-Passwort: " N8N_BASIC_AUTH_PASSWORD
    echo
    read -s -p "Passwort wiederholen: " N8N_BASIC_AUTH_PASSWORD_CONFIRM
    echo
    while [[ "$N8N_BASIC_AUTH_PASSWORD" != "$N8N_BASIC_AUTH_PASSWORD_CONFIRM" ]]; do
        echo -e "${RED}Passwörter stimmen nicht überein!${NC}"
        read -s -p "Admin-Passwort: " N8N_BASIC_AUTH_PASSWORD
        echo
        read -s -p "Passwort wiederholen: " N8N_BASIC_AUTH_PASSWORD_CONFIRM
        echo
    done
else
    N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 32)
    echo -e "${GREEN}Generiertes Passwort: ${YELLOW}$N8N_BASIC_AUTH_PASSWORD${NC}"
    echo -e "${RED}⚠️  WICHTIG: Notieren Sie sich dieses Passwort!${NC}"
fi

# Installationsverzeichnis
N8N_DIR="/opt/n8n"
echo -e "\n${YELLOW}📁 Erstelle n8n-Verzeichnis in $N8N_DIR${NC}"
mkdir -p $N8N_DIR
cd $N8N_DIR

# .env Datei erstellen
echo -e "${YELLOW}📝 Erstelle .env Datei...${NC}"
cat > $N8N_DIR/.env << EOF
# n8n Konfiguration
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://$DOMAIN/

# Basis-Authentifizierung
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$N8N_BASIC_AUTH_PASSWORD

# Zeitzone
GENERIC_TIMEZONE=$TIMEZONE

# Verschlüsselungsschlüssel (automatisch generiert)
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)

# Datenbank (SQLite als Standard)
DB_TYPE=sqlite

# Ausführungsmodus
EXECUTIONS_PROCESS=main
N8N_DIAGNOSTICS_ENABLED=false

# Weitere Einstellungen
N8N_METRICS=false
N8N_VERSION_NOTIFICATIONS_ENABLED=true
EOF

# docker-compose.yml erstellen
echo -e "${YELLOW}🐳 Erstelle docker-compose.yml...${NC}"
cat > $N8N_DIR/docker-compose.yml << 'EOF'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=${N8N_PORT}
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - WEBHOOK_URL=${WEBHOOK_URL}
      - N8N_BASIC_AUTH_ACTIVE=${N8N_BASIC_AUTH_ACTIVE}
      - N8N_BASIC_AUTH_USER=${N8N_BASIC_AUTH_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_BASIC_AUTH_PASSWORD}
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - DB_TYPE=${DB_TYPE}
      - EXECUTIONS_PROCESS=${EXECUTIONS_PROCESS}
      - N8N_DIAGNOSTICS_ENABLED=${N8N_DIAGNOSTICS_ENABLED}
      - N8N_METRICS=${N8N_METRICS}
      - N8N_VERSION_NOTIFICATIONS_ENABLED=${N8N_VERSION_NOTIFICATIONS_ENABLED}
    volumes:
      - ./n8n_data:/home/node/.n8n
      - ./files:/files
    networks:
      - n8n_network

networks:
  n8n_network:
    driver: bridge

volumes:
  n8n_data:
  files:
EOF

# n8n starten
echo -e "${YELLOW}🚀 Starte n8n Container...${NC}"
docker-compose up -d

# Warten bis n8n läuft
echo -e "${YELLOW}⏳ Warte auf n8n Start...${NC}"
sleep 10

# Nginx Konfiguration
echo -e "${YELLOW}🔧 Konfiguriere Nginx...${NC}"
cat > /etc/nginx/sites-available/$DOMAIN << EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;
        
        # Timeouts für lange laufende Workflows
        proxy_connect_timeout 90;
        proxy_send_timeout 90;
        proxy_read_timeout 90;
    }
}
EOF

# Nginx Site aktivieren
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# SSL-Zertifikat mit Certbot
echo -e "${YELLOW}🔐 Erstelle SSL-Zertifikat...${NC}"
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL --redirect

# Systemd Service erstellen (optional für Auto-Start)
echo -e "${YELLOW}⚙️  Erstelle Systemd-Service...${NC}"
cat > /etc/systemd/system/n8n.service << EOF
[Unit]
Description=n8n workflow automation
After=docker.service
Requires=docker.service

[Service]
Type=simple
WorkingDirectory=$N8N_DIR
ExecStart=/usr/bin/docker-compose up
ExecStop=/usr/bin/docker-compose down
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable n8n

# Zusammenfassung
echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         🎉 n8n Installation erfolgreich! 🎉          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${BLUE}📋 Zusammenfassung:${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "🌐 URL:        ${GREEN}https://$DOMAIN${NC}"
echo -e "👤 Benutzer:   ${GREEN}admin${NC}"
echo -e "🔑 Passwort:   ${YELLOW}$N8N_BASIC_AUTH_PASSWORD${NC}"
echo -e "📁 Verzeichnis: ${GREEN}$N8N_DIR${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo -e "${YELLOW}📝 Nützliche Befehle:${NC}"
echo -e "  Status:  ${BLUE}docker-compose -f $N8N_DIR/docker-compose.yml ps${NC}"
echo -e "  Logs:    ${BLUE}docker-compose -f $N8N_DIR/docker-compose.yml logs -f${NC}"
echo -e "  Restart: ${BLUE}docker-compose -f $N8N_DIR/docker-compose.yml restart${NC}"
echo -e "  Update:  ${BLUE}docker-compose -f $N8N_DIR/docker-compose.yml pull && docker-compose -f $N8N_DIR/docker-compose.yml up -d${NC}"
echo
echo -e "${RED}⚠️  WICHTIG: Speichern Sie die Zugangsdaten an einem sicheren Ort!${NC}"
