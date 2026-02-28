from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('outfits', views.OutfitViewSet, basename='outfit')

urlpatterns = [
    path('recommendations/daily/', views.daily_recommendation_view, name='daily-recommendations'),
    path('recommendations/generate/', views.generate_recommendation_view, name='generate-recommendations'),
    path('recommendations/<uuid:pk>/accept/', views.accept_recommendation_view, name='accept-recommendation'),
    path('recommendations/<uuid:pk>/reject/', views.reject_recommendation_view, name='reject-recommendation'),
    path('', include(router.urls)),
]
