try:
    from django.conf import settings
    if getattr(settings, 'USE_CELERY', False):
        from .celery_app import app as celery_app
    else:
        celery_app = None
except Exception:
    celery_app = None

__all__ = ('celery_app',)
