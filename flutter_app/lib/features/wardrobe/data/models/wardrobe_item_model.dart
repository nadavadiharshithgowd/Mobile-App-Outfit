class WardrobeItemModel {
  final String id;
  final String category;
  final String? subcategory;
  final String? primaryColor;
  final String? secondaryColor;
  final String? colorHex;
  final String? brand;
  final String? name;
  final String? season;
  final List<WardrobeImageModel> images;
  final DateTime createdAt;

  const WardrobeItemModel({
    required this.id,
    required this.category,
    this.subcategory,
    this.primaryColor,
    this.secondaryColor,
    this.colorHex,
    this.brand,
    this.name,
    this.season,
    this.images = const [],
    required this.createdAt,
  });

  factory WardrobeItemModel.fromJson(Map<String, dynamic> json) {
    String? nonEmpty(dynamic v) {
      final s = v as String?;
      return (s == null || s.isEmpty) ? null : s;
    }

    return WardrobeItemModel(
      id: json['id'] as String,
      category: json['category'] as String,
      subcategory: nonEmpty(json['subcategory']),
      primaryColor: nonEmpty(json['primary_color']),
      secondaryColor: nonEmpty(json['secondary_color']),
      colorHex: nonEmpty(json['color_hex']),
      brand: nonEmpty(json['brand']),
      name: nonEmpty(json['name']),
      season: nonEmpty(json['season']),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) =>
                  WardrobeImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'color_hex': colorHex,
      'brand': brand,
      'name': name,
      'season': season,
      'images': images.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String? get thumbnailUrl {
    final thumb = images.where((i) => i.imageType == 'thumbnail');
    if (thumb.isNotEmpty) return thumb.first.url;
    final original = images.where((i) => i.imageType == 'original');
    if (original.isNotEmpty) return original.first.url;
    return images.isNotEmpty ? images.first.url : null;
  }

  String? get originalUrl {
    final original = images.where((i) => i.imageType == 'original');
    return original.isNotEmpty ? original.first.url : thumbnailUrl;
  }

  String get displayName => name ?? '${_capitalize(category)} item';

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class WardrobeImageModel {
  final String id;
  final String? url;
  final String imageType;

  const WardrobeImageModel({
    required this.id,
    this.url,
    required this.imageType,
  });

  factory WardrobeImageModel.fromJson(Map<String, dynamic> json) {
    return WardrobeImageModel(
      id: json['id'] as String,
      url: json['url'] as String?,
      imageType: json['image_type'] as String? ?? 'original',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'image_type': imageType,
    };
  }
}
