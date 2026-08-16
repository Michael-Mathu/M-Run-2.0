// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    displayName,
    createdAt,
    settingsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String? email;
  final String displayName;
  final DateTime createdAt;
  final String settingsJson;
  const User({
    required this.id,
    this.email,
    required this.displayName,
    required this.createdAt,
    required this.settingsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['settings_json'] = Variable<String>(settingsJson);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
      settingsJson: Value(settingsJson),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String?>(json['email']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String?>(email),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'settingsJson': serializer.toJson<String>(settingsJson),
    };
  }

  User copyWith({
    String? id,
    Value<String?> email = const Value.absent(),
    String? displayName,
    DateTime? createdAt,
    String? settingsJson,
  }) => User(
    id: id ?? this.id,
    email: email.present ? email.value : this.email,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt ?? this.createdAt,
    settingsJson: settingsJson ?? this.settingsJson,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('settingsJson: $settingsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, email, displayName, createdAt, settingsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.settingsJson == this.settingsJson);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String?> email;
  final Value<String> displayName;
  final Value<DateTime> createdAt;
  final Value<String> settingsJson;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.email = const Value.absent(),
    required String displayName,
    required DateTime createdAt,
    required String settingsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       createdAt = Value(createdAt),
       settingsJson = Value(settingsJson);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<String>? settingsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? email,
    Value<String>? displayName,
    Value<DateTime>? createdAt,
    Value<String>? settingsJson,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      settingsJson: settingsJson ?? this.settingsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Run'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movingTimeMsMeta = const VerificationMeta(
    'movingTimeMs',
  );
  @override
  late final GeneratedColumn<int> movingTimeMs = GeneratedColumn<int>(
    'moving_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elevationGainMMeta = const VerificationMeta(
    'elevationGainM',
  );
  @override
  late final GeneratedColumn<double> elevationGainM = GeneratedColumn<double>(
    'elevation_gain_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgCadenceMeta = const VerificationMeta(
    'avgCadence',
  );
  @override
  late final GeneratedColumn<int> avgCadence = GeneratedColumn<int>(
    'avg_cadence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    startedAt,
    endedAt,
    distanceM,
    durationMs,
    movingTimeMs,
    calories,
    elevationGainM,
    avgHeartRate,
    avgCadence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('moving_time_ms')) {
      context.handle(
        _movingTimeMsMeta,
        movingTimeMs.isAcceptableOrUnknown(
          data['moving_time_ms']!,
          _movingTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movingTimeMsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('elevation_gain_m')) {
      context.handle(
        _elevationGainMMeta,
        elevationGainM.isAcceptableOrUnknown(
          data['elevation_gain_m']!,
          _elevationGainMMeta,
        ),
      );
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('avg_cadence')) {
      context.handle(
        _avgCadenceMeta,
        avgCadence.isAcceptableOrUnknown(data['avg_cadence']!, _avgCadenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      movingTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moving_time_ms'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      elevationGainM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_m'],
      )!,
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      )!,
      avgCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_cadence'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final String id;
  final String userId;
  final String type;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceM;
  final int durationMs;
  final int movingTimeMs;
  final int calories;
  final double elevationGainM;
  final int avgHeartRate;
  final int avgCadence;
  const Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.startedAt,
    this.endedAt,
    required this.distanceM,
    required this.durationMs,
    required this.movingTimeMs,
    required this.calories,
    required this.elevationGainM,
    required this.avgHeartRate,
    required this.avgCadence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['distance_m'] = Variable<double>(distanceM);
    map['duration_ms'] = Variable<int>(durationMs);
    map['moving_time_ms'] = Variable<int>(movingTimeMs);
    map['calories'] = Variable<int>(calories);
    map['elevation_gain_m'] = Variable<double>(elevationGainM);
    map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    map['avg_cadence'] = Variable<int>(avgCadence);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      distanceM: Value(distanceM),
      durationMs: Value(durationMs),
      movingTimeMs: Value(movingTimeMs),
      calories: Value(calories),
      elevationGainM: Value(elevationGainM),
      avgHeartRate: Value(avgHeartRate),
      avgCadence: Value(avgCadence),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      movingTimeMs: serializer.fromJson<int>(json['movingTimeMs']),
      calories: serializer.fromJson<int>(json['calories']),
      elevationGainM: serializer.fromJson<double>(json['elevationGainM']),
      avgHeartRate: serializer.fromJson<int>(json['avgHeartRate']),
      avgCadence: serializer.fromJson<int>(json['avgCadence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'distanceM': serializer.toJson<double>(distanceM),
      'durationMs': serializer.toJson<int>(durationMs),
      'movingTimeMs': serializer.toJson<int>(movingTimeMs),
      'calories': serializer.toJson<int>(calories),
      'elevationGainM': serializer.toJson<double>(elevationGainM),
      'avgHeartRate': serializer.toJson<int>(avgHeartRate),
      'avgCadence': serializer.toJson<int>(avgCadence),
    };
  }

  Activity copyWith({
    String? id,
    String? userId,
    String? type,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    double? distanceM,
    int? durationMs,
    int? movingTimeMs,
    int? calories,
    double? elevationGainM,
    int? avgHeartRate,
    int? avgCadence,
  }) => Activity(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    distanceM: distanceM ?? this.distanceM,
    durationMs: durationMs ?? this.durationMs,
    movingTimeMs: movingTimeMs ?? this.movingTimeMs,
    calories: calories ?? this.calories,
    elevationGainM: elevationGainM ?? this.elevationGainM,
    avgHeartRate: avgHeartRate ?? this.avgHeartRate,
    avgCadence: avgCadence ?? this.avgCadence,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      movingTimeMs: data.movingTimeMs.present
          ? data.movingTimeMs.value
          : this.movingTimeMs,
      calories: data.calories.present ? data.calories.value : this.calories,
      elevationGainM: data.elevationGainM.present
          ? data.elevationGainM.value
          : this.elevationGainM,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      avgCadence: data.avgCadence.present
          ? data.avgCadence.value
          : this.avgCadence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationMs: $durationMs, ')
          ..write('movingTimeMs: $movingTimeMs, ')
          ..write('calories: $calories, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('avgCadence: $avgCadence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    type,
    startedAt,
    endedAt,
    distanceM,
    durationMs,
    movingTimeMs,
    calories,
    elevationGainM,
    avgHeartRate,
    avgCadence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.distanceM == this.distanceM &&
          other.durationMs == this.durationMs &&
          other.movingTimeMs == this.movingTimeMs &&
          other.calories == this.calories &&
          other.elevationGainM == this.elevationGainM &&
          other.avgHeartRate == this.avgHeartRate &&
          other.avgCadence == this.avgCadence);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double> distanceM;
  final Value<int> durationMs;
  final Value<int> movingTimeMs;
  final Value<int> calories;
  final Value<double> elevationGainM;
  final Value<int> avgHeartRate;
  final Value<int> avgCadence;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.movingTimeMs = const Value.absent(),
    this.calories = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String userId,
    this.type = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required double distanceM,
    required int durationMs,
    required int movingTimeMs,
    this.calories = const Value.absent(),
    this.elevationGainM = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       startedAt = Value(startedAt),
       distanceM = Value(distanceM),
       durationMs = Value(durationMs),
       movingTimeMs = Value(movingTimeMs);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? distanceM,
    Expression<int>? durationMs,
    Expression<int>? movingTimeMs,
    Expression<int>? calories,
    Expression<double>? elevationGainM,
    Expression<int>? avgHeartRate,
    Expression<int>? avgCadence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (distanceM != null) 'distance_m': distanceM,
      if (durationMs != null) 'duration_ms': durationMs,
      if (movingTimeMs != null) 'moving_time_ms': movingTimeMs,
      if (calories != null) 'calories': calories,
      if (elevationGainM != null) 'elevation_gain_m': elevationGainM,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (avgCadence != null) 'avg_cadence': avgCadence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? type,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double>? distanceM,
    Value<int>? durationMs,
    Value<int>? movingTimeMs,
    Value<int>? calories,
    Value<double>? elevationGainM,
    Value<int>? avgHeartRate,
    Value<int>? avgCadence,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceM: distanceM ?? this.distanceM,
      durationMs: durationMs ?? this.durationMs,
      movingTimeMs: movingTimeMs ?? this.movingTimeMs,
      calories: calories ?? this.calories,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      avgCadence: avgCadence ?? this.avgCadence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (movingTimeMs.present) {
      map['moving_time_ms'] = Variable<int>(movingTimeMs.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (elevationGainM.present) {
      map['elevation_gain_m'] = Variable<double>(elevationGainM.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (avgCadence.present) {
      map['avg_cadence'] = Variable<int>(avgCadence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationMs: $durationMs, ')
          ..write('movingTimeMs: $movingTimeMs, ')
          ..write('calories: $calories, ')
          ..write('elevationGainM: $elevationGainM, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityPointsTable extends ActivityPoints
    with TableInfo<$ActivityPointsTable, ActivityPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointIndexMeta = const VerificationMeta(
    'pointIndex',
  );
  @override
  late final GeneratedColumn<int> pointIndex = GeneratedColumn<int>(
    'point_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elevationMeta = const VerificationMeta(
    'elevation',
  );
  @override
  late final GeneratedColumn<double> elevation = GeneratedColumn<double>(
    'elevation',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paceMeta = const VerificationMeta('pace');
  @override
  late final GeneratedColumn<double> pace = GeneratedColumn<double>(
    'pace',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<int> accuracy = GeneratedColumn<int>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hdopMeta = const VerificationMeta('hdop');
  @override
  late final GeneratedColumn<double> hdop = GeneratedColumn<double>(
    'hdop',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _satelliteCountMeta = const VerificationMeta(
    'satelliteCount',
  );
  @override
  late final GeneratedColumn<int> satelliteCount = GeneratedColumn<int>(
    'satellite_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMockedMeta = const VerificationMeta(
    'isMocked',
  );
  @override
  late final GeneratedColumn<bool> isMocked = GeneratedColumn<bool>(
    'is_mocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fixTypeMeta = const VerificationMeta(
    'fixType',
  );
  @override
  late final GeneratedColumn<String> fixType = GeneratedColumn<String>(
    'fix_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    activityId,
    pointIndex,
    lat,
    lng,
    elevation,
    pace,
    timestamp,
    accuracy,
    hdop,
    satelliteCount,
    provider,
    isMocked,
    fixType,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('point_index')) {
      context.handle(
        _pointIndexMeta,
        pointIndex.isAcceptableOrUnknown(data['point_index']!, _pointIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pointIndexMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('elevation')) {
      context.handle(
        _elevationMeta,
        elevation.isAcceptableOrUnknown(data['elevation']!, _elevationMeta),
      );
    } else if (isInserting) {
      context.missing(_elevationMeta);
    }
    if (data.containsKey('pace')) {
      context.handle(
        _paceMeta,
        pace.isAcceptableOrUnknown(data['pace']!, _paceMeta),
      );
    } else if (isInserting) {
      context.missing(_paceMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('hdop')) {
      context.handle(
        _hdopMeta,
        hdop.isAcceptableOrUnknown(data['hdop']!, _hdopMeta),
      );
    }
    if (data.containsKey('satellite_count')) {
      context.handle(
        _satelliteCountMeta,
        satelliteCount.isAcceptableOrUnknown(
          data['satellite_count']!,
          _satelliteCountMeta,
        ),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('is_mocked')) {
      context.handle(
        _isMockedMeta,
        isMocked.isAcceptableOrUnknown(data['is_mocked']!, _isMockedMeta),
      );
    }
    if (data.containsKey('fix_type')) {
      context.handle(
        _fixTypeMeta,
        fixType.isAcceptableOrUnknown(data['fix_type']!, _fixTypeMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {activityId, pointIndex};
  @override
  ActivityPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityPoint(
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      pointIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_index'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      elevation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation'],
      )!,
      pace: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pace'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy'],
      ),
      hdop: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hdop'],
      ),
      satelliteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}satellite_count'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      isMocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mocked'],
      )!,
      fixType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fix_type'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
    );
  }

  @override
  $ActivityPointsTable createAlias(String alias) {
    return $ActivityPointsTable(attachedDatabase, alias);
  }
}

class ActivityPoint extends DataClass implements Insertable<ActivityPoint> {
  final String activityId;
  final int pointIndex;
  final double lat;
  final double lng;
  final double elevation;
  final double pace;
  final DateTime timestamp;
  final int? accuracy;
  final double? hdop;
  final int? satelliteCount;
  final String? provider;
  final bool isMocked;
  final String? fixType;
  final String? state;
  const ActivityPoint({
    required this.activityId,
    required this.pointIndex,
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.pace,
    required this.timestamp,
    this.accuracy,
    this.hdop,
    this.satelliteCount,
    this.provider,
    required this.isMocked,
    this.fixType,
    this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['activity_id'] = Variable<String>(activityId);
    map['point_index'] = Variable<int>(pointIndex);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['elevation'] = Variable<double>(elevation);
    map['pace'] = Variable<double>(pace);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<int>(accuracy);
    }
    if (!nullToAbsent || hdop != null) {
      map['hdop'] = Variable<double>(hdop);
    }
    if (!nullToAbsent || satelliteCount != null) {
      map['satellite_count'] = Variable<int>(satelliteCount);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['is_mocked'] = Variable<bool>(isMocked);
    if (!nullToAbsent || fixType != null) {
      map['fix_type'] = Variable<String>(fixType);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    return map;
  }

  ActivityPointsCompanion toCompanion(bool nullToAbsent) {
    return ActivityPointsCompanion(
      activityId: Value(activityId),
      pointIndex: Value(pointIndex),
      lat: Value(lat),
      lng: Value(lng),
      elevation: Value(elevation),
      pace: Value(pace),
      timestamp: Value(timestamp),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      hdop: hdop == null && nullToAbsent ? const Value.absent() : Value(hdop),
      satelliteCount: satelliteCount == null && nullToAbsent
          ? const Value.absent()
          : Value(satelliteCount),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      isMocked: Value(isMocked),
      fixType: fixType == null && nullToAbsent
          ? const Value.absent()
          : Value(fixType),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
    );
  }

  factory ActivityPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityPoint(
      activityId: serializer.fromJson<String>(json['activityId']),
      pointIndex: serializer.fromJson<int>(json['pointIndex']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      elevation: serializer.fromJson<double>(json['elevation']),
      pace: serializer.fromJson<double>(json['pace']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      accuracy: serializer.fromJson<int?>(json['accuracy']),
      hdop: serializer.fromJson<double?>(json['hdop']),
      satelliteCount: serializer.fromJson<int?>(json['satelliteCount']),
      provider: serializer.fromJson<String?>(json['provider']),
      isMocked: serializer.fromJson<bool>(json['isMocked']),
      fixType: serializer.fromJson<String?>(json['fixType']),
      state: serializer.fromJson<String?>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'activityId': serializer.toJson<String>(activityId),
      'pointIndex': serializer.toJson<int>(pointIndex),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'elevation': serializer.toJson<double>(elevation),
      'pace': serializer.toJson<double>(pace),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'accuracy': serializer.toJson<int?>(accuracy),
      'hdop': serializer.toJson<double?>(hdop),
      'satelliteCount': serializer.toJson<int?>(satelliteCount),
      'provider': serializer.toJson<String?>(provider),
      'isMocked': serializer.toJson<bool>(isMocked),
      'fixType': serializer.toJson<String?>(fixType),
      'state': serializer.toJson<String?>(state),
    };
  }

  ActivityPoint copyWith({
    String? activityId,
    int? pointIndex,
    double? lat,
    double? lng,
    double? elevation,
    double? pace,
    DateTime? timestamp,
    Value<int?> accuracy = const Value.absent(),
    Value<double?> hdop = const Value.absent(),
    Value<int?> satelliteCount = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    bool? isMocked,
    Value<String?> fixType = const Value.absent(),
    Value<String?> state = const Value.absent(),
  }) => ActivityPoint(
    activityId: activityId ?? this.activityId,
    pointIndex: pointIndex ?? this.pointIndex,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    elevation: elevation ?? this.elevation,
    pace: pace ?? this.pace,
    timestamp: timestamp ?? this.timestamp,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    hdop: hdop.present ? hdop.value : this.hdop,
    satelliteCount: satelliteCount.present
        ? satelliteCount.value
        : this.satelliteCount,
    provider: provider.present ? provider.value : this.provider,
    isMocked: isMocked ?? this.isMocked,
    fixType: fixType.present ? fixType.value : this.fixType,
    state: state.present ? state.value : this.state,
  );
  ActivityPoint copyWithCompanion(ActivityPointsCompanion data) {
    return ActivityPoint(
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      pointIndex: data.pointIndex.present
          ? data.pointIndex.value
          : this.pointIndex,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      elevation: data.elevation.present ? data.elevation.value : this.elevation,
      pace: data.pace.present ? data.pace.value : this.pace,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      hdop: data.hdop.present ? data.hdop.value : this.hdop,
      satelliteCount: data.satelliteCount.present
          ? data.satelliteCount.value
          : this.satelliteCount,
      provider: data.provider.present ? data.provider.value : this.provider,
      isMocked: data.isMocked.present ? data.isMocked.value : this.isMocked,
      fixType: data.fixType.present ? data.fixType.value : this.fixType,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityPoint(')
          ..write('activityId: $activityId, ')
          ..write('pointIndex: $pointIndex, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('elevation: $elevation, ')
          ..write('pace: $pace, ')
          ..write('timestamp: $timestamp, ')
          ..write('accuracy: $accuracy, ')
          ..write('hdop: $hdop, ')
          ..write('satelliteCount: $satelliteCount, ')
          ..write('provider: $provider, ')
          ..write('isMocked: $isMocked, ')
          ..write('fixType: $fixType, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    activityId,
    pointIndex,
    lat,
    lng,
    elevation,
    pace,
    timestamp,
    accuracy,
    hdop,
    satelliteCount,
    provider,
    isMocked,
    fixType,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityPoint &&
          other.activityId == this.activityId &&
          other.pointIndex == this.pointIndex &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.elevation == this.elevation &&
          other.pace == this.pace &&
          other.timestamp == this.timestamp &&
          other.accuracy == this.accuracy &&
          other.hdop == this.hdop &&
          other.satelliteCount == this.satelliteCount &&
          other.provider == this.provider &&
          other.isMocked == this.isMocked &&
          other.fixType == this.fixType &&
          other.state == this.state);
}

class ActivityPointsCompanion extends UpdateCompanion<ActivityPoint> {
  final Value<String> activityId;
  final Value<int> pointIndex;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double> elevation;
  final Value<double> pace;
  final Value<DateTime> timestamp;
  final Value<int?> accuracy;
  final Value<double?> hdop;
  final Value<int?> satelliteCount;
  final Value<String?> provider;
  final Value<bool> isMocked;
  final Value<String?> fixType;
  final Value<String?> state;
  final Value<int> rowid;
  const ActivityPointsCompanion({
    this.activityId = const Value.absent(),
    this.pointIndex = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.elevation = const Value.absent(),
    this.pace = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.hdop = const Value.absent(),
    this.satelliteCount = const Value.absent(),
    this.provider = const Value.absent(),
    this.isMocked = const Value.absent(),
    this.fixType = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityPointsCompanion.insert({
    required String activityId,
    required int pointIndex,
    required double lat,
    required double lng,
    required double elevation,
    required double pace,
    required DateTime timestamp,
    this.accuracy = const Value.absent(),
    this.hdop = const Value.absent(),
    this.satelliteCount = const Value.absent(),
    this.provider = const Value.absent(),
    this.isMocked = const Value.absent(),
    this.fixType = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : activityId = Value(activityId),
       pointIndex = Value(pointIndex),
       lat = Value(lat),
       lng = Value(lng),
       elevation = Value(elevation),
       pace = Value(pace),
       timestamp = Value(timestamp);
  static Insertable<ActivityPoint> custom({
    Expression<String>? activityId,
    Expression<int>? pointIndex,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? elevation,
    Expression<double>? pace,
    Expression<DateTime>? timestamp,
    Expression<int>? accuracy,
    Expression<double>? hdop,
    Expression<int>? satelliteCount,
    Expression<String>? provider,
    Expression<bool>? isMocked,
    Expression<String>? fixType,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (activityId != null) 'activity_id': activityId,
      if (pointIndex != null) 'point_index': pointIndex,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (elevation != null) 'elevation': elevation,
      if (pace != null) 'pace': pace,
      if (timestamp != null) 'timestamp': timestamp,
      if (accuracy != null) 'accuracy': accuracy,
      if (hdop != null) 'hdop': hdop,
      if (satelliteCount != null) 'satellite_count': satelliteCount,
      if (provider != null) 'provider': provider,
      if (isMocked != null) 'is_mocked': isMocked,
      if (fixType != null) 'fix_type': fixType,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityPointsCompanion copyWith({
    Value<String>? activityId,
    Value<int>? pointIndex,
    Value<double>? lat,
    Value<double>? lng,
    Value<double>? elevation,
    Value<double>? pace,
    Value<DateTime>? timestamp,
    Value<int?>? accuracy,
    Value<double?>? hdop,
    Value<int?>? satelliteCount,
    Value<String?>? provider,
    Value<bool>? isMocked,
    Value<String?>? fixType,
    Value<String?>? state,
    Value<int>? rowid,
  }) {
    return ActivityPointsCompanion(
      activityId: activityId ?? this.activityId,
      pointIndex: pointIndex ?? this.pointIndex,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      elevation: elevation ?? this.elevation,
      pace: pace ?? this.pace,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
      hdop: hdop ?? this.hdop,
      satelliteCount: satelliteCount ?? this.satelliteCount,
      provider: provider ?? this.provider,
      isMocked: isMocked ?? this.isMocked,
      fixType: fixType ?? this.fixType,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (pointIndex.present) {
      map['point_index'] = Variable<int>(pointIndex.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (elevation.present) {
      map['elevation'] = Variable<double>(elevation.value);
    }
    if (pace.present) {
      map['pace'] = Variable<double>(pace.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<int>(accuracy.value);
    }
    if (hdop.present) {
      map['hdop'] = Variable<double>(hdop.value);
    }
    if (satelliteCount.present) {
      map['satellite_count'] = Variable<int>(satelliteCount.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (isMocked.present) {
      map['is_mocked'] = Variable<bool>(isMocked.value);
    }
    if (fixType.present) {
      map['fix_type'] = Variable<String>(fixType.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityPointsCompanion(')
          ..write('activityId: $activityId, ')
          ..write('pointIndex: $pointIndex, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('elevation: $elevation, ')
          ..write('pace: $pace, ')
          ..write('timestamp: $timestamp, ')
          ..write('accuracy: $accuracy, ')
          ..write('hdop: $hdop, ')
          ..write('satelliteCount: $satelliteCount, ')
          ..write('provider: $provider, ')
          ..write('isMocked: $isMocked, ')
          ..write('fixType: $fixType, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $ActivityPointsTable activityPoints = $ActivityPointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    activities,
    activityPoints,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      Value<String?> email,
      required String displayName,
      required DateTime createdAt,
      required String settingsJson,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String?> email,
      Value<String> displayName,
      Value<DateTime> createdAt,
      Value<String> settingsJson,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                displayName: displayName,
                createdAt: createdAt,
                settingsJson: settingsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> email = const Value.absent(),
                required String displayName,
                required DateTime createdAt,
                required String settingsJson,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                displayName: displayName,
                createdAt: createdAt,
                settingsJson: settingsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      required String userId,
      Value<String> type,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required double distanceM,
      required int durationMs,
      required int movingTimeMs,
      Value<int> calories,
      Value<double> elevationGainM,
      Value<int> avgHeartRate,
      Value<int> avgCadence,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> type,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double> distanceM,
      Value<int> durationMs,
      Value<int> movingTimeMs,
      Value<int> calories,
      Value<double> elevationGainM,
      Value<int> avgHeartRate,
      Value<int> avgCadence,
      Value<int> rowid,
    });

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingTimeMs => $composableBuilder(
    column: $table.movingTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingTimeMs => $composableBuilder(
    column: $table.movingTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get movingTimeMs => $composableBuilder(
    column: $table.movingTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get elevationGainM => $composableBuilder(
    column: $table.elevationGainM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => column,
  );
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
          Activity,
          PrefetchHooks Function()
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> movingTimeMs = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<double> elevationGainM = const Value.absent(),
                Value<int> avgHeartRate = const Value.absent(),
                Value<int> avgCadence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                userId: userId,
                type: type,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceM: distanceM,
                durationMs: durationMs,
                movingTimeMs: movingTimeMs,
                calories: calories,
                elevationGainM: elevationGainM,
                avgHeartRate: avgHeartRate,
                avgCadence: avgCadence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String> type = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required double distanceM,
                required int durationMs,
                required int movingTimeMs,
                Value<int> calories = const Value.absent(),
                Value<double> elevationGainM = const Value.absent(),
                Value<int> avgHeartRate = const Value.absent(),
                Value<int> avgCadence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                startedAt: startedAt,
                endedAt: endedAt,
                distanceM: distanceM,
                durationMs: durationMs,
                movingTimeMs: movingTimeMs,
                calories: calories,
                elevationGainM: elevationGainM,
                avgHeartRate: avgHeartRate,
                avgCadence: avgCadence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
      Activity,
      PrefetchHooks Function()
    >;
typedef $$ActivityPointsTableCreateCompanionBuilder =
    ActivityPointsCompanion Function({
      required String activityId,
      required int pointIndex,
      required double lat,
      required double lng,
      required double elevation,
      required double pace,
      required DateTime timestamp,
      Value<int?> accuracy,
      Value<double?> hdop,
      Value<int?> satelliteCount,
      Value<String?> provider,
      Value<bool> isMocked,
      Value<String?> fixType,
      Value<String?> state,
      Value<int> rowid,
    });
typedef $$ActivityPointsTableUpdateCompanionBuilder =
    ActivityPointsCompanion Function({
      Value<String> activityId,
      Value<int> pointIndex,
      Value<double> lat,
      Value<double> lng,
      Value<double> elevation,
      Value<double> pace,
      Value<DateTime> timestamp,
      Value<int?> accuracy,
      Value<double?> hdop,
      Value<int?> satelliteCount,
      Value<String?> provider,
      Value<bool> isMocked,
      Value<String?> fixType,
      Value<String?> state,
      Value<int> rowid,
    });

class $$ActivityPointsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityPointsTable> {
  $$ActivityPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointIndex => $composableBuilder(
    column: $table.pointIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevation => $composableBuilder(
    column: $table.elevation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pace => $composableBuilder(
    column: $table.pace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hdop => $composableBuilder(
    column: $table.hdop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get satelliteCount => $composableBuilder(
    column: $table.satelliteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMocked => $composableBuilder(
    column: $table.isMocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fixType => $composableBuilder(
    column: $table.fixType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityPointsTable> {
  $$ActivityPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointIndex => $composableBuilder(
    column: $table.pointIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevation => $composableBuilder(
    column: $table.elevation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pace => $composableBuilder(
    column: $table.pace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hdop => $composableBuilder(
    column: $table.hdop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get satelliteCount => $composableBuilder(
    column: $table.satelliteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMocked => $composableBuilder(
    column: $table.isMocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixType => $composableBuilder(
    column: $table.fixType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityPointsTable> {
  $$ActivityPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointIndex => $composableBuilder(
    column: $table.pointIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get elevation =>
      $composableBuilder(column: $table.elevation, builder: (column) => column);

  GeneratedColumn<double> get pace =>
      $composableBuilder(column: $table.pace, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get hdop =>
      $composableBuilder(column: $table.hdop, builder: (column) => column);

  GeneratedColumn<int> get satelliteCount => $composableBuilder(
    column: $table.satelliteCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<bool> get isMocked =>
      $composableBuilder(column: $table.isMocked, builder: (column) => column);

  GeneratedColumn<String> get fixType =>
      $composableBuilder(column: $table.fixType, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$ActivityPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityPointsTable,
          ActivityPoint,
          $$ActivityPointsTableFilterComposer,
          $$ActivityPointsTableOrderingComposer,
          $$ActivityPointsTableAnnotationComposer,
          $$ActivityPointsTableCreateCompanionBuilder,
          $$ActivityPointsTableUpdateCompanionBuilder,
          (
            ActivityPoint,
            BaseReferences<_$AppDatabase, $ActivityPointsTable, ActivityPoint>,
          ),
          ActivityPoint,
          PrefetchHooks Function()
        > {
  $$ActivityPointsTableTableManager(
    _$AppDatabase db,
    $ActivityPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> activityId = const Value.absent(),
                Value<int> pointIndex = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double> elevation = const Value.absent(),
                Value<double> pace = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int?> accuracy = const Value.absent(),
                Value<double?> hdop = const Value.absent(),
                Value<int?> satelliteCount = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<bool> isMocked = const Value.absent(),
                Value<String?> fixType = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityPointsCompanion(
                activityId: activityId,
                pointIndex: pointIndex,
                lat: lat,
                lng: lng,
                elevation: elevation,
                pace: pace,
                timestamp: timestamp,
                accuracy: accuracy,
                hdop: hdop,
                satelliteCount: satelliteCount,
                provider: provider,
                isMocked: isMocked,
                fixType: fixType,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String activityId,
                required int pointIndex,
                required double lat,
                required double lng,
                required double elevation,
                required double pace,
                required DateTime timestamp,
                Value<int?> accuracy = const Value.absent(),
                Value<double?> hdop = const Value.absent(),
                Value<int?> satelliteCount = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<bool> isMocked = const Value.absent(),
                Value<String?> fixType = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityPointsCompanion.insert(
                activityId: activityId,
                pointIndex: pointIndex,
                lat: lat,
                lng: lng,
                elevation: elevation,
                pace: pace,
                timestamp: timestamp,
                accuracy: accuracy,
                hdop: hdop,
                satelliteCount: satelliteCount,
                provider: provider,
                isMocked: isMocked,
                fixType: fixType,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityPointsTable,
      ActivityPoint,
      $$ActivityPointsTableFilterComposer,
      $$ActivityPointsTableOrderingComposer,
      $$ActivityPointsTableAnnotationComposer,
      $$ActivityPointsTableCreateCompanionBuilder,
      $$ActivityPointsTableUpdateCompanionBuilder,
      (
        ActivityPoint,
        BaseReferences<_$AppDatabase, $ActivityPointsTable, ActivityPoint>,
      ),
      ActivityPoint,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$ActivityPointsTableTableManager get activityPoints =>
      $$ActivityPointsTableTableManager(_db, _db.activityPoints);
}
