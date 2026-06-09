import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final BorderSide? borderSide;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24.0,
    this.blur = 15.0,
    this.borderSide,
    this.padding,
    this.gradientColors,
  });

  @override
  Widget build(final BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(20.0.w);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark
        ? AppColors.darkGlassBackground
        : AppColors.lightGlassBackground;

    final border =
        borderSide ??
        BorderSide(
          color: isDark
              ? AppColors.darkGlassBorder
              : AppColors.lightGlassBorder,
          width: 1.5,
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: effectivePadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.fromBorderSide(border),
            gradient: LinearGradient(
              colors:
                  gradientColors ??
                  [
                    background.withValues(alpha: isDark ? 0.08 : 0.4),
                    background.withValues(alpha: isDark ? 0.03 : 0.15),
                  ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
