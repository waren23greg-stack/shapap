import 'package:flutter/material.dart';
import '../data/app_state.dart';

class VisitScreen extends StatelessWidget {
  final Visit visit;
  const VisitScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    final isToday = visit.date == 'Today';
    const accent  = Color(0xFF34D399);
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: context.primaryTxt,
        title: Text(visit.hospital,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Date chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isToday ? accent.withValues(alpha: 0.12) : context.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isToday ? accent : context.dividerCol),
              ),
              child: Text(visit.date,
                style: TextStyle(
                  color: isToday ? accent : context.mutedTxt,
                  fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 22),

            // What happened
            _label(context, 'What happened'),
            const SizedBox(height: 6),
            Text(visit.condition,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                color: context.primaryTxt, height: 1.2)),
            const SizedBox(height: 22),

            // Diagnosis
            _label(context, 'Diagnosis'),
            const SizedBox(height: 6),
            Text(visit.diagnosis,
              style: TextStyle(fontSize: 15, color: context.primaryTxt,
                fontWeight: FontWeight.w500)),
            const SizedBox(height: 22),

            // Medications
            _label(context, 'Medications prescribed'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: visit.medications.map((m) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.dividerCol),
                ),
                child: Text(m,
                  style: TextStyle(fontSize: 13, color: context.primaryTxt)),
              )).toList(),
            ),
            const SizedBox(height: 24),

            // Outcome
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.35)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label(context, 'Outcome'),
                const SizedBox(height: 6),
                Text(visit.outcome,
                  style: const TextStyle(fontSize: 16, color: accent,
                    fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _label(BuildContext ctx, String text) => Text(text,
    style: TextStyle(fontSize: 11, color: ctx.mutedTxt, letterSpacing: 0.8));
}