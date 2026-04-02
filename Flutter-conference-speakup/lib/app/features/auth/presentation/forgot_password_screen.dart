import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';
import 'package:video_confrence_app/app/components/ui/button.dart';
import 'package:video_confrence_app/app/components/ui/input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SSizes.pagePadding),
          child: _emailSent ? _buildSentState(isDark) : _buildForm(isDark),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          STexts.forgotPassword,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: SSizes.sm),
        Text(
          'Enter your email and we\'ll send you a reset link.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
              ),
        ),
        const SizedBox(height: SSizes.xl),
        SInput(
          controller: _emailCtrl,
          label: STexts.email,
          hint: 'you@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: SSizes.lg),
        SButton(
          text: 'Send Reset Link',
          isLoading: _isLoading,
          onPressed: () {
            // TODO: Forgot password logic
            setState(() => _emailSent = true);
          },
        ),
      ],
    );
  }

  Widget _buildSentState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 80, color: SColors.primary),
          const SizedBox(height: SSizes.lg),
          Text('Check your email', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: SSizes.sm),
          Text(
            'We sent a password reset link to\n${_emailCtrl.text}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: SSizes.xl),
          SButton(
            text: 'Back to Login',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
