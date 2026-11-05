import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shapap/data/api.dart';
import 'package:shapap/data/app_state.dart';
import 'package:shapap/data/outbox.dart';
import 'package:shapap/data/sync.dart';

/// A stand-in server. [answer] gets the number of the request (1, 2, ...) and may throw.
class _Server {
  _Server(this.answer);

  final Future<http.Response> Function(int callNumber) answer;
  final List<http.Request> requests = [];

  ApiClient get client => ApiClient(
        base: 'http://api.test',
        client: MockClient((request) async {
          requests.add(request);
          return answer(requests.length);
        }),
      );
}

Future<http.Response> _created(int n) async => http.Response('{}', 201);

ProviderContainer _start(_Server server, {String? token = 'tok'}) {
  final container = ProviderContainer(
    overrides: [apiClientProvider.overrideWithValue(server.client)],
  );
  addTearDown(container.dispose);
  container.read(syncRunnerProvider);
  if (token != null) container.read(accessTokenProvider.notifier).state = token;
  return container;
}

Future<void> _queue(ProviderContainer container) {
  return container.read(outboxProvider.notifier).queue('P001', 'DISCHARGE');
}

/// Waits (up to 3 seconds) until [condition] is true.
Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 150; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('Timed out waiting for the condition');
}

bool _finished(ProviderContainer c) =>
    c.read(pendingCountProvider) == 0 && !c.read(syncingProvider);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sends a waiting event when signed in and online, then marks it as sent', () async {
    final server = _Server(_created);
    final c = _start(server);
    await _queue(c);
    await _until(() => _finished(c));
    expect(server.requests.length, 1);
    expect(server.requests.first.headers['Authorization'], 'Bearer tok');
    expect(c.read(outboxProvider).single.synced, isTrue);
    expect(c.read(syncStatusProvider).phase, SyncPhase.idle);
  });

  test('does nothing until someone signs in, then sends what was waiting', () async {
    final server = _Server(_created);
    final c = _start(server, token: null);
    await _queue(c);
    await _until(() => c.read(syncStatusProvider).phase == SyncPhase.needsSignIn);
    expect(server.requests.length, 0);
    expect(c.read(pendingCountProvider), 1);

    c.read(accessTokenProvider.notifier).state = 'tok';
    await _until(() => _finished(c));
    expect(server.requests.length, 1);
    await _until(() => c.read(syncStatusProvider).phase == SyncPhase.idle);
  });

  test('a 401 forgets the token and asks for a new sign-in', () async {
    final server = _Server((n) async => http.Response('{}', 401));
    final c = _start(server, token: 'old');
    await _queue(c);
    await _until(() => c.read(syncStatusProvider).phase == SyncPhase.needsSignIn);
    expect(c.read(accessTokenProvider), isNull);
    expect(c.read(pendingCountProvider), 1);
    expect(server.requests.length, 1);
  });

  test('a 429 waits as long as the server says, then tries again', () async {
    final server = _Server((n) async => n == 1
        ? http.Response('{}', 429, headers: {'retry-after': '1'})
        : http.Response('{}', 201));
    final c = _start(server);
    await _queue(c);
    await _until(() => c.read(syncStatusProvider).phase == SyncPhase.waiting);
    expect(c.read(syncStatusProvider).number, 1);
    expect(c.read(pendingCountProvider), 1);
    await _until(() => _finished(c));
    expect(server.requests.length, 2);
  });

  test('no answer keeps the event and reports that the server cannot be reached', () async {
    final server = _Server((n) async => throw http.ClientException('down'));
    final c = _start(server);
    await _queue(c);
    await _until(() => c.read(syncStatusProvider).phase == SyncPhase.unreachable);
    expect(c.read(pendingCountProvider), 1);
    expect(server.requests.length, 1);
  });

  test('sends nothing while the demo switch is offline, and sends when it is back online', () async {
    final server = _Server(_created);
    final c = _start(server);
    var everSending = false;
    c.listen<bool>(syncingProvider, (previous, next) {
      if (next) everSending = true;
    });
    c.read(onlineProvider.notifier).state = false;
    await _queue(c);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(server.requests.length, 0);
    expect(everSending, isFalse);
    expect(c.read(pendingCountProvider), 1);

    c.read(onlineProvider.notifier).state = true;
    await _until(() => _finished(c));
    expect(server.requests.length, 1);
  });

  test('a refused event is reported once and not retried over and over', () async {
    final server = _Server((n) async => http.Response('{}', 422));
    final c = _start(server);
    await _queue(c);
    await _until(() => c.read(syncStatusProvider).phase == SyncPhase.refused);
    expect(c.read(syncStatusProvider).number, 1);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(server.requests.length, 1);
    expect(c.read(pendingCountProvider), 1);
  });

  test('markSynced marks only the event it is given', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final outbox = c.read(outboxProvider.notifier);
    await outbox.queue('P001', 'DISCHARGE');
    await outbox.queue('P001', 'EMERGENCY_SOS');
    await outbox.markSynced(c.read(outboxProvider).first.id);
    final events = c.read(outboxProvider);
    expect(events.first.synced, isTrue);
    expect(events.last.synced, isFalse);
    expect(c.read(pendingCountProvider), 1);
  });

  test('what was marked as sent is remembered after a restart', () async {
    final first = ProviderContainer();
    final outbox = first.read(outboxProvider.notifier);
    await outbox.queue('P001', 'DISCHARGE');
    await outbox.queue('P001', 'EMERGENCY_SOS');
    await outbox.markSynced(first.read(outboxProvider).first.id);
    first.dispose();

    final second = ProviderContainer();
    addTearDown(second.dispose);
    second.read(outboxProvider);
    await _until(() => second.read(outboxProvider).length == 2);
    expect(second.read(outboxProvider).first.synced, isTrue);
    expect(second.read(outboxProvider).last.synced, isFalse);
  });
}
