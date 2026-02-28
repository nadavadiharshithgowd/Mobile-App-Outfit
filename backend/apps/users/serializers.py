from rest_framework import serializers
from common.s3_utils import generate_presigned_download_url
from .models import User


class UserSerializer(serializers.ModelSerializer):
    profile_photo = serializers.SerializerMethodField()
    wardrobe_count = serializers.SerializerMethodField()
    outfit_count = serializers.SerializerMethodField()
    tryon_count = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            'id', 'email', 'full_name', 'profile_photo',
            'auth_provider', 'date_joined',
            'wardrobe_count', 'outfit_count', 'tryon_count',
        ]
        read_only_fields = ['id', 'email', 'auth_provider', 'date_joined']

    def get_profile_photo(self, obj):
        if obj.profile_photo:
            try:
                return generate_presigned_download_url(obj.profile_photo)
            except Exception:
                return None
        return None

    def get_wardrobe_count(self, obj):
        return obj.wardrobe_items.filter(is_active=True).count()

    def get_outfit_count(self, obj):
        return obj.outfits.count()

    def get_tryon_count(self, obj):
        return obj.tryon_results.count()


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['full_name']


class SendOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()


class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6, min_length=6)


class GoogleAuthSerializer(serializers.Serializer):
    id_token = serializers.CharField()


class AuthResponseSerializer(serializers.Serializer):
    access = serializers.CharField()
    refresh = serializers.CharField()
    user = UserSerializer()
