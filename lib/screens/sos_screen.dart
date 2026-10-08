import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_state.dart';
import '../data/outbox.dart';

// Simulated contents of the NFC wristband. In the real design this payload is
// encrypted on the tag and decrypted locally by the responder app.
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
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        foregroundColor: context.primaryTxt,
        scrolledUnderElevation: 0,
        title: const Text('Responder view (demo)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _read ? _result(online) : _tapView()),
                  Text(
                    'Demo only. In the real system this is a separate app '
                    'for responders. It cannot discharge patients.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: context.mutedTxt),
                  ),
                ],
              ),
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
        Text('Unconscious patient? Tap the wristband.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: context.primaryTxt)),
        const SizedBox(height: 28),
        SizedBox(
          width: 180,
          height: 180,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: _reading ? null : _tap,
            child: _reading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.nfc, size: 48),
                      SizedBox(height: 8),
                      Text('Simulate wristband tap'),
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
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDC2626), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('EMERGENCY INFORMATION',
                  style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const SizedBox(height: 12),
              for (final e in _tag.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10, color: context.mutedTxt)),
                      Text(e.value,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: context.primaryTxt)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          online
              ? 'Alert sent to the nearest facility (simulated).'
              : 'No internet: alert saved, it sends as soon as there is a signal.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.mutedTxt),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () => setState(() => _read = false),
          child: const Text('Tap another wristband'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}