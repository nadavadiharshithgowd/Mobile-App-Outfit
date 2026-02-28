import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cached_s3_image.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../data/models/outfit_model.dart';
import '../bloc/outfit_bloc.dart';
import '../bloc/outfit_event.dart';

class OutfitDetailScreen extends StatefulWidget {
  final String outfitId;
  final OutfitModel? outfit;

  const OutfitDetailScreen({
    super.key,
    required this.outfitId,
    this.outfit,
  });

  @override
  State<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.outfit?.isFavorite ?? false;
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    context.read<OutfitBloc>().add(OutfitToggleFavorite(widget.outfitId));
  }

  @override
  Widget build(BuildContext context) {
    final outfit = widget.outfit;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(outfit?.name?.isNotEmpty == true
            ? outfit!.name!
            : 'Outfit Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _isFavorite ? AppColors.accent : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compatibility score badge
            if (outfit?.compatibilityScore != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(outfit!.compatibilityScore! * 100).round()}% Match',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.accentDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Items
            Text('Items in this outfit', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            if (outfit == null || outfit.items.isEmpty)
              _buildEmptyItems()
            else
              ...outfit.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOutfitItem(item),
                ),
              ),

            const SizedBox(height: 32),

            PastelButton(
              text: 'Try This On',
              width: double.infinity,
              icon: Icons.auto_awesome,
              onPressed: () => context.go('/tryon'),
            ),
            const SizedBox(height: 12),
            PastelButton(
              text: _isFavorite ? 'Saved' : 'Save Outfit',
              width: double.infinity,
              isOutlined: true,
              icon: _isFavorite ? Icons.bookmark : Icons.bookmark_border,
              onPressed: _toggleFavorite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitItem(OutfitItemModel item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedS3Image(
              imageUrl: item.wardrobeItem.thumbnailUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholderIcon: Icons.checkroom,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(item.slot),
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  item.wardrobeItem.displayName,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItems() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          'No items in this outfit yet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
