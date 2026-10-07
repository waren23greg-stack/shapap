import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onlineProvider    = StateProvider<bool>((ref) => true);
final syncingProvider   = StateProvider<bool>((ref) => false);
final demoHourProvider  = StateProvider<int>((ref) => 10);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// Use ctx.cardBg / ctx.primaryTxt etc. instead of hardcoded colours
extension AppColors on BuildContext {
  bool  get isDark     => Theme.of(this).brightness == Brightness.dark;
  Color get scaffoldBg => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get cardBg     => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get primaryTxt => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get mutedTxt   => isDark ? Colors.white54 : const Color(0xFF64748B);
  Color get dividerCol => isDark ? Colors.white12 : const Color(0xFFE2E8F0);
}

class Patient {
  final String id, name, shaId;
  final int age;
  final List<String> summary, timeline;
  const Patient({
    required this.id, required this.name, required this.age,
    required this.shaId, required this.summary, required this.timeline,
  });
}

class Visit {
  final String hospital, shortLabel, date, condition, diagnosis, outcome;
  final List<String> medications;
  const Visit({
    required this.hospital, required this.shortLabel, required this.date,
    required this.condition, required this.diagnosis,
    required this.medications, required this.outcome,
  });
}

const demoPatient = Patient(
  id: 'P001', name: 'Amina Wanjiru', age: 27, shaId: 'SHA-0042-1187',
  summary: [
    'BP normalizing (118/76).',
    'SVD successful at 04:00 today.',
    'Baby 3.2\u00A0kg, healthy.',
  ],
  timeline: [
    'KNH \u00B7 May',
    'AKH \u00B7 Aug',
    'Here \u00B7 Today',
  ],
);

const demoVisits = [
  Visit(
    hospital:   'Kenyatta National Hospital',
    shortLabel: 'KNH \u00B7 May',
    date:       'May 2026',
    condition:  'Antenatal care \u2014 first visit',
    diagnosis:  'Z34.0  \u2014  Normal first pregnancy',
    medications: ['Folic acid 5mg daily', 'Ferrous sulphate 200mg daily'],
    outcome:    'Healthy. Scan booked for 20 weeks.',
  ),
  Visit(
    hospital:   'Aga Khan University Hospital',
    shortLabel: 'AKH \u00B7 Aug',
    date:       'Aug 2026',
    condition:  '20-week obstetric scan',
    diagnosis:  'Z36  \u2014  Antenatal screening, normal',
    medications: ['Calcium 500mg daily'],
    outcome:    'Normal fetal growth. EDD confirmed.',
  ),
  Visit(
    hospital:   'This facility',
    shortLabel: 'Here \u00B7 Today',
    date:       'Today',
    condition:  'Labour and delivery',
    diagnosis:  'O80  \u2014  Spontaneous vertex delivery',
    medications: ['Oxytocin 10 IU IM', 'Amoxicillin 500mg TDS \u00D7 5 days'],
    outcome:    'SVD successful. Baby 3.2\u00A0kg. Apgar 9/10.',
  ),
];