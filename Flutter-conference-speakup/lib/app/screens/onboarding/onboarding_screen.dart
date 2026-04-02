import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      title: STexts.onboardingTitle1,
      subtitle: STexts.onboardingSubtitle1,
      icon: Icons.videocam_rounded,
    ),
    _OnboardingPage(
      title: STexts.onboardingTitle2,
      subtitle: STexts.onboardingSubtitle2,
      icon: Icons.chat_bubble_rounded,
    ),
    _OnboardingPage(
      title: STexts.onboardingTitle3,
      subtitle: STexts.onboardingSubtitle3,
      icon: Icons.lock_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: SSizes.animNormal),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? SColors.primary
                        : (isDark ? SColors.darkBorder : SColors.lightBorder),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SSizes.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SSizes.pagePadding),
              child: SizedBox(
                width: double.infinity,
                height: SSizes.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: SSizes.animNormal),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Navigate to auth
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Next'
                        : 'Get Started',
                  ),
                ),
              ),
            ),
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: () {
                  // Navigate to auth / skip
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary,
                  ),
                ),
              ),
            const SizedBox(height: SSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(SSizes.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: SColors.accentGradient,
              borderRadius: BorderRadius.circular(SSizes.radiusXl),
            ),
            child: Icon(icon, size: 56, color: Colors.white),
          ),
          const SizedBox(height: SSizes.xl),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SSizes.md),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? SColors.textDarkSecondary
                      : SColors.textLightSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
