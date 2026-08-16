import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().named('display_name')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  TextColumn get settingsJson => text().named('settings_json')();

  @override
  Set<Column> get primaryKey => {id};
}

class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text().withDefault(const Constant('Run'))();
  DateTimeColumn get startedAt => dateTime().named('started_at')();
  DateTimeColumn get endedAt => dateTime().named('ended_at').nullable()();
  RealColumn get distanceM => real().named('distance_m')();
  IntColumn get durationMs => integer().named('duration_ms')();
  IntColumn get movingTimeMs => integer().named('moving_time_ms')();
  IntColumn get calories => integer().withDefault(const Constant(0))();
  RealColumn get elevationGainM => real().named('elevation_gain_m').withDefault(const Constant(0.0))();
  IntColumn get avgHeartRate => integer().withDefault(const Constant(0))();
  IntColumn get avgCadence => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class ActivityPoints extends Table {
  TextColumn get activityId => text()();
  IntColumn get pointIndex => integer()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get elevation => real()();
  RealColumn get pace => real()();
  DateTimeColumn get timestamp => dateTime()();
  
  IntColumn get accuracy => integer().nullable()();
  RealColumn get hdop => real().nullable()();
  IntColumn get satelliteCount => integer().nullable()();
  TextColumn get provider => text().nullable()();
  BoolColumn get isMocked => boolean().withDefault(const Constant(false))();
  TextColumn get fixType => text().nullable()();
  TextColumn get state => text().nullable()();

  @override
  Set<Column> get primaryKey => {activityId, pointIndex};
}