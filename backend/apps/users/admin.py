from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, OTPToken


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('email', 'full_name', 'auth_provider', 'is_active', 'date_joined')
    list_filter = ('auth_provider', 'is_active', 'is_staff')
    search_fields = ('email', 'full_name')
    ordering = ('-date_joined',)

    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('full_name', 'profile_photo')}),
        ('Auth', {'fields': ('auth_provider', 'google_id')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
        ('Dates', {'fields': ('date_joined',)}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2'),
        }),
    )


@admin.register(OTPToken)
class OTPTokenAdmin(admin.ModelAdmin):
    list_display = ('email', 'otp_code', 'is_used', 'expires_at', 'created_at')
    list_filter = ('is_used',)
    search_fields = ('email',)
