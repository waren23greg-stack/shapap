import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shapap/data/api.dart';
import 'package:shapap/data/outbox.dart';

OutboxEvent _event() => OutboxEvent(
      id: '8c0e3f2a-5b1d-4c7e-9a2f-1d3b5e7f9a01',
      patientId: 'P001',
      type: 'DISCHARGE',
      createdAt: DateTime(2026, 11, 1, 12, 30, 15),
    );

ApiClient _answering(
  int status, {
  Map<String, String> headers = const {},
  String body = '{}',
}) {
  return ApiClient(
    base: 'http://api.test',
    client: MockClient((request) async => http.Response(body, status, headers: headers)),
  );
}

void main() {
  group('sendEvent', () {
    test('posts exactly four fields, in UTC, with the token', () async {
      http.Request? seen;
      final client = ApiClient(
        base: 'http://api.test',
        client: MockClient((request) async {
          seen = request;
          return http.Response('{}', 201);
        }),
      );
      final result = await client.sendEvent('tok-123', _event());
      expect(result.outcome, SendOutcome.sent);
      expect(seen!.method, 'POST');
      expect(seen!.url.toString(), 'http://api.test/sync');
      expect(seen!.headers['Authorization'], 'Bearer tok-123');
      expect(seen!.headers['Content-Type'], startsWith('application/json'));
      final body = jsonDecode(seen!.body) as Map<String, dynamic>;
      expect(body.keys.toSet(), {'id', 'patientId', 'type', 'createdAt'});
      final sentTime = body['createdAt'] as String;
      expect(sentTime.endsWith('Z'), isTrue);
      expect(DateTime.parse(sentTime).isAtSameMomentAs(_event().createdAt), isTrue);
    });

    final cases = <int, SendOutcome>{
      200: SendOutcome.sent,
      201: SendOutcome.sent,
      401: SendOutcome.signIn,
      403: SendOutcome.refused,
      413: SendOutcome.refused,
      422: SendOutcome.refused,
      500: SendOutcome.retryLater,
      503: SendOutcome.retryLater,
    };
    cases.forEach((status, expected) {
      test('status $status is $expected', () async {
        final result = await _answering(status).sendEvent('t', _event());
        expect(result.outcome, expected);
      });
    });

    test('429 waits as long as Retry-After says, within sane limits', () async {
      Future<int> waitFor(Map<String, String> headers) async {
        final result = await _answering(429, headers: headers).sendEvent('t', _event());
        expect(result.outcome, SendOutcome.wait);
        return result.retryAfter;
      }

      expect(await waitFor({'retry-after': '42'}), 42);
      expect(await waitFor({}), 60);
      expect(await waitFor({'retry-after': 'soon'}), 60);
      expect(await waitFor({'retry-after': '99999'}), 3600);
      expect(await waitFor({'retry-after': '0'}), 1);
    });

    test('no answer keeps the event for later', () async {
      final failing = ApiClient(
        base: 'http://api.test',
        client: MockClient((_) async => throw http.ClientException('down')),
      );
      expect((await failing.sendEvent('t', _event())).outcome, SendOutcome.retryLater);

      final silent = ApiClient(
        base: 'http://api.test',
        timeout: const Duration(milliseconds: 50),
        client: MockClient((_) => Completer<http.Response>().future),
      );
      expect((await silent.sendEvent('t', _event())).outcome, SendOutcome.retryLater);
    });
  });

  group('login', () {
    test('returns the token', () async {
      final result = await _answering(
        200,
        body: '{"access_token":"abc","token_type":"bearer","expires_in":900}',
      ).login('amina', 'a long passphrase');
      expect(result.token, 'abc');
      expect(result.failure, isNull);
    });

    test('sends only the username and password', () async {
      http.Request? seen;
      final client = ApiClient(
        base: 'http://api.test',
        client: MockClient((request) async {
          seen = request;
          return http.Response('{"access_token":"abc"}', 200);
        }),
      );
      await client.login('amina', 'a long passphrase');
      expect(seen!.url.toString(), 'http://api.test/login');
      final body = jsonDecode(seen!.body) as Map<String, dynamic>;
      expect(body.keys.toSet(), {'username', 'password'});
      expect(seen!.headers.containsKey('Authorization'), isFalse);
    });

    test('a refused sign-in is just "wrong password"', () async {
      for (final status in [401, 403, 422]) {
        final result = await _answering(status).login('amina', 'nope');
        expect(result.token, isNull);
        expect(result.failure, LoginFailure.wrongPassword);
      }
    });

    test('too many attempts says how long to wait', () async {
      final result = await _answering(429, headers: {'retry-after': '30'}).login('a', 'b');
      expect(result.failure, LoginFailure.wait);
      expect(result.retryAfter, 30);
    });

    test('server trouble or a nonsense answer means unreachable', () async {
      final answers = [
        _answering(500),
        _answering(200, body: 'not json'),
        _answering(200, body: '{}'),
        _answering(200, body: '{"access_token":""}'),
        ApiClient(
          base: 'http://api.test',
          client: MockClient((_) async => throw http.ClientException('down')),
        ),
      ];
      for (final client in answers) {
        final result = await client.login('amina', 'a long passphrase');
        expect(result.token, isNull);
        expect(result.failure, LoginFailure.unreachable);
      }
    });
  });
}
