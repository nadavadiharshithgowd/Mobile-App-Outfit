import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class OutfitCard extends StatelessWidget {
  final List<OutfitCardItem> items;
  final double? compatibilityScore;
  final String? reason;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OutfitCard({
    super.key,
    required this.items,
    this.compatibilityScore,
    this.reason,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (compatibilityScore != null) ...[
                      _buildScoreBadge(),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child: _buildItemsLayout(),
                    ),
                    if (reason != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        reason!,
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (onAccept != null || onReject != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    if (onReject != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          child: const Text('Skip'),
                        ),
                      ),
                    if (onAccept != null && onReject != null)
                      const SizedBox(width: 12),
                    if (onAccept != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          child: const Text('Wear This'),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBadge() {
    final score = (compatibilityScore! * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            '$score% Match',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.accentDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsLayout() {
    if (items.isEmpty) return const SizedBox.shrink();

    if (items.length <= 2) {
      return Row(
        children: items.map((item) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: _buildItemTile(item),
          ),
        )).toList(),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildItemTile(items[0]),
          ),
        ),
        Expanded(
          child: Row(
            children: items.skip(1).map((item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: _buildItemTile(item),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTile(OutfitCardItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.imageUrl != null)
            CachedNetworkImage(
              imageUrl: item.imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _placeholderIcon(item.slot),
            )
          else
            _placeholderIcon(item.slot),
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.slot,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderIcon(String slot) {
    IconData icon;
    switch (slot.toLowerCase()) {
      case 'top':
        icon = Icons.checkroom;
        break;
      case 'bottom':
        icon = Icons.straighten;
        break;
      case 'shoes':
        icon = Icons.ice_skating;
        break;
      case 'dress':
        icon = Icons.dry_cleaning;
        break;
      default:
        icon = Icons.style;
    }
    return Center(
      child: Icon(icon, color: AppColors.textHint, size: 32),
    );
  }
}

class OutfitCardItem {
  final String slot;
  final String? imageUrl;
  final String? name;

  const OutfitCardItem({
    required this.slot,
    this.imageUrl,
    this.name,
  });
}
