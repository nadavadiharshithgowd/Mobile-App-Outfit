import io
import json
import os
import re
import time
import tempfile
import logging
import requests
from PIL import Image
from common.task_utils import shared_task
from django.utils import timezone

logger = logging.getLogger(__name__)


def _ensure_jpeg(image_bytes: bytes) -> bytes:
    """Convert image bytes to valid JPEG, normalising format and orientation."""
    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    # IDM-VTON works best at 768×1024; downscale if needed, never upscale
    max_w, max_h = 768, 1024
    if img.width > max_w or img.height > max_h:
        img.thumbnail((max_w, max_h), Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, format='JPEG', quality=95)
    return buf.getvalue()


def _resolve_result(value, hf_token: str = None) -> bytes:
    """
    gradio_client >= 1.0 returns file outputs as dicts:
      {'path': '/tmp/local/...', 'url': 'https://...hf.space/file=...', ...}
    Older versions returned a plain string path.

    Tries the local path first (already downloaded by gradio_client),
    then falls back to direct HTTP download of the remote URL with auth.
    """
    local_path = ''
    remote_url = ''

    if isinstance(value, dict):
        local_path = value.get('path', '')
        remote_url = value.get('url', '')
    else:
        local_path = value or ''

    # Try the local path that gradio_client downloaded
    if local_path and os.path.isfile(local_path):
        logger.info(f'Reading result from local path: {local_path}')
        with open(local_path, 'rb') as f:
            return f.read()

    # Fall back to direct HTTP download with HF token
    if remote_url:
        logger.info(f'Local path not found, downloading from URL: {remote_url}')
        return _download_url(remote_url, hf_token)

    raise ValueError(f'Cannot resolve result — no valid path or URL in: {value!r}')


def _download_url(url: str, hf_token: str = None, max_retries: int = 3) -> bytes:
    """Download a file from a URL with retry logic and optional HF auth."""
    headers = {}
    if hf_token:
        headers['Authorization'] = f'Bearer {hf_token}'

    for attempt in range(max_retries):
        try:
            resp = requests.get(url, headers=headers, timeout=120)
            resp.raise_for_status()
            logger.info(f'Downloaded {len(resp.content)} bytes from {url}')
            return resp.content
        except requests.HTTPError as e:
            if attempt < max_retries - 1:
                wait = 5 * (attempt + 1)
                logger.warning(f'Download attempt {attempt + 1} failed ({e}), retrying in {wait}s...')
                time.sleep(wait)
            else:
                raise
    raise RuntimeError(f'Failed to download after {max_retries} attempts: {url}')


def _extract_url_from_error(error_msg: str) -> str:
    """Extract an HF Space file URL from a gradio_client error message."""
    match = re.search(r'https://[^\s\'"]+\.hf\.space/file=[^\s\'"]+', error_msg)
    return match.group(0) if match else ''


def _call_idm_vton(person_bytes: bytes, garment_bytes: bytes, garment_description: str = "clothing") -> bytes:
    """
    Call the IDM-VTON Gradio API hosted on Hugging Face Spaces.

    Handles the common race condition where the HF Space processes the image
    successfully but the result temp file expires before gradio_client downloads
    it (manifests as a 404 on the /file= endpoint).
    """
    # gradio_client 1.x renamed file() to handle_file(); support both versions
    try:
        from gradio_client import Client, handle_file as _gradio_file
    except ImportError:
        from gradio_client import Client, file as _gradio_file  # type: ignore[no-redef]

    # Normalise to valid JPEG before sending (handles PNG, WebP, HEIC, etc.)
    person_bytes = _ensure_jpeg(person_bytes)
    garment_bytes = _ensure_jpeg(garment_bytes)

    hf_token = os.environ.get('HF_TOKEN', None)

    # Save to temp files (gradio_client requires file paths, not raw bytes)
    with tempfile.NamedTemporaryFile(suffix='.jpg', delete=False) as person_f:
        person_f.write(person_bytes)
        person_path = person_f.name

    with tempfile.NamedTemporaryFile(suffix='.jpg', delete=False) as garment_f:
        garment_f.write(garment_bytes)
        garment_path = garment_f.name

    try:
        logger.info('Connecting to IDM-VTON API...')
        client = Client("yisol/IDM-VTON", hf_token=hf_token)

        MAX_PREDICT_ATTEMPTS = 3
        last_error = None

        for attempt in range(MAX_PREDICT_ATTEMPTS):
            try:
                logger.info(f'Sending try-on request to IDM-VTON (attempt {attempt + 1})...')
                result = client.predict(
                    dict={
                        "background": _gradio_file(person_path),
                        "layers": [],
                        "composite": None,
                    },
                    garm_img=_gradio_file(garment_path),
                    garment_des=garment_description,
                    is_checked=True,        # Use auto-generated mask
                    is_checked_crop=False,  # Don't auto-crop
                    denoise_steps=30,
                    seed=42,
                    api_name="/tryon",
                )

                logger.info(f'IDM-VTON raw result: {result!r}')
                image_bytes = _resolve_result(result[0], hf_token)
                result_img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
                buf = io.BytesIO()
                result_img.save(buf, format='JPEG', quality=92)
                logger.info('IDM-VTON try-on image generated successfully')
                return buf.getvalue()

            except Exception as e:
                last_error = e
                err_msg = str(e)
                logger.warning(f'IDM-VTON attempt {attempt + 1} failed: {err_msg}')

                # 404 means the Space processed OK but the result file expired.
                # Try downloading the URL directly from the error message.
                if '404' in err_msg:
                    file_url = _extract_url_from_error(err_msg)
                    if file_url:
                        logger.info(f'Attempting direct download of expired result: {file_url}')
                        try:
                            image_bytes = _download_url(file_url, hf_token)
                            result_img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
                            buf = io.BytesIO()
                            result_img.save(buf, format='JPEG', quality=92)
                            logger.info('Direct download of result succeeded')
                            return buf.getvalue()
                        except Exception as dl_err:
                            logger.warning(f'Direct download also failed: {dl_err}')

                # If not the last attempt, wait and retry the full prediction
                if attempt < MAX_PREDICT_ATTEMPTS - 1:
                    wait = 15 * (attempt + 1)
                    logger.info(f'Retrying prediction in {wait}s...')
                    time.sleep(wait)
                    continue

        raise last_error

    finally:
        for path in [person_path, garment_path]:
            try:
                os.unlink(path)
            except OSError:
                pass


