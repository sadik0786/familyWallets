import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.prefix = '₹',
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_IN');

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: duration,
      curve: Curves.easeOutQuart,
      builder: (context, val, child) {
        return Text(
          '$prefix${currencyFormatter.format(val)}$suffix',
          style: style,
        );
      },
    );
  }
}
