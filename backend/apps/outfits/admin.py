from django.contrib import admin
from .models import Outfit, OutfitItem, DailyRecommendation


class OutfitItemInline(admin.TabularInline):
    model = OutfitItem
    extra = 0


@admin.register(Outfit)
class OutfitAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'source', 'compatibility_score', 'is_favorite', 'created_at')
    list_filter = ('source', 'is_favorite')
    search_fields = ('name', 'user__email')
    inlines = [OutfitItemInline]


@admin.register(DailyRecommendation)
class DailyRecommendationAdmin(admin.ModelAdmin):
    list_display = ('user', 'recommendation_date', 'rank', 'was_accepted')
    list_filter = ('recommendation_date', 'was_accepted')
    search_fields = ('user__email',)
