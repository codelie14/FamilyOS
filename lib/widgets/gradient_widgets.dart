import 'package:flutter/material.dart';
import '../core/theme.dart';

/// A BoxDecoration that applies the main gradient.
BoxDecoration gradientDecoration({
  double radius = kRadiusSm,
  LinearGradient gradient = kGradMain,
  List<BoxShadow>? boxShadow,
}) {
  return BoxDecoration(
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: boxShadow,
  );
}

/// Full-width gradient button.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient = kGradMain,
    this.radius = 14.0,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
    this.textStyle,
  });

  final String label;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final double radius;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: kPurple.withAlpha(100),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textStyle ??
              const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}

/// Gradient text using ShaderMask.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = kGradCyan,
  });

  final String text;
  final TextStyle style;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}
