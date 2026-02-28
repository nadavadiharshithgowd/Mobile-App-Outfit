"""
Preprocessing utilities for the virtual try-on pipeline.

Handles:
- DensePose body estimation
- Garment segmentation/masking
- Image resizing and normalization
"""

import io
import logging
import numpy as np
from PIL import Image

logger = logging.getLogger(__name__)

TARGET_SIZE = (768, 1024)  # Standard VTON input size


def estimate_densepose(image_bytes: bytes):
    """
    Estimate DensePose from a person image.

    In production, uses detectron2 with DensePose model.
    Returns body part segmentation and UV coordinates.

    Args:
        image_bytes: Person image as bytes

    Returns:
        DensePose result dict or None
    """
    try:
        # In production:
        # from detectron2.engine import DefaultPredictor
        # from densepose import add_densepose_config
        # predictor = DefaultPredictor(cfg)
        # outputs = predictor(image)
        # return extract_densepose(outputs)

        logger.info('DensePose estimation (stub) - returning None')
        return None

    except Exception as e:
        logger.error(f'DensePose estimation failed: {e}')
        return None


def segment_garment(image_bytes: bytes):
    """
    Segment the garment area from a person image.

    Creates a binary mask indicating the garment region
    that will be replaced during try-on.

    Args:
        image_bytes: Person image as bytes

    Returns:
        PIL Image mask or None
    """
    try:
        image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        w, h = image.size

        # Stub: create a simple torso mask
        mask = Image.new('L', (w, h), 0)
        pixels = mask.load()

        # Approximate torso region (center 60% width, 20-60% height)
        x_start = int(w * 0.2)
        x_end = int(w * 0.8)
        y_start = int(h * 0.15)
        y_end = int(h * 0.6)

        for y in range(y_start, y_end):
            for x in range(x_start, x_end):
                pixels[x, y] = 255

        logger.info('Garment segmentation (stub) - returning approximate mask')
        return mask

    except Exception as e:
        logger.error(f'Garment segmentation failed: {e}')
        return None


def resize_for_vton(image: Image.Image, target_size=TARGET_SIZE) -> Image.Image:
    """Resize image to standard VTON input size while maintaining aspect ratio."""
    image = image.convert('RGB')
    image.thumbnail(target_size, Image.LANCZOS)

    # Pad to exact size
    padded = Image.new('RGB', target_size, (255, 255, 255))
    offset = (
        (target_size[0] - image.size[0]) // 2,
        (target_size[1] - image.size[1]) // 2,
    )
    padded.paste(image, offset)
    return padded


def normalize_image(image: Image.Image) -> np.ndarray:
    """Normalize image to [-1, 1] range for model input."""
    arr = np.array(image).astype(np.float32) / 255.0
    arr = (arr - 0.5) / 0.5
    return arr
