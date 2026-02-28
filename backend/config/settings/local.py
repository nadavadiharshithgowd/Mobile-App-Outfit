"""
Local development settings - no Docker, no PostgreSQL, no Redis, no Celery.
Uses SQLite and Python threading for background tasks.
"""
from .base import *

DEBUG = True
ALLOWED_HOSTS = ['*']

# Use console email backend for development
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# SQLite database (no PostgreSQL needed)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Disable Celery - use Python threading instead
USE_CELERY = False

# Remove Celery-dependent apps
INSTALLED_APPS = [app for app in INSTALLED_APPS if app not in (
    'django_celery_beat',
    'django_celery_results',
)]

# More permissive throttling for dev
REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'] = {
    'anon': '1000/minute',
    'user': '5000/minute',
}
