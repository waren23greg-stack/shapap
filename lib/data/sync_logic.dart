import 'api.dart';
import 'outbox.dart';

/// What one pass over the waiting events achieved, and why it stopped early, if it did.
class SyncReport {
  /// Events the server confirmed (201 or 200). Only these were marked as sent.
  final int sent;

  /// Events the server will never accept as they are. They stay in the outbox.
  final int refused;

  /// Why the pass stopped before the end, or null if no answer made it stop.
  final SendOutcome? stoppedBy;

  /// Seconds to wait, when [stoppedBy] is [SendOutcome.wait].
  final int retryAfter;

  const SyncReport({
    this.sent = 0,
    this.refused = 0,
    this.stoppedBy,
    this.retryAfter = 0,
  });
}

/// Sends the waiting events one at a time, oldest first.
///
/// An event is marked as sent only after the server confirms it, so a crash in between just
/// means a harmless repeat later (the server answers 200 for an event it already has).
/// A 401, a 429 or a network failure stops the pass, because every later event would fail the
/// same way. A refused event is skipped, so one bad event cannot block the rest.
/// [mustStop] is checked before each event, for example when the user goes offline mid-pass.
Future<SyncReport> syncPending({
  required List<OutboxEvent> pending,
  required String token,
  required Future<SendResult> Function(String token, OutboxEvent event) send,
  required Future<void> Function(String id) markSynced,
  bool Function()? mustStop,
}) async {
  var sent = 0;
  var refused = 0;
  for (final event in pending) {
    if (mustStop != null && mustStop()) break;
    final result = await send(token, event);
    switch (result.outcome) {
      case SendOutcome.sent:
        await markSynced(event.id);
        sent++;
      case SendOutcome.refused:
        refused++;
      case SendOutcome.signIn:
      case SendOutcome.retryLater:
        return SyncReport(sent: sent, refused: refused, stoppedBy: result.outcome);
      case SendOutcome.wait:
        return SyncReport(
          sent: sent,
          refused: refused,
          stoppedBy: SendOutcome.wait,
          retryAfter: result.retryAfter,
        );
    }
  }
  return SyncReport(sent: sent, refused: refused);
}
