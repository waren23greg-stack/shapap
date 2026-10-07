import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_state.dart';
import 'outbox.dart';

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

  // Only sync when coming back online — not on every toggle
  ref.listen<bool>(onlineProvider, (prev, next) {
    if (prev == false && next == true) run();
  });
});