import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Password input with visibility toggle.
class SPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;

  const SPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint,
    this.validator,
    this.textInputAction,
  });

  @override
  State<SPasswordField> createState() => _SPasswordFieldState();
}

class _SPasswordFieldState extends State<SPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }
}

/// Labeled text field with optional character counter.
class SLabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;

  const SLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: SColors.error),
              ),
          ],
        ),
        const SizedBox(height: SSizes.sm),
        child,
      ],
    );
  }
}

/// OTP / Verification code input fields.
class SOtpField extends StatelessWidget {
  final int length;
  final ValueChanged<String>? onCompleted;

  const SOtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controllers = List.generate(length, (_) => TextEditingController());
    final focusNodes = List.generate(length, (_) => FocusNode());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        return Container(
          width: 48,
          height: 56,
          margin: EdgeInsets.only(right: i < length - 1 ? SSizes.sm : 0),
          child: TextFormField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: isDark ? SColors.darkCard : SColors.lightElevated,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && i < length - 1) {
                focusNodes[i + 1].requestFocus();
              }
              if (value.isEmpty && i > 0) {
                focusNodes[i - 1].requestFocus();
              }
              final code = controllers.map((c) => c.text).join();
              if (code.length == length) {
                onCompleted?.call(code);
              }
            },
          ),
        );
      }),
    );
  }
}
