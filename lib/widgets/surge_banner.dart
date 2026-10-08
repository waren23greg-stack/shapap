import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';
import '../stats/stats.dart';

class SurgeBanner extends ConsumerWidget {
  const SurgeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = ref.watch(demoHourProvider);
    final p = surgeProbability(hourlyLambda[hour], surgeCapacity);
    final busy = p > surgeThreshold;
    final pct = (p * 100).round();
    final hh = hour.toString().padLeft(2, '0');
    final color = busy ? context.warn : context.mutedTxt;

    return GestureDetector(
      onTap: () =>
          ref.read(demoHourProvider.notifier).state = hour == 10 ? 3 : 10,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              busy
                  ? 'Busy hour expected at $hh:00 (about $pct% chance of '
                      '$surgeCapacity+ arrivals). Offline backup is ready.'
                  : 'Quiet hour at $hh:00 (about $pct% chance of '
                      '$surgeCapacity+ arrivals).',
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text('Demo: tap to change the hour',
                style: TextStyle(color: context.mutedTxt, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}