import 'package:flutter_test/flutter_test.dart';
import 'package:shapap/data/api.dart';
import 'package:shapap/data/messages.dart';
import 'package:shapap/data/sync.dart';

String _line({
  int total = 1,
  int pending = 1,
  bool online = true,
  bool sending = false,
  SyncStatus status = const SyncStatus(SyncPhase.idle),
}) {
  return syncLine(
    total: total,
    pending: pending,
    online: online,
    sending: sending,
    status: status,
  );
}

void main() {
  test('no claims yet, or everything sent', () {
    expect(_line(total: 0, pending: 0), 'No claims yet');
    expect(_line(total: 2, pending: 0), 'All claims sent to SHA');
  });

  test('offline claims wait for internet, in singular and plural', () {
    expect(_line(online: false), '1 claim saved here, waiting for internet');
    expect(_line(online: false, pending: 3), '3 claims saved here, waiting for internet');
  });

  test('online: sending, and each reason it is not sending', () {
    expect(_line(sending: true, pending: 2), 'Sending 2 claims to SHA...');
    expect(_line(), 'Sending 1 claim to SHA...');
    expect(
      _line(status: const SyncStatus(SyncPhase.needsSignIn)),
      'Sign in to send 1 claim',
    );
    expect(
      _line(status: const SyncStatus(SyncPhase.waiting, 42)),
      'Server is busy. Trying again in about 42 s',
    );
    expect(
      _line(status: const SyncStatus(SyncPhase.unreachable)),
      'Cannot reach the server. Trying again soon',
    );
    expect(
      _line(pending: 2, status: const SyncStatus(SyncPhase.refused, 2)),
      '2 claims refused by the server and kept here',
    );
    expect(
      _line(status: const SyncStatus(SyncPhase.refused, 1)),
      '1 claim refused by the server and kept here',
    );
  });

  test('offline wins over every other reason', () {
    expect(
      _line(online: false, status: const SyncStatus(SyncPhase.needsSignIn)),
      '1 claim saved here, waiting for internet',
    );
    expect(
      _line(online: false, sending: true),
      '1 claim saved here, waiting for internet',
    );
  });

  test('sign-in problems are plain sentences, and success has none', () {
    expect(signInProblem(const LoginResult.signedIn('abc')), isNull);
    expect(
      signInProblem(const LoginResult.failed(LoginFailure.wrongPassword)),
      'Wrong username or password.',
    );
    expect(
      signInProblem(const LoginResult.failed(LoginFailure.wait, 30)),
      'Too many attempts. Try again in 30 seconds.',
    );
    expect(
      signInProblem(const LoginResult.failed(LoginFailure.unreachable)),
      'Cannot reach the server. Check the connection.',
    );
  });
}
