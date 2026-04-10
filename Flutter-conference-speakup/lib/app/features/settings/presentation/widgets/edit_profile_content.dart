import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/components/ui/input.dart';

/// Stateful form for editing user name and bio inside a bottom sheet.
class EditProfileContent extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController bioController;
  final VoidCallback onSave;

  const EditProfileContent({
    super.key,
    required this.nameController,
    required this.bioController,
    required this.onSave,
  });

  @override
  State<EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<EditProfileContent> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SInput(
          controller: widget.nameController,
          label: 'Full Name',
          hint: 'Enter your name',
        ),
        const SizedBox(height: SSizes.md),
        SInput(
          controller: widget.bioController,
          label: 'Bio',
          hint: 'Tell us about yourself',
          maxLines: 3,
        ),
        const SizedBox(height: SSizes.lg),
        SButton(
          text: _saving ? 'Saving...' : 'Save Changes',
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  widget.onSave();
                },
        ),
      ],
    );
  }
}
