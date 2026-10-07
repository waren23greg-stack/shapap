import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/outbox.dart';

void main() => runApp(const ProviderScope(child: ShapapApp()));

class ShapapApp extends StatelessWidget {
  const ShapapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shapap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingCountProvider);
    final total = ref.watch(outboxProvider).length;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$pending queued / $total total',
                style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  ref.read(outboxProvider.notifier).queue('P001', 'DISCHARGE'),
              child: const Text('Queue event'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  ref.read(outboxProvider.notifier).markAllSynced(),
              child: const Text('Mark all synced'),
            ),
          ],
        ),
      ),
    );
  }
}