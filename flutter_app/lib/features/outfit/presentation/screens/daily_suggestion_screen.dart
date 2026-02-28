import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/outfit_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/outfit_bloc.dart';
import '../bloc/outfit_event.dart';
import '../bloc/outfit_state.dart';

class DailySuggestionScreen extends StatefulWidget {
  const DailySuggestionScreen({super.key});

  @override
  State<DailySuggestionScreen> createState() => _DailySuggestionScreenState();
}

class _DailySuggestionScreenState extends State<DailySuggestionScreen> {
  final _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<OutfitBloc>().add(const OutfitLoadDaily());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(AppStrings.todaysPick),
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<OutfitBloc>().add(const OutfitGenerateNew());
            },
          ),
        ],
      ),
      body: BlocBuilder<OutfitBloc, OutfitState>(
        builder: (context, state) {
          if (state is OutfitLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (state is OutfitError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: AppStrings.error,
              subtitle: state.message,
              actionLabel: AppStrings.retry,
              onAction: () {
                context.read<OutfitBloc>().add(const OutfitLoadDaily());
              },
            );
          }

          if (state is OutfitEmpty) {
            return EmptyStateWidget(
              icon: Icons.wb_sunny_outlined,
              title: AppStrings.noSuggestions,
              subtitle: AppStrings.noSuggestionsSub,
              actionLabel: AppStrings.addClothes,
              onAction: () => context.go('/closet/upload'),
            );
          }

          if (state is OutfitDailyLoaded) {
            return Column(
              children: [
                const SizedBox(height: 16),
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    state.recommendations.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.accent
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Outfit cards
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: state.recommendations.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final rec = state.recommendations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: OutfitCard(
                          items: rec.outfit.items
                              .map((item) => OutfitCardItem(
                                    slot: item.slot,
                                    imageUrl:
                                        item.wardrobeItem.thumbnailUrl,
                                    name: item.wardrobeItem.displayName,
                                  ))
                              .toList(),
                          compatibilityScore: rec.compatibilityScore,
                          reason: rec.reason,
                          onTap: () => context.go(
                            '/home/outfit/${rec.outfit.id}',
                            extra: rec.outfit,
                          ),
                          onAccept: () {
                            context
                                .read<OutfitBloc>()
                                .add(OutfitAccept(rec.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Outfit saved! Have a great day!'),
                              ),
                            );
                          },
                          onReject: () {
                            context
                                .read<OutfitBloc>()
                                .add(OutfitReject(rec.id));
                            if (_currentPage <
                                state.recommendations.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
