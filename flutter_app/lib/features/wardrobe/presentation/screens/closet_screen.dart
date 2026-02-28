import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/clothing_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/wardrobe_bloc.dart';
import '../bloc/wardrobe_event.dart';
import '../bloc/wardrobe_state.dart';
import '../widgets/category_filter_chips.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<WardrobeBloc>().add(const WardrobeLoadItems());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WardrobeBloc>().add(const WardrobeLoadMore());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.myCloset),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // TODO: Search functionality
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/closet/upload'),
        child: const Icon(Icons.add_a_photo_rounded),
      ),
      body: Column(
        children: [
          // Category filter chips
          BlocBuilder<WardrobeBloc, WardrobeState>(
            builder: (context, state) {
              final activeCategory = state is WardrobeLoaded
                  ? state.activeCategory
                  : null;
              return CategoryFilterChips(
                activeCategory: activeCategory,
                onCategorySelected: (category) {
                  context
                      .read<WardrobeBloc>()
                      .add(WardrobeFilterCategory(category));
                },
              );
            },
          ),
          const SizedBox(height: 8),
          // Grid
          Expanded(
            child: BlocBuilder<WardrobeBloc, WardrobeState>(
              builder: (context, state) {
                if (state is WardrobeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                    ),
                  );
                }

                if (state is WardrobeError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: AppStrings.error,
                    subtitle: state.message,
                    actionLabel: AppStrings.retry,
                    onAction: () {
                      context
                          .read<WardrobeBloc>()
                          .add(const WardrobeLoadItems());
                    },
                  );
                }

                if (state is WardrobeLoaded) {
                  if (state.items.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.checkroom_outlined,
                      title: AppStrings.emptyCloset,
                      subtitle: AppStrings.emptyClosetSub,
                      actionLabel: AppStrings.addClothes,
                      onAction: () => context.go('/closet/upload'),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () async {
                      context.read<WardrobeBloc>().add(
                            WardrobeLoadItems(
                              category: state.activeCategory,
                              refresh: true,
                            ),
                          );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MasonryGridView.count(
                        controller: _scrollController,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount: state.items.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accent,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          final item = state.items[index];
                          return SizedBox(
                            height: index.isEven ? 220 : 260,
                            child: ClothingCard(
                              imageUrl: item.thumbnailUrl,
                              name: item.displayName,
                              category: item.category,
                              colorHex: item.colorHex,
                              onTap: () =>
                                  context.go('/closet/item/${item.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
