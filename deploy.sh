#!/bin/bash
# ============================================================
# EC2 Deployment Script — Outfit Stylist Backend
# ============================================================
# Usage:
#   First time:  chmod +x deploy.sh && ./deploy.sh --setup
#   Updates:     ./deploy.sh
# ============================================================

set -euo pipefail

# ── Config ───────────────────────────────────────────────────
APP_DIR="/home/ubuntu/outfit-app"
BACKEND_DIR="$APP_DIR/backend"
VENV_DIR="$APP_DIR/venv"
REPO_URL="https://github.com/YOUR_USERNAME/outfit-stylist.git"  # ← change this
BRANCH="main"
PYTHON="python3.11"

GREEN="\033[0;32m"; YELLOW="\033[1;33m"; RED="\033[0;31m"; NC="\033[0m"
log()  { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${YELLOW}[→]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# ── INITIAL SETUP (run once on a fresh EC2) ──────────────────
setup() {
  info "Running one-time EC2 setup..."

  # System packages
  sudo apt-get update -qq
  sudo apt-get install -y \
    python3.11 python3.11-venv python3.11-dev \
    postgresql postgresql-contrib \
    redis-server \
    nginx certbot python3-certbot-nginx \
    git curl build-essential libpq-dev \
    ffmpeg libsm6 libxext6  # for OpenCV/YOLO

  log "System packages installed"

  # Create app directory
  sudo mkdir -p "$APP_DIR"
  sudo chown ubuntu:ubuntu "$APP_DIR"

  # Clone repo
  if [ ! -d "$APP_DIR/.git" ]; then
    git clone "$REPO_URL" "$APP_DIR"
    log "Repository cloned"
  fi

  # Python virtual environment
  "$PYTHON" -m venv "$VENV_DIR"
  log "Virtual environment created"

  # PostgreSQL setup
  info "Setting up PostgreSQL..."
  sudo -u postgres psql -c "CREATE USER outfit_user WITH PASSWORD 'your-strong-db-password';" 2>/dev/null || true
  sudo -u postgres psql -c "CREATE DATABASE outfit_stylist_db OWNER outfit_user;" 2>/dev/null || true
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE outfit_stylist_db TO outfit_user;" 2>/dev/null || true
  # Install pgvector extension
  sudo apt-get install -y postgresql-16-pgvector 2>/dev/null || \
    sudo -u postgres psql -d outfit_stylist_db -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>/dev/null || true
  log "PostgreSQL configured"

  # Redis
  sudo systemctl enable redis-server
  sudo systemctl start redis-server
  log "Redis started"

  # Copy .env file
  if [ ! -f "$BACKEND_DIR/.env" ]; then
    cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
    err ".env created from example — EDIT $BACKEND_DIR/.env with your real values, then re-run ./deploy.sh"
  fi

  # Systemd services
  info "Installing systemd services..."
  sudo cp "$APP_DIR/systemd/outfit-stylist.service"    /etc/systemd/system/
  sudo cp "$APP_DIR/systemd/outfit-celery.service"     /etc/systemd/system/
  sudo cp "$APP_DIR/systemd/outfit-celery-beat.service" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable outfit-stylist outfit-celery outfit-celery-beat
  log "Systemd services installed"

  # Nginx
  info "Configuring Nginx..."
  sudo cp "$APP_DIR/nginx/nginx.conf" /etc/nginx/sites-available/outfit-stylist
  sudo ln -sf /etc/nginx/sites-available/outfit-stylist /etc/nginx/sites-enabled/
  sudo rm -f /etc/nginx/sites-enabled/default
  sudo nginx -t && sudo systemctl reload nginx
  log "Nginx configured"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Setup complete! Next steps:"
  echo "  1. Edit $BACKEND_DIR/.env with your real values"
  echo "  2. Update nginx.conf domain name"
  echo "  3. Run: sudo certbot --nginx -d api.yourdomain.com"
  echo "  4. Run: ./deploy.sh   (to deploy the app)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ── DEPLOY (run on every update) ─────────────────────────────
deploy() {
  info "Deploying backend update..."

  cd "$APP_DIR"

  # Pull latest code
  git fetch origin "$BRANCH"
  git reset --hard "origin/$BRANCH"
  log "Code updated from git"

  # Activate venv
  source "$VENV_DIR/bin/activate"

  # Install/update Python dependencies
  pip install --upgrade pip -q
  pip install -r "$BACKEND_DIR/requirements.txt" -q
  log "Dependencies installed"

  cd "$BACKEND_DIR"

  # Set settings module
  export DJANGO_SETTINGS_MODULE=config.settings.production

  # Run migrations
  python manage.py migrate --noinput
  log "Migrations applied"

  # Collect static files
  python manage.py collectstatic --noinput -v 0
  log "Static files collected"

  # Restart services
  sudo systemctl restart outfit-stylist
  sudo systemctl restart outfit-celery
  sudo systemctl restart outfit-celery-beat
  log "Services restarted"

  # Reload nginx
  sudo nginx -t && sudo systemctl reload nginx
  log "Nginx reloaded"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ✅ Deployment complete!"
  echo "  Check status:  sudo systemctl status outfit-stylist"
  echo "  View logs:     sudo journalctl -u outfit-stylist -f"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ── Entry point ───────────────────────────────────────────────
if [[ "${1:-}" == "--setup" ]]; then
  setup
else
  deploy
fi
