import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Authenticated session. When [userId] is null the user is anonymous and
/// runs stay local-only (offline-first); signing in enables cloud sync.
class SessionState {
  final String? userId;
  final String? email;
  const SessionState({this.userId, this.email});

  bool get isAnonymous => userId == null;

  SessionState copyWith({String? userId, String? email}) =>
      SessionState(userId: userId ?? this.userId, email: email ?? this.email);
}

class Session extends Notifier<SessionState> {
  static const _kUser = 'session_user_id';
  static const _kEmail = 'session_email';

  @override
  SessionState build() {
    _restore();
    return const SessionState();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(_kUser);
    final email = prefs.getString(_kEmail);
    if (user != null) state = SessionState(userId: user, email: email);
  }

  /// Register a new account, then sign in.
  Future<String?> register(String email, String password) async {
    final client = ref.read(apiClientProvider);
    try {
      await client.dio.post('/api/v1/auth/register', data: {
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      return _errMessage(e);
    }
    return login(email, password);
  }

  /// Sign in and persist the JWT via [ApiClient].
  Future<String?> login(String email, String password) async {
    final client = ref.read(apiClientProvider);
    try {
      final res = await client.dio.post('/api/v1/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = res.data['access_token'] as String?;
      if (token == null) return 'No token returned';
      await client.setToken(token);
      state = SessionState(userId: email, email: email);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUser, email);
      await prefs.setString(_kEmail, email);
      return null;
    } on DioException catch (e) {
      return _errMessage(e);
    }
  }

  /// Clear the session locally and notify the backend (best-effort).
  Future<void> logout() async {
    final client = ref.read(apiClientProvider);
    try {
      await client.dio.post('/api/v1/auth/logout');
    } catch (_) {
      // offline-first: ignore network errors on logout
    }
    await client.clearToken();
    state = const SessionState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUser);
    await prefs.remove(_kEmail);
  }

  /// POST a finished run to the backend and refresh the leaderboard entry.
  /// No-op (and returns false) when anonymous. Returns true on success.
  Future<bool> submitRun({
    required double distanceM,
    required int durationMs,
    required int movingTimeMs,
    required double elevationGainM,
    required DateTime startedAt,
    String type = 'Run',
  }) async {
    if (state.isAnonymous) return false;
    final client = ref.read(apiClientProvider);
    try {
      await client.dio.post('/api/v1/activities', data: {
        'type': type,
        'started_at': startedAt.toUtc().toIso8601String(),
        'distance_m': distanceM,
        'moving_time_ms': movingTimeMs,
        'elevation_gain_m': elevationGainM,
      });
      await client.dio.post('/api/v1/leaderboard/submit');
      return true;
    } catch (_) {
      return false;
    }
  }

  String? _errMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) return data['error'];
    if (data is Map && data['status'] is String) return data['status'];
    if (e.response?.statusCode == 401) return 'Invalid email or password';
    if (e.response?.statusCode == 409) return 'Account already exists';
    return null;
  }
}

final sessionProvider = NotifierProvider<Session, SessionState>(Session.new);
