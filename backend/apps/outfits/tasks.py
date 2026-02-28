import logging
from datetime import date
from itertools import product as iterproduct
from common.task_utils import shared_task

logger = logging.getLogger(__name__)


@shared_task
def generate_all_daily_recommendations():
    """Generate daily recommendations for all active users. Called by Celery Beat."""
    from apps.users.models import User

    active_users = User.objects.filter(is_active=True)
    for user in active_users:
        wardrobe_count = user.wardrobe_items.filter(is_active=True).count()
        if wardrobe_count >= 3:  # Need at least 3 items
            from django.conf import settings
            if getattr(settings, 'USE_CELERY', False):
                generate_daily_recommendations.delay(str(user.id))
            else:
                generate_daily_recommendations(str(user.id))

    logger.info(f'Triggered recommendation generation for active users')


@shared_task(bind=True, max_retries=2)
def generate_daily_recommendations(self, user_id: str):
    """
    Generate 3 outfit suggestions for a user.
    Uses CLIP embeddings for compatibility scoring + color harmony.
    """
    from apps.wardrobe.models import WardrobeItem
    from apps.outfits.models import Outfit, OutfitItem, DailyRecommendation

    try:
        today = date.today()

        # Check if already generated today
        existing = DailyRecommendation.objects.filter(
            user_id=user_id,
            recommendation_date=today,
        ).count()
        if existing > 0:
            # Clear existing for regeneration
            DailyRecommendation.objects.filter(
                user_id=user_id,
                recommendation_date=today,
            ).delete()

        # Fetch active wardrobe items
        items = list(
            WardrobeItem.objects.filter(
                user_id=user_id,
                is_active=True,
            )
        )

        if len(items) < 2:
            logger.info(f'User {user_id} has too few items for recommendations')
            return

        # Group by category
        tops = [i for i in items if i.category in ('top', 'outerwear')]
        bottoms = [i for i in items if i.category == 'bottom']
        shoes = [i for i in items if i.category == 'shoes']
        dresses = [i for i in items if i.category == 'dress']

        candidates = []

        # Generate top + bottom + shoes combos
        for top, bottom in iterproduct(tops, bottoms):
            score = _compute_outfit_score(top, bottom)
            items_list = [
                (top, 'top'),
                (bottom, 'bottom'),
            ]
            if shoes:
                shoe = shoes[0]  # Pick first shoe for simplicity
                items_list.append((shoe, 'shoes'))
                score = _compute_outfit_score(top, bottom, shoe)

            candidates.append({
                'items': items_list,
                'score': score,
                'reason': _generate_reason(top, bottom),
            })

        # Generate dress + shoes combos
        for dress in dresses:
            items_list = [(dress, 'dress')]
            score = 0.75  # Base score for single-item outfit
            if shoes:
                shoe = shoes[0]
                items_list.append((shoe, 'shoes'))
                score = _compute_outfit_score(dress, shoe)

            candidates.append({
                'items': items_list,
                'score': score,
                'reason': f'Elegant {dress.primary_color or ""} dress look',
            })

        if not candidates:
            logger.info(f'No outfit candidates for user {user_id}')
            return

        # Sort by score and pick top 3 diverse outfits
        candidates.sort(key=lambda c: c['score'], reverse=True)
        selected = candidates[:3]

        # Create outfit and recommendation records
        for rank, candidate in enumerate(selected, 1):
            outfit = Outfit.objects.create(
                user_id=user_id,
                source='daily',
                compatibility_score=candidate['score'],
                name=f'Daily Pick #{rank}',
            )

            for item, slot in candidate['items']:
                OutfitItem.objects.create(
                    outfit=outfit,
                    wardrobe_item=item,
                    slot=slot,
                )

            DailyRecommendation.objects.create(
                user_id=user_id,
                outfit=outfit,
                recommendation_date=today,
                rank=rank,
                reason=candidate['reason'],
            )

        logger.info(f'Generated {len(selected)} recommendations for user {user_id}')

    except Exception as e:
        logger.error(f'Failed to generate recommendations for {user_id}: {e}')
        if self is not None:
            raise self.retry(exc=e)
        raise


def _compute_outfit_score(*items):
    """
    Score an outfit combination.
    Uses CLIP embedding similarity + color harmony.
    """
    import numpy as np

    embeddings = [i.clip_embedding for i in items if i.clip_embedding]

    clip_score = 0.5  # Default
    if len(embeddings) >= 2:
        try:
            # Pairwise cosine similarity
            similarities = []
            for i in range(len(embeddings)):
                for j in range(i + 1, len(embeddings)):
                    a = np.array(embeddings[i])
                    b = np.array(embeddings[j])
                    sim = np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
                    similarities.append(float(sim))
            clip_score = sum(similarities) / len(similarities)
        except Exception:
            clip_score = 0.5

    # Color harmony bonus
    colors = [i.color_hex for i in items if i.color_hex]
    color_score = _color_harmony_score(colors) if colors else 0.5

    # Season match
    from datetime import date
    current_month = date.today().month
    season_map = {1: 'winter', 2: 'winter', 3: 'spring', 4: 'spring',
                  5: 'spring', 6: 'summer', 7: 'summer', 8: 'summer',
                  9: 'fall', 10: 'fall', 11: 'fall', 12: 'winter'}
    current_season = season_map.get(current_month, 'all')

    season_scores = []
    for item in items:
        if item.season in (current_season, 'all'):
            season_scores.append(1.0)
        else:
            season_scores.append(0.3)
    season_score = sum(season_scores) / len(season_scores) if season_scores else 0.5

    # Weighted combination
    final_score = (0.50 * clip_score + 0.30 * color_score + 0.20 * season_score)
    return round(min(max(final_score, 0), 1), 3)


def _color_harmony_score(hex_colors):
    """Simple color harmony scoring."""
    if len(hex_colors) < 2:
        return 0.7

    try:
        rgbs = []
        for h in hex_colors:
            h = h.lstrip('#')
            rgbs.append(tuple(int(h[i:i+2], 16) for i in (0, 2, 4)))

        # Neutral colors (black, white, gray, beige) go with everything
        neutral_count = 0
        for r, g, b in rgbs:
            if max(r, g, b) - min(r, g, b) < 30:  # Low saturation = neutral
                neutral_count += 1

        if neutral_count >= len(rgbs) - 1:
            return 0.85  # At most one non-neutral = good harmony

        return 0.6  # Default for non-neutral combos

    except Exception:
        return 0.5


def _generate_reason(item1, item2):
    """Generate a human-readable reason for the outfit suggestion."""
    reasons = []

    if item1.primary_color and item2.primary_color:
        reasons.append(f'{item1.primary_color.title()} and {item2.primary_color.title()} pairing')

    if item1.season == item2.season and item1.season != 'all':
        reasons.append(f'Perfect for {item1.season}')
    else:
        reasons.append('Versatile everyday look')

    return ' - '.join(reasons) if reasons else 'Great outfit combination'
