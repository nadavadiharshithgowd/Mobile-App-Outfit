import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/widgets/cached_s3_image.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../../../di/injection_container.dart';
import '../../../wardrobe/data/models/wardrobe_item_model.dart';
import '../bloc/tryon_bloc.dart';
import '../bloc/tryon_event.dart';
import '../bloc/tryon_state.dart';
import '../widgets/tryon_progress_indicator.dart';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<TryOnBloc>().add(const TryOnLoadHistory());
  }

  Future<void> _pickPersonImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (picked != null && mounted) {
      final bytes = await picked.readAsBytes();
      context.read<TryOnBloc>().add(
            TryOnSelectPersonImage(
              imageBytes: bytes,
              fileName: picked.name,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.virtualTryOn),
      ),
      body: BlocConsumer<TryOnBloc, TryOnState>(
        listener: (context, state) {
          if (state is TryOnCompleted) {
            context.go('/tryon/result/${state.tryOnId}');
          } else if (state is TryOnError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TryOnProcessing) {
            return TryOnProgressIndicatorWidget(
              progress: state.progress,
              step: state.step,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Two image slots
                Row(
                  children: [
                    Expanded(
                      child: _ImageSlot(
                        label: AppStrings.yourPhoto,
                        icon: Icons.person_outline,
                        imageBytes: state is TryOnReady
                            ? state.personImageBytes
                            : null,
                        onTap: _pickPersonImage,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ImageSlot(
                        label: AppStrings.selectGarment,
                        icon: Icons.checkroom_outlined,
                        imageUrl: state is TryOnReady
                            ? state.garmentImageUrl
                            : null,
                        subtitle: state is TryOnReady
                            ? state.garmentName
                            : null,
                        onTap: () => _showGarmentPicker(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Generate button
                PastelButton(
                  text: AppStrings.generateTryOn,
                  width: double.infinity,
                  icon: Icons.auto_awesome,
                  onPressed:
                      (state is TryOnReady && state.canGenerate)
                          ? () {
                              context
                                  .read<TryOnBloc>()
                                  .add(const TryOnGenerate());
                            }
                          : null,
                ),

                const SizedBox(height: 32),

                // Recent try-ons
                if (state is TryOnReady && state.history.isNotEmpty) ...[
                  Text('Recent Try-Ons', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.history.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final result = state.history[index];
                        return GestureDetector(
                          onTap: () {
                            if (result.isCompleted) {
                              context.go('/tryon/result/${result.id}');
                            }
                          },
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: result.resultImageUrl != null
                                ? CachedS3Image(
                                    imageUrl: result.resultImageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: result.isProcessing
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.accent,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.image_outlined,
                                            color: AppColors.textHint,
                                          ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                if (state is TryOnReady && state.history.isEmpty) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          size: 48,
                          color: AppColors.textHint.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select a photo and garment\nto see how you look!',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
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
    );
  }

  void _showGarmentPicker(BuildContext outerContext) {
    showModalBottomSheet(
      context: outerContext,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: _GarmentPickerSheet(
            onGarmentSelected: (item) {
              Navigator.pop(ctx);
              outerContext.read<TryOnBloc>().add(
                    TryOnSelectGarment(
                      garmentItemId: item.id,
                      garmentImageUrl: item.thumbnailUrl,
                      garmentName: item.displayName,
                    ),
                  );
            },
          ),
        );
      },
    );
  }
}

class _GarmentPickerSheet extends StatefulWidget {
  final void Function(WardrobeItemModel) onGarmentSelected;

  const _GarmentPickerSheet({
    required this.onGarmentSelected,
  });

  @override
  State<_GarmentPickerSheet> createState() => _GarmentPickerSheetState();
}

class _GarmentPickerSheetState extends State<_GarmentPickerSheet> {
  List<WardrobeItemModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  Future<void> _loadWardrobe() async {
    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.get(
        ApiEndpoints.wardrobe,
        queryParameters: {'page': 1, 'page_size': 50},
      );
      final data = response.data as Map<String, dynamic>;
      final results = (data['results'] as List<dynamic>)
          .map((e) => WardrobeItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _items = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load wardrobe: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Text('Select a Garment', style: AppTextStyles.h3),
              const Spacer(),
              Text('${_items.length} items',
                  style: AppTextStyles.caption),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.accent))
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: AppTextStyles.bodySmall,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            PastelButton(
                              text: 'Retry',
                              icon: Icons.refresh,
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                  _error = null;
                                });
                                _loadWardrobe();
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : _items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.checkroom_outlined,
                                    size: 48, color: AppColors.textHint),
                                const SizedBox(height: 12),
                                Text(
                                    'Your closet is empty.\nAdd clothes first!',
                                    style: AppTextStyles.bodySmall,
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _GarmentGridTile(
                              item: item,
                              onTap: () =>
                                  widget.onGarmentSelected(item),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _GarmentGridTile extends StatelessWidget {
  final WardrobeItemModel item;
  final VoidCallback onTap;

  const _GarmentGridTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: item.thumbnailUrl != null
                    ? CachedS3Image(
                        imageUrl: item.thumbnailUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(
                        child: Icon(Icons.checkroom,
                            color: AppColors.textHint, size: 32),
                      ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 4),
                color: AppColors.background,
                child: Text(
                  item.displayName,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final String label;
  final IconData icon;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final String? subtitle;
  final VoidCallback onTap;

  const _ImageSlot({
    required this.label,
    required this.icon,
    this.imageBytes,
    this.imageUrl,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.divider,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageBytes != null
              ? Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                )
              : imageUrl != null
                  ? CachedS3Image(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.accent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          label,
                          style: AppTextStyles.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
        ),
      ),
    );
  }
}
