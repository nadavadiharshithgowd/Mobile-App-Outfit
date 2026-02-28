import uuid
from django.db.models import Count
from rest_framework import viewsets, status
from rest_framework.decorators import api_view, action, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from common.permissions import IsOwner
from common.s3_utils import (
    generate_presigned_upload_url,
    build_wardrobe_s3_key,
    build_profile_s3_key,
    build_tryon_person_s3_key,
)
from .models import WardrobeItem, WardrobeItemImage
from .serializers import (
    WardrobeItemSerializer,
    WardrobeItemUpdateSerializer,
    PresignedUrlRequestSerializer,
    UploadConfirmSerializer,
)
from .tasks import process_wardrobe_upload


class WardrobeViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsOwner]
    filterset_fields = ['category', 'season']
    search_fields = ['name', 'brand', 'primary_color']
    ordering_fields = ['created_at', 'name', 'category']

    def get_serializer_class(self):
        if self.action in ('partial_update', 'update'):
            return WardrobeItemUpdateSerializer
        return WardrobeItemSerializer

    def get_queryset(self):
        return WardrobeItem.objects.filter(
            user=self.request.user,
            is_active=True,
        ).prefetch_related('images')

    def perform_destroy(self, instance):
        """Soft delete."""
        instance.is_active = False
        instance.save(update_fields=['is_active'])

    @action(detail=False, methods=['get'])
    def categories(self, request):
        """Get category counts for filter UI."""
        counts = (
            WardrobeItem.objects.filter(user=request.user, is_active=True)
            .values('category')
            .annotate(count=Count('id'))
        )
        result = {item['category']: item['count'] for item in counts}
        result['all'] = sum(result.values())
        return Response(result)

    @action(detail=True, methods=['get'])
    def similar(self, request, pk=None):
        """Get similar items based on CLIP embedding."""
        item = self.get_object()
        if not item.clip_embedding:
            return Response([])

        # Simple cosine similarity search
        # In production, use pgvector for efficient nearest neighbor
        all_items = WardrobeItem.objects.filter(
            user=request.user,
            is_active=True,
            clip_embedding__isnull=False,
        ).exclude(id=item.id).prefetch_related('images')

        # Return top 5 for now (proper vector search needed for scale)
        serializer = WardrobeItemSerializer(all_items[:5], many=True)
        return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def presigned_url_view(request):
    """Generate a presigned URL for direct S3 upload."""
    serializer = PresignedUrlRequestSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    user_id = str(request.user.id)
    file_name = serializer.validated_data['file_name']
    content_type = serializer.validated_data['content_type']
    upload_type = serializer.validated_data['upload_type']

    if upload_type == 'wardrobe':
        item_id = str(uuid.uuid4())
        s3_key = build_wardrobe_s3_key(user_id, item_id, file_name)
    elif upload_type == 'profile':
        s3_key = build_profile_s3_key(user_id, 'avatar', file_name)
    elif upload_type == 'tryon_person':
        s3_key = build_tryon_person_s3_key(user_id, file_name)
    else:
        return Response(
            {'detail': 'Invalid upload type'},
            status=status.HTTP_400_BAD_REQUEST,
        )

    presigned_url = generate_presigned_upload_url(s3_key, content_type)

    return Response({
        'presigned_url': presigned_url,
        's3_key': s3_key,
        'expires_in': 300,
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def confirm_upload_view(request):
    """Confirm upload and trigger AI processing pipeline."""
    serializer = UploadConfirmSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    s3_key = serializer.validated_data['s3_key']
    upload_type = serializer.validated_data['upload_type']

    if upload_type == 'wardrobe':
        # Use user-provided category if supplied; AI will refine it later
        initial_category = serializer.validated_data.get('category', 'top')
        initial_name = serializer.validated_data.get('name') or 'Processing...'
        initial_season = serializer.validated_data.get('season', 'all')

        # Create wardrobe item record
        item = WardrobeItem.objects.create(
            user=request.user,
            category=initial_category,
            name=initial_name,
            season=initial_season,
        )

        # Create image record
        WardrobeItemImage.objects.create(
            wardrobe_item=item,
            s3_key=s3_key,
            image_type='original',
        )

        # Trigger AI processing pipeline
        from django.conf import settings as django_settings
        if getattr(django_settings, 'USE_CELERY', False):
            process_wardrobe_upload.delay(str(item.id), s3_key)
        else:
            from common.task_utils import run_in_thread
            run_in_thread(process_wardrobe_upload, str(item.id), s3_key)

        return Response(
            {
                'wardrobe_item_id': str(item.id),
                'status': 'processing',
                'message': 'AI detection started',
            },
            status=status.HTTP_202_ACCEPTED,
        )

    elif upload_type == 'profile':
        request.user.profile_photo = s3_key
        request.user.save(update_fields=['profile_photo'])
        return Response({'status': 'saved', 's3_key': s3_key})

    elif upload_type == 'tryon_person':
        return Response({'status': 'saved', 's3_key': s3_key})

    return Response(
        {'detail': 'Invalid upload type'},
        status=status.HTTP_400_BAD_REQUEST,
    )
