import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider);
    final color  = online ? const Color(0xFF34D399) : const Color(0xFFFBBF24);
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(demoPatient.name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
              color: context.primaryTxt)),
          const SizedBox(height: 2),
          Text('${demoPatient.age} yrs \u00B7 ${demoPatient.shaId}',
            style: TextStyle(color: context.mutedTxt)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(online ? Icons.check_circle_outline : Icons.cloud_off,
            size: 15, color: color),
          const SizedBox(width: 6),
          Text(online ? 'Identity confirmed' : 'Offline \u2014 claim saved locally',
            style: TextStyle(color: color, fontSize: 12)),
        ]),
      ),
    ]);
  }
}