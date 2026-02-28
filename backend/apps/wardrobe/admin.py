from django.contrib import admin
from .models import WardrobeItem, WardrobeItemImage


class WardrobeItemImageInline(admin.TabularInline):
    model = WardrobeItemImage
    extra = 0
    readonly_fields = ('s3_key', 'image_type', 'created_at')


@admin.register(WardrobeItem)
class WardrobeItemAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'category', 'subcategory', 'primary_color', 'is_active', 'created_at')
    list_filter = ('category', 'season', 'is_active')
    search_fields = ('name', 'user__email', 'brand')
    inlines = [WardrobeItemImageInline]
    readonly_fields = ('clip_embedding', 'detection_data')
