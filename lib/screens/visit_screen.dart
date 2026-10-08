import 'package:flutter/material.dart';
import '../data/app_state.dart';

class VisitScreen extends StatelessWidget {
  final Visit visit;
  const VisitScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        foregroundColor: context.primaryTxt,
        scrolledUnderElevation: 0,
        title: Text(visit.hospital,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Align(alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(visit.date,
                      style: TextStyle(color: context.mutedTxt, fontSize: 13)),
                  const SizedBox(height: 18),
                  _label(context, 'WHAT WAS TREATED'),
                  const SizedBox(height: 4),
                  Text(visit.reason,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: context.primaryTxt)),
                  const SizedBox(height: 20),
                  _label(context, 'DIAGNOSIS'),
                  const SizedBox(height: 4),
                  Text(visit.diagnosis,
                      style: TextStyle(
                          fontSize: 15, color: context.primaryTxt)),
                  const SizedBox(height: 20),
                  _label(context, 'MEDICATION'),
                  const SizedBox(height: 6),
                  for (final m in visit.medications)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('- $m',
                          style: TextStyle(
                              fontSize: 15, color: context.primaryTxt)),
                    ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.good.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(context, 'OUTCOME'),
                        const SizedBox(height: 4),
                        Text(visit.outcome,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.good)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(text,
      style: TextStyle(
          fontSize: 11, letterSpacing: 0.8, color: context.mutedTxt));
}