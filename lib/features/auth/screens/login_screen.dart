import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_background.dart';
import 'signup_screen.dart';

/// Log In Screen matching the exact Word Hunt design mockup.
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(
    text: 'wordhunter@example.com',
  );
  final _passwordController = TextEditingController(text: '••••••••••••');
  bool _rememberMe = true;
  bool _obscurePassword = true;

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
                      onPressed: widget.onLoginSuccess,
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
              const SizedBox(height: AppSpacing.lg),

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
              const SizedBox(height: AppSpacing.md),

              // Greeting & Cloud Reassurance
              Center(
                child: Column(
                  children: [
                    Text(
                      'Welcome Back, Hunter!',
                      style: AppTextStyles.headlineLarge(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log in to sync your puzzles, coins & 7-day streak across devices.',
                      style: AppTextStyles.bodySmall(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
                          Text(
                            'Cloud Save Active • Never lose your progress',
                            style: AppTextStyles.bodySmall().copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Form Card
              AppCard(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email or Player Tag',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.mail_outline_rounded,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.radiusMd,
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Secret Password',
                          style: AppTextStyles.bodySmall().copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.radiusMd,
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Remember Me Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? true),
                          activeColor: const Color(0xFF6C5CE7),
                        ),
                        Text(
                          'Remember me on this device',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Primary Button: LOG IN & PLAY
                    AppButton(
                      text: 'LOG IN & PLAY',
                      icon: Icons.play_arrow_rounded,
                      onPressed: widget.onLoginSuccess,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Social Divider
                    Center(
                      child: Text(
                        '── OR CONTINUE WITH ──',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Google and Apple Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Text(
                              'G',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            label: const Text('Google'),
                            onPressed: widget.onLoginSuccess,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.radiusMd,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.apple_rounded, size: 20),
                            label: const Text('Apple'),
                            onPressed: widget.onLoginSuccess,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Play as Guest Button
                    AppButton(
                      text: 'Play as Guest (Progress saved locally)',
                      icon: Icons.sports_esports_rounded,
                      variant: AppButtonVariant.secondary,
                      height: 44,
                      onPressed: widget.onLoginSuccess,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Bonus Coins Promo Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.coinGold.withValues(alpha: 0.15),
                  borderRadius: AppRadius.radiusPill,
                  border: Border.all(
                    color: AppColors.coinGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Center(
                  child: Text(
                    '🪙 +100 Bonus Coins credited upon sign in!',
                    style: AppTextStyles.buttonSmall(
                      color: AppColors.coinGoldDark,
                    ).copyWith(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Create account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New to Word Hunt? ', style: AppTextStyles.bodySmall()),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SignUpScreen(
                            onSignUpSuccess: widget.onLoginSuccess,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Create an Account',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  'Terms of Service • Privacy Policy',
                  style: AppTextStyles.bodySmall().copyWith(fontSize: 10),
                ),
              ),
              const SizedBox(height: 20),
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
