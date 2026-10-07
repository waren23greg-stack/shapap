import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';

class NetworkToggle extends ConsumerWidget {
  const NetworkToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(online ? Icons.wifi : Icons.wifi_off,
            size: 18, color: Colors.white54),
        const SizedBox(width: 6),
        Text(online ? 'Network online' : 'Network OFFLINE',
            style: const TextStyle(fontSize: 12, color: Colors.white54)),
        Switch(
          value: online,
          onChanged: (v) => ref.read(onlineProvider.notifier).state = v,
        ),
      ],
    );
  }
}