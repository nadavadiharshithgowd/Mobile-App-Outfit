import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/cached_s3_image.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../../../di/injection_container.dart';
import '../../data/models/tryon_result_model.dart';
class TryOnResultScreen extends StatefulWidget {
  final String tryonId;

  const TryOnResultScreen({super.key, required this.tryonId});

  @override
  State<TryOnResultScreen> createState() => _TryOnResultScreenState();
}

class _TryOnResultScreenState extends State<TryOnResultScreen> {
  TryOnResultModel? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      final apiClient = sl<ApiClient>();
      final response =
          await apiClient.get(ApiEndpoints.tryOnDetail(widget.tryonId));
      final data = response.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _result = TryOnResultModel.fromJson(data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load result: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/tryon'),
        ),
        title: const Text(AppStrings.tryOnResult),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
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
                          text: 'Go Back',
                          icon: Icons.arrow_back,
                          onPressed: () => context.go('/tryon'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildResultContent(),
    );
  }

  Widget _buildResultContent() {
    final result = _result!;

    if (result.isFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text('Try-On Failed', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                result.errorMessage ?? 'An unknown error occurred',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PastelButton(
                text: 'Try Again',
                width: double.infinity,
                icon: Icons.replay_rounded,
                onPressed: () => context.go('/tryon'),
              ),
            ],
          ),
        ),
      );
    }

    if (result.isProcessing || result.isPending) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            Text('Still processing...', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Text('Check back in a moment',
                style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    // Completed - show result
    return Column(
      children: [
        // Result image
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: result.resultImageUrl != null
                  ? CachedS3Image(
                      imageUrl: result.resultImageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    )
                  : Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 64, color: AppColors.textHint),
                            SizedBox(height: 8),
                            Text('No result image available',
                                style: AppTextStyles.labelMedium),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // Info row
        if (result.processingTimeMs != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Generated in ${(result.processingTimeMs! / 1000).toStringAsFixed(1)}s',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              PastelButton(
                text: 'Save to Gallery',
                width: double.infinity,
                icon: Icons.download_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to gallery!')),
                  );
                },
              ),
              const SizedBox(height: 12),
              PastelButton(
                text: 'Try Another',
                width: double.infinity,
                isOutlined: true,
                icon: Icons.replay_rounded,
                onPressed: () => context.go('/tryon'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
