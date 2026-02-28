from rest_framework import serializers
from common.s3_utils import generate_presigned_download_url
from .models import WardrobeItem, WardrobeItemImage


class WardrobeItemImageSerializer(serializers.ModelSerializer):
    url = serializers.SerializerMethodField()

    class Meta:
        model = WardrobeItemImage
        fields = ['id', 'url', 'image_type', 'width', 'height']

    def get_url(self, obj):
        try:
            return generate_presigned_download_url(obj.s3_key)
        except Exception:
            return None


class WardrobeItemSerializer(serializers.ModelSerializer):
    images = WardrobeItemImageSerializer(many=True, read_only=True)

    class Meta:
        model = WardrobeItem
        fields = [
            'id', 'category', 'subcategory', 'primary_color',
            'secondary_color', 'color_hex', 'brand', 'name',
            'season', 'images', 'created_at', 'updated_at',
        ]
        read_only_fields = [
            'id', 'primary_color', 'secondary_color', 'color_hex',
            'subcategory', 'created_at', 'updated_at',
        ]


class WardrobeItemUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = WardrobeItem
        fields = ['name', 'category', 'season', 'brand']


class PresignedUrlRequestSerializer(serializers.Serializer):
    file_name = serializers.CharField(max_length=255)
    content_type = serializers.CharField(max_length=100)
    upload_type = serializers.ChoiceField(
        choices=['wardrobe', 'profile', 'tryon_person']
    )


class UploadConfirmSerializer(serializers.Serializer):
    s3_key = serializers.CharField(max_length=500)
    upload_type = serializers.ChoiceField(
        choices=['wardrobe', 'profile', 'tryon_person']
    )
    # Optional user-provided metadata (used as initial values before AI runs)
    category = serializers.ChoiceField(
        choices=['top', 'bottom', 'dress', 'outerwear', 'shoes', 'accessory'],
        required=False,
    )
    name = serializers.CharField(max_length=200, required=False, allow_blank=True)
    season = serializers.ChoiceField(
        choices=['all', 'spring', 'summer', 'fall', 'winter'],
        required=False,
    )
