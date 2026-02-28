from django.conf import settings
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import (
    SendOTPSerializer,
    VerifyOTPSerializer,
    GoogleAuthSerializer,
    UserSerializer,
    UserUpdateSerializer,
)
from .services import send_otp_email, verify_otp, verify_google_token, get_or_create_google_user


def _get_tokens_for_user(user):
    """Generate JWT token pair for a user."""
    refresh = RefreshToken.for_user(user)
    return {
        'access': str(refresh.access_token),
        'refresh': str(refresh),
    }


@api_view(['POST'])
@permission_classes([AllowAny])
def send_otp_view(request):
    """Send OTP to the provided email address."""
    serializer = SendOTPSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    email = serializer.validated_data['email']
    try:
        send_otp_email(email)
        return Response(
            {'message': 'OTP sent', 'expires_in': 300},
            status=status.HTTP_200_OK,
        )
    except Exception as e:
        return Response(
            {'detail': str(e)},
            status=status.HTTP_400_BAD_REQUEST,
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def verify_otp_view(request):
    """Verify OTP and return JWT tokens."""
    serializer = VerifyOTPSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    try:
        user = verify_otp(
            email=serializer.validated_data['email'],
            otp_code=serializer.validated_data['otp'],
        )
        tokens = _get_tokens_for_user(user)
        user_data = UserSerializer(user).data
        return Response({
            **tokens,
            'user': user_data,
        })
    except ValueError as e:
        return Response(
            {'detail': str(e)},
            status=status.HTTP_400_BAD_REQUEST,
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def google_auth_view(request):
    """Authenticate via Google ID token."""
    serializer = GoogleAuthSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    try:
        google_info = verify_google_token(serializer.validated_data['id_token'])
        user = get_or_create_google_user(google_info)
        tokens = _get_tokens_for_user(user)
        user_data = UserSerializer(user).data
        return Response({
            **tokens,
            'user': user_data,
        })
    except ValueError as e:
        return Response(
            {'detail': str(e)},
            status=status.HTTP_400_BAD_REQUEST,
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def dev_register_view(request):
    """
    DEV-ONLY: Register with email + password (no OTP required).
    If the email already exists, the password is updated.
    Only available when DEBUG=True.
    """
    if not settings.DEBUG:
        return Response(
            {'detail': 'Not available in production.'},
            status=status.HTTP_403_FORBIDDEN,
        )

    from django.contrib.auth import get_user_model
    UserModel = get_user_model()

    email = request.data.get('email', '').strip().lower()
    password = request.data.get('password', '')

    if not email or not password:
        return Response(
            {'detail': 'email and password are required.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    user, created = UserModel.objects.get_or_create(email=email)
    user.set_password(password)
    user.is_active = True
    user.save(update_fields=['password', 'is_active'])

    tokens = _get_tokens_for_user(user)
    user_data = UserSerializer(user).data
    return Response(
        {**tokens, 'user': user_data, 'created': created},
        status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
    )


@api_view(['POST'])
@permission_classes([AllowAny])
def dev_login_view(request):
    """
    DEV-ONLY: Login with email + password directly (no OTP).
    If the credentials match DEV_TEST_EMAIL / DEV_TEST_PASSWORD from .env,
    the test account is auto-created on first use — no manual setup needed.
    Only available when DEBUG=True. Returns 403 in production.
    """
    if not settings.DEBUG:
        return Response(
            {'detail': 'Not available in production.'},
            status=status.HTTP_403_FORBIDDEN,
        )

    from django.contrib.auth import get_user_model
    import os
    UserModel = get_user_model()

    email = request.data.get('email', '').strip().lower()
    password = request.data.get('password', '')

    if not email or not password:
        return Response(
            {'detail': 'email and password are required.'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    # Auto-create the test account from .env on first login attempt
    test_email = os.environ.get('DEV_TEST_EMAIL', '').strip().lower()
    test_password = os.environ.get('DEV_TEST_PASSWORD', '')

    if test_email and test_password and email == test_email and password == test_password:
        user, _ = UserModel.objects.get_or_create(email=test_email)
        user.set_password(test_password)
        user.is_active = True
        user.save(update_fields=['password', 'is_active'])
    else:
        user = authenticate(request, username=email, password=password)
        if user is None:
            return Response(
                {'detail': 'Invalid email or password.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        if not user.is_active:
            return Response(
                {'detail': 'Account is disabled.'},
                status=status.HTTP_403_FORBIDDEN,
            )

    tokens = _get_tokens_for_user(user)
    user_data = UserSerializer(user).data
    return Response({**tokens, 'user': user_data})


@api_view(['GET', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
def me_view(request):
    """Get, update, or deactivate current user profile."""
    user = request.user

    if request.method == 'GET':
        return Response(UserSerializer(user).data)

    if request.method == 'PATCH':
        update_serializer = UserUpdateSerializer(user, data=request.data, partial=True)
        update_serializer.is_valid(raise_exception=True)
        update_serializer.save()
        return Response(UserSerializer(user).data)

    if request.method == 'DELETE':
        user.is_active = False
        user.save(update_fields=['is_active'])
        return Response(status=status.HTTP_204_NO_CONTENT)
