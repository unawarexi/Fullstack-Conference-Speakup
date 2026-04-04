import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/text_strings.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/components/ui/input.dart';

class JoinMeetingScreen extends StatefulWidget {
  const JoinMeetingScreen({super.key});

  @override
  State<JoinMeetingScreen> createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  final _meetingIdCtrl = TextEditingController();
  bool _muteAudio = false;
  bool _muteVideo = false;

  @override
  void dispose() {
    _meetingIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(STexts.joinMeeting)),
      body: Padding(
        padding: const EdgeInsets.all(SSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SInput(
              controller: _meetingIdCtrl,
              label: STexts.meetingId,
              hint: STexts.enterMeetingId,
              prefixIcon: Icons.link,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: SSizes.lg),
            SwitchListTile(
              title: const Text('Mute microphone'),
              value: _muteAudio,
              onChanged: (v) => setState(() => _muteAudio = v),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Turn off camera'),
              value: _muteVideo,
              onChanged: (v) => setState(() => _muteVideo = v),
              contentPadding: EdgeInsets.zero,
            ),
            const Spacer(),
            SButton(
              text: STexts.joinMeeting,
              onPressed: _meetingIdCtrl.text.isNotEmpty
                  ? () {
                      context.push('/meeting/${_meetingIdCtrl.text}');
                    }
                  : null,
            ),
            const SizedBox(height: SSizes.lg),
          ],
        ),
      ),
    );
  }
}
