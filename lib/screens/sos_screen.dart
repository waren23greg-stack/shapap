import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';
import '../data/outbox.dart';

// Simulated contents of the NFC tag. In the real design this payload is
// AES-encrypted on the tag and decrypted locally by the responder app.
const _tag = <String, String>{
  'Blood type': 'O negative',
  'Allergy': 'Severe penicillin allergy',
  'Condition': 'Type 1 diabetic',
  'Location': 'Nairobi-Nakuru Hwy (simulated GPS)',
};

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  bool _reading = false;
  bool _read = false;

  Future<void> _tap() async {
    setState(() => _reading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // fake tag read
    await ref
        .read(outboxProvider.notifier)
        .queue(demoPatient.id, 'EMERGENCY_SOS');
    if (!mounted) return;
    setState(() {
      _reading = false;
      _read = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(onlineProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Emergency responder'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _read ? _result(online) : _tapView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tapView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Unconscious patient. Tap the wristband.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          height: 200,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: _reading ? null : _tap,
            child: _reading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.nfc, size: 56),
                      SizedBox(height: 8),
                      Text('Simulate NFC tap'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _result(bool online) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DISPATCH ALERT',
                  style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
              const SizedBox(height: 12),
              for (final e in _tag.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white54)),
                      Text(e.value,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          online
              ? 'SOS sent to the nearest facility (simulated).'
              : 'Offline: SOS queued. It sends when any signal returns.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () => setState(() => _read = false),
          child: const Text('Tap another wristband'),
        ),
      ],
    );
  }
}