import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api.dart';
import '../data/app_state.dart';
import '../data/messages.dart';
import '../data/outbox.dart';
import '../data/sync.dart';
import 'sign_in_dialog.dart';

class ActionStrip extends ConsumerWidget {
  const ActionStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider);
    final events = ref.watch(outboxProvider);
    final pending = ref.watch(pendingCountProvider);
    final sync = ref.watch(syncStatusProvider);
    final sending = ref.watch(syncingProvider);
    final done = events.any((e) =>
        e.patientId == demoPatient.id && e.type.startsWith('DISCHARGE'));

    final color = online ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final label = done
        ? 'Discharged'
        : online
            ? 'Discharge patient'
            : 'Discharge patient (saved on this device)';
    final status = syncLine(
      total: events.length,
      pending: pending,
      online: online,
      sending: sending,
      status: sync,
    );
    final canSignIn =
        online && pending > 0 && sync.phase == SyncPhase.needsSignIn;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.black87,
              disabledBackgroundColor: context.good.withValues(alpha: 0.18),
              disabledForegroundColor: context.good,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: done
                ? null
                : () async {
                    final type = online ? 'DISCHARGE' : 'DISCHARGE_TRUST';
                    await ref
                        .read(outboxProvider.notifier)
                        .queue(demoPatient.id, type);
                    if (context.mounted) {
                      _showDone(
                        context,
                        offline: !online,
                        signedIn: ref.read(accessTokenProvider) != null,
                      );
                    }
                  },
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(status,
                  style: TextStyle(color: context.mutedTxt, fontSize: 12)),
            ),
            if (canSignIn)
              TextButton(
                onPressed: () => showSignInDialog(context),
                child: const Text('Sign in', style: TextStyle(fontSize: 12)),
              ),
            TextButton(
              onPressed: () => ref.read(outboxProvider.notifier).clear(),
              child: Text('Reset demo',
                  style: TextStyle(fontSize: 12, color: context.mutedTxt)),
            ),
          ],
        ),
      ],
    );
  }
}

void _showDone(BuildContext context,
    {required bool offline, required bool signedIn}) {
  final needsSignIn = !offline && !signedIn;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Mother discharged', textAlign: TextAlign.center),
      content: Text(
        offline
            ? 'No internet, so the claim is saved on this device. '
                'It goes to SHA automatically when the internet returns.'
            : signedIn
                ? 'The claim is being sent to SHA.'
                : 'The claim is saved on this device. '
                    'Sign in to send it to SHA.',
        textAlign: TextAlign.center,
      ),
      actions: [
        if (needsSignIn)
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              showSignInDialog(context);
            },
            child: const Text('Sign in'),
          ),
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(needsSignIn ? 'Later' : 'Done')),
      ],
    ),
  );
}
