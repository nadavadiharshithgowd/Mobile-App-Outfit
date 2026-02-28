import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cached_s3_image.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/outfit_bloc.dart';
import '../bloc/outfit_event.dart';
import '../bloc/outfit_state.dart';

class OutfitHistoryScreen extends StatefulWidget {
  const OutfitHistoryScreen({super.key});

  @override
  State<OutfitHistoryScreen> createState() => _OutfitHistoryScreenState();
}

class _OutfitHistoryScreenState extends State<OutfitHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OutfitBloc>().add(const OutfitLoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.outfitHistory),
      ),
      body: BlocBuilder<OutfitBloc, OutfitState>(
        builder: (context, state) {
          if (state is OutfitLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (state is OutfitHistoryLoaded) {
            if (state.outfits.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.history,
                title: 'No outfits yet',
                subtitle: 'Your outfit history will appear here',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.outfits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final outfit = state.outfits[index];
                return InkWell(
                  onTap: () => context.go(
                    '/profile/history/outfit/${outfit.id}',
                    extra: outfit,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      // Item thumbnails
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          children: [
                            for (var i = 0;
                                i < outfit.items.length && i < 3;
                                i++)
                              Positioned(
                                left: i * 12.0,
                                child: Container(
                                  width: 56,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.background,
                                      width: 2,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: CachedS3Image(
                                    imageUrl: outfit.items[i].wardrobeItem
                                        .thumbnailUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              outfit.name ?? 'Outfit #${index + 1}',
                              style: AppTextStyles.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${outfit.items.length} items',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, yyyy')
                                  .format(outfit.createdAt),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (outfit.compatibilityScore != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(outfit.compatibilityScore! * 100).round()}%',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.accentDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                  ),
                );
              },
            );
          }

          if (state is OutfitError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: AppStrings.error,
              subtitle: state.message,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
