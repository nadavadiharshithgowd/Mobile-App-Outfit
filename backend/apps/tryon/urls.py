from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('tryon', views.TryOnViewSet, basename='tryon')

urlpatterns = [
    path('', include(router.urls)),
]
