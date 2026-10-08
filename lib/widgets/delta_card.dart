import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../stats/stats.dart';

class DeltaCard extends StatelessWidget {
  const DeltaCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Live model output: claim risk, typed by hand vs auto-filled.
    final before = (rejectionRisk(const ClaimInputs(
                dateMismatch: true,
                blur: 0.6,
                nameDissimilarity: 0.3,
                clerkExpMonths: 6)) *
            100)
        .round();
    final after = (rejectionRisk(const ClaimInputs(
                dateMismatch: false,
                blur: 0.1,
                nameDissimilarity: 0.0,
                clerkExpMonths: 6)) *
            100)
        .round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.lineCol),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TODAY',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.8,
                        color: context.mutedTxt)),
                const SizedBox(height: 8),
                for (var i = 0; i < demoPatient.summary.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${i + 1}. ${demoPatient.summary[i]}',
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          color: context.primaryTxt),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 104,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Claim rejection risk',
                    style: TextStyle(fontSize: 10, color: context.mutedTxt)),
                const SizedBox(height: 4),
                Text('$after%',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: context.good)),
                Text('$before% if typed by hand',
                    style: TextStyle(fontSize: 11, color: context.bad)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}