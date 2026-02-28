"""
Style rules for outfit validation.

Defines which clothing category combinations make valid outfits
and basic style compatibility rules.
"""

# Valid outfit slot combinations
VALID_COMBINATIONS = [
    {'top', 'bottom'},
    {'top', 'bottom', 'shoes'},
    {'top', 'bottom', 'shoes', 'outerwear'},
    {'top', 'bottom', 'shoes', 'accessory'},
    {'dress'},
    {'dress', 'shoes'},
    {'dress', 'shoes', 'outerwear'},
    {'dress', 'shoes', 'accessory'},
]

# Categories that conflict (can't wear both)
CONFLICTING_CATEGORIES = [
    ('dress', 'top'),
    ('dress', 'bottom'),
]


def is_valid_combination(items) -> bool:
    """
    Check if a set of items forms a valid outfit combination.

    Args:
        items: List of WardrobeItem objects

    Returns:
        True if the combination is valid
    """
    categories = {item.category for item in items}

    # Check for conflicts
    for cat_a, cat_b in CONFLICTING_CATEGORIES:
        if cat_a in categories and cat_b in categories:
            return False

    # Dress-based outfits shouldn't have separate top/bottom
    if 'dress' in categories and ('top' in categories or 'bottom' in categories):
        return False

    return True


def get_required_slots(has_dress: bool = False) -> list:
    """Get the required slots for a complete outfit."""
    if has_dress:
        return ['dress', 'shoes']
    return ['top', 'bottom', 'shoes']


def get_optional_slots() -> list:
    """Get optional slots that can enhance an outfit."""
    return ['outerwear', 'accessory']
