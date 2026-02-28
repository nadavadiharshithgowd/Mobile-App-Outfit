from rest_framework import serializers
from common.s3_utils import generate_presigned_download_url
from .models import TryOnResult


class TryOnResultSerializer(serializers.ModelSerializer):
    result_image_url = serializers.SerializerMethodField()

    class Meta:
        model = TryOnResult
        fields = [
            'id', 'person_image_s3', 'garment_item_id',
            'result_image_url', 'status', 'error_message',
            'processing_time_ms', 'created_at', 'completed_at',
        ]
        read_only_fields = [
            'id', 'result_image_url', 'status', 'error_message',
            'processing_time_ms', 'created_at', 'completed_at',
        ]

    def get_result_image_url(self, obj):
        if obj.result_image_s3:
            try:
                return generate_presigned_download_url(obj.result_image_s3)
            except Exception:
                return None
        return None


class TryOnSubmitSerializer(serializers.Serializer):
    person_image_s3 = serializers.CharField(max_length=500)
    garment_item_id = serializers.UUIDField()
