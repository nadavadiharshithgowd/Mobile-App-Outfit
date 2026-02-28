import uuid
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.db import models
from django.utils import timezone
from .managers import UserManager


class User(AbstractBaseUser, PermissionsMixin):
    AUTH_PROVIDER_CHOICES = [
        ('email', 'Email'),
        ('google', 'Google'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=150, blank=True)
    profile_photo = models.CharField(max_length=500, blank=True)
    auth_provider = models.CharField(
        max_length=20, choices=AUTH_PROVIDER_CHOICES, default='email'
    )
    google_id = models.CharField(max_length=255, unique=True, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    class Meta:
        db_table = 'users'
        ordering = ['-date_joined']

    def __str__(self):
        return self.email


class OTPToken(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        User, on_delete=models.CASCADE, null=True, blank=True,
        related_name='otp_tokens'
    )
    otp_code = models.CharField(max_length=6)
    email = models.EmailField()
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'otp_tokens'
        indexes = [
            models.Index(fields=['email', 'is_used']),
        ]

    def __str__(self):
        return f'OTP for {self.email}'

    @property
    def is_expired(self):
        return timezone.now() > self.expires_at
