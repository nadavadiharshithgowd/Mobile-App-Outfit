from datetime import date
from rest_framework import viewsets, status
from rest_framework.decorators import api_view, action, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from common.permissions import IsOwner
from .models import Outfit, OutfitItem, DailyRecommendation
from .serializers import OutfitSerializer, OutfitItemSerializer, RecommendationSerializer
from .tasks import generate_daily_recommendations


class OutfitViewSet(viewsets.ModelViewSet):
    serializer_class = OutfitSerializer
    permission_classes = [IsAuthenticated, IsOwner]
    filterset_fields = ['source', 'is_favorite', 'occasion']

    def get_queryset(self):
        return Outfit.objects.filter(
            user=self.request.user,
        ).prefetch_related('items__wardrobe_item__images')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, source='manual')

    @action(detail=True, methods=['post'])
    def favorite(self, request, pk=None):
        outfit = self.get_object()
        outfit.is_favorite = not outfit.is_favorite
        outfit.save(update_fields=['is_favorite'])
        return Response({'is_favorite': outfit.is_favorite})

    @action(detail=True, methods=['post'], url_path='items')
    def add_item(self, request, pk=None):
        """Add or replace an item in a slot. POST /outfits/{id}/items/"""
        outfit = self.get_object()
        serializer = OutfitItemSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        outfit_item, created = OutfitItem.objects.update_or_create(
            outfit=outfit,
            slot=serializer.validated_data['slot'],
            defaults={'wardrobe_item_id': serializer.validated_data['wardrobe_item_id']},
        )
        outfit_item = (
            OutfitItem.objects
            .select_related('wardrobe_item')
            .prefetch_related('wardrobe_item__images')
            .get(pk=outfit_item.pk)
        )
        return Response(
            OutfitItemSerializer(outfit_item, context={'request': request}).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    @action(detail=True, methods=['delete'], url_path='items/(?P<slot>[^/.]+)')
    def remove_item(self, request, pk=None, slot=None):
        """Remove an item from a slot. DELETE /outfits/{id}/items/{slot}/"""
        outfit = self.get_object()
        deleted, _ = OutfitItem.objects.filter(outfit=outfit, slot=slot).delete()
        if not deleted:
            return Response({'detail': 'Item not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def daily_recommendation_view(request):
    """Get today's daily recommendations."""
    today = date.today()
    recommendations = DailyRecommendation.objects.filter(
        user=request.user,
        recommendation_date=today,
    ).select_related('outfit').prefetch_related(
        'outfit__items__wardrobe_item__images'
    )

    serializer = RecommendationSerializer(recommendations, many=True)
    return Response({
        'date': today.isoformat(),
        'recommendations': serializer.data,
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_recommendation_view(request):
    """Force regenerate daily recommendations."""
    from django.conf import settings as django_settings
    if getattr(django_settings, 'USE_CELERY', False):
        generate_daily_recommendations.delay(str(request.user.id))
    else:
        from common.task_utils import run_in_thread
        run_in_thread(generate_daily_recommendations, str(request.user.id))
    return Response(
        {'message': 'Generating new recommendations...'},
        status=status.HTTP_202_ACCEPTED,
    )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def accept_recommendation_view(request, pk):
    """Mark a recommendation as accepted."""
    try:
        rec = DailyRecommendation.objects.get(id=pk, user=request.user)
        rec.was_accepted = True
        rec.save(update_fields=['was_accepted'])
        return Response({'status': 'accepted'})
    except DailyRecommendation.DoesNotExist:
        return Response(
            {'detail': 'Recommendation not found'},
            status=status.HTTP_404_NOT_FOUND,
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reject_recommendation_view(request, pk):
    """Mark a recommendation as rejected."""
    try:
        rec = DailyRecommendation.objects.get(id=pk, user=request.user)
        rec.was_accepted = False
        rec.save(update_fields=['was_accepted'])
        return Response({'status': 'rejected'})
    except DailyRecommendation.DoesNotExist:
        return Response(
            {'detail': 'Recommendation not found'},
            status=status.HTTP_404_NOT_FOUND,
        )
