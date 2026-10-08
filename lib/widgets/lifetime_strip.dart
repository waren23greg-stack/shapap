import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../screens/visit_screen.dart';

class LifetimeStrip extends StatelessWidget {
  const LifetimeStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final last = demoVisits.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Past visits (tap one for details)',
            style: TextStyle(fontSize: 11, color: context.mutedTxt)),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < demoVisits.length; i++) ...[
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => VisitScreen(visit: demoVisits[i])),
                ),
                child: SizedBox(
                  width: 84,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == last ? context.good : context.mutedTxt,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(demoVisits[i].shortLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11, color: context.primaryTxt)),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              if (i < last)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(top: 6),
                    color: context.lineCol,
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}