import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/cached_s3_image.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../data/models/wardrobe_item_model.dart';
import '../bloc/wardrobe_bloc.dart';
import '../bloc/wardrobe_event.dart';
import '../bloc/wardrobe_state.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  WardrobeItemModel? _item;
  bool _isEditing = false;
  late TextEditingController _nameController;
  String? _selectedCategory;
  String? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadItem();
  }

  void _loadItem() {
    final state = context.read<WardrobeBloc>().state;
    if (state is WardrobeLoaded) {
      final item = state.items.where((i) => i.id == widget.itemId);
      if (item.isNotEmpty) {
        _item = item.first;
        _nameController.text = _item?.name ?? '';
        _selectedCategory = _item?.category;
        _selectedSeason = _item?.season;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _item == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : CustomScrollView(
              slivers: [
                // Image header
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 18,
                      ),
                    ),
                    onPressed: () => context.go('/closet'),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isEditing ? Icons.close : Icons.edit_outlined,
                          size: 18,
                        ),
                      ),
                      onPressed: () {
                        setState(() => _isEditing = !_isEditing);
                      },
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                      onPressed: _showDeleteDialog,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: CachedS3Image(
                      imageUrl: _item!.originalUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _isEditing
                        ? _buildEditForm()
                        : _buildDetails(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_item!.displayName, style: AppTextStyles.h2),
        const SizedBox(height: 16),
        _DetailRow(label: 'Category', value: _item!.category),
        if (_item!.subcategory != null)
          _DetailRow(label: 'Type', value: _item!.subcategory!),
        if (_item!.primaryColor != null)
          _DetailRow(label: 'Color', value: _item!.primaryColor!),
        if (_item!.season != null)
          _DetailRow(label: 'Season', value: _item!.season!),
        if (_item!.brand != null)
          _DetailRow(label: 'Brand', value: _item!.brand!),
        const SizedBox(height: 16),
        if (_item!.colorHex != null)
          Row(
            children: [
              Text('Color Swatch:', style: AppTextStyles.labelLarge),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _parseColor(_item!.colorHex!),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        PastelButton(
          text: 'Try On This Item',
          width: double.infinity,
          icon: Icons.auto_awesome,
          onPressed: () => context.go('/tryon'),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Edit Item', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(labelText: 'Category'),
          items: ['top', 'bottom', 'dress', 'outerwear', 'shoes', 'accessory']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedSeason,
          decoration: const InputDecoration(labelText: 'Season'),
          items: ['all', 'spring', 'summer', 'fall', 'winter']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => setState(() => _selectedSeason = val),
        ),
        const SizedBox(height: 24),
        PastelButton(
          text: 'Save Changes',
          width: double.infinity,
          onPressed: () {
            context.read<WardrobeBloc>().add(
                  WardrobeUpdateItem(
                    itemId: widget.itemId,
                    data: {
                      'name': _nameController.text,
                      'category': _selectedCategory,
                      'season': _selectedSeason,
                    },
                  ),
                );
            setState(() => _isEditing = false);
          },
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to remove this item from your closet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<WardrobeBloc>()
                  .add(WardrobeDeleteItem(widget.itemId));
              context.go('/closet');
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
