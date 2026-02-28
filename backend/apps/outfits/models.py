import uuid
from django.db import models
from django.conf import settings
from apps.wardrobe.models import WardrobeItem


class Outfit(models.Model):
    SOURCE_CHOICES = [
        ('manual', 'Manual'),
        ('ai_recommended', 'AI Recommended'),
        ('daily', 'Daily Suggestion'),
    ]

    OCCASION_CHOICES = [
        ('casual', 'Casual'),
        ('formal', 'Formal'),
        ('business', 'Business'),
        ('sport', 'Sport'),
        ('party', 'Party'),
        ('date', 'Date'),
        ('work', 'Work'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='outfits'
    )
    name = models.CharField(max_length=200, blank=True)
    occasion = models.CharField(max_length=50, choices=OCCASION_CHOICES, blank=True)
    season = models.CharField(max_length=20, blank=True)
    source = models.CharField(max_length=20, choices=SOURCE_CHOICES, default='manual')
    compatibility_score = models.FloatField(null=True, blank=True)
    is_favorite = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'outfits'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['user', 'source']),
        ]

    def __str__(self):
        return f'{self.name or "Outfit"} - {self.user.email}'


class OutfitItem(models.Model):
    SLOT_CHOICES = [
        ('top', 'Top'),
        ('bottom', 'Bottom'),
        ('dress', 'Dress'),
        ('shoes', 'Shoes'),
        ('outerwear', 'Outerwear'),
        ('accessory', 'Accessory'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    outfit = models.ForeignKey(
        Outfit, on_delete=models.CASCADE, related_name='items'
    )
    wardrobe_item = models.ForeignKey(
        WardrobeItem, on_delete=models.CASCADE, related_name='outfit_appearances'
    )
    slot = models.CharField(max_length=30, choices=SLOT_CHOICES)

    class Meta:
        db_table = 'outfit_items'
        unique_together = [('outfit', 'slot')]
        indexes = [
            models.Index(fields=['outfit']),
        ]


class DailyRecommendation(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='daily_recommendations'
    )
    outfit = models.ForeignKey(
        Outfit, on_delete=models.CASCADE, related_name='recommendations'
    )
    recommendation_date = models.DateField()
    rank = models.IntegerField(default=1)
    reason = models.TextField(blank=True)
    was_accepted = models.BooleanField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'daily_recommendations'
        unique_together = [('user', 'recommendation_date', 'rank')]
        ordering = ['rank']
        indexes = [
            models.Index(fields=['user', 'recommendation_date']),
        ]

    def __str__(self):
        return f'Rec #{self.rank} for {self.user.email} on {self.recommendation_date}'
