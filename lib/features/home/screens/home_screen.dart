import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../game/screens/game_screen.dart';
import '../../profile/viewmodels/player_profile_provider.dart';
import '../../settings/screens/settings_screen.dart';

/// Home Dashboard matching the exact Word Hunt design mockups.
class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenMap;
  final VoidCallback onOpenThemes;
  final VoidCallback onOpenAchievements;
  final VoidCallback onOpenProfile;

  const HomeScreen({
    super.key,
    required this.onOpenMap,
    required this.onOpenThemes,
    required this.onOpenAchievements,
    required this.onOpenProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptUsername();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptUsername();
    });
  }

  void _checkAndPromptUsername() {
    if (!mounted || _dialogShown) return;
    final profile = context.read<PlayerProfileProvider>();
    if (profile.needsUsernameSetup && !profile.hasSetUniqueUsername) {
      _dialogShown = true;
      _showUniqueUsernameDialog();
    }
  }

  void _showUniqueUsernameDialog() {
    final profile = context.read<PlayerProfileProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UniqueUsernameDialog(profile: profile),
    );
  }

  void _onPlayLevel(
    BuildContext context, {
    int level = 27,
    String category = 'Nature World',
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(levelNumber: level, category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<PlayerProfileProvider>();

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: AppSpacing.paddingMd,
            children: [
              // Top Bar: Player Avatar & Coins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onOpenProfile,
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.coinGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${profile.playerLevel}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PLAYER',
                                  style: AppTextStyles.bodySmall().copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  profile.nickname,
                                  style: AppTextStyles.headlineSmall().copyWith(
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),

                  // Coin Badge with + button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CoinBadge(
                        coins: profile.coins,
                        showAddIcon: true,
                        onTap: () {
                          profile.updateCoins(100);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('+100 Coins added!')),
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good evening, Subha 👋',
                          style: AppTextStyles.headlineLarge().copyWith(
                            fontSize: 22,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ready to solve your evening puzzles?',
                          style: AppTextStyles.bodySmall(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.radiusPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lvl ${profile.playerLevel}',
                          style: AppTextStyles.buttonSmall(
                            color: theme.colorScheme.primary,
                          ).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Hero "CONTINUE PUZZLE" Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5138EE), Color(0xFF6C5CE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.radiusXl,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5138EE).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: AppRadius.radiusPill,
                                ),
                                child: Text(
                                  'CONTINUE PUZZLE',
                                  style: AppTextStyles.buttonSmall(
                                    color: Colors.white,
                                  ).copyWith(fontSize: 10, letterSpacing: 0.8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Level ${profile.currentLevel}',
                                style: AppTextStyles.displaySmall(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Nature World',
                                style: AppTextStyles.bodyMedium(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 3x3 Mini Grid Preview Graphic
                        Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMiniRow(['B', 'I', 'R']),
                              _buildMiniRow(['D', 'E', 'S']),
                              _buildMiniRow(['T', 'R', 'E']),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: AppTextStyles.bodySmall(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          '8 of 10 words found',
                          style: AppTextStyles.bodySmall(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 0.8),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, factor, _) {
                        return ClipRRect(
                          borderRadius: AppRadius.radiusPill,
                          child: Container(
                            height: 8,
                            color: Colors.white.withValues(alpha: 0.25),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: factor,
                                child: Container(
                                  color: AppColors.primaryEmerald,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.radiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AppButton(
                        text: 'CONTINUE PLAYING',
                        icon: Icons.play_arrow_rounded,
                        customColor: Colors.white,
                        onPressed: () =>
                            _onPlayLevel(context, level: profile.currentLevel),
                        height: 48,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3 Lifetime Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.starActive,
                      label: 'BEST SCORE',
                      value: '${profile.bestScore}',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.warning,
                      label: 'STREAK',
                      value: '${profile.streak} Days',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppColors.coinGoldDark,
                      label: 'SOLVED',
                      value: '${profile.puzzlesSolved} Puzzles',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Daily Challenge Teaser Card
              AppCard(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.warning,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'DAILY CHALLENGE',
                              style: AppTextStyles.bodySmall().copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' • Sept 21',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Autumn Breeze',
                            style: AppTextStyles.headlineSmall().copyWith(
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: [
                              _buildMiniBadge('🔥 HARD', AppColors.error),
                              _buildMiniBadge(
                                '+50 Coins',
                                AppColors.coinGoldDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      text: 'PLAY TODAY',
                      customColor: const Color(0xFFF97316),
                      height: 38,
                      onPressed: () => _onPlayLevel(
                        context,
                        level: 0,
                        category: 'Autumn Breeze',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // World Journey Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('World Journey', style: AppTextStyles.headlineSmall()),
                  GestureDetector(
                    onTap: widget.onOpenMap,
                    child: Text(
                      'View All >',
                      style: AppTextStyles.buttonSmall(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                onTap: widget.onOpenMap,
                padding: AppSpacing.paddingMd,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryEmerald.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: AppColors.primaryEmerald,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'WORLD 1: NATURE',
                                    style: AppTextStyles.headlineSmall()
                                        .copyWith(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                ],
                              ),
                              Text(
                                'Levels 1–20 • Completed',
                                style: AppTextStyles.bodySmall(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: AppRadius.radiusPill,
                          ),
                          child: const Text(
                            '100%',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const AppProgressBar(
                      progress: 1.0,
                      height: 6,
                      fillColor: AppColors.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniRow(List<String> chars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: chars
          .map(
            (c) => Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusXs,
              ),
              child: Center(
                child: Text(
                  c,
                  style: const TextStyle(
                    color: Color(0xFF5138EE),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return AppCard(
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
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineSmall().copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusPill,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// One-time unique username generator dialog.
class _UniqueUsernameDialog extends StatefulWidget {
  final PlayerProfileProvider profile;

  const _UniqueUsernameDialog({required this.profile});

  @override
  State<_UniqueUsernameDialog> createState() => _UniqueUsernameDialogState();
}

class _UniqueUsernameDialogState extends State<_UniqueUsernameDialog> {
  late final TextEditingController _controller;
  String _currentTag = '';
  String? _errorMessage;

  static const List<String> _prefixes = [
    'Word',
    'Lexi',
    'Quest',
    'Cipher',
    'Hunt',
    'Vowel',
    'Riddle',
    'Glyph',
    'Alpha',
    'Star',
    'Cosmic',
    'Shadow',
    'Mythic',
    'Epic',
    'Nova',
    'Pixel',
  ];

  static const List<String> _suffixes = [
    'Hunter',
    'Master',
    'Seeker',
    'Knight',
    'Sage',
    'Ninja',
    'Slayer',
    'Warden',
    'Wizard',
    'Hero',
    'Finder',
    'Legend',
    'Scout',
    'Champ',
    'Falcon',
    'Spark',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _generateRandomUsername());
    _currentTag = '#WH-${1000 + Random().nextInt(9000)}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _generateRandomUsername() {
    final rand = Random();
    final p = _prefixes[rand.nextInt(_prefixes.length)];
    final s = _suffixes[rand.nextInt(_suffixes.length)];
    final num = 100 + rand.nextInt(900);
    return '$p${s}_$num';
  }

  void _onRoll() {
    setState(() {
      _controller.text = _generateRandomUsername();
      _currentTag = '#WH-${1000 + Random().nextInt(9000)}';
      _errorMessage = null;
    });
  }

  void _onConfirm() {
    final name = _controller.text.trim();
    if (name.length < 3) {
      setState(() => _errorMessage = 'Username must be at least 3 characters');
      return;
    }
    if (name.length > 18) {
      setState(() => _errorMessage = 'Username must be 18 characters or fewer');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
      setState(
        () => _errorMessage = 'Only letters, numbers, and underscores allowed',
      );
      return;
    }

    widget.profile.setUniqueUsername(name, tag: _currentTag);
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 Welcome aboard, $name! Your unique tag is $_currentTag',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: theme.cardTheme.color,
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar / Crown icon badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.coinGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.coinGold.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('👑', style: TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'Claim Your Hunter Tag',
              style: AppTextStyles.headlineMedium(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Generate or customize your unique username. This is set one time only for your profile!',
              style: AppTextStyles.bodySmall(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Tag badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusPill,
              ),
              child: Text(
                'Assigned Tag: $_currentTag',
                style: AppTextStyles.buttonSmall(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Text input row with Roll button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: 18,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        size: 20,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                InkWell(
                  key: const Key('generate_username_button'),
                  borderRadius: AppRadius.radiusMd,
                  onTap: _onRoll,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.coinGold.withValues(alpha: 0.18),
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: AppColors.coinGold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎲', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text(
                          'Roll',
                          style: AppTextStyles.buttonSmall(
                            color: AppColors.coinGoldDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // Confirm button
            AppButton(
              key: const Key('confirm_username_button'),
              text: 'CONFIRM & START PLAYING',
              icon: Icons.check_circle_rounded,
              height: 48,
              onPressed: _onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
