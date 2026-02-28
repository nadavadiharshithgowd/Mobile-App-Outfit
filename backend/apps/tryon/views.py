from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from common.permissions import IsOwner
from apps.wardrobe.models import WardrobeItem
from .models import TryOnResult
from .serializers import TryOnResultSerializer, TryOnSubmitSerializer
from .tasks import run_virtual_tryon


class TryOnViewSet(viewsets.ModelViewSet):
    serializer_class = TryOnResultSerializer
    permission_classes = [IsAuthenticated, IsOwner]
    http_method_names = ['get', 'post', 'delete']

    def get_queryset(self):
        return TryOnResult.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        """Submit a new try-on request."""
        serializer = TryOnSubmitSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Verify garment belongs to user
        try:
            garment = WardrobeItem.objects.get(
                id=serializer.validated_data['garment_item_id'],
                user=request.user,
                is_active=True,
            )
        except WardrobeItem.DoesNotExist:
            return Response(
                {'detail': 'Garment item not found'},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Create try-on result
        tryon = TryOnResult.objects.create(
            user=request.user,
            person_image_s3=serializer.validated_data['person_image_s3'],
            garment_item=garment,
            status='pending',
        )

        # Trigger async processing
        from django.conf import settings as django_settings
        if getattr(django_settings, 'USE_CELERY', False):
            run_virtual_tryon.delay(str(tryon.id))
        else:
            from common.task_utils import run_in_thread
            run_in_thread(run_virtual_tryon, str(tryon.id))

        result_serializer = TryOnResultSerializer(tryon)
        return Response(
            result_serializer.data,
            status=status.HTTP_202_ACCEPTED,
        )
