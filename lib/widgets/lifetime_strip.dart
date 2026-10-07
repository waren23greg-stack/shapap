import 'package:flutter/material.dart';
import '../data/app_state.dart';

class LifetimeStrip extends StatelessWidget {
  const LifetimeStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final items = demoPatient.timeline;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          SizedBox(
            width: 84,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == items.length - 1
                        ? const Color(0xFF34D399)
                        : Colors.white38,
                  ),
                ),
                const SizedBox(height: 6),
                Text(items[i],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          if (i < items.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: 5),
                color: Colors.white24,
              ),
            ),
        ],
      ],
    );
  }
}