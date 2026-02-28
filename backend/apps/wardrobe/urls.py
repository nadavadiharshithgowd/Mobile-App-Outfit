from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('wardrobe', views.WardrobeViewSet, basename='wardrobe')

urlpatterns = [
    path('upload/presigned-url/', views.presigned_url_view, name='presigned-url'),
    path('upload/confirm/', views.confirm_upload_view, name='confirm-upload'),
    path('', include(router.urls)),
]
