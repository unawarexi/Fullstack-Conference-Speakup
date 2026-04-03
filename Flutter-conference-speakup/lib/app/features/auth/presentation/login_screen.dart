import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';
import 'package:video_confrence_app/app/components/ui/button.dart';
import 'package:video_confrence_app/app/components/ui/input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  final bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: SSizes.xxl),
                Text(
                  STexts.login,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: SSizes.sm),
                Text(
                  STexts.appTagline,
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
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: SSizes.md),
                SInput(
                  controller: _passwordCtrl,
                  label: STexts.password,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: SSizes.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(STexts.forgotPassword),
                  ),
                ),
                const SizedBox(height: SSizes.lg),
                SButton(
                  text: STexts.login,
                  isLoading: _isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Auth logic
                    }
                  },
                ),
                const SizedBox(height: SSizes.lg),
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? SColors.darkBorder : SColors.lightBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
                      child: Text(
                        STexts.orSignInWith,
                        style: TextStyle(
                          color: isDark
                              ? SColors.textDarkTertiary
                              : SColors.textLightTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? SColors.darkBorder : SColors.lightBorder)),
                  ],
                ),
                const SizedBox(height: SSizes.lg),
                SButton(
                  text: STexts.continueWithGoogle,
                  variant: SButtonVariant.outline,
                  prefixIcon: Icons.g_mobiledata,
                  onPressed: () {},
                ),
                const SizedBox(height: SSizes.sm),
                SButton(
                  text: STexts.continueWithGithub,
                  variant: SButtonVariant.outline,
                  prefixIcon: Icons.code,
                  onPressed: () {},
                ),
                const SizedBox(height: SSizes.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      STexts.dontHaveAccount,
                      style: TextStyle(
                        color: isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text(STexts.signUp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
