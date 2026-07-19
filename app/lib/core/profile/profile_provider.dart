import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user profile: display name and (optional) avatar photo path.
/// Offline-first — stored in SharedPreferences.
class UserProfileState {
  final String username;
  final String? photoPath;

  const UserProfileState({this.username = 'Runner', this.photoPath});

  UserProfileState copyWith({String? username, String? photoPath}) =>
      UserProfileState(
        username: username ?? this.username,
        photoPath: photoPath ?? this.photoPath,
      );
}

class UserProfile extends Notifier<UserProfileState> {
  static const _kName = 'profile_username';
  static const _kPhoto = 'profile_photo';

  @override
  UserProfileState build() {
    _restore();
    return const UserProfileState();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kName);
    final photo = prefs.getString(_kPhoto);
    if (name != null || photo != null) {
      state = UserProfileState(
        username: name ?? 'Runner',
        photoPath: photo,
      );
    }
  }

  Future<void> setUsername(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(username: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, trimmed);
  }

  Future<void> setPhoto(String? path) async {
    state = state.copyWith(photoPath: path);
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_kPhoto);
    } else {
      await prefs.setString(_kPhoto, path);
    }
  }
}

final userProfileProvider =
    NotifierProvider<UserProfile, UserProfileState>(UserProfile.new);

/// Distance unit preference. Metric uses kilometres, imperial uses miles.
enum Units { metric, imperial }

class UnitsNotifier extends Notifier<Units> {
  static const _kKey = 'units_mode';

  @override
  Units build() {
    _restore();
    return Units.metric;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_kKey);
    if (v != null) state = Units.values[v];
  }

  Future<void> toggle() async {
    state = state == Units.metric ? Units.imperial : Units.metric;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kKey, state.index);
  }

  Future<void> set(Units u) async {
    state = u;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kKey, state.index);
  }
}

final unitsProvider = NotifierProvider<UnitsNotifier, Units>(UnitsNotifier.new);

/// Format a distance in metres respecting the user's [units] preference.
String formatDistanceUnits(double meters, Units units) {
  if (units == Units.imperial) {
    final miles = meters / 1609.344;
    if (miles < 10) return '${miles.toStringAsFixed(2)} mi';
    return '${miles.toStringAsFixed(1)} mi';
  }
  final km = meters / 1000;
  if (km < 10) return '${km.toStringAsFixed(2)} km';
  return '${km.toStringAsFixed(1)} km';
}
