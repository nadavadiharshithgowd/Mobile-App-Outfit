"""
Task utilities for running with or without Celery.

When USE_CELERY is False (local dev), tasks run as plain Python functions
with threading used in views to avoid blocking requests.
"""
import logging

logger = logging.getLogger(__name__)

try:
    from celery import shared_task as celery_shared_task
    CELERY_AVAILABLE = True
except ImportError:
    CELERY_AVAILABLE = False


def _check_celery_enabled():
    """Check if Celery is both available and enabled in settings."""
    if not CELERY_AVAILABLE:
        return False
    try:
        from django.conf import settings
        return getattr(settings, 'USE_CELERY', False)
    except Exception:
        return False


def shared_task(*args, **kwargs):
    """
    Drop-in replacement for celery.shared_task.

    When Celery is enabled: delegates to real @shared_task.
    When Celery is disabled: returns the function as-is, adding a .delay()
    method that just calls the function directly (synchronously).
    """
    if _check_celery_enabled():
        return celery_shared_task(*args, **kwargs)

    # No Celery: return a decorator that makes the function callable normally
    bind = kwargs.get('bind', False)

    def decorator(func):
        def wrapper(*a, **kw):
            if bind:
                # Skip the 'self' parameter since there's no Celery task instance
                return func(None, *a, **kw)
            return func(*a, **kw)

        # Add .delay() that just calls the function directly
        wrapper.delay = wrapper
        wrapper.__name__ = func.__name__
        wrapper.__module__ = func.__module__
        return wrapper

    # Handle @shared_task (no parens) vs @shared_task(...) (with parens)
    if len(args) == 1 and callable(args[0]) and not kwargs:
        return decorator(args[0])

    return decorator


def run_in_thread(func, *args):
    """Run a function in a background thread."""
    import threading
    thread = threading.Thread(target=func, args=args, daemon=True)
    thread.start()
    return thread
