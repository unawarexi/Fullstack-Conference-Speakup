import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/image_strings.dart';
import 'package:video_confrence_app/core/constants/responsive.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';
import 'package:video_confrence_app/app/components/ui/button.dart';
import 'package:video_confrence_app/app/components/ui/input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _sheetController;
  late Animation<Offset> _sheetSlide;
  late Animation<double> _sheetFade;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    ));
    _sheetFade = CurvedAnimation(
      parent: _sheetController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _sheetController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = SResponsive.isDesktop(context);
    return Scaffold(
      body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
    );
  }

  // ─────────────── MOBILE LAYOUT ───────────────
  Widget _buildMobile(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        // ── Top half: brand visual ──
        SizedBox(
          height: size.height * 0.40,
          width: double.infinity,
          child: _BrandHeader(isDark: isDark),
        ),

        // ── Bottom sheet: curved top ──
        Positioned(
          top: size.height * 0.34,
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: _sheetSlide,
            child: FadeTransition(
              opacity: _sheetFade,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      SSizes.pagePadding + 4,
                      SSizes.xl + 4,
                      SSizes.pagePadding + 4,
                      SSizes.xl,
                    ),
                    child: _buildForm(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────── DESKTOP LAYOUT ───────────────
  Widget _buildDesktop(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // ── Left: brand visual (50%) ──
        Expanded(
          child: _BrandHeader(isDark: isDark, isDesktop: true),
        ),

        // ── Right: form (50%) ──
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SlideTransition(
                position: _sheetSlide,
                child: FadeTransition(
                  opacity: _sheetFade,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SSizes.xxl,
                      vertical: SSizes.xl,
                    ),
                    child: _buildForm(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────── FORM ───────────────
  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;
    final secondaryColor = isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ──
          Text(
            'Welcome back',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: SSizes.xs),
          Text(
            'Sign in to continue to ${STexts.appName}',
            style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
          ),
          const SizedBox(height: SSizes.sectionSpacing),

          // ── OAuth buttons ──
          _OAuthButton(
            label: STexts.continueWithGoogle,
            icon: 'G',
            iconColor: const Color(0xFF4285F4),
            onTap: () {
              // TODO: Google sign-in
            },
          ),
          const SizedBox(height: SSizes.sm + 4),
          _OAuthButton(
            label: STexts.continueWithGithub,
            icon: '',
            useGithubIcon: true,
            onTap: () {
              // TODO: GitHub sign-in
            },
          ),

          const SizedBox(height: SSizes.lg),

          // ── Divider ──
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
                child: Text(
                  'or continue with email',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),

          const SizedBox(height: SSizes.lg),

          // ── Email ──
          SInput(
            controller: _emailCtrl,
            label: STexts.email,
            hint: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: SSizes.md),

          // ── Password ──
          SInput(
            controller: _passwordCtrl,
            label: STexts.password,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Min 6 characters';
              return null;
            },
          ),

          const SizedBox(height: SSizes.xs),

          // ── Forgot password ──
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: SSizes.sm, vertical: SSizes.xs),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                STexts.forgotPassword,
                style: TextStyle(
                  color: SColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: SSizes.lg),

          // ── Sign In button ──
          SButton(
            text: STexts.login,
            size: SButtonSize.lg,
            isLoading: _isLoading,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: Auth logic
              }
            },
          ),

          const SizedBox(height: SSizes.lg),

          // ── Sign up link ──
          Center(
            child: Text.rich(
              TextSpan(
                text: STexts.dontHaveAccount,
                style: TextStyle(color: secondaryColor, fontSize: 14),
                children: [
                  TextSpan(
                    text: STexts.signUp,
                    style: const TextStyle(
                      color: SColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: SSizes.lg),

          // ── Policy text ──
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
              child: Text.rich(
                TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: TextStyle(color: mutedColor, fontSize: 11, height: 1.5),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Brand header with logo + emblem
// ─────────────────────────────────────────────
class _BrandHeader extends StatelessWidget {
  final bool isDark;
  final bool isDesktop;

  const _BrandHeader({required this.isDark, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [SColors.darkBg, SColors.darkSurface, SColors.blue900.withValues(alpha: 0.4)]
              : [SColors.blue50, SColors.primarySurface, SColors.primary.withValues(alpha: 0.08)],
        ),
      ),
      child: Stack(
        children: [
          // Subtle glow
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emblem
                Image.asset(
                  SImages.brandEmblem,
                  width: isDesktop ? 100 : 80,
                  height: isDesktop ? 100 : 80,
                ),
                SizedBox(height: isDesktop ? SSizes.lg : SSizes.md),
                // Logo text
                Image.asset(
                  SImages.brandLogo,
                  width: isDesktop ? 180 : 140,
                  color: isDark ? Colors.white : null,
                ),
                SizedBox(height: isDesktop ? SSizes.md : SSizes.sm),
                Text(
                  STexts.appTagline,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  OAuth button (Google / GitHub)
// ─────────────────────────────────────────────
class _OAuthButton extends StatelessWidget {
  final String label;
  final String icon;
  final Color? iconColor;
  final bool useGithubIcon;
  final VoidCallback onTap;

  const _OAuthButton({
    required this.label,
    this.icon = '',
    this.iconColor,
    this.useGithubIcon = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: SSizes.buttonHeightMd + 4,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
          side: BorderSide(color: isDark ? SColors.darkBorder : SColors.lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useGithubIcon)
              Icon(
                Icons.code_rounded,
                size: 22,
                color: isDark ? SColors.textDark : SColors.textLight,
              )
            else
              Text(
                icon,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
            const SizedBox(width: SSizes.sm + 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? SColors.textDark : SColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
