import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';
import '../data/outbox.dart';

class ActionStrip extends ConsumerWidget {
  const ActionStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider);
    final events = ref.watch(outboxProvider);
    final pending = ref.watch(pendingCountProvider);
    final done = events.any((e) =>
        e.patientId == demoPatient.id && e.type.startsWith('DISCHARGE'));

    final color = online ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final label = done
        ? 'Discharged'
        : online
            ? 'Discharge patient'
            : 'Discharge patient (saved on this device)';
    final status = events.isEmpty
        ? 'No claims yet'
        : pending == 0
            ? 'All claims sent to SHA'
            : online
                ? 'Sending claim to SHA...'
                : '$pending claim${pending == 1 ? '' : 's'} saved here, '
                    'waiting for internet';

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
                    if (context.mounted) _showDone(context, offline: !online);
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

void _showDone(BuildContext context, {required bool offline}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Mother discharged', textAlign: TextAlign.center),
      content: Text(
        offline
            ? 'No internet, so the claim is saved on this device. '
                'It goes to SHA automatically when the internet returns.'
            : 'The claim is being sent to SHA.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
      ],
    ),
  );
}