import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../bloc/upload_bloc.dart';
import '../bloc/upload_event.dart';
import '../bloc/upload_state.dart';
import '../bloc/wardrobe_bloc.dart';
import '../bloc/wardrobe_event.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _imagePicker = ImagePicker();
  final _nameController = TextEditingController();
  String _selectedCategory = 'top';
  String _selectedSeason = 'all';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      if (mounted) {
        context.read<UploadBloc>().add(
              UploadImageSelected(
                imageBytes: bytes,
                fileName: picked.name,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadBloc, UploadState>(
      listener: (context, state) {
        if (state is UploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added to closet!')),
          );
          context.read<WardrobeBloc>().add(const WardrobeLoadItems(refresh: true));
          context.go('/closet');
        } else if (state is UploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.go('/closet'),
          ),
          title: const Text(AppStrings.uploadTitle),
        ),
        body: BlocBuilder<UploadBloc, UploadState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image picker / preview
                  _buildImageSection(state),
                  const SizedBox(height: 24),

                  if (state is UploadImageReady || state is UploadInProgress) ...[
                    // Item name
                    Text('Item Name', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Blue Denim Jacket',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category
                    Text(AppStrings.category, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),
                    const SizedBox(height: 20),

                    // Season
                    Text(AppStrings.season, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    _buildSeasonSelector(),
                    const SizedBox(height: 32),

                    // Upload button
                    PastelButton(
                      text: AppStrings.saveToCloset,
                      isLoading: state is UploadInProgress,
                      width: double.infinity,
                      icon: Icons.cloud_upload_outlined,
                      onPressed: () {
                        context.read<UploadBloc>().add(
                              UploadStarted(
                                overrides: {
                                  'name': _nameController.text,
                                  'category': _selectedCategory,
                                  'season': _selectedSeason,
                                },
                              ),
                            );
                      },
                    ),
                  ],

                  if (state is UploadProcessing) ...[
                    const SizedBox(height: 40),
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.accent),
                          SizedBox(height: 16),
                          Text(
                            AppStrings.detecting,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageSection(UploadState state) {
    if (state is UploadImageReady) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              state.imageBytes,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                context.read<UploadBloc>().add(const UploadReset());
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PickerOption(
                icon: Icons.camera_alt_outlined,
                label: AppStrings.takePhoto,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 32),
              _PickerOption(
                icon: Icons.photo_library_outlined,
                label: AppStrings.chooseGallery,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      ('top', 'Top'),
      ('bottom', 'Bottom'),
      ('dress', 'Dress'),
      ('outerwear', 'Outerwear'),
      ('shoes', 'Shoes'),
      ('accessory', 'Accessory'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat.$1;
        return ChoiceChip(
          label: Text(cat.$2),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedCategory = cat.$1);
          },
          selectedColor: AppColors.accentSurface,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.accentDark : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeasonSelector() {
    final seasons = [
      ('all', 'All Year'),
      ('spring', 'Spring'),
      ('summer', 'Summer'),
      ('fall', 'Fall'),
      ('winter', 'Winter'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: seasons.map((s) {
        final isSelected = _selectedSeason == s.$1;
        return ChoiceChip(
          label: Text(s.$2),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedSeason = s.$1);
          },
          selectedColor: AppColors.accentSurface,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.accentDark : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.accent, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
