import uuid
from django.db import models
from django.conf import settings


class WardrobeItem(models.Model):
    CATEGORY_CHOICES = [
        ('top', 'Top'),
        ('bottom', 'Bottom'),
        ('dress', 'Dress'),
        ('outerwear', 'Outerwear'),
        ('shoes', 'Shoes'),
        ('accessory', 'Accessory'),
    ]

    SEASON_CHOICES = [
        ('spring', 'Spring'),
        ('summer', 'Summer'),
        ('fall', 'Fall'),
        ('winter', 'Winter'),
        ('all', 'All Seasons'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='wardrobe_items'
    )
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    subcategory = models.CharField(max_length=80, blank=True)
    primary_color = models.CharField(max_length=30, blank=True)
    secondary_color = models.CharField(max_length=30, blank=True)
    color_hex = models.CharField(max_length=7, blank=True)
    brand = models.CharField(max_length=100, blank=True)
    name = models.CharField(max_length=200, blank=True)
    season = models.CharField(max_length=20, choices=SEASON_CHOICES, default='all')
    # CLIP embedding stored as JSON array (for pgvector, use a custom field)
    clip_embedding = models.JSONField(null=True, blank=True)
    detection_data = models.JSONField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'wardrobe_items'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'is_active']),
            models.Index(fields=['user', 'category']),
        ]

    def __str__(self):
        return f'{self.name or self.category} - {self.user.email}'


class WardrobeItemImage(models.Model):
    IMAGE_TYPE_CHOICES = [
        ('original', 'Original'),
        ('cropped', 'Cropped'),
        ('thumbnail', 'Thumbnail'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wardrobe_item = models.ForeignKey(
        WardrobeItem, on_delete=models.CASCADE, related_name='images'
    )
    s3_key = models.CharField(max_length=500)
    image_type = models.CharField(
        max_length=20, choices=IMAGE_TYPE_CHOICES, default='original'
    )
    width = models.IntegerField(null=True, blank=True)
    height = models.IntegerField(null=True, blank=True)
    file_size_bytes = models.IntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'wardrobe_item_images'
        indexes = [
            models.Index(fields=['wardrobe_item']),
        ]

    def __str__(self):
        return f'{self.image_type} - {self.wardrobe_item}'
