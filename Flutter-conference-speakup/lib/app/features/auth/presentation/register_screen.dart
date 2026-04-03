import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';
import 'package:video_confrence_app/app/components/ui/button.dart';
import 'package:video_confrence_app/app/components/ui/input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  STexts.signUp,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: SSizes.sm),
                Text(
                  'Create your SpeakUp account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                ),
                const SizedBox(height: SSizes.xl),
                SInput(
                  controller: _nameCtrl,
                  label: STexts.fullName,
                  hint: 'John Doe',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: SSizes.md),
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
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.next,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Min 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: SSizes.md),
                SInput(
                  controller: _confirmPasswordCtrl,
                  label: STexts.confirmPassword,
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  suffix: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'Passwords don\'t match';
                    return null;
                  },
                ),
                const SizedBox(height: SSizes.xl),
                SButton(
                  text: STexts.signUp,
                  isLoading: _isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Register logic
                    }
                  },
                ),
                const SizedBox(height: SSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      STexts.alreadyHaveAccount,
                      style: TextStyle(
                        color: isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(STexts.login),
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
