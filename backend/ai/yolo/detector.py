"""
YOLOv8-based clothing detection module.

Uses a YOLOv8 model (fine-tuned on fashion datasets like Fashionpedia or
DeepFashion) to detect and classify clothing items in images.

Usage:
    detector = ClothingDetector()
    detections = detector.detect(image)
    # Returns: [{"class": ("top", "tshirt"), "confidence": 0.94, "bbox": [x1,y1,x2,y2]}]
"""

import logging
from pathlib import Path
from PIL import Image
from django.conf import settings

logger = logging.getLogger(__name__)

# Mapping from YOLO class indices to (category, subcategory) pairs
CATEGORY_MAP = {
    0: ('top', 'tshirt'),
    1: ('top', 'shirt'),
    2: ('top', 'blouse'),
    3: ('bottom', 'jeans'),
    4: ('bottom', 'trousers'),
    5: ('bottom', 'shorts'),
    6: ('bottom', 'skirt'),
    7: ('dress', 'dress'),
    8: ('outerwear', 'jacket'),
    9: ('outerwear', 'coat'),
    10: ('outerwear', 'hoodie'),
    11: ('shoes', 'sneakers'),
    12: ('shoes', 'boots'),
    13: ('shoes', 'heels'),
    14: ('accessory', 'hat'),
    15: ('accessory', 'bag'),
    16: ('accessory', 'scarf'),
}


class ClothingDetector:
    """Detect clothing items in images using YOLOv8."""

    def __init__(self, model_path: str = None, confidence_threshold: float = 0.5):
        self.confidence_threshold = confidence_threshold
        self.model = None
        self._is_fashion_model = False  # True only when fashion-specific weights loaded
        self._model_path = model_path or getattr(
            settings, 'YOLO_MODEL_PATH', 'ai_models/yolo/weights/yolov8n-fashion.pt'
        )
        self._load_model()

    def _load_model(self):
        """Load the YOLO model. Falls back gracefully if not available."""
        try:
            from ultralytics import YOLO
            model_path = Path(self._model_path)
            if model_path.exists():
                self.model = YOLO(str(model_path))
                self._is_fashion_model = True
                logger.info(f'Loaded fashion YOLO model from {model_path}')
            else:
                # Pretrained YOLOv8n uses different class IDs (COCO, not fashion).
                # Do NOT load it for clothing detection — use fallback instead.
                logger.warning(
                    f'Fashion YOLO model not found at {model_path}. '
                    'AI detection will use fallback. '
                    'User-selected category will be preserved.'
                )
        except ImportError:
            logger.error('ultralytics not installed. YOLO detection disabled.')
        except Exception as e:
            logger.error(f'Failed to load YOLO model: {e}')

    def detect(self, image) -> list:
        """
        Detect clothing items in an image.

        Args:
            image: PIL Image or numpy array

        Returns:
            List of detections, each containing:
            - class: Tuple of (category, subcategory)
            - confidence: Detection confidence score
            - bbox: Bounding box [x1, y1, x2, y2]
        """
        if self.model is None or not self._is_fashion_model:
            logger.warning('Fashion YOLO model not loaded, returning fallback detection')
            return self._fallback_detection(image)

        try:
            results = self.model.predict(
                image,
                conf=self.confidence_threshold,
                verbose=False,
            )

            detections = []
            for box in results[0].boxes:
                cls_id = int(box.cls[0])
                confidence = float(box.conf[0])
                bbox = box.xyxy[0].tolist()

                # Map class to category
                category_info = CATEGORY_MAP.get(cls_id, ('top', 'unknown'))

                detections.append({
                    'class_id': cls_id,
                    'class': category_info,
                    'confidence': confidence,
                    'bbox': bbox,
                })

            if not detections:
                return self._fallback_detection(image)

            return detections

        except Exception as e:
            logger.error(f'YOLO detection failed: {e}')
            return self._fallback_detection(image)

    def _fallback_detection(self, image):
        """Fallback when YOLO model is unavailable or detection fails."""
        if isinstance(image, Image.Image):
            w, h = image.size
        else:
            h, w = image.shape[:2]

        return [{
            'class_id': -1,
            'class': ('top', 'unknown'),
            'confidence': 0.3,
            'bbox': [0, 0, w, h],
        }]
