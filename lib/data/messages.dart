import 'api.dart';
import 'sync.dart';

String _claims(int n) => '$n claim${n == 1 ? '' : 's'}';

/// The line under the discharge button: what is happening to the saved claims.
String syncLine({
  required int total,
  required int pending,
  required bool online,
  required bool sending,
  required SyncStatus status,
}) {
  if (total == 0) return 'No claims yet';
  if (pending == 0) return 'All claims sent to SHA';
  if (!online) return '${_claims(pending)} saved here, waiting for internet';
  if (sending) return 'Sending ${_claims(pending)} to SHA...';
  switch (status.phase) {
    case SyncPhase.needsSignIn:
      return 'Sign in to send ${_claims(pending)}';
    case SyncPhase.waiting:
      return 'Server is busy. Trying again in about ${status.number} s';
    case SyncPhase.unreachable:
      return 'Cannot reach the server. Trying again soon';
    case SyncPhase.refused:
      return '${_claims(status.number)} refused by the server and kept here';
    case SyncPhase.idle:
      return 'Sending ${_claims(pending)} to SHA...';
  }
}

/// What to tell the user when signing in did not work. Null when it did work.
String? signInProblem(LoginResult result) {
  switch (result.failure) {
    case null:
      return null;
    case LoginFailure.wrongPassword:
      return 'Wrong username or password.';
    case LoginFailure.wait:
      return 'Too many attempts. Try again in ${result.retryAfter} seconds.';
    case LoginFailure.unreachable:
      return 'Cannot reach the server. Check the connection.';
  }
}
