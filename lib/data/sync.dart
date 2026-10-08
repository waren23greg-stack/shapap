import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_state.dart';
import 'outbox.dart';

/// Fake sync: when online and a claim is waiting, wait 2 s, then mark it sent.
/// Real version later: POST each event to the backend /sync endpoint.
final syncRunnerProvider = Provider<void>((ref) {
  Future<void> run() async {
    if (!ref.read(onlineProvider)) return;
    if (ref.read(pendingCountProvider) == 0) return;
    if (ref.read(syncingProvider)) return;

    ref.read(syncingProvider.notifier).state = true;
    await Future.delayed(const Duration(seconds: 2));
    if (ref.read(onlineProvider)) {
      await ref.read(outboxProvider.notifier).markAllSynced();
    }
    ref.read(syncingProvider.notifier).state = false;
  }

  ref.listen<bool>(onlineProvider, (_, __) => run());
  ref.listen<int>(pendingCountProvider, (_, __) => run());
});