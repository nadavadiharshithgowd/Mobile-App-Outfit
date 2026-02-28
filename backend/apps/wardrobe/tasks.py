import io
import logging
from common.task_utils import shared_task
from PIL import Image

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=30)
def process_wardrobe_upload(self, wardrobe_item_id: str, s3_key: str):
    """
    Full processing pipeline for a newly uploaded wardrobe image.
    Steps:
    1. Download image from S3
    2. Run YOLO detection (clothing type, bounding box)
    3. Crop detected garment
    4. Generate CLIP embedding
    5. Extract dominant colors
    6. Update database with results
    """
    from apps.wardrobe.models import WardrobeItem, WardrobeItemImage
    from common.s3_utils import download_from_s3, upload_to_s3

    try:
        logger.info(f'Processing wardrobe item {wardrobe_item_id}')

        # Step 1: Download image from S3
        image_bytes = download_from_s3(s3_key)
        image = Image.open(io.BytesIO(image_bytes))

        # Step 2: YOLO detection
        try:
            from ai.yolo.detector import ClothingDetector
            detector = ClothingDetector()
            detections = detector.detect(image)
        except Exception as e:
            logger.warning(f'YOLO detection failed: {e}, using defaults')
            detections = [{'class': ('top', 'unknown'), 'confidence': 0.5, 'bbox': None}]

        # Get best detection
        # class_id == -1 means fallback (no real model output) — don't trust it
        if detections:
            best = max(detections, key=lambda d: d.get('confidence', 0))
            is_fallback = best.get('class_id', -1) == -1
            category, subcategory = best.get('class', ('top', 'unknown'))
        else:
            is_fallback = True
            category, subcategory = None, 'unknown'

        # Step 3: Crop (if bbox available)
        cropped = image
        if detections and detections[0].get('bbox'):
            bbox = detections[0]['bbox']
            try:
                cropped = image.crop([int(b) for b in bbox])
            except Exception:
                cropped = image

        # Step 4: Generate thumbnails and upload
        # Thumbnail
        thumb = cropped.copy()
        thumb.thumbnail((256, 256), Image.LANCZOS)
        thumb_buffer = io.BytesIO()
        thumb.save(thumb_buffer, format='JPEG', quality=85)
        thumb_key = s3_key.replace('original', 'thumbnail')
        upload_to_s3(thumb_key, thumb_buffer.getvalue())

        # Cropped
        crop_buffer = io.BytesIO()
        cropped_resized = cropped.copy()
        cropped_resized.thumbnail((512, 512), Image.LANCZOS)
        cropped_resized.save(crop_buffer, format='JPEG', quality=90)
        crop_key = s3_key.replace('original', 'cropped')
        upload_to_s3(crop_key, crop_buffer.getvalue())

        # Step 5: CLIP embedding
        clip_embedding = None
        try:
            from ai.clip.embedder import FashionEmbedder
            embedder = FashionEmbedder()
            clip_embedding = embedder.encode_image(cropped).tolist()
        except Exception as e:
            logger.warning(f'CLIP embedding failed: {e}')

        # Step 6: Color extraction
        primary_color, color_hex = _extract_dominant_color(cropped)

        # Step 7: Update database
        # Only overwrite category when YOLO actually detected a garment confidently.
        # When is_fallback is True the user-provided category set at upload time is kept.
        update_fields = dict(
            subcategory=subcategory,
            primary_color=primary_color,
            color_hex=color_hex,
            clip_embedding=clip_embedding,
            detection_data=detections,
            name=f'{_capitalize(primary_color)} {_capitalize(subcategory)}' if primary_color else _capitalize(subcategory),
        )
        if not is_fallback and category:
            update_fields['category'] = category

        WardrobeItem.objects.filter(id=wardrobe_item_id).update(**update_fields)

        # Create additional image records
        WardrobeItemImage.objects.bulk_create([
            WardrobeItemImage(
                wardrobe_item_id=wardrobe_item_id,
                s3_key=crop_key,
                image_type='cropped',
            ),
            WardrobeItemImage(
                wardrobe_item_id=wardrobe_item_id,
                s3_key=thumb_key,
                image_type='thumbnail',
            ),
        ])

        logger.info(f'Successfully processed wardrobe item {wardrobe_item_id}')

    except Exception as e:
        logger.error(f'Failed to process wardrobe item {wardrobe_item_id}: {e}')
        if self is not None:
            raise self.retry(exc=e)
        raise


def _extract_dominant_color(image):
    """Extract dominant color from image using simple averaging."""
    try:
        img = image.convert('RGB').resize((50, 50))
        pixels = list(img.getdata())

        r = sum(p[0] for p in pixels) // len(pixels)
        g = sum(p[1] for p in pixels) // len(pixels)
        b = sum(p[2] for p in pixels) // len(pixels)

        color_hex = f'#{r:02x}{g:02x}{b:02x}'
        color_name = _hex_to_name(r, g, b)

        return color_name, color_hex
    except Exception:
        return 'unknown', '#808080'


def _hex_to_name(r, g, b):
    """Simple color naming based on RGB values."""
    colors = {
        'white': (255, 255, 255),
        'black': (0, 0, 0),
        'red': (255, 0, 0),
        'blue': (0, 0, 255),
        'green': (0, 128, 0),
        'yellow': (255, 255, 0),
        'orange': (255, 165, 0),
        'purple': (128, 0, 128),
        'pink': (255, 192, 203),
        'brown': (139, 69, 19),
        'gray': (128, 128, 128),
        'navy': (0, 0, 128),
        'beige': (245, 245, 220),
    }
    min_dist = float('inf')
    closest = 'unknown'
    for name, (cr, cg, cb) in colors.items():
        dist = (r - cr) ** 2 + (g - cg) ** 2 + (b - cb) ** 2
        if dist < min_dist:
            min_dist = dist
            closest = name
    return closest


def _capitalize(s):
    return s[0].upper() + s[1:] if s else s