def _get_garment_description(garment_item) -> str:
    """
    Build a text description of the garment from its metadata.
    """
    parts = []

    if garment_item.primary_color:
        parts.append(garment_item.primary_color)

    if garment_item.name and garment_item.name.lower() not in ['unknown', 'none', '']:
        parts.append(garment_item.name)

    if garment_item.category:
        category_map = {
            'top': 'top shirt',
            'bottom': 'pants trousers',
            'dress': 'dress',
            'outerwear': 'jacket coat outerwear',
            'activewear': 'activewear sportswear',
            'swimwear': 'swimwear',
            'formal': 'formal wear suit',
            'traditional': 'traditional clothing',
        }
        parts.append(category_map.get(garment_item.category, garment_item.category))

    if garment_item.subcategory:
        parts.append(garment_item.subcategory)

    description = ' '.join(parts).strip()
    return description if description else 'clothing garment'


@shared_task(bind=True, max_retries=2, time_limit=600)
def run_virtual_tryon(self, tryon_id: str):
    """
    Execute virtual try-on using IDM-VTON via Hugging Face Gradio API.

    Steps:
    1. Download person image and garment image from S3
    2. Build garment description from metadata
    3. Call IDM-VTON API for realistic try-on
    4. Upload result to S3
    5. Update database
    """
    from apps.tryon.models import TryOnResult
    from common.s3_utils import download_from_s3, upload_to_s3, build_tryon_result_s3_key

    start_time = time.time()

    try:
        tryon = TryOnResult.objects.select_related('garment_item').get(id=tryon_id)

        # Update status to processing
        tryon.status = 'processing'
        tryon.save(update_fields=['status'])
        _publish_status(tryon_id, 'processing', 5, 'downloading_images')

        # Step 1: Download images from S3
        logger.info(f'Try-on {tryon_id}: Downloading person image from S3...')
        person_bytes = download_from_s3(tryon.person_image_s3)

        # Find garment image - prefer cropped, fallback to original
        garment_image_record = None
        if tryon.garment_item:
            garment_image_record = (
                tryon.garment_item.images.filter(image_type='cropped').first()
                or tryon.garment_item.images.filter(image_type='original').first()
                or tryon.garment_item.images.first()
            )

        if not garment_image_record:
            raise ValueError('No garment image found for this item')

        logger.info(f'Try-on {tryon_id}: Downloading garment image from S3...')
        garment_bytes = download_from_s3(garment_image_record.s3_key)

        _publish_status(tryon_id, 'processing', 15, 'preparing_images')

        # Step 2: Build garment description
        garment_desc = _get_garment_description(tryon.garment_item)
        logger.info(f'Try-on {tryon_id}: Garment description: "{garment_desc}"')

        _publish_status(tryon_id, 'processing', 20, 'connecting_to_ai')

        # Step 3: Call IDM-VTON API
        logger.info(f'Try-on {tryon_id}: Calling IDM-VTON API...')
        _publish_status(tryon_id, 'processing', 30, 'generating_tryon')

        result_image = _call_idm_vton(
            person_bytes=person_bytes,
            garment_bytes=garment_bytes,
            garment_description=garment_desc,
        )

        logger.info(f'Try-on {tryon_id}: IDM-VTON result received ({len(result_image)} bytes)')
        _publish_status(tryon_id, 'processing', 85, 'uploading_result')

        # Step 4: Upload result to S3
        result_s3_key = build_tryon_result_s3_key(
            str(tryon.user_id), str(tryon_id)
        )
        upload_to_s3(result_s3_key, result_image)

        # Step 5: Update database
        elapsed_ms = int((time.time() - start_time) * 1000)
        tryon.result_image_s3 = result_s3_key
        tryon.status = 'completed'
        tryon.completed_at = timezone.now()
        tryon.processing_time_ms = elapsed_ms
        tryon.save()

        _publish_status(tryon_id, 'completed', 100, 'done')
        logger.info(f'Try-on {tryon_id} completed successfully in {elapsed_ms}ms')

    except Exception as e:
        logger.error(f'Try-on {tryon_id} failed: {e}', exc_info=True)
        try:
            tryon = TryOnResult.objects.get(id=tryon_id)
            tryon.status = 'failed'
            tryon.error_message = str(e)[:500]
            tryon.save(update_fields=['status', 'error_message'])
        except Exception:
            pass

        _publish_status(tryon_id, 'failed', 0, str(e))
        if self is not None:
            raise self.retry(exc=e)
        raise


def _publish_status(tryon_id: str, status: str, progress: int, step: str):
    """Publish try-on status to Redis for WebSocket delivery."""
    try:
        import redis
        from django.conf import settings

        r = redis.from_url(settings.REDIS_URL)
        channel = f'tryon:{tryon_id}'
        r.publish(channel, json.dumps({
            'status': status,
            'progress': progress,
            'step': step,
        }))
    except Exception as e:
        logger.debug(f'Failed to publish status: {e}')
