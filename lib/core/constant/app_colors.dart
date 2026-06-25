import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand colors
  static const primary = Color(0xFF6366F1);       // Indigo
  static const primaryLight = Color(0xFF818CF8);  // Light Indigo
  static const primaryDark = Color(0xFF4F46E5);   // Dark Indigo
  static const secondary = Color(0xFFEC4899);     // Pink / Rose
  static const tertiary = Color(0xFF8B5CF6);      // Violet / Purple

  // Status colors
  static const success = Color(0xFF10B981);       // Emerald
  static const warning = Color(0xFFF59E0B);       // Amber
  static const error = Color(0xFFEF4444);         // Red
  static const info = Color(0xFF3B82F6);          // Blue

  // Light Theme background/surfaces
  static const bgLight = Color(0xFFF8FAFC);       // Slate 50
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE2E8F0);   // Slate 200

  // Dark Theme background/surfaces
  static const bgDark = Color(0xFF0F172A);        // Slate 900
  static const surfaceDark = Color(0xFF1E293B);   // Slate 800
  static const cardDark = Color(0xFF1E293B);
  static const borderDark = Color(0xFF334155);    // Slate 700

  // Text colors (Light)
  static const textPrimaryLight = Color(0xFF0F172A);   // Slate 900
  static const textSecondaryLight = Color(0xFF475569); // Slate 600
  static const textMutedLight = Color(0xFF94A3B8);     // Slate 400

  // Text colors (Dark)
  static const textPrimaryDark = Color(0xFFF8FAFC);    // Slate 50
  static const textSecondaryDark = Color(0xFFCBD5E1);  // Slate 300
  static const textMutedDark = Color(0xFF64748B);      // Slate 500

  // Premium Gradients
  static const primaryGradient = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
  ];

  static const accentGradient = [
    Color(0xFFEC4899), // Pink
    Color(0xFFF43F5E), // Rose
  ];

  static const successGradient = [
    Color(0xFF10B981), // Emerald
    Color(0xFF059669), // Green
  ];

  static const errorGradient = [
    Color(0xFFEF4444), // Red
    Color(0xFFDC2626), // Dark Red
  ];

  static const cardGradients = [
    [Color(0xFF818CF8), Color(0xFF6366F1)], // Indigo
    [Color(0xFFF472B6), Color(0xFFEC4899)], // Pink
    [Color(0xFF34D399), Color(0xFF059669)], // Teal/Green
    [Color(0xFFFBBF24), Color(0xFFD97706)], // Amber/Orange
  ];
}
