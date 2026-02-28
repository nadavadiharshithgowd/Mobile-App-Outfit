"""
Outfit recommendation engine.

Combines CLIP embedding compatibility, color harmony, style rules,
and seasonal appropriateness to score and rank outfit combinations.

Usage:
    engine = OutfitRecommendationEngine()
    score = engine.score_outfit([top_item, bottom_item, shoe_item])
    suggestions = engine.generate_suggestions(wardrobe_items, count=3)
"""

import logging
import numpy as np
from datetime import date
from itertools import product as iterproduct

from .color_harmony import compute_color_harmony_score
from .style_rules import is_valid_combination

logger = logging.getLogger(__name__)

SEASON_MAP = {
    1: 'winter', 2: 'winter', 3: 'spring', 4: 'spring',
    5: 'spring', 6: 'summer', 7: 'summer', 8: 'summer',
    9: 'fall', 10: 'fall', 11: 'fall', 12: 'winter',
}


class OutfitRecommendationEngine:
    """Score and rank outfit combinations."""

    def __init__(self, weights=None):
        self.weights = weights or {
            'clip': 0.50,
            'color': 0.25,
            'season': 0.15,
            'variety': 0.10,
        }

    def score_outfit(self, items, recently_worn_ids=None) -> float:
        """
        Score an outfit combination.

        Args:
            items: List of WardrobeItem objects
            recently_worn_ids: Set of recently worn item IDs to penalize

        Returns:
            Float between 0 and 1
        """
        if not items:
            return 0.0

        # CLIP compatibility
        clip_score = self._clip_compatibility_score(items)

        # Color harmony
        colors = [i.color_hex for i in items if i.color_hex]
        color_score = compute_color_harmony_score(colors) if colors else 0.5

        # Season appropriateness
        season_score = self._season_score(items)

        # Variety penalty (avoid recently worn items)
        variety_score = 1.0
        if recently_worn_ids:
            worn_count = sum(1 for i in items if i.id in recently_worn_ids)
            variety_score = max(0.3, 1.0 - (worn_count * 0.3))

        final = (
            self.weights['clip'] * clip_score +
            self.weights['color'] * color_score +
            self.weights['season'] * season_score +
            self.weights['variety'] * variety_score
        )

        return round(min(max(final, 0), 1), 3)

    def generate_suggestions(self, items, count=3, recently_worn_ids=None):
        """
        Generate top outfit suggestions from a wardrobe.

        Args:
            items: List of all WardrobeItem objects
            count: Number of suggestions to generate
            recently_worn_ids: Set of recently worn item IDs

        Returns:
            List of dicts with 'items', 'slots', 'score', 'reason'
        """
        by_category = {}
        for item in items:
            by_category.setdefault(item.category, []).append(item)

        tops = by_category.get('top', []) + by_category.get('outerwear', [])
        bottoms = by_category.get('bottom', [])
        shoes = by_category.get('shoes', [])
        dresses = by_category.get('dress', [])

        candidates = []

        # Top + Bottom combos
        for top, bottom in iterproduct(tops[:10], bottoms[:10]):
            combo_items = [top, bottom]
            combo_slots = ['top', 'bottom']
            if shoes:
                combo_items.append(shoes[0])
                combo_slots.append('shoes')

            if not is_valid_combination(combo_items):
                continue

            score = self.score_outfit(combo_items, recently_worn_ids)
            candidates.append({
                'items': combo_items,
                'slots': combo_slots,
                'score': score,
                'reason': self._generate_reason(combo_items),
            })

        # Dress combos
        for dress in dresses[:5]:
            combo_items = [dress]
            combo_slots = ['dress']
            if shoes:
                combo_items.append(shoes[0])
                combo_slots.append('shoes')

            score = self.score_outfit(combo_items, recently_worn_ids)
            candidates.append({
                'items': combo_items,
                'slots': combo_slots,
                'score': score,
                'reason': f'Elegant {dress.primary_color or ""} dress look',
            })

        # Sort and pick diverse top-k
        candidates.sort(key=lambda c: c['score'], reverse=True)
        return self._select_diverse(candidates, count)

    def _clip_compatibility_score(self, items) -> float:
        """Compute average pairwise CLIP similarity."""
        embeddings = [i.clip_embedding for i in items if i.clip_embedding]
        if len(embeddings) < 2:
            return 0.5

        try:
            similarities = []
            for i in range(len(embeddings)):
                for j in range(i + 1, len(embeddings)):
                    a = np.array(embeddings[i])
                    b = np.array(embeddings[j])
                    sim = np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
                    similarities.append(float(sim))
            return sum(similarities) / len(similarities)
        except Exception:
            return 0.5

    def _season_score(self, items) -> float:
        """Check if items match current season."""
        current_season = SEASON_MAP.get(date.today().month, 'all')
        scores = []
        for item in items:
            if item.season in (current_season, 'all'):
                scores.append(1.0)
            else:
                scores.append(0.3)
        return sum(scores) / len(scores) if scores else 0.5

    def _generate_reason(self, items) -> str:
        """Generate human-readable suggestion reason."""
        colors = [i.primary_color for i in items if i.primary_color]
        if len(colors) >= 2:
            return f'{colors[0].title()} & {colors[1].title()} combination'
        elif colors:
            return f'Stylish {colors[0].title()} look'
        return 'Great outfit combination'

    def _select_diverse(self, candidates, count):
        """Select diverse candidates (avoid repeating items)."""
        selected = []
        used_items = set()

        for candidate in candidates:
            item_ids = {str(i.id) for i in candidate['items']}
            # Allow some overlap but not complete overlap
            overlap = len(item_ids & used_items)
            if overlap < len(item_ids):
                selected.append(candidate)
                used_items.update(item_ids)
                if len(selected) >= count:
                    break

        return selected
