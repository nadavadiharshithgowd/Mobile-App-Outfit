import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.local')

django_asgi_app = get_asgi_application()

from fastapi_app.main import fastapi_app


async def application(scope, receive, send):
    """Route between Django and FastAPI based on path."""
    if scope['type'] == 'http':
        path = scope.get('path', '')
        if path.startswith('/ws/') or path.startswith('/fastapi/'):
            await fastapi_app(scope, receive, send)
        else:
            await django_asgi_app(scope, receive, send)
    elif scope['type'] == 'websocket':
        await fastapi_app(scope, receive, send)
    else:
        await django_asgi_app(scope, receive, send)
