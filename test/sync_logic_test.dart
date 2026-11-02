import 'package:flutter_test/flutter_test.dart';
import 'package:shapap/data/api.dart';
import 'package:shapap/data/outbox.dart';
import 'package:shapap/data/sync_logic.dart';

OutboxEvent _event(String id) => OutboxEvent(
      id: id,
      patientId: 'P001',
      type: 'DISCHARGE',
      createdAt: DateTime(2026, 11, 1, 12, 30, 15),
    );

/// A stand-in server and outbox that write down everything that happens to them.
class _Fake {
  _Fake([this.answers = const {}]);

  final Map<String, SendResult> answers;
  final List<String> log = [];
  final Set<String> tokens = {};

  Future<SendResult> send(String token, OutboxEvent event) async {
    tokens.add(token);
    log.add('send ${event.id}');
    return answers[event.id] ?? const SendResult(SendOutcome.sent);
  }

  Future<void> markSynced(String id) async => log.add('mark $id');
}

Future<SyncReport> _run(_Fake fake, List<String> ids, {bool Function()? mustStop}) {
  return syncPending(
    pending: [for (final id in ids) _event(id)],
    token: 'tok',
    send: fake.send,
    markSynced: fake.markSynced,
    mustStop: mustStop,
  );
}

void main() {
  test('sends oldest first and marks each event only after the server confirms it', () async {
    final fake = _Fake();
    final report = await _run(fake, ['a', 'b', 'c']);
    expect(fake.log, ['send a', 'mark a', 'send b', 'mark b', 'send c', 'mark c']);
    expect(fake.tokens, {'tok'});
    expect(report.sent, 3);
    expect(report.refused, 0);
    expect(report.stoppedBy, isNull);
  });

  test('a 401 stops the pass, and later events are not even tried', () async {
    final fake = _Fake({'b': const SendResult(SendOutcome.signIn)});
    final report = await _run(fake, ['a', 'b', 'c']);
    expect(fake.log, ['send a', 'mark a', 'send b']);
    expect(report.sent, 1);
    expect(report.stoppedBy, SendOutcome.signIn);
  });

  test('a 429 stops the pass and passes on how long to wait', () async {
    final fake = _Fake({'a': const SendResult(SendOutcome.wait, 42)});
    final report = await _run(fake, ['a', 'b']);
    expect(fake.log, ['send a']);
    expect(report.sent, 0);
    expect(report.stoppedBy, SendOutcome.wait);
    expect(report.retryAfter, 42);
  });

  test('no answer stops the pass and leaves the event waiting', () async {
    final fake = _Fake({'a': const SendResult(SendOutcome.retryLater)});
    final report = await _run(fake, ['a', 'b']);
    expect(fake.log, ['send a']);
    expect(report.sent, 0);
    expect(report.stoppedBy, SendOutcome.retryLater);
  });

  test('a refused event is skipped and does not block the rest', () async {
    final fake = _Fake({'a': const SendResult(SendOutcome.refused)});
    final report = await _run(fake, ['a', 'b']);
    expect(fake.log, ['send a', 'send b', 'mark b']);
    expect(report.refused, 1);
    expect(report.sent, 1);
    expect(report.stoppedBy, isNull);
  });

  test('stops before the next event when told to', () async {
    final fake = _Fake();
    final report = await _run(fake, ['a', 'b'], mustStop: () => fake.log.contains('mark a'));
    expect(fake.log, ['send a', 'mark a']);
    expect(report.sent, 1);
    expect(report.stoppedBy, isNull);
  });

  test('nothing waiting means nothing sent', () async {
    final fake = _Fake();
    final report = await _run(fake, []);
    expect(fake.log, <String>[]);
    expect(report.sent, 0);
    expect(report.stoppedBy, isNull);
  });
}
