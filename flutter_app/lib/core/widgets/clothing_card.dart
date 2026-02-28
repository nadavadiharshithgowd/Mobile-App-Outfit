import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ClothingCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String category;
  final String? colorHex;
  final VoidCallback? onTap;

  const ClothingCard({
    super.key,
    this.imageUrl,
    required this.name,
    required this.category,
    this.colorHex,
    this.onTap,
  });

  Color get _categoryColor {
    switch (category.toLowerCase()) {
      case 'top':
        return AppColors.categoryTop;
      case 'bottom':
        return AppColors.categoryBottom;
      case 'dress':
        return AppColors.categoryDress;
      case 'shoes':
        return AppColors.categoryShoes;
      case 'accessory':
        return AppColors.categoryAccessory;
      case 'outerwear':
        return AppColors.categoryOuterwear;
      default:
        return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.shimmerBase,
                        highlightColor: AppColors.shimmerHighlight,
                        child: Container(color: AppColors.surface),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.checkroom,
                          color: AppColors.textHint,
                          size: 40,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.checkroom,
                        color: AppColors.textHint,
                        size: 40,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _categoryColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (colorHex != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _parseColor(colorHex!),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                name,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.textHint;
    }
  }
}
