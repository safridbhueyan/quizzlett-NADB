import 'package:flutter/material.dart';

class QuickActionItem {
  const QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

class FeaturedTip {
  const FeaturedTip({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradientColors,
  });

  final String emoji;
  final String title;
  final String description;
  final List<Color> gradientColors;
}

abstract final class MockData {
  static const List<QuickActionItem> quickActions = [
    QuickActionItem(
      icon: Icons.camera_alt_rounded,
      title: 'Scan Plant',
      subtitle: 'Detect diseases',
      color: Color(0xFF2E7D32),
    ),
    QuickActionItem(
      icon: Icons.smart_toy_rounded,
      title: 'AI Plant Doctor',
      subtitle: 'Get diagnosis',
      color: Color(0xFF1565C0),
    ),
    QuickActionItem(
      icon: Icons.local_library_rounded,
      title: 'Plant Library',
      subtitle: 'Browse plants',
      color: Color(0xFF6A1B9A),
    ),
    QuickActionItem(
      icon: Icons.history_rounded,
      title: 'History',
      subtitle: 'Past scans',
      color: Color(0xFFE65100),
    ),
  ];

  static const List<FeaturedTip> featuredTips = [
    FeaturedTip(
      emoji: '🍅',
      title: 'Tomato Care Tips',
      description: 'Keep leaves dry to prevent blight. Water at the base early morning.',
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    ),
    FeaturedTip(
      emoji: '🌹',
      title: 'Rose Disease Prevention',
      description: 'Prune dead wood regularly and ensure good air circulation.',
      gradientColors: [Color(0xFFE91E8C), Color(0xFFAA00FF)],
    ),
    FeaturedTip(
      emoji: '🥭',
      title: 'Mango Fertilizer Guide',
      description: 'Apply balanced NPK fertilizer during flowering season for best yield.',
      gradientColors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
    ),
    FeaturedTip(
      emoji: '🌿',
      title: 'Indoor Plant Care',
      description: 'Indirect sunlight and well-draining soil are key to thriving indoors.',
      gradientColors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
    ),
  ];
}
