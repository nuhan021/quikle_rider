import 'package:flutter/material.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final Color? borderColor;
  final bool isLoading;
  final TextStyle? style;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 50,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.borderRadius = 8,
    this.borderColor,
    this.isLoading = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isLoading
              ? backgroundColor.withValues(alpha: .6)
              : backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style:
                    style ??
                    getTextStyle2(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: textColor,
                    ),
              ),
      ),
    );
  }
}