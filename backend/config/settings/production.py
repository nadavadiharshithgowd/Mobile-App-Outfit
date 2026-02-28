from .base import *

# ─────────────────────────────────────────────
# SECURITY
# ─────────────────────────────────────────────
DEBUG = False

ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=['api.yourdomain.com'])

SECRET_KEY = env('SECRET_KEY')  # Required — no default in production

SECURE_BROWSER_XSS_FILTER      = True
SECURE_CONTENT_TYPE_NOSNIFF    = True
SECURE_SSL_REDIRECT            = True
SECURE_HSTS_SECONDS            = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD            = True
SESSION_COOKIE_SECURE          = True
CSRF_COOKIE_SECURE             = True
X_FRAME_OPTIONS                = 'DENY'

# ─────────────────────────────────────────────
# CORS — Allow only your Amplify frontend
# ─────────────────────────────────────────────
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[
    'https://yourdomain.amplifyapp.com',
    'https://www.yourdomain.com',
])
CORS_ALLOW_CREDENTIALS = True

# ─────────────────────────────────────────────
# DATABASE — PostgreSQL
# ─────────────────────────────────────────────
DATABASES = {
    'default': env.db('DATABASE_URL'),
}

# ─────────────────────────────────────────────
# STATIC FILES (WhiteNoise)
# ─────────────────────────────────────────────
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# ─────────────────────────────────────────────
# CACHES — Redis
# ─────────────────────────────────────────────
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://127.0.0.1:6379/0'),
    }
}

# ─────────────────────────────────────────────
# LOGGING — stdout → journalctl / CloudWatch
# ─────────────────────────────────────────────
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {'class': 'logging.StreamHandler', 'formatter': 'verbose'},
    },
    'root': {'handlers': ['console'], 'level': env('LOG_LEVEL', default='INFO')},
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': env('LOG_LEVEL', default='INFO'),
            'propagate': False,
        },
    },
}

# ─────────────────────────────────────────────
# EMAIL
# ─────────────────────────────────────────────
EMAIL_BACKEND       = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST          = env('EMAIL_HOST', default='smtp.gmail.com')
EMAIL_PORT          = env.int('EMAIL_PORT', default=587)
EMAIL_USE_TLS       = True
EMAIL_HOST_USER     = env('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = env('EMAIL_HOST_PASSWORD')
DEFAULT_FROM_EMAIL  = env('DEFAULT_FROM_EMAIL', default=EMAIL_HOST_USER)
