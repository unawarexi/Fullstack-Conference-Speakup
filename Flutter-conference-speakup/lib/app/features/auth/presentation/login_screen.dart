import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/animations/screen_animations.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/image_strings.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/text_strings.dart';
import 'package:flutter_conference_speakup/app/features/auth/usecases/login_usecase.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late LoginUseCase _loginUseCase;
  late SheetRevealAnim _sheetAnim;

  @override
  void initState() {
    super.initState();
    _sheetAnim = SheetRevealAnim(vsync: this);
    _sheetAnim.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginUseCase = LoginUseCase(
      ref: ref,
      context: context,
      onStateChanged: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _sheetAnim.dispose();
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
            position: _sheetAnim.slide,
            child: FadeTransition(
              opacity: _sheetAnim.fade,
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
                    padding: const EdgeInsets.fromLTRB(
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
                position: _sheetAnim.slide,
                child: FadeTransition(
                  opacity: _sheetAnim.fade,
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

  // ─────────────── AUTH CONTENT ───────────────
  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;
    final secondaryColor = isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Greeting ──
        Text(
          'Welcome to ${STexts.appName}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: SSizes.xs),
        Text(
          'Sign in to continue',
          style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
        ),
        const SizedBox(height: SSizes.sectionSpacing),

        // ── OAuth buttons ──
        _OAuthButton(
          label: STexts.continueWithGoogle,
          icon: 'G',
          iconColor: const Color(0xFF4285F4),
          isLoading: _loginUseCase.isLoading,
          onTap: _loginUseCase.signInWithGoogle,
        ),
        const SizedBox(height: SSizes.sm + 4),
        _OAuthButton(
          label: STexts.continueWithGithub,
          icon: '',
          useGithubIcon: true,
          isLoading: _loginUseCase.isLoading,
          onTap: _loginUseCase.signInWithGithub,
        ),

        const SizedBox(height: SSizes.xl),

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
  final bool isLoading;
  final VoidCallback onTap;

  const _OAuthButton({
    required this.label,
    this.icon = '',
    this.iconColor,
    this.useGithubIcon = false,
    this.isLoading = false,
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
        onPressed: isLoading ? null : onTap,
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
