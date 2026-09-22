import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../settings/screens/settings_screen.dart';
import '../../themes/screens/themes_screen.dart';
import '../viewmodels/player_profile_provider.dart';

/// Player Profile screen matching the exact Word Hunt design mockup.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<PlayerProfileProvider>();

    return Scaffold(
      appBar: AppCustomBar(
        title: 'Player Profile',
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: GradientBackground(
        child: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            // Avatar & Player Identity Card
            AppCard(
              padding: AppSpacing.paddingLg,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.coinGold,
                            width: 3,
                          ),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5138EE), Color(0xFF6C5CE7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.coinGold,
                          borderRadius: AppRadius.radiusPill,
                        ),
                        child: Text(
                          'Lvl ${profile.playerLevel}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile.nickname,
                    style: AppTextStyles.headlineLarge(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    profile.playerTag,
                    style: AppTextStyles.bodySmall().copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.radiusPill,
                    ),
                    child: Text(
                      '⭐ ${profile.playerTitle}',
                      style: AppTextStyles.buttonSmall(
                        color: theme.colorScheme.primary,
                      ).copyWith(fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Edit Profile',
                          icon: Icons.edit_outlined,
                          variant: AppButtonVariant.outline,
                          height: 38,
                          onPressed: () {
                            _showEditNicknameDialog(context, profile);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          text: 'Share Profile',
                          icon: Icons.share_outlined,
                          variant: AppButtonVariant.outline,
                          height: 38,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profile link copied to clipboard!',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Lifetime Stats Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lifetime Stats', style: AppTextStyles.headlineSmall()),
                Text('All Game Modes', style: AppTextStyles.bodySmall()),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // 6-Tile Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.grid_view_rounded,
                    value: '${profile.puzzlesSolved}',
                    label: 'Levels Solved',
                    color: const Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.search_rounded,
                    value: '${profile.wordsFound}',
                    label: 'Words Found',
                    color: AppColors.primaryCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.timer_outlined,
                    value: profile.playTime,
                    label: 'Play Time',
                    color: AppColors.primaryEmerald,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.local_fire_department_rounded,
                    value: '${profile.streak} Days',
                    label: 'Daily Streak',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.military_tech_rounded,
                    value: '${profile.bestScore}',
                    label: 'High Score',
                    color: AppColors.coinGoldDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.track_changes_rounded,
                    value: '${profile.accuracyRate}%',
                    label: 'Accuracy Rate',
                    color: AppColors.primaryEmerald,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Featured Badges Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '⭐ Featured Badges',
                    style: AppTextStyles.headlineSmall(),
                  ),
                ),
                Text(
                  'View All (18)',
                  style: AppTextStyles.buttonSmall(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _buildBadgePill(
                    'Speed Solver',
                    'Gold Tier',
                    Icons.bolt_rounded,
                    AppColors.coinGold,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _buildBadgePill(
                    'Perfect...',
                    'Master Tier',
                    Icons.star_rounded,
                    const Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _buildBadgePill(
                    'Ocean...',
                    'Special Event',
                    Icons.water_rounded,
                    AppColors.primaryCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Current Journey Card
            AppCard(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryCyan.withValues(alpha: 0.15),
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: const Icon(
                          Icons.waves_rounded,
                          color: AppColors.primaryCyan,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT JOURNEY',
                              style: AppTextStyles.bodySmall().copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'World 2: Ocean Sanctuary',
                              style: AppTextStyles.headlineSmall().copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Level 27/40',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const AppProgressBar(
                    progress: 27 / 40,
                    height: 6,
                    fillColor: AppColors.primaryCyan,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Navigation & System List Tiles
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.cloud_done_rounded,
                      color: AppColors.primaryEmerald,
                    ),
                    title: const Text('Cloud Save Active'),
                    subtitle: const Text(
                      'Google Play Games Sync',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeTrackColor: AppColors.primaryEmerald,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.tune_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Game Settings & Audio'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.palette_rounded,
                      color: Color(0xFF8B5CF6),
                    ),
                    title: const Text('My Themes & Tile Skins'),
                    subtitle: const Text(
                      '3 Unlocked',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ThemesScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.blue,
                    ),
                    title: const Text('Help & Player Support'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Contact support: support@wordhunt.app',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headlineMedium().copyWith(fontSize: 18),
          ),
          Text(label, style: AppTextStyles.bodySmall().copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBadgePill(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditNicknameDialog(
    BuildContext context,
    PlayerProfileProvider profile,
  ) {
    final controller = TextEditingController(text: profile.nickname);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Nickname'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new nickname'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                profile.updateNickname(controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
