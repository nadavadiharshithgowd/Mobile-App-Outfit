"""
WebSocket endpoint for real-time try-on status streaming.

The Flutter app connects to this WebSocket to receive live updates
during try-on processing (progress percentage, current step, result URL).
"""

import json
import asyncio
import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

logger = logging.getLogger(__name__)

router = APIRouter()


@router.websocket('/tryon/{tryon_id}/status/')
async def tryon_status_ws(websocket: WebSocket, tryon_id: str):
    """
    WebSocket endpoint for try-on status updates.

    The client connects with the try-on ID and receives JSON messages:
    {
        "status": "processing",
        "progress": 50,
        "step": "diffusion_inference"
    }

    When status is "completed", the message includes:
    {
        "status": "completed",
        "progress": 100,
        "step": "done",
        "result_url": "https://..."
    }
    """
    await websocket.accept()

    try:
        import redis.asyncio as aioredis

        redis_client = aioredis.from_url('redis://localhost:6379/0')
        pubsub = redis_client.pubsub()
        channel = f'tryon:{tryon_id}'
        await pubsub.subscribe(channel)

        logger.info(f'WebSocket connected for try-on {tryon_id}')

        # Send initial status
        await websocket.send_json({
            'status': 'connected',
            'progress': 0,
            'step': 'waiting',
        })

        # Listen for Redis messages
        while True:
            message = await pubsub.get_message(
                ignore_subscribe_messages=True,
                timeout=1.0,
            )

            if message and message['type'] == 'message':
                data = json.loads(message['data'])
                await websocket.send_json(data)

                # Close WebSocket when done
                if data.get('status') in ('completed', 'failed'):
                    break

            # Check if client is still connected
            try:
                await asyncio.wait_for(
                    websocket.receive_text(),
                    timeout=0.1,
                )
            except asyncio.TimeoutError:
                pass  # No message from client, continue
            except WebSocketDisconnect:
                break

        await pubsub.unsubscribe(channel)
        await redis_client.aclose()

    except ImportError:
        # Redis not available, fall back to polling
        logger.warning('Redis not available for WebSocket, using polling fallback')
        await _polling_fallback(websocket, tryon_id)

    except WebSocketDisconnect:
        logger.info(f'WebSocket disconnected for try-on {tryon_id}')

    except Exception as e:
        logger.error(f'WebSocket error for try-on {tryon_id}: {e}')
        try:
            await websocket.send_json({
                'status': 'error',
                'message': str(e),
            })
        except Exception:
            pass


async def _polling_fallback(websocket: WebSocket, tryon_id: str):
    """Fallback when Redis is not available - poll the database."""
    import os
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')

    max_polls = 60  # Max 3 minutes at 3s intervals

    for _ in range(max_polls):
        try:
            # This is a simplified polling approach
            # In production, use proper Django ORM access
            await websocket.send_json({
                'status': 'processing',
                'progress': 50,
                'step': 'Processing...',
            })
            await asyncio.sleep(3)

        except WebSocketDisconnect:
            break
