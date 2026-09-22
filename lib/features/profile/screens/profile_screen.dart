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
import '../../achievements/screens/achievements_screen.dart';
import '../../levels/screens/level_map_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../themes/screens/themes_screen.dart';
import '../viewmodels/player_profile_provider.dart';

/// Player Profile screen matching the exact Word Hunt design mockup.
class ProfileScreen extends StatelessWidget {
  final VoidCallback? onOpenBadges;
  final VoidCallback? onOpenJourney;

  const ProfileScreen({
    super.key,
    this.onOpenBadges,
    this.onOpenJourney,
  });

  void _openBadges(BuildContext context) {
    if (onOpenBadges != null) {
      onOpenBadges!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AchievementsScreen()),
      );
    }
  }

  void _openJourney(BuildContext context) {
    if (onOpenJourney != null) {
      onOpenJourney!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LevelMapScreen()),
      );
    }
  }

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
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                    child: Stack(
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
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.coinGold.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
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

            // 4-Tile Statistics Grid
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
                InkWell(
                  onTap: () => _openBadges(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All (18)',
                          style: AppTextStyles.buttonSmall(
                            color: theme.colorScheme.primary,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _buildBadgePill(
                    context,
                    'Speed Solver',
                    'Gold Tier',
                    Icons.bolt_rounded,
                    AppColors.coinGold,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _buildBadgePill(
                    context,
                    'Perfectionist',
                    'Master Tier',
                    Icons.star_rounded,
                    const Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _buildBadgePill(
                    context,
                    'Ocean Diver',
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
              onTap: () => _openJourney(context),
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
                      value: profile.isCloudSaveEnabled,
                      onChanged: (val) {
                        profile.toggleCloudSave(val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text(
                              val ? 'Cloud save enabled' : 'Cloud save paused',
                            ),
                          ),
                        );
                      },
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
            const SizedBox(height: 100),
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
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      onTap: () => _openBadges(context),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 9),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showEditNicknameDialog(
    BuildContext context,
    PlayerProfileProvider profile,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _EditNicknameDialog(
        currentNickname: profile.nickname,
        onSave: (newName) => profile.updateNickname(newName),
      ),
    );
  }
}

class _EditNicknameDialog extends StatefulWidget {
  final String currentNickname;
  final ValueChanged<String> onSave;

  const _EditNicknameDialog({
    required this.currentNickname,
    required this.onSave,
  });

  @override
  State<_EditNicknameDialog> createState() => _EditNicknameDialogState();
}

class _EditNicknameDialogState extends State<_EditNicknameDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNickname);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    _controller.addListener(() {
      if (_errorText != null) {
        setState(() => _errorText = null);
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _errorText = 'Nickname cannot be empty');
      return;
    }
    if (trimmed.length < 3) {
      setState(() => _errorText = 'Must be at least 3 characters');
      return;
    }
    widget.onSave(trimmed);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final currentLength = _controller.text.length;
    const maxLength = 20;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151928) : Colors.white,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color: primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon Badge
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title & Subtitle
            Text(
              'Edit Nickname',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your display name for leaderboards and achievements',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stylish Modernized TextField
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: AppRadius.radiusMd,
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: maxLength,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                style: AppTextStyles.headlineSmall(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                cursorColor: primary,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter new nickname',
                  hintStyle: AppTextStyles.bodyMedium(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E2438)
                      : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: primary,
                        size: 20,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.cancel_rounded,
                            size: 20,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          onPressed: () => _controller.clear(),
                          tooltip: 'Clear',
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide(
                      color: _errorText != null
                          ? const Color(0xFFEF4444)
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.radiusMd,
                    borderSide: BorderSide(
                      color: _errorText != null
                          ? const Color(0xFFEF4444)
                          : primary,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),

            // Character count & validation message
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_errorText != null)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      '3-20 characters',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  Text(
                    '$currentLength/$maxLength',
                    style: AppTextStyles.bodySmall().copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: currentLength >= maxLength
                          ? AppColors.coinGoldDark
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Buttons: Cancel & Save
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.secondary,
                    height: 46,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: 'Save',
                    icon: Icons.check_rounded,
                    height: 46,
                    onPressed: _controller.text.trim().isNotEmpty ? _save : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
