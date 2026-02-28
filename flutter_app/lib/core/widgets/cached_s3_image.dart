import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

class CachedS3Image extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  const CachedS3Image({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final widget = imageUrl != null
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, __) => _shimmerPlaceholder(),
            errorWidget: (_, __, ___) => _errorPlaceholder(),
          )
        : _errorPlaceholder();

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: widget,
      );
    }

    return widget;
  }

  Widget _shimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        color: AppColors.surface,
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: Icon(
        placeholderIcon,
        color: AppColors.textHint,
        size: 32,
      ),
    );
  }
}
