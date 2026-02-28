"""
Color harmony scoring for outfit combinations.

Implements basic color theory rules:
- Complementary colors (opposite on color wheel)
- Analogous colors (adjacent on color wheel)
- Neutral + any color is always harmonious
"""

import colorsys
import logging

logger = logging.getLogger(__name__)

NEUTRAL_COLORS = {'black', 'white', 'gray', 'grey', 'beige', 'navy', 'cream', 'khaki'}


def compute_color_harmony_score(hex_colors: list) -> float:
    """
    Score the color harmony of a set of clothing items.

    Args:
        hex_colors: List of hex color strings (e.g., ['#FF5733', '#334455'])

    Returns:
        Float between 0 and 1 (higher = more harmonious)
    """
    if len(hex_colors) < 2:
        return 0.7

    try:
        hsvs = [_hex_to_hsv(h) for h in hex_colors]
        neutrals = [_is_neutral(hsv) for hsv in hsvs]

        # If all neutrals, great harmony
        if all(neutrals):
            return 0.9

        # If all but one is neutral, good harmony
        non_neutral_count = sum(1 for n in neutrals if not n)
        if non_neutral_count <= 1:
            return 0.85

        # Check harmony between non-neutral colors
        non_neutral_hsvs = [hsv for hsv, n in zip(hsvs, neutrals) if not n]
        return _score_hue_relationship(non_neutral_hsvs)

    except Exception as e:
        logger.debug(f'Color harmony calculation failed: {e}')
        return 0.5


def _hex_to_hsv(hex_color: str) -> tuple:
    """Convert hex color to HSV tuple."""
    h = hex_color.lstrip('#')
    r, g, b = tuple(int(h[i:i+2], 16) / 255.0 for i in (0, 2, 4))
    return colorsys.rgb_to_hsv(r, g, b)


def _is_neutral(hsv: tuple) -> bool:
    """Check if a color is neutral (low saturation)."""
    _, s, v = hsv
    return s < 0.15 or v < 0.15 or (v > 0.9 and s < 0.1)


def _score_hue_relationship(hsvs: list) -> float:
    """Score the hue relationship between non-neutral colors."""
    if len(hsvs) < 2:
        return 0.7

    hues = [h * 360 for h, _, _ in hsvs]
    scores = []

    for i in range(len(hues)):
        for j in range(i + 1, len(hues)):
            diff = abs(hues[i] - hues[j])
            if diff > 180:
                diff = 360 - diff

            # Complementary (180 +/- 30)
            if 150 <= diff <= 210:
                scores.append(0.85)
            # Analogous (0-30)
            elif diff <= 30:
                scores.append(0.80)
            # Triadic (120 +/- 20)
            elif 100 <= diff <= 140:
                scores.append(0.75)
            # Split complementary
            elif 140 <= diff <= 160:
                scores.append(0.70)
            # Clashing
            else:
                scores.append(0.40)

    return sum(scores) / len(scores) if scores else 0.5
