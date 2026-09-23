import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/main_navigation_shell.dart';
import '../../../core/audio/audio_haptic_service.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../auth/screens/login_screen.dart';
import '../../levels/viewmodels/level_progress_provider.dart';
import '../../profile/viewmodels/player_profile_provider.dart';
import '../../themes/screens/themes_screen.dart';
import '../../../core/network/api_endpoints.dart';

/// Settings Screen for sound, haptics, cloud save, and reset options.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HiveStorageService _storage = HiveStorageService();
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings = _storage.getSettings();
  }

  void _updateSetting(String key, bool value) {
    setState(() {
      _settings[key] = value;
    });
    _storage.saveSettings(_settings);

    if (key == 'soundFx') {
      AudioHapticService.soundEnabled = value;
    } else if (key == 'haptics') {
      AudioHapticService.hapticsEnabled = value;
    }
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text(
          'This will reset your levels, stars, coins, and achievements to default values. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Reset profile
              final profile = _storage.getPlayerProfile();
              profile['coins'] = 500;
              profile['highestUnlockedLevel'] = 1;
              profile['currentLevel'] = 1;
              profile['totalStars'] = 0;
              profile['puzzlesSolved'] = 0;
              profile['wordsFound'] = 0;
              await _storage.savePlayerProfile(profile);
              await _storage.clearActiveGame();

              if (mounted) {
                context.read<PlayerProfileProvider>().refreshFromStorage();
                context.read<LevelProgressProvider>().resetProgress();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress reset successfully')),
                );
              }
            },
            child: const Text(
              'RESET',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out? Your game progress remains saved on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (loginContext) => LoginScreen(
                    onLoginSuccess: () {
                      Navigator.of(loginContext).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MainNavigationShell(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
                (route) => false,
              );
              messenger.showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text(
              'LOG OUT',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppCustomBar(title: 'Settings'),
      body: GradientBackground(
        child: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            // Audio & Haptics Section
            Text(
              'AUDIO & HAPTICS',
              style: AppTextStyles.titleSmall(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Sound Effects'),
                    subtitle: const Text('Tile select and word find audio'),
                    secondary: const Icon(Icons.volume_up_rounded),
                    value: _settings['soundFx'] as bool? ?? true,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (val) => _updateSetting('soundFx', val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Background Music'),
                    subtitle: const Text('Relaxing ambient melodies'),
                    secondary: const Icon(Icons.music_note_rounded),
                    value: _settings['music'] as bool? ?? true,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (val) => _updateSetting('music', val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Haptic Vibration'),
                    subtitle: const Text('Grid swipe and completion feedback'),
                    secondary: const Icon(Icons.vibration_rounded),
                    value: _settings['haptics'] as bool? ?? true,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (val) => _updateSetting('haptics', val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Gameplay & Appearance Section
            Text(
              'APPEARANCE & CLOUD',
              style: AppTextStyles.titleSmall(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Theme & Tile Skins'),
                    subtitle: const Text(
                      'Customize your colors and board styles',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ThemesScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Daily puzzle reminders & streaks'),
                    secondary: const Icon(Icons.notifications_outlined),
                    value: _settings['notifications'] as bool? ?? true,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (val) => _updateSetting('notifications', val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Cloud Sync (Play Games)'),
                    subtitle: const Text(
                      'Sync badges and stars across devices',
                    ),
                    secondary: const Icon(Icons.cloud_sync_outlined),
                    value: _settings['cloudSave'] as bool? ?? true,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (val) => _updateSetting('cloudSave', val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.cloud_done_rounded,
                      color: ApiEndpoints.isServerOnline
                          ? const Color(0xFF10B981)
                          : Colors.amber.shade700,
                    ),
                    title: const Text('Backend API Server'),
                    subtitle: Text(
                      ApiEndpoints.isServerOnline
                          ? 'Connected (${ApiEndpoints.baseUrl})'
                          : 'Offline / Disconnected',
                      style: TextStyle(
                        fontSize: 12,
                        color: ApiEndpoints.isServerOnline
                            ? const Color(0xFF10B981)
                            : Colors.amber.shade800,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final profileProvider = context.read<PlayerProfileProvider>();
                        final ok = await ApiEndpoints.init();
                        if (!mounted) return;
                        setState(() {});
                        if (ok) {
                          profileProvider.refreshFromStorage();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Connected to live Word Hunter backend!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Could not reach backend on localhost:5000'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      child: const Text('RECONNECT'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Danger Zone
            Text(
              'ACCOUNT & DATA',
              style: AppTextStyles.titleSmall(
                color: AppColors.error,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Reset Game Progress',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Wipe local solve data and restart from Level 1',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _showResetConfirmDialog,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              key: const Key('logout_button'),
              text: 'LOG OUT',
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.outline,
              customColor: AppColors.error,
              textColor: AppColors.error,
              onPressed: _showLogoutConfirmDialog,
            ),
            const SizedBox(height: AppSpacing.xl),

            // About Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'WORD HUNT v1.0.0',
                    style: AppTextStyles.buttonSmall(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Built with Flutter • Offline First',
                    style: AppTextStyles.bodySmall().copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
