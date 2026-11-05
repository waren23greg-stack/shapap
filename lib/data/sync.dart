import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api.dart';
import 'app_state.dart';
import 'outbox.dart';
import 'sync_logic.dart';

/// Where the real sync stands, for the status line on the main screen.
enum SyncPhase {
  /// Nothing to report: nothing is waiting, or everything waiting has been sent.
  idle,

  /// Events are waiting, but nobody is signed in.
  needsSignIn,

  /// The server asked us to slow down. [SyncStatus.number] is the seconds to wait.
  waiting,

  /// The server could not be reached. We try again soon.
  unreachable,

  /// The server will not accept some events. [SyncStatus.number] is how many.
  refused,
}

class SyncStatus {
  final SyncPhase phase;

  /// Seconds to wait, or how many events were refused, depending on [phase].
  final int number;

  const SyncStatus(this.phase, [this.number = 0]);
}

final syncStatusProvider =
    StateProvider<SyncStatus>((ref) => const SyncStatus(SyncPhase.idle));

/// How long to wait before trying again when the server could not be reached.
const syncRetryDelay = Duration(seconds: 30);

/// Sends the waiting events to the real server. It runs whenever the demo switch is online,
/// someone is signed in and events are waiting. Watch it from the main screen to keep it alive.
final syncRunnerProvider = Provider<void>((ref) {
  Timer? retry;
  var running = false;

  void setStatus(SyncStatus status) {
    ref.read(syncStatusProvider.notifier).state = status;
  }

  Future<void> run() async {
    if (running || !ref.read(onlineProvider)) return;
    final pending = [
      for (final event in ref.read(outboxProvider))
        if (!event.synced) event,
    ];
    if (pending.isEmpty) {
      setStatus(const SyncStatus(SyncPhase.idle));
      return;
    }
    final token = ref.read(accessTokenProvider);
    if (token == null) {
      setStatus(const SyncStatus(SyncPhase.needsSignIn));
      return;
    }

    running = true;
    retry?.cancel();
    ref.read(syncingProvider.notifier).state = true;
    final api = ref.read(apiClientProvider);
    final report = await syncPending(
      pending: pending,
      token: token,
      send: api.sendEvent,
      markSynced: ref.read(outboxProvider.notifier).markSynced,
      mustStop: () => !ref.read(onlineProvider),
    ).whenComplete(() {
      running = false;
      ref.read(syncingProvider.notifier).state = false;
    });

    Duration? tryAgainIn;
    switch (report.stoppedBy) {
      case SendOutcome.signIn:
        // The token expired or was refused: forget it, so the screen asks for a new sign-in.
        ref.read(accessTokenProvider.notifier).state = null;
        setStatus(const SyncStatus(SyncPhase.needsSignIn));
      case SendOutcome.wait:
        setStatus(SyncStatus(SyncPhase.waiting, report.retryAfter));
        tryAgainIn = Duration(seconds: report.retryAfter);
      case SendOutcome.retryLater:
        setStatus(const SyncStatus(SyncPhase.unreachable));
        tryAgainIn = syncRetryDelay;
      default:
        setStatus(report.refused > 0
            ? SyncStatus(SyncPhase.refused, report.refused)
            : const SyncStatus(SyncPhase.idle));
    }
    if (tryAgainIn != null) retry = Timer(tryAgainIn, () => unawaited(run()));

    // Events saved while this pass was running are picked up straight away.
    final seen = {for (final event in pending) event.id};
    final newer = ref
        .read(outboxProvider)
        .any((event) => !event.synced && !seen.contains(event.id));
    if (report.stoppedBy == null && newer) unawaited(run());
  }

  ref.listen<bool>(onlineProvider, (previous, next) => unawaited(run()));
  ref.listen<int>(pendingCountProvider, (previous, next) => unawaited(run()));
  ref.listen<String?>(accessTokenProvider, (previous, next) => unawaited(run()));
  ref.onDispose(() => retry?.cancel());
});
