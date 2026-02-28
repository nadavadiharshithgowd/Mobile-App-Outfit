from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/auth/', include('apps.users.urls')),
    path('api/v1/', include('apps.wardrobe.urls')),
    path('api/v1/', include('apps.outfits.urls')),
    path('api/v1/', include('apps.tryon.urls')),
]
