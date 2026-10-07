import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../stats/stats.dart';

class DeltaCard extends StatelessWidget {
  const DeltaCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Live model output: claim risk, manual entry vs single-event capture.
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < demoPatient.summary.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${i + 1}. ${demoPatient.summary[i]}',
                      style: const TextStyle(fontSize: 16, height: 1.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Text('CLAIM RISK',
                  style: TextStyle(
                      fontSize: 10, color: Colors.white54, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('$before% \u2192 $after%',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF87171))),
              const SizedBox(height: 2),
              const Text('manual \u2192 auto',
                  style: TextStyle(fontSize: 10, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }
}