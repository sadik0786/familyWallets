import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Theme Palette (Premium Obsidian)
  static const Color darkBackground = Color(0xFF0D0E12);
  static const Color darkSurface = Color(0xFF161820);
  static const Color darkCard = Color(0xFF1E212B);
  static const Color darkBorder = Color(0xFF2E3242);
  static const Color darkGlassBackground = Color(0x331E212B);
  static const Color darkGlassBorder = Color(0x1AFFFFFF);

  // Light Theme Palette (Premium Slate)
  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightGlassBackground = Color(0x40FFFFFF);
  static const Color lightGlassBorder = Color(0x1B000000);

  // Brand Accents & Gradients (SaaS Aesthetics)
  static const Color primaryPurple = Color(0xFF8A2BE2);
  static const Color primaryCyan = Color(0xFF00F0FF);
  static const Color primaryBlue = Color(0xFF5F67EC);
  static const Color primaryPink = Color(0xFFFF5280);

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber Yellow
  static const Color error = Color(0xFFEF4444); // Rose Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white10, Colors.white24],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Color Helpers
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'grocery':
        return const Color(0xFF10B981); // Emerald
      case 'electricity':
        return const Color(0xFFF59E0B); // Amber
      case 'water':
        return const Color(0xFF3B82F6); // Blue
      case 'gas':
        return const Color(0xFFEF4444); // Red
      case 'rent':
        return const Color(0xFF8B5CF6); // Violet
      case 'internet':
        return const Color(0xFFEC4899); // Pink
      case 'medicine':
        return const Color(0xFF14B8A6); // Teal
      case 'education':
        return const Color(0xFF6366F1); // Indigo
      case 'transport':
        return const Color(0xFFF97316); // Orange
      case 'other':
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'grocery':
        return Icons.shopping_basket_outlined;
      case 'electricity':
        return Icons.electric_bolt_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'gas':
        return Icons.gas_meter_outlined;
      case 'rent':
        return Icons.home_outlined;
      case 'internet':
        return Icons.wifi_outlined;
      case 'medicine':
        return Icons.medical_services_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'other':
      default:
        return Icons.monetization_on_outlined;
    }
  }
}
