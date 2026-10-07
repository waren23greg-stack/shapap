import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true = network "plugged in"; false = offline / Trust Mode.
final onlineProvider = StateProvider<bool>((ref) => true);

/// true while the fake sync is running (used from H5).
final syncingProvider = StateProvider<bool>((ref) => false);

/// Demo hour for the surge banner (used from H6). Tap banner to flip 10 / 3.
final demoHourProvider = StateProvider<int>((ref) => 10);

class Patient {
  final String id;
  final String name;
  final int age;
  final String shaId;
  final List<String> summary;
  final List<String> timeline;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.shaId,
    required this.summary,
    required this.timeline,
  });
}

// All demo data is fictional.
const demoPatient = Patient(
  id: 'P001',
  name: 'Amina Wanjiru',
  age: 27,
  shaId: 'SHA-0042-1187',
  summary: [
    'BP normalizing (118/76).',
    'SVD successful at 04:00 today.',
    'Baby 3.2 kg, healthy.',
  ],
  timeline: [
    'ANC 1 \u00B7 KNH \u00B7 May',
    'Scan \u00B7 Aga Khan \u00B7 Aug',
    'Admitted \u00B7 Here \u00B7 Today',
  ],
);