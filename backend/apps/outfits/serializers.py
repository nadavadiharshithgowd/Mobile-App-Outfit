from rest_framework import serializers
from apps.wardrobe.models import WardrobeItem
from apps.wardrobe.serializers import WardrobeItemSerializer
from .models import Outfit, OutfitItem, DailyRecommendation


class OutfitItemSerializer(serializers.ModelSerializer):
    wardrobe_item = WardrobeItemSerializer(read_only=True)
    wardrobe_item_id = serializers.UUIDField(write_only=True)

    class Meta:
        model = OutfitItem
        fields = ['slot', 'wardrobe_item', 'wardrobe_item_id']

    def validate_wardrobe_item_id(self, value):
        request = self.context.get('request')
        if request and not WardrobeItem.objects.filter(id=value, user=request.user).exists():
            raise serializers.ValidationError('Wardrobe item not found.')
        return value


class OutfitSerializer(serializers.ModelSerializer):
    items = OutfitItemSerializer(many=True, required=False)
    # Web frontend sends item_ids (slot inferred from wardrobe item category)
    item_ids = serializers.ListField(
        child=serializers.UUIDField(),
        write_only=True,
        required=False,
    )

    class Meta:
        model = Outfit
        fields = [
            'id', 'name', 'occasion', 'season', 'source',
            'compatibility_score', 'is_favorite', 'items', 'item_ids',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'source', 'compatibility_score', 'created_at', 'updated_at']

    def validate_item_ids(self, value):
        request = self.context.get('request')
        if request and value:
            found = WardrobeItem.objects.filter(
                id__in=value, user=request.user
            ).values_list('id', flat=True)
            missing = set(str(v) for v in value) - set(str(f) for f in found)
            if missing:
                raise serializers.ValidationError('Some wardrobe items were not found.')
        return value

    def create(self, validated_data):
        items_data = validated_data.pop('items', [])
        item_ids = validated_data.pop('item_ids', [])
        outfit = Outfit.objects.create(**validated_data)

        # items with explicit slot (mobile app / direct API)
        for item_data in items_data:
            OutfitItem.objects.update_or_create(
                outfit=outfit,
                slot=item_data['slot'],
                defaults={'wardrobe_item_id': item_data['wardrobe_item_id']},
            )

        # item_ids without slot — infer slot from wardrobe item category (web frontend)
        if item_ids:
            wardrobe_items = WardrobeItem.objects.filter(
                id__in=item_ids, user=outfit.user
            )
            for wardrobe_item in wardrobe_items:
                OutfitItem.objects.update_or_create(
                    outfit=outfit,
                    slot=wardrobe_item.category,
                    defaults={'wardrobe_item': wardrobe_item},
                )

        return outfit

    def update(self, instance, validated_data):
        validated_data.pop('items', None)
        validated_data.pop('item_ids', None)
        return super().update(instance, validated_data)


class RecommendationSerializer(serializers.ModelSerializer):
    outfit = OutfitSerializer(read_only=True)

    class Meta:
        model = DailyRecommendation
        fields = [
            'id', 'rank', 'reason', 'was_accepted',
            'outfit', 'recommendation_date',
        ]


class DailyRecommendationResponseSerializer(serializers.Serializer):
    date = serializers.DateField()
    recommendations = RecommendationSerializer(many=True)
