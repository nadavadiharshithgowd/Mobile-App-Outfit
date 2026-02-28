import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class CategoryFilterChips extends StatelessWidget {
  final String? activeCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterChips({
    super.key,
    this.activeCategory,
    required this.onCategorySelected,
  });

  static const _categories = [
    (null, AppStrings.allItems, Icons.grid_view_rounded),
    ('top', AppStrings.tops, Icons.checkroom),
    ('bottom', AppStrings.bottoms, Icons.straighten),
    ('dress', AppStrings.dresses, Icons.dry_cleaning),
    ('shoes', AppStrings.shoes, Icons.ice_skating),
    ('outerwear', AppStrings.outerwear, Icons.shield_outlined),
    ('accessory', AppStrings.accessories, Icons.watch),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label, icon) = _categories[index];
          final isSelected = activeCategory == value;

          return GestureDetector(
            onTap: () => onCategorySelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.background
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.background
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
