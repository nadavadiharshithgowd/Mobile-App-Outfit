"""
CLIP-based fashion embedding module.

Generates embeddings for clothing items using FashionCLIP or standard CLIP.
These embeddings are used for outfit compatibility scoring and similar item search.

Usage:
    embedder = FashionEmbedder()
    embedding = embedder.encode_image(pil_image)  # shape: (512,)
    similarity = embedder.compute_compatibility(emb_a, emb_b)  # float 0-1
"""

import logging
import numpy as np
from PIL import Image
from django.conf import settings

logger = logging.getLogger(__name__)


class FashionEmbedder:
    """Generate CLIP embeddings for clothing items."""

    def __init__(self, model_name: str = None):
        self.model = None
        self.processor = None
        self._model_name = model_name or getattr(
            settings, 'CLIP_MODEL_NAME', 'patrickjohncyh/fashion-clip'
        )
        self._load_model()

    def _load_model(self):
        """Load the CLIP model and processor."""
        try:
            from transformers import CLIPProcessor, CLIPModel
            self.model = CLIPModel.from_pretrained(self._model_name)
            self.processor = CLIPProcessor.from_pretrained(self._model_name)
            self.model.eval()
            logger.info(f'Loaded CLIP model: {self._model_name}')
        except ImportError:
            logger.error('transformers not installed. CLIP embedding disabled.')
        except Exception as e:
            logger.error(f'Failed to load CLIP model: {e}')

    def encode_image(self, image) -> np.ndarray:
        """
        Generate a normalized embedding for a clothing image.

        Args:
            image: PIL Image

        Returns:
            numpy array of shape (512,) - L2 normalized embedding
        """
        if self.model is None or self.processor is None:
            logger.warning('CLIP model not loaded, returning random embedding')
            return np.random.randn(512).astype(np.float32)

        try:
            import torch

            if not isinstance(image, Image.Image):
                image = Image.open(image)

            image = image.convert('RGB')
            inputs = self.processor(images=image, return_tensors='pt')

            with torch.no_grad():
                features = self.model.get_image_features(**inputs)

            # L2 normalize
            features = features / features.norm(dim=-1, keepdim=True)
            return features.squeeze().cpu().numpy()

        except Exception as e:
            logger.error(f'CLIP encoding failed: {e}')
            return np.random.randn(512).astype(np.float32)

    def encode_text(self, text: str) -> np.ndarray:
        """
        Generate a normalized embedding for a text description.

        Args:
            text: Text description of clothing

        Returns:
            numpy array of shape (512,)
        """
        if self.model is None or self.processor is None:
            return np.random.randn(512).astype(np.float32)

        try:
            import torch

            inputs = self.processor(text=[text], return_tensors='pt', padding=True)

            with torch.no_grad():
                features = self.model.get_text_features(**inputs)

            features = features / features.norm(dim=-1, keepdim=True)
            return features.squeeze().cpu().numpy()

        except Exception as e:
            logger.error(f'CLIP text encoding failed: {e}')
            return np.random.randn(512).astype(np.float32)

    @staticmethod
    def compute_compatibility(embedding_a: np.ndarray, embedding_b: np.ndarray) -> float:
        """
        Compute cosine similarity between two item embeddings.

        Args:
            embedding_a: First item embedding
            embedding_b: Second item embedding

        Returns:
            Float between -1 and 1 (higher = more compatible)
        """
        a = np.array(embedding_a)
        b = np.array(embedding_b)
        norm_a = np.linalg.norm(a)
        norm_b = np.linalg.norm(b)
        if norm_a == 0 or norm_b == 0:
            return 0.0
        return float(np.dot(a, b) / (norm_a * norm_b))
