import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../screens/visit_screen.dart';

class LifetimeStrip extends StatelessWidget {
  const LifetimeStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < demoVisits.length; i++) ...[
          SizedBox(
            width: 84,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => VisitScreen(visit: demoVisits[i]))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == demoVisits.length - 1
                      ? const Color(0xFF34D399) : Colors.white38,
                    border: Border.all(
                      color: i == demoVisits.length - 1
                        ? Colors.transparent : Colors.white24, width: 1.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(demoVisits[i].shortLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: context.mutedTxt)),
              ]),
            ),
          ),
          if (i < demoVisits.length - 1)
            Expanded(child: Container(
              height: 2, margin: const EdgeInsets.only(top: 6),
              color: context.dividerCol)),
        ],
      ],
    );
  }
}