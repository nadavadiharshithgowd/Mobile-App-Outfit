import uuid
from django.db import models
from django.conf import settings
from apps.wardrobe.models import WardrobeItem


class TryOnResult(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name='tryon_results'
    )
    person_image_s3 = models.CharField(max_length=500)
    garment_item = models.ForeignKey(
        WardrobeItem, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='tryon_results'
    )
    result_image_s3 = models.CharField(max_length=500, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    error_message = models.TextField(blank=True)
    processing_time_ms = models.IntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'tryon_results'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user']),
            models.Index(
                fields=['status'],
                condition=models.Q(status__in=['pending', 'processing']),
                name='idx_tryon_active_status',
            ),
        ]

    def __str__(self):
        return f'TryOn {self.id} - {self.status} - {self.user.email}'
