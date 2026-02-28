from django.contrib import admin
from .models import TryOnResult


@admin.register(TryOnResult)
class TryOnResultAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'status', 'processing_time_ms', 'created_at', 'completed_at')
    list_filter = ('status',)
    search_fields = ('user__email',)
    readonly_fields = ('person_image_s3', 'result_image_s3', 'error_message')
