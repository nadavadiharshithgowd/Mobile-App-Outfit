"""
FastAPI application for WebSocket and streaming endpoints.

Mounted alongside Django via ASGI in config/asgi.py.
Handles:
- WebSocket connection for try-on status streaming
- SSE (Server-Sent Events) fallback for status updates
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes import tryon_routes

fastapi_app = FastAPI(
    title='Outfit Stylist - Realtime API',
    version='1.0.0',
    docs_url='/fastapi/docs',
    openapi_url='/fastapi/openapi.json',
)

fastapi_app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

fastapi_app.include_router(tryon_routes.router, prefix='/ws')
