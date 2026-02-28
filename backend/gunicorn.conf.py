# ============================================================
# Gunicorn Configuration — EC2 Production
# ============================================================
import multiprocessing

# Bind
bind = "0.0.0.0:8000"

# Workers — 2×CPU + 1 is the standard formula
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "uvicorn.workers.UvicornWorker"  # Use Uvicorn for ASGI (WebSocket support)
worker_connections = 1000
timeout = 120
keepalive = 5

# Logging
loglevel = "info"
accesslog = "-"   # stdout → picked up by journalctl
errorlog = "-"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "outfit-stylist-backend"

# Graceful restart
graceful_timeout = 30
max_requests = 1000
max_requests_jitter = 50

# Preload app for faster worker spawn
preload_app = True
