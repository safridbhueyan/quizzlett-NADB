import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizlett/core/constant/app_colors.dart';
import 'package:quizlett/core/constant/theme_provider.dart';
import 'package:quizlett/src/features/auth/presentation/providers/auth_provider.dart';

final profilePicLoadingProvider = StateProvider<bool>((ref) => false);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final isUploading = ref.watch(profilePicLoadingProvider);

    // Badges definitions
    final allBadges = [
      _BadgeItem(
        title: 'Novice',
        description: 'Completed your first quiz!',
        icon: '🎓',
        isUnlocked: user.badges.contains('Novice'),
        color: const Color(0xFF6366F1),
      ),
      _BadgeItem(
        title: 'Fast Learner',
        description: 'Answered a question under 5s',
        icon: '⚡',
        isUnlocked: user.badges.contains('Fast Learner') || user.quizzesTaken >= 1, // Simulating unlock
        color: const Color(0xFFF59E0B),
      ),
      _BadgeItem(
        title: 'Streak Master',
        description: 'Achieved a 5-day quiz streak',
        icon: '🔥',
        isUnlocked: user.badges.contains('Streak Master') || user.streak >= 5,
        color: const Color(0xFFEC4899),
      ),
      _BadgeItem(
        title: 'Quiz Whiz',
        description: 'Completed 5 quiz sessions',
        icon: '🧠',
        isUnlocked: user.badges.contains('Quiz Whiz') || user.quizzesTaken >= 5,
        color: const Color(0xFF10B981),
      ),
      _BadgeItem(
        title: 'Grandmaster',
        description: 'Accumulated 500+ XP points',
        icon: '👑',
        isUnlocked: user.badges.contains('Grandmaster') || user.xp >= 500,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    // Determine current level title
    String levelTitle = 'Beginner';
    if (user.level >= 5) {
      levelTitle = 'Grandmaster';
    } else if (user.level >= 3) {
      levelTitle = 'Quiz Whiz';
    } else if (user.level >= 2) {
      levelTitle = 'Apprentice';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Dynamic theme mode switcher in appbar
          IconButton(
            icon: Icon(
              currentThemeMode == ThemeMode.dark 
                  ? Icons.light_mode_rounded 
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = 
                  currentThemeMode == ThemeMode.dark 
                      ? ThemeMode.light 
                      : ThemeMode.dark;
            },
            tooltip: 'Toggle theme mode',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              
              // 1. Profile Avatar & Info Card
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isUploading
                          ? null
                          : () => _showImageSourceBottomSheet(context, ref),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5)),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: theme.colorScheme.surface,
                              backgroundImage: user.photoUrl != null && !isUploading
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: isUploading
                                  ? const CircularProgressIndicator(color: AppColors.primary)
                                  : (user.photoUrl == null
                                      ? Text(
                                          user.displayName.isNotEmpty
                                              ? user.displayName[0].toUpperCase()
                                              : 'U',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        )
                                      : null),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${user.level} • $levelTitle',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. XP Progress Detail
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Experience',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${user.xp} XP',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: user.levelProgress,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level ${user.level}',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${user.xpToNextLevel} XP left to Level ${user.level + 1}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Stats Rows
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(
                      context,
                      'Quizzes taken',
                      '${user.quizzesTaken}',
                      Icons.emoji_events_rounded,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMiniStat(
                      context,
                      'Avg. Accuracy',
                      '${(user.accuracy * 100).toInt()}%',
                      Icons.insights_rounded,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 4. Badges / Achievements Title
              Text(
                'Unlocked Badges',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              
              // Grid list of badges
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allBadges.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final badge = allBadges[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Badge Icon
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: badge.isUnlocked 
                                ? badge.color.withValues(alpha: 0.15) 
                                : Colors.grey.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            badge.isUnlocked ? badge.icon : '🔒',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Badge Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                badge.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: badge.isUnlocked 
                                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight) 
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                badge.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: badge.isUnlocked 
                                      ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight) 
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (badge.isUnlocked)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 20,
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 5. Dynamic Theme Mode Selector Tile
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
                  ),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Dark Mode Theme',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    currentThemeMode == ThemeMode.dark ? 'Enabled' : 'Disabled',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: currentThemeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    ref.read(themeModeProvider.notifier).state = 
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 6. Sign Out Button
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.error.withValues(alpha: 0.05),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle indicator
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Change Profile Picture',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a photo source to update your profile image',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSourceTile(
                          context: context,
                          ref: ref,
                          icon: Icons.photo_library_rounded,
                          title: 'Gallery',
                          description: 'Choose from photos',
                          source: ImageSource.gallery,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSourceTile(
                          context: context,
                          ref: ref,
                          icon: Icons.camera_alt_rounded,
                          title: 'Camera',
                          description: 'Take a live photo',
                          source: ImageSource.camera,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFD946EF)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceTile({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String description,
    required ImageSource source,
    required Gradient gradient,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _pickImage(context, ref, source);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
            ),
            color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        ref.read(profilePicLoadingProvider.notifier).state = true;
        await ref
            .read(authControllerProvider.notifier)
            .updateProfilePicture(pickedFile.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      ref.read(profilePicLoadingProvider.notifier).state = false;
    }
  }
}

class _BadgeItem {
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final Color color;

  const _BadgeItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });
}
