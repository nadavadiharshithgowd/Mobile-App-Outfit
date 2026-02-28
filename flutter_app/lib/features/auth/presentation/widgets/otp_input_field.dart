import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;

  const OtpInputField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return Container(
          width: 48,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: controller.text.length == index
                  ? AppColors.accent
                  : AppColors.divider,
              width: controller.text.length == index ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              index < controller.text.length ? controller.text[index] : '',
              style: AppTextStyles.h2,
            ),
          ),
        );
      }),
    );
  }
}
