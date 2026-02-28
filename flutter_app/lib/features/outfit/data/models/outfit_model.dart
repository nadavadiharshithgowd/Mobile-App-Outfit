import '../../../wardrobe/data/models/wardrobe_item_model.dart';

class OutfitModel {
  final String id;
  final String? name;
  final String? occasion;
  final String? season;
  final String source;
  final double? compatibilityScore;
  final bool isFavorite;
  final List<OutfitItemModel> items;
  final DateTime createdAt;

  const OutfitModel({
    required this.id,
    this.name,
    this.occasion,
    this.season,
    required this.source,
    this.compatibilityScore,
    this.isFavorite = false,
    this.items = const [],
    required this.createdAt,
  });

  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    return OutfitModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      occasion: json['occasion'] as String?,
      season: json['season'] as String?,
      source: json['source'] as String? ?? 'manual',
      compatibilityScore: (json['compatibility_score'] as num?)?.toDouble(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => OutfitItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class OutfitItemModel {
  final String slot;
  final WardrobeItemModel wardrobeItem;

  const OutfitItemModel({
    required this.slot,
    required this.wardrobeItem,
  });

  factory OutfitItemModel.fromJson(Map<String, dynamic> json) {
    return OutfitItemModel(
      slot: json['slot'] as String,
      wardrobeItem: WardrobeItemModel.fromJson(
          json['wardrobe_item'] as Map<String, dynamic>),
    );
  }
}

class RecommendationModel {
  final String id;
  final int rank;
  final String? reason;
  final double? compatibilityScore;
  final OutfitModel outfit;
  final bool? wasAccepted;

  const RecommendationModel({
    required this.id,
    required this.rank,
    this.reason,
    this.compatibilityScore,
    required this.outfit,
    this.wasAccepted,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] as String,
      rank: json['rank'] as int,
      reason: json['reason'] as String?,
      compatibilityScore:
          (json['compatibility_score'] as num?)?.toDouble(),
      outfit: OutfitModel.fromJson(json['outfit'] as Map<String, dynamic>),
      wasAccepted: json['was_accepted'] as bool?,
    );
  }
}

class DailyRecommendationResponse {
  final String date;
  final List<RecommendationModel> recommendations;

  const DailyRecommendationResponse({
    required this.date,
    required this.recommendations,
  });

  factory DailyRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return DailyRecommendationResponse(
      date: json['date'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) =>
              RecommendationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
