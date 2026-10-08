import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true = internet on; false = offline (claims are saved on the device).
final onlineProvider = StateProvider<bool>((ref) => true);

/// true while the fake sync is running.
final syncingProvider = StateProvider<bool>((ref) => false);

/// Demo hour for the busy-hour banner. Tap the banner to flip 10 / 3.
final demoHourProvider = StateProvider<int>((ref) => 10);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// Theme-aware colours: use context.cardBg, context.good, etc.
extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get scaffoldBg =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
  Color get cardBg => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get primaryTxt => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get mutedTxt => isDark ? Colors.white60 : const Color(0xFF64748B);
  Color get lineCol => isDark ? Colors.white12 : const Color(0xFFE2E8F0);
  Color get good => isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
  Color get warn => isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
  Color get bad => isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
}

class Patient {
  final String id;
  final String name;
  final int age;
  final String shaId;
  final List<String> summary;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.shaId,
    required this.summary,
  });
}

class Visit {
  final String hospital;
  final String shortLabel;
  final String date;
  final String reason;
  final String diagnosis;
  final List<String> medications;
  final String outcome;

  const Visit({
    required this.hospital,
    required this.shortLabel,
    required this.date,
    required this.reason,
    required this.diagnosis,
    required this.medications,
    required this.outcome,
  });
}

// All demo data is fictional.
const demoPatient = Patient(
  id: 'P001',
  name: 'Amina Wanjiru',
  age: 27,
  shaId: 'SHA-0042-1187',
  summary: [
    'Blood pressure normal (118/76).',
    'Normal delivery at 04:00 today.',
    'Baby 3.2 kg, healthy.',
  ],
);

const demoVisits = [
  Visit(
    hospital: 'Kenyatta National Hospital',
    shortLabel: 'KNH\nMay',
    date: 'May 2026',
    reason: 'First antenatal visit',
    diagnosis: 'Z34.0 - Supervision of normal first pregnancy',
    medications: ['Folic acid 5 mg daily', 'Ferrous sulphate 200 mg daily'],
    outcome: 'Healthy. Scan booked for 20 weeks.',
  ),
  Visit(
    hospital: 'Aga Khan University Hospital',
    shortLabel: 'Aga Khan\nAug',
    date: 'Aug 2026',
    reason: '20-week scan',
    diagnosis: 'Z36 - Antenatal screening, normal',
    medications: ['Calcium 500 mg daily'],
    outcome: 'Baby growing normally. Due date confirmed.',
  ),
  Visit(
    hospital: 'This facility',
    shortLabel: 'This facility\nToday',
    date: 'Today',
    reason: 'Labour and delivery',
    diagnosis: 'O80 - Normal delivery',
    medications: [
      'Oxytocin 10 IU injection (after delivery)',
      'Paracetamol 1 g when needed',
      'Ferrous sulphate 200 mg daily',
    ],
    outcome: 'Normal delivery. Baby 3.2 kg. Apgar 9/10.',
  ),
];