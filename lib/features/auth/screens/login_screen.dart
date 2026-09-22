import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../profile/viewmodels/player_profile_provider.dart';

/// Streamlined Social Login Screen supporting Gmail/Google and Facebook authentication.
class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  void _handleLogin(BuildContext context, String provider) {
    final profileProvider = context.read<PlayerProfileProvider>();
    profileProvider.initializeNewLogin(provider: provider);
    onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: AppSpacing.paddingLg,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                      ),
                      onPressed: onLoginSuccess,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: AppRadius.radiusPill,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryEmerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'WORD HUNT V2.4',
                          style: AppTextStyles.buttonSmall(
                            color: Colors.grey.shade700,
                          ).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3D Letter Tiles Logo: [W] [O] [R] [D]
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _build3DLetterTile('W', const Color(0xFF6C5CE7)),
                  const SizedBox(width: 8),
                  _build3DLetterTile('O', const Color(0xFF5138EE)),
                  const SizedBox(width: 8),
                  _build3DLetterTile('R', AppColors.coinGoldDark),
                  const SizedBox(width: 8),
                  _build3DLetterTile('D', AppColors.primaryCyan),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Greeting & Cloud Reassurance
              Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome to Word Hunt',
                      style: AppTextStyles.headlineLarge(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in with your account to sync puzzles, coins & 7-day streak across devices.',
                      style: AppTextStyles.bodySmall(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: AppRadius.radiusPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Cloud Save Active • Never lose your progress',
                              style: AppTextStyles.bodySmall().copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Social Sign-In Card
              AppCard(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CHOOSE LOGIN METHOD',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Google / Gmail Login Button
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.radiusPill,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const Key('google_login_button'),
                          borderRadius: AppRadius.radiusPill,
                          onTap: () => _handleLogin(context, 'google'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEA4335),
                                ),
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Continue with Google',
                                    style: AppTextStyles.buttonLarge(
                                      color: const Color(0xFF1F1F1F),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Facebook Login Button
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1877F2),
                        borderRadius: AppRadius.radiusPill,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1877F2).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const Key('facebook_login_button'),
                          borderRadius: AppRadius.radiusPill,
                          onTap: () => _handleLogin(context, 'facebook'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.facebook_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Continue with Facebook',
                                    style: AppTextStyles.buttonLarge(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Security reassurance text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Fast & secure • No password needed',
                              style: AppTextStyles.bodySmall().copyWith(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Terms & Privacy Footer
              Center(
                child: Text(
                  'Terms of Service • Privacy Policy',
                  style: AppTextStyles.bodySmall().copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DLetterTile(String char, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
