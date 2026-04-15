import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/components/ui/toast_notifier.dart';
import 'package:flutter_conference_speakup/store/connectivity_provider.dart';

/// Listens to connectivity changes and fires toasts just below the notch.
/// Drop this anywhere in the widget tree (renders as an empty SizedBox).
class ConnectivityToast extends ConsumerWidget {
  const ConnectivityToast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<NetworkState>(connectivityProvider, (prev, next) {
      if (next.quality == NetworkQuality.offline) {
        SToast.show(
          context,
          message: 'No internet connection',
          type: SToastType.error,
          duration: const Duration(seconds: 5),
        );
      } else if (next.quality == NetworkQuality.slow) {
        SToast.show(
          context,
          message: 'Slow network detected',
          type: SToastType.warning,
        );
      } else if (prev != null &&
          (prev.quality == NetworkQuality.offline ||
              prev.quality == NetworkQuality.slow)) {
        SToast.show(
          context,
          message: 'Back online',
          type: SToastType.success,
        );
      }
    });

    return const SizedBox.shrink();
  }
}
