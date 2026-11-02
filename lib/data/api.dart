import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'outbox.dart';

/// Where the API lives. To point the app somewhere else:
/// flutter run --dart-define=API_URL=http://192.168.1.5:8000
const apiBase =
    String.fromEnvironment('API_URL', defaultValue: 'http://127.0.0.1:8000');

/// What happened when one event was sent.
enum SendOutcome {
  /// The server has the event: 201 (new) or 200 (it already had it).
  sent,

  /// 401: the token is missing, wrong or expired. Sign in again.
  signIn,

  /// 429: too many requests. Try again after [SendResult.retryAfter] seconds.
  wait,

  /// Any other 4xx: the server will never accept this event as it is.
  refused,

  /// No answer, or a 5xx: keep the event and try again later.
  retryLater,
}

class SendResult {
  final SendOutcome outcome;

  /// Seconds to wait. Only meaningful when the outcome is [SendOutcome.wait].
  final int retryAfter;

  const SendResult(this.outcome, [this.retryAfter = 0]);
}

enum LoginFailure { wrongPassword, wait, unreachable }

class LoginResult {
  final String? token;
  final LoginFailure? failure;
  final int retryAfter;

  const LoginResult.signedIn(this.token)
      : failure = null,
        retryAfter = 0;

  const LoginResult.failed(this.failure, [this.retryAfter = 0]) : token = null;
}

class ApiClient {
  final http.Client _client;
  final String base;
  final Duration timeout;

  ApiClient({
    http.Client? client,
    this.base = apiBase,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  Future<LoginResult> login(String username, String password) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$base/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(timeout);
      final code = response.statusCode;
      if (code == 200) {
        final decoded = jsonDecode(response.body);
        final token = decoded is Map ? decoded['access_token'] : null;
        if (token is String && token.isNotEmpty) {
          return LoginResult.signedIn(token);
        }
        return const LoginResult.failed(LoginFailure.unreachable);
      }
      if (code == 429) {
        return LoginResult.failed(LoginFailure.wait, _retryAfter(response));
      }
      if (code >= 500) return const LoginResult.failed(LoginFailure.unreachable);
      return const LoginResult.failed(LoginFailure.wrongPassword);
    } on Exception {
      return const LoginResult.failed(LoginFailure.unreachable);
    }
  }

  /// Sends one event. Only these four fields go out: the server refuses any extra field, so
  /// the outbox's own `synced` flag must never be sent. The time goes out in UTC.
  Future<SendResult> sendEvent(String token, OutboxEvent event) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$base/sync'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'id': event.id,
              'patientId': event.patientId,
              'type': event.type,
              'createdAt': event.createdAt.toUtc().toIso8601String(),
            }),
          )
          .timeout(timeout);
      final code = response.statusCode;
      if (code == 200 || code == 201) return const SendResult(SendOutcome.sent);
      if (code == 401) return const SendResult(SendOutcome.signIn);
      if (code == 429) {
        return SendResult(SendOutcome.wait, _retryAfter(response));
      }
      if (code >= 500) return const SendResult(SendOutcome.retryLater);
      return const SendResult(SendOutcome.refused);
    } on Exception {
      return const SendResult(SendOutcome.retryLater);
    }
  }

  void close() => _client.close();

  /// Seconds from the Retry-After header, kept between 1 second and 1 hour.
  int _retryAfter(http.Response response) {
    final seconds = int.tryParse(response.headers['retry-after'] ?? '') ?? 60;
    if (seconds < 1) return 1;
    if (seconds > 3600) return 3600;
    return seconds;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});

/// The sign-in token. Kept in memory only, so closing the app signs you out.
final accessTokenProvider = StateProvider<String?>((ref) => null);
