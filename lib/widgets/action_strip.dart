import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';
import '../data/outbox.dart';

class ActionStrip extends ConsumerWidget {
  const ActionStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online  = ref.watch(onlineProvider);
    final syncing = ref.watch(syncingProvider);
    final pending = ref.watch(pendingCountProvider);
    final done    = ref.watch(outboxProvider).any((e) =>
      e.patientId == demoPatient.id && e.type.startsWith('DISCHARGE'));

    final color = online ? const Color(0xFF34D399) : const Color(0xFFFBBF24);
    final label = done
      ? 'Discharged \u2713'
      : online
        ? 'Discharge patient'
        : 'Discharge patient  (saves locally \u2014 syncs when connected)';

    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: double.infinity, height: 64,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black,
            disabledBackgroundColor: const Color(0xFF065F46),
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: done ? null : () async {
            final type = online ? 'DISCHARGE' : 'DISCHARGE_TRUST';
            await ref.read(outboxProvider.notifier).queue(demoPatient.id, type);
            if (context.mounted) _showDone(context, trust: !online);
          },
          child: Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          syncing
            ? 'Sending to SHA...'
            : pending == 0
              ? 'All claims sent \u2713'
              : '$pending claim${pending == 1 ? '' : 's'} saved locally',
          style: TextStyle(color: context.mutedTxt, fontSize: 12),
        ),
        TextButton(
          onPressed: () => ref.read(outboxProvider.notifier).clear(),
          child: Text('Reset demo', style: TextStyle(fontSize: 12, color: context.mutedTxt)),
        ),
      ]),
    ]);
  }
}

void _showDone(BuildContext context, {required bool trust}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 48),
      title: const Text('Mother discharged.', textAlign: TextAlign.center),
      content: Text(
        trust
          ? 'Claim saved on this device. It will reach SHA automatically once the network returns.'
          : 'Claim filed with SHA.',
        textAlign: TextAlign.center,
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
    ),
  );
}