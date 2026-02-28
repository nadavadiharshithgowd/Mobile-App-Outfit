import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BeforeAfterSlider extends StatefulWidget {
  final Widget beforeWidget;
  final Widget afterWidget;

  const BeforeAfterSlider({
    super.key,
    required this.beforeWidget,
    required this.afterWidget,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sliderPosition += details.delta.dx / width;
              _sliderPosition = _sliderPosition.clamp(0.05, 0.95);
            });
          },
          child: Stack(
            children: [
              // After image (full width behind)
              Positioned.fill(child: widget.afterWidget),

              // Before image (clipped)
              ClipRect(
                clipper: _SliderClipper(sliderPosition: _sliderPosition),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: widget.beforeWidget,
                ),
              ),

              // Slider line
              Positioned(
                left: width * _sliderPosition - 1.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: AppColors.background,
                ),
              ),

              // Slider handle
              Positioned(
                left: width * _sliderPosition - 20,
                top: height / 2 - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chevron_left,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double sliderPosition;

  _SliderClipper({required this.sliderPosition});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * sliderPosition, size.height);
  }

  @override
  bool shouldReclip(covariant _SliderClipper oldClipper) {
    return oldClipper.sliderPosition != sliderPosition;
  }
}
