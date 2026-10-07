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
    final surge = p > surgeThreshold;
    final pct = (p * 100).round();
    final hh = hour.toString().padLeft(2, '0');
    final color = surge ? const Color(0xFFFBBF24) : Colors.white54;

    return GestureDetector(
      onTap: () =>
          ref.read(demoHourProvider.notifier).state = hour == 10 ? 3 : 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(surge ? Icons.trending_up : Icons.trending_flat,
                color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                surge
                    ? 'Rush expected $hh:00. P($surgeCapacity+ arrivals) = $pct%. '
                        'Trust Mode pre-armed.'
                    : 'Quiet at $hh:00. P($surgeCapacity+ arrivals) = $pct%.',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}