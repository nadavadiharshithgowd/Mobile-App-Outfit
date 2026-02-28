import random
import string
from datetime import timedelta

from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

from .models import User, OTPToken


def generate_otp() -> str:
    """Generate a random 6-digit OTP code."""
    return ''.join(random.choices(string.digits, k=settings.OTP_LENGTH))


def send_otp_email(email: str) -> OTPToken:
    """Generate OTP, save to DB, and send via email."""
    otp_code = generate_otp()
    expires_at = timezone.now() + timedelta(minutes=settings.OTP_EXPIRY_MINUTES)

    # Deactivate previous unused OTPs for this email
    OTPToken.objects.filter(email=email, is_used=False).update(is_used=True)

    # Get or create user
    user, _ = User.objects.get_or_create(
        email=email,
        defaults={'auth_provider': 'email'},
    )

    otp_token = OTPToken.objects.create(
        user=user,
        otp_code=otp_code,
        email=email,
        expires_at=expires_at,
    )

    # Send email
    send_mail(
        subject='Your Outfit Stylist Verification Code',
        message=f'Your verification code is: {otp_code}\n\nThis code expires in {settings.OTP_EXPIRY_MINUTES} minutes.',
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[email],
        fail_silently=False,
    )

    return otp_token


def verify_otp(email: str, otp_code: str) -> User:
    """Verify OTP code and return the user."""
    try:
        otp_token = OTPToken.objects.filter(
            email=email,
            otp_code=otp_code,
            is_used=False,
        ).latest('created_at')
    except OTPToken.DoesNotExist:
        raise ValueError('Invalid verification code')

    if otp_token.is_expired:
        raise ValueError('Verification code has expired')

    # Mark OTP as used
    otp_token.is_used = True
    otp_token.save(update_fields=['is_used'])

    # Get or create user
    user, _ = User.objects.get_or_create(
        email=email,
        defaults={'auth_provider': 'email'},
    )

    return user


def verify_google_token(token: str) -> dict:
    """Verify a Google ID token or access token and return user info."""
    # First try as ID token
    try:
        idinfo = id_token.verify_oauth2_token(
            token,
            google_requests.Request(),
            settings.GOOGLE_CLIENT_ID,
        )
        return {
            'google_id': idinfo['sub'],
            'email': idinfo['email'],
            'full_name': idinfo.get('name', ''),
            'profile_photo': idinfo.get('picture', ''),
        }
    except Exception:
        pass

    # Fallback: treat as access token (used by web Google Sign-In)
    try:
        import requests
        resp = requests.get(
            'https://www.googleapis.com/oauth2/v3/userinfo',
            headers={'Authorization': f'Bearer {token}'},
            timeout=10,
        )
        if resp.status_code == 200:
            userinfo = resp.json()
            return {
                'google_id': userinfo['sub'],
                'email': userinfo['email'],
                'full_name': userinfo.get('name', ''),
                'profile_photo': userinfo.get('picture', ''),
            }
        raise ValueError(f'Google userinfo API returned {resp.status_code}')
    except ValueError:
        raise
    except Exception as e:
        raise ValueError(f'Invalid Google token: {str(e)}')


def get_or_create_google_user(google_info: dict) -> User:
    """Get or create a user from Google sign-in info."""
    try:
        user = User.objects.get(google_id=google_info['google_id'])
        return user
    except User.DoesNotExist:
        pass

    try:
        user = User.objects.get(email=google_info['email'])
        user.google_id = google_info['google_id']
        user.auth_provider = 'google'
        if not user.full_name and google_info.get('full_name'):
            user.full_name = google_info['full_name']
        user.save()
        return user
    except User.DoesNotExist:
        pass

    return User.objects.create_user(
        email=google_info['email'],
        full_name=google_info.get('full_name', ''),
        profile_photo=google_info.get('profile_photo', ''),
        google_id=google_info['google_id'],
        auth_provider='google',
    )
