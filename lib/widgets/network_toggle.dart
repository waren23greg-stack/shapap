import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';

/// Demo switch that simulates the internet going away and coming back.
class NetworkToggle extends ConsumerWidget {
  const NetworkToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(online ? 'Internet: ON' : 'Internet: OFF',
            style: TextStyle(fontSize: 12, color: context.mutedTxt)),
        Switch(
          value: online,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (v) => ref.read(onlineProvider.notifier).state = v,
        ),
      ],
    );
  }
}