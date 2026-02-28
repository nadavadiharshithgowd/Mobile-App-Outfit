from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path('email/send-otp/', views.send_otp_view, name='send-otp'),
    path('email/verify-otp/', views.verify_otp_view, name='verify-otp'),
    path('google/', views.google_auth_view, name='google-auth'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('me/', views.me_view, name='me'),
    # DEV ONLY — direct email+password login/register (disabled in production)
    path('dev-login/', views.dev_login_view, name='dev-login'),
    path('dev-register/', views.dev_register_view, name='dev-register'),
]
