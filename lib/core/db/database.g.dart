// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, Workspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultCurrencyMeta = const VerificationMeta(
    'defaultCurrency',
  );
  @override
  late final GeneratedColumn<String> defaultCurrency = GeneratedColumn<String>(
    'default_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDemoMeta = const VerificationMeta('isDemo');
  @override
  late final GeneratedColumn<bool> isDemo = GeneratedColumn<bool>(
    'is_demo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_demo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    defaultCurrency,
    isDemo,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('default_currency')) {
      context.handle(
        _defaultCurrencyMeta,
        defaultCurrency.isAcceptableOrUnknown(
          data['default_currency']!,
          _defaultCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultCurrencyMeta);
    }
    if (data.containsKey('is_demo')) {
      context.handle(
        _isDemoMeta,
        isDemo.isAcceptableOrUnknown(data['is_demo']!, _isDemoMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workspace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      defaultCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_currency'],
      )!,
      isDemo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_demo'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class Workspace extends DataClass implements Insertable<Workspace> {
  final String id;
  final String name;
  final String kind;
  final String defaultCurrency;
  final bool isDemo;
  final String role;
  const Workspace({
    required this.id,
    required this.name,
    required this.kind,
    required this.defaultCurrency,
    required this.isDemo,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['default_currency'] = Variable<String>(defaultCurrency);
    map['is_demo'] = Variable<bool>(isDemo);
    map['role'] = Variable<String>(role);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      defaultCurrency: Value(defaultCurrency),
      isDemo: Value(isDemo),
      role: Value(role),
    );
  }

  factory Workspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workspace(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      defaultCurrency: serializer.fromJson<String>(json['defaultCurrency']),
      isDemo: serializer.fromJson<bool>(json['isDemo']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'defaultCurrency': serializer.toJson<String>(defaultCurrency),
      'isDemo': serializer.toJson<bool>(isDemo),
      'role': serializer.toJson<String>(role),
    };
  }

  Workspace copyWith({
    String? id,
    String? name,
    String? kind,
    String? defaultCurrency,
    bool? isDemo,
    String? role,
  }) => Workspace(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    isDemo: isDemo ?? this.isDemo,
    role: role ?? this.role,
  );
  Workspace copyWithCompanion(WorkspacesCompanion data) {
    return Workspace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      defaultCurrency: data.defaultCurrency.present
          ? data.defaultCurrency.value
          : this.defaultCurrency,
      isDemo: data.isDemo.present ? data.isDemo.value : this.isDemo,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workspace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('isDemo: $isDemo, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kind, defaultCurrency, isDemo, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workspace &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.defaultCurrency == this.defaultCurrency &&
          other.isDemo == this.isDemo &&
          other.role == this.role);
}

class WorkspacesCompanion extends UpdateCompanion<Workspace> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> defaultCurrency;
  final Value<bool> isDemo;
  final Value<String> role;
  final Value<int> rowid;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.defaultCurrency = const Value.absent(),
    this.isDemo = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required String defaultCurrency,
    this.isDemo = const Value.absent(),
    required String role,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       defaultCurrency = Value(defaultCurrency),
       role = Value(role);
  static Insertable<Workspace> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? defaultCurrency,
    Expression<bool>? isDemo,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (defaultCurrency != null) 'default_currency': defaultCurrency,
      if (isDemo != null) 'is_demo': isDemo,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? defaultCurrency,
    Value<bool>? isDemo,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      isDemo: isDemo ?? this.isDemo,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (defaultCurrency.present) {
      map['default_currency'] = Variable<String>(defaultCurrency.value);
    }
    if (isDemo.present) {
      map['is_demo'] = Variable<bool>(isDemo.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('defaultCurrency: $defaultCurrency, ')
          ..write('isDemo: $isDemo, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspaceTagsTable extends WorkspaceTags
    with TableInfo<$WorkspaceTagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspaceTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $WorkspaceTagsTable createAlias(String alias) {
    return $WorkspaceTagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String name;

  /// '#RRGGBB' the user chose; null leaves the colour to the app (categoryFill).
  final String? color;
  const Tag({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  WorkspaceTagsCompanion toCompanion(bool nullToAbsent) {
    return WorkspaceTagsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
    };
  }

  Tag copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> color = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
  );
  Tag copyWithCompanion(WorkspaceTagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.color == this.color);
}

class WorkspaceTagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> name;
  final Value<String?> color;
  final Value<int> rowid;
  const WorkspaceTagsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspaceTagsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspaceTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? name,
    Value<String?>? color,
    Value<int>? rowid,
  }) {
    return WorkspaceTagsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceTagsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashbooksTable extends Cashbooks
    with TableInfo<$CashbooksTable, Cashbook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashbooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookNameMeta = const VerificationMeta(
    'bookName',
  );
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
    'book_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    bookName,
    description,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cashbooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cashbook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cashbook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cashbook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      bookName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $CashbooksTable createAlias(String alias) {
    return $CashbooksTable(attachedDatabase, alias);
  }
}

class Cashbook extends DataClass implements Insertable<Cashbook> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String bookName;
  final String? description;
  final String currency;
  const Cashbook({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.bookName,
    this.description,
    required this.currency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['book_name'] = Variable<String>(bookName);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['currency'] = Variable<String>(currency);
    return map;
  }

  CashbooksCompanion toCompanion(bool nullToAbsent) {
    return CashbooksCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      bookName: Value(bookName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      currency: Value(currency),
    );
  }

  factory Cashbook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cashbook(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      bookName: serializer.fromJson<String>(json['bookName']),
      description: serializer.fromJson<String?>(json['description']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'bookName': serializer.toJson<String>(bookName),
      'description': serializer.toJson<String?>(description),
      'currency': serializer.toJson<String>(currency),
    };
  }

  Cashbook copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? bookName,
    Value<String?> description = const Value.absent(),
    String? currency,
  }) => Cashbook(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    bookName: bookName ?? this.bookName,
    description: description.present ? description.value : this.description,
    currency: currency ?? this.currency,
  );
  Cashbook copyWithCompanion(CashbooksCompanion data) {
    return Cashbook(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      description: data.description.present
          ? data.description.value
          : this.description,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cashbook(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('bookName: $bookName, ')
          ..write('description: $description, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    bookName,
    description,
    currency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cashbook &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.bookName == this.bookName &&
          other.description == this.description &&
          other.currency == this.currency);
}

class CashbooksCompanion extends UpdateCompanion<Cashbook> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> bookName;
  final Value<String?> description;
  final Value<String> currency;
  final Value<int> rowid;
  const CashbooksCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.bookName = const Value.absent(),
    this.description = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashbooksCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String bookName,
    this.description = const Value.absent(),
    required String currency,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       bookName = Value(bookName),
       currency = Value(currency);
  static Insertable<Cashbook> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? bookName,
    Expression<String>? description,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (bookName != null) 'book_name': bookName,
      if (description != null) 'description': description,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashbooksCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? bookName,
    Value<String?>? description,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return CashbooksCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      bookName: bookName ?? this.bookName,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashbooksCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('bookName: $bookName, ')
          ..write('description: $description, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntryCategoriesTable extends EntryCategories
    with TableInfo<$EntryCategoriesTable, EntryCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashbookIdMeta = const VerificationMeta(
    'cashbookId',
  );
  @override
  late final GeneratedColumn<String> cashbookId = GeneratedColumn<String>(
    'cashbook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    categoryName,
    isDefault,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cashbook_id')) {
      context.handle(
        _cashbookIdMeta,
        cashbookId.isAcceptableOrUnknown(data['cashbook_id']!, _cashbookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashbookIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      cashbookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashbook_id'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $EntryCategoriesTable createAlias(String alias) {
    return $EntryCategoriesTable(attachedDatabase, alias);
  }
}

class EntryCategory extends DataClass implements Insertable<EntryCategory> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String cashbookId;
  final String categoryName;
  final bool isDefault;

  /// '#RRGGBB' the user chose; null leaves the colour to the app (categoryFill).
  final String? color;
  const EntryCategory({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cashbookId,
    required this.categoryName,
    required this.isDefault,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['cashbook_id'] = Variable<String>(cashbookId);
    map['category_name'] = Variable<String>(categoryName);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  EntryCategoriesCompanion toCompanion(bool nullToAbsent) {
    return EntryCategoriesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cashbookId: Value(cashbookId),
      categoryName: Value(categoryName),
      isDefault: Value(isDefault),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory EntryCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryCategory(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      cashbookId: serializer.fromJson<String>(json['cashbookId']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'cashbookId': serializer.toJson<String>(cashbookId),
      'categoryName': serializer.toJson<String>(categoryName),
      'isDefault': serializer.toJson<bool>(isDefault),
      'color': serializer.toJson<String?>(color),
    };
  }

  EntryCategory copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? cashbookId,
    String? categoryName,
    bool? isDefault,
    Value<String?> color = const Value.absent(),
  }) => EntryCategory(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    cashbookId: cashbookId ?? this.cashbookId,
    categoryName: categoryName ?? this.categoryName,
    isDefault: isDefault ?? this.isDefault,
    color: color.present ? color.value : this.color,
  );
  EntryCategory copyWithCompanion(EntryCategoriesCompanion data) {
    return EntryCategory(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cashbookId: data.cashbookId.present
          ? data.cashbookId.value
          : this.cashbookId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryCategory(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('categoryName: $categoryName, ')
          ..write('isDefault: $isDefault, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    categoryName,
    isDefault,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryCategory &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cashbookId == this.cashbookId &&
          other.categoryName == this.categoryName &&
          other.isDefault == this.isDefault &&
          other.color == this.color);
}

class EntryCategoriesCompanion extends UpdateCompanion<EntryCategory> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> cashbookId;
  final Value<String> categoryName;
  final Value<bool> isDefault;
  final Value<String?> color;
  final Value<int> rowid;
  const EntryCategoriesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cashbookId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryCategoriesCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String cashbookId,
    required String categoryName,
    this.isDefault = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cashbookId = Value(cashbookId),
       categoryName = Value(categoryName);
  static Insertable<EntryCategory> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? cashbookId,
    Expression<String>? categoryName,
    Expression<bool>? isDefault,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cashbookId != null) 'cashbook_id': cashbookId,
      if (categoryName != null) 'category_name': categoryName,
      if (isDefault != null) 'is_default': isDefault,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? cashbookId,
    Value<String>? categoryName,
    Value<bool>? isDefault,
    Value<String?>? color,
    Value<int>? rowid,
  }) {
    return EntryCategoriesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cashbookId: cashbookId ?? this.cashbookId,
      categoryName: categoryName ?? this.categoryName,
      isDefault: isDefault ?? this.isDefault,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (cashbookId.present) {
      map['cashbook_id'] = Variable<String>(cashbookId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('categoryName: $categoryName, ')
          ..write('isDefault: $isDefault, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentMethodsTable extends PaymentMethods
    with TableInfo<$PaymentMethodsTable, PaymentMethod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashbookIdMeta = const VerificationMeta(
    'cashbookId',
  );
  @override
  late final GeneratedColumn<String> cashbookId = GeneratedColumn<String>(
    'cashbook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodNameMeta = const VerificationMeta(
    'paymentMethodName',
  );
  @override
  late final GeneratedColumn<String> paymentMethodName =
      GeneratedColumn<String>(
        'payment_method_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    paymentMethodName,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_methods';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentMethod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cashbook_id')) {
      context.handle(
        _cashbookIdMeta,
        cashbookId.isAcceptableOrUnknown(data['cashbook_id']!, _cashbookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashbookIdMeta);
    }
    if (data.containsKey('payment_method_name')) {
      context.handle(
        _paymentMethodNameMeta,
        paymentMethodName.isAcceptableOrUnknown(
          data['payment_method_name']!,
          _paymentMethodNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodNameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentMethod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentMethod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      cashbookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashbook_id'],
      )!,
      paymentMethodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $PaymentMethodsTable createAlias(String alias) {
    return $PaymentMethodsTable(attachedDatabase, alias);
  }
}

class PaymentMethod extends DataClass implements Insertable<PaymentMethod> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String cashbookId;
  final String paymentMethodName;
  final bool isDefault;
  const PaymentMethod({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cashbookId,
    required this.paymentMethodName,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['cashbook_id'] = Variable<String>(cashbookId);
    map['payment_method_name'] = Variable<String>(paymentMethodName);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  PaymentMethodsCompanion toCompanion(bool nullToAbsent) {
    return PaymentMethodsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cashbookId: Value(cashbookId),
      paymentMethodName: Value(paymentMethodName),
      isDefault: Value(isDefault),
    );
  }

  factory PaymentMethod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentMethod(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      cashbookId: serializer.fromJson<String>(json['cashbookId']),
      paymentMethodName: serializer.fromJson<String>(json['paymentMethodName']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'cashbookId': serializer.toJson<String>(cashbookId),
      'paymentMethodName': serializer.toJson<String>(paymentMethodName),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  PaymentMethod copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? cashbookId,
    String? paymentMethodName,
    bool? isDefault,
  }) => PaymentMethod(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    cashbookId: cashbookId ?? this.cashbookId,
    paymentMethodName: paymentMethodName ?? this.paymentMethodName,
    isDefault: isDefault ?? this.isDefault,
  );
  PaymentMethod copyWithCompanion(PaymentMethodsCompanion data) {
    return PaymentMethod(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cashbookId: data.cashbookId.present
          ? data.cashbookId.value
          : this.cashbookId,
      paymentMethodName: data.paymentMethodName.present
          ? data.paymentMethodName.value
          : this.paymentMethodName,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethod(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('paymentMethodName: $paymentMethodName, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    paymentMethodName,
    isDefault,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentMethod &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cashbookId == this.cashbookId &&
          other.paymentMethodName == this.paymentMethodName &&
          other.isDefault == this.isDefault);
}

class PaymentMethodsCompanion extends UpdateCompanion<PaymentMethod> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> cashbookId;
  final Value<String> paymentMethodName;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const PaymentMethodsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cashbookId = const Value.absent(),
    this.paymentMethodName = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentMethodsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String cashbookId,
    required String paymentMethodName,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cashbookId = Value(cashbookId),
       paymentMethodName = Value(paymentMethodName);
  static Insertable<PaymentMethod> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? cashbookId,
    Expression<String>? paymentMethodName,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cashbookId != null) 'cashbook_id': cashbookId,
      if (paymentMethodName != null) 'payment_method_name': paymentMethodName,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentMethodsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? cashbookId,
    Value<String>? paymentMethodName,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return PaymentMethodsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cashbookId: cashbookId ?? this.cashbookId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (cashbookId.present) {
      map['cashbook_id'] = Variable<String>(cashbookId.value);
    }
    if (paymentMethodName.present) {
      map['payment_method_name'] = Variable<String>(paymentMethodName.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethodsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('paymentMethodName: $paymentMethodName, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntryFieldsTable extends EntryFields
    with TableInfo<$EntryFieldsTable, EntryField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashbookIdMeta = const VerificationMeta(
    'cashbookId',
  );
  @override
  late final GeneratedColumn<String> cashbookId = GeneratedColumn<String>(
    'cashbook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isRequiredMeta = const VerificationMeta(
    'isRequired',
  );
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
    'required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showInListMeta = const VerificationMeta(
    'showInList',
  );
  @override
  late final GeneratedColumn<bool> showInList = GeneratedColumn<bool>(
    'show_in_list',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_in_list" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    name,
    kind,
    options,
    isRequired,
    showInList,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryField> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cashbook_id')) {
      context.handle(
        _cashbookIdMeta,
        cashbookId.isAcceptableOrUnknown(data['cashbook_id']!, _cashbookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashbookIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    }
    if (data.containsKey('required')) {
      context.handle(
        _isRequiredMeta,
        isRequired.isAcceptableOrUnknown(data['required']!, _isRequiredMeta),
      );
    }
    if (data.containsKey('show_in_list')) {
      context.handle(
        _showInListMeta,
        showInList.isAcceptableOrUnknown(
          data['show_in_list']!,
          _showInListMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryField(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      cashbookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashbook_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      )!,
      isRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}required'],
      )!,
      showInList: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_in_list'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $EntryFieldsTable createAlias(String alias) {
    return $EntryFieldsTable(attachedDatabase, alias);
  }
}

class EntryField extends DataClass implements Insertable<EntryField> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String cashbookId;
  final String name;

  /// text, number, date or choice. Fixed once the field exists.
  final String kind;

  /// JSON list of what a choice field offers; '[]' for every other kind.
  final String options;

  /// Asked for by the app on new entries only; the server never refuses a missing value.
  final bool isRequired;

  /// The one field shown on the book's entry list.
  final bool showInList;
  final int position;
  const EntryField({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cashbookId,
    required this.name,
    required this.kind,
    required this.options,
    required this.isRequired,
    required this.showInList,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['cashbook_id'] = Variable<String>(cashbookId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['options'] = Variable<String>(options);
    map['required'] = Variable<bool>(isRequired);
    map['show_in_list'] = Variable<bool>(showInList);
    map['position'] = Variable<int>(position);
    return map;
  }

  EntryFieldsCompanion toCompanion(bool nullToAbsent) {
    return EntryFieldsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cashbookId: Value(cashbookId),
      name: Value(name),
      kind: Value(kind),
      options: Value(options),
      isRequired: Value(isRequired),
      showInList: Value(showInList),
      position: Value(position),
    );
  }

  factory EntryField.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryField(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      cashbookId: serializer.fromJson<String>(json['cashbookId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      options: serializer.fromJson<String>(json['options']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
      showInList: serializer.fromJson<bool>(json['showInList']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'cashbookId': serializer.toJson<String>(cashbookId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'options': serializer.toJson<String>(options),
      'isRequired': serializer.toJson<bool>(isRequired),
      'showInList': serializer.toJson<bool>(showInList),
      'position': serializer.toJson<int>(position),
    };
  }

  EntryField copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? cashbookId,
    String? name,
    String? kind,
    String? options,
    bool? isRequired,
    bool? showInList,
    int? position,
  }) => EntryField(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    cashbookId: cashbookId ?? this.cashbookId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    options: options ?? this.options,
    isRequired: isRequired ?? this.isRequired,
    showInList: showInList ?? this.showInList,
    position: position ?? this.position,
  );
  EntryField copyWithCompanion(EntryFieldsCompanion data) {
    return EntryField(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cashbookId: data.cashbookId.present
          ? data.cashbookId.value
          : this.cashbookId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      options: data.options.present ? data.options.value : this.options,
      isRequired: data.isRequired.present
          ? data.isRequired.value
          : this.isRequired,
      showInList: data.showInList.present
          ? data.showInList.value
          : this.showInList,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryField(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('options: $options, ')
          ..write('isRequired: $isRequired, ')
          ..write('showInList: $showInList, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    name,
    kind,
    options,
    isRequired,
    showInList,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryField &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cashbookId == this.cashbookId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.options == this.options &&
          other.isRequired == this.isRequired &&
          other.showInList == this.showInList &&
          other.position == this.position);
}

class EntryFieldsCompanion extends UpdateCompanion<EntryField> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> cashbookId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> options;
  final Value<bool> isRequired;
  final Value<bool> showInList;
  final Value<int> position;
  final Value<int> rowid;
  const EntryFieldsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cashbookId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.options = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.showInList = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryFieldsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String cashbookId,
    required String name,
    required String kind,
    this.options = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.showInList = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cashbookId = Value(cashbookId),
       name = Value(name),
       kind = Value(kind);
  static Insertable<EntryField> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? cashbookId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? options,
    Expression<bool>? isRequired,
    Expression<bool>? showInList,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cashbookId != null) 'cashbook_id': cashbookId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (options != null) 'options': options,
      if (isRequired != null) 'required': isRequired,
      if (showInList != null) 'show_in_list': showInList,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryFieldsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? cashbookId,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? options,
    Value<bool>? isRequired,
    Value<bool>? showInList,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return EntryFieldsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cashbookId: cashbookId ?? this.cashbookId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      showInList: showInList ?? this.showInList,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (cashbookId.present) {
      map['cashbook_id'] = Variable<String>(cashbookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (isRequired.present) {
      map['required'] = Variable<bool>(isRequired.value);
    }
    if (showInList.present) {
      map['show_in_list'] = Variable<bool>(showInList.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryFieldsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('options: $options, ')
          ..write('isRequired: $isRequired, ')
          ..write('showInList: $showInList, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashbookIdMeta = const VerificationMeta(
    'cashbookId',
  );
  @override
  late final GeneratedColumn<String> cashbookId = GeneratedColumn<String>(
    'cashbook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodIdMeta = const VerificationMeta(
    'paymentMethodId',
  );
  @override
  late final GeneratedColumn<String> paymentMethodId = GeneratedColumn<String>(
    'payment_method_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagIdsMeta = const VerificationMeta('tagIds');
  @override
  late final GeneratedColumn<String> tagIds = GeneratedColumn<String>(
    'tag_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _createdByIdMeta = const VerificationMeta(
    'createdById',
  );
  @override
  late final GeneratedColumn<String> createdById = GeneratedColumn<String>(
    'created_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customValuesMeta = const VerificationMeta(
    'customValues',
  );
  @override
  late final GeneratedColumn<String> customValues = GeneratedColumn<String>(
    'custom_values',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    categoryId,
    paymentMethodId,
    entryType,
    amountMinor,
    currency,
    title,
    remarks,
    merchant,
    tagIds,
    entryDate,
    source,
    createdById,
    customValues,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cashbook_id')) {
      context.handle(
        _cashbookIdMeta,
        cashbookId.isAcceptableOrUnknown(data['cashbook_id']!, _cashbookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashbookIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('payment_method_id')) {
      context.handle(
        _paymentMethodIdMeta,
        paymentMethodId.isAcceptableOrUnknown(
          data['payment_method_id']!,
          _paymentMethodIdMeta,
        ),
      );
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('tag_ids')) {
      context.handle(
        _tagIdsMeta,
        tagIds.isAcceptableOrUnknown(data['tag_ids']!, _tagIdsMeta),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_by_id')) {
      context.handle(
        _createdByIdMeta,
        createdById.isAcceptableOrUnknown(
          data['created_by_id']!,
          _createdByIdMeta,
        ),
      );
    }
    if (data.containsKey('custom_values')) {
      context.handle(
        _customValuesMeta,
        customValues.isAcceptableOrUnknown(
          data['custom_values']!,
          _customValuesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      cashbookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashbook_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      paymentMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_id'],
      ),
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      tagIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_ids'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_id'],
      ),
      customValues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_values'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String cashbookId;
  final String? categoryId;
  final String? paymentMethodId;
  final String entryType;
  final int amountMinor;
  final String currency;
  final String? title;
  final String? remarks;

  /// The party paid or paid by; '' when not given (features/tags/merchants.dart).
  final String merchant;

  /// JSON list of the workspace's tag ids (features/tags/tag_ids.dart).
  final String tagIds;
  final String entryDate;
  final String source;
  final String? createdById;

  /// JSON map of the book's own fields: {field id: value as text}.
  final String customValues;
  const Entry({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cashbookId,
    this.categoryId,
    this.paymentMethodId,
    required this.entryType,
    required this.amountMinor,
    required this.currency,
    this.title,
    this.remarks,
    required this.merchant,
    required this.tagIds,
    required this.entryDate,
    required this.source,
    this.createdById,
    required this.customValues,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['cashbook_id'] = Variable<String>(cashbookId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || paymentMethodId != null) {
      map['payment_method_id'] = Variable<String>(paymentMethodId);
    }
    map['entry_type'] = Variable<String>(entryType);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    map['merchant'] = Variable<String>(merchant);
    map['tag_ids'] = Variable<String>(tagIds);
    map['entry_date'] = Variable<String>(entryDate);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || createdById != null) {
      map['created_by_id'] = Variable<String>(createdById);
    }
    map['custom_values'] = Variable<String>(customValues);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cashbookId: Value(cashbookId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      paymentMethodId: paymentMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodId),
      entryType: Value(entryType),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      merchant: Value(merchant),
      tagIds: Value(tagIds),
      entryDate: Value(entryDate),
      source: Value(source),
      createdById: createdById == null && nullToAbsent
          ? const Value.absent()
          : Value(createdById),
      customValues: Value(customValues),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      cashbookId: serializer.fromJson<String>(json['cashbookId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      paymentMethodId: serializer.fromJson<String?>(json['paymentMethodId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      title: serializer.fromJson<String?>(json['title']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      merchant: serializer.fromJson<String>(json['merchant']),
      tagIds: serializer.fromJson<String>(json['tagIds']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      source: serializer.fromJson<String>(json['source']),
      createdById: serializer.fromJson<String?>(json['createdById']),
      customValues: serializer.fromJson<String>(json['customValues']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'cashbookId': serializer.toJson<String>(cashbookId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'paymentMethodId': serializer.toJson<String?>(paymentMethodId),
      'entryType': serializer.toJson<String>(entryType),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'title': serializer.toJson<String?>(title),
      'remarks': serializer.toJson<String?>(remarks),
      'merchant': serializer.toJson<String>(merchant),
      'tagIds': serializer.toJson<String>(tagIds),
      'entryDate': serializer.toJson<String>(entryDate),
      'source': serializer.toJson<String>(source),
      'createdById': serializer.toJson<String?>(createdById),
      'customValues': serializer.toJson<String>(customValues),
    };
  }

  Entry copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? cashbookId,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> paymentMethodId = const Value.absent(),
    String? entryType,
    int? amountMinor,
    String? currency,
    Value<String?> title = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    String? merchant,
    String? tagIds,
    String? entryDate,
    String? source,
    Value<String?> createdById = const Value.absent(),
    String? customValues,
  }) => Entry(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    cashbookId: cashbookId ?? this.cashbookId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    paymentMethodId: paymentMethodId.present
        ? paymentMethodId.value
        : this.paymentMethodId,
    entryType: entryType ?? this.entryType,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    title: title.present ? title.value : this.title,
    remarks: remarks.present ? remarks.value : this.remarks,
    merchant: merchant ?? this.merchant,
    tagIds: tagIds ?? this.tagIds,
    entryDate: entryDate ?? this.entryDate,
    source: source ?? this.source,
    createdById: createdById.present ? createdById.value : this.createdById,
    customValues: customValues ?? this.customValues,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cashbookId: data.cashbookId.present
          ? data.cashbookId.value
          : this.cashbookId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      title: data.title.present ? data.title.value : this.title,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      tagIds: data.tagIds.present ? data.tagIds.value : this.tagIds,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      source: data.source.present ? data.source.value : this.source,
      createdById: data.createdById.present
          ? data.createdById.value
          : this.createdById,
      customValues: data.customValues.present
          ? data.customValues.value
          : this.customValues,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('entryType: $entryType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('title: $title, ')
          ..write('remarks: $remarks, ')
          ..write('merchant: $merchant, ')
          ..write('tagIds: $tagIds, ')
          ..write('entryDate: $entryDate, ')
          ..write('source: $source, ')
          ..write('createdById: $createdById, ')
          ..write('customValues: $customValues')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    categoryId,
    paymentMethodId,
    entryType,
    amountMinor,
    currency,
    title,
    remarks,
    merchant,
    tagIds,
    entryDate,
    source,
    createdById,
    customValues,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cashbookId == this.cashbookId &&
          other.categoryId == this.categoryId &&
          other.paymentMethodId == this.paymentMethodId &&
          other.entryType == this.entryType &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.title == this.title &&
          other.remarks == this.remarks &&
          other.merchant == this.merchant &&
          other.tagIds == this.tagIds &&
          other.entryDate == this.entryDate &&
          other.source == this.source &&
          other.createdById == this.createdById &&
          other.customValues == this.customValues);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> cashbookId;
  final Value<String?> categoryId;
  final Value<String?> paymentMethodId;
  final Value<String> entryType;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String?> title;
  final Value<String?> remarks;
  final Value<String> merchant;
  final Value<String> tagIds;
  final Value<String> entryDate;
  final Value<String> source;
  final Value<String?> createdById;
  final Value<String> customValues;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cashbookId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.title = const Value.absent(),
    this.remarks = const Value.absent(),
    this.merchant = const Value.absent(),
    this.tagIds = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.source = const Value.absent(),
    this.createdById = const Value.absent(),
    this.customValues = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String cashbookId,
    this.categoryId = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    required String entryType,
    required int amountMinor,
    required String currency,
    this.title = const Value.absent(),
    this.remarks = const Value.absent(),
    this.merchant = const Value.absent(),
    this.tagIds = const Value.absent(),
    required String entryDate,
    this.source = const Value.absent(),
    this.createdById = const Value.absent(),
    this.customValues = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cashbookId = Value(cashbookId),
       entryType = Value(entryType),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       entryDate = Value(entryDate);
  static Insertable<Entry> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? cashbookId,
    Expression<String>? categoryId,
    Expression<String>? paymentMethodId,
    Expression<String>? entryType,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? title,
    Expression<String>? remarks,
    Expression<String>? merchant,
    Expression<String>? tagIds,
    Expression<String>? entryDate,
    Expression<String>? source,
    Expression<String>? createdById,
    Expression<String>? customValues,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cashbookId != null) 'cashbook_id': cashbookId,
      if (categoryId != null) 'category_id': categoryId,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (entryType != null) 'entry_type': entryType,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (title != null) 'title': title,
      if (remarks != null) 'remarks': remarks,
      if (merchant != null) 'merchant': merchant,
      if (tagIds != null) 'tag_ids': tagIds,
      if (entryDate != null) 'entry_date': entryDate,
      if (source != null) 'source': source,
      if (createdById != null) 'created_by_id': createdById,
      if (customValues != null) 'custom_values': customValues,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? cashbookId,
    Value<String?>? categoryId,
    Value<String?>? paymentMethodId,
    Value<String>? entryType,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String?>? title,
    Value<String?>? remarks,
    Value<String>? merchant,
    Value<String>? tagIds,
    Value<String>? entryDate,
    Value<String>? source,
    Value<String?>? createdById,
    Value<String>? customValues,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cashbookId: cashbookId ?? this.cashbookId,
      categoryId: categoryId ?? this.categoryId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      entryType: entryType ?? this.entryType,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      title: title ?? this.title,
      remarks: remarks ?? this.remarks,
      merchant: merchant ?? this.merchant,
      tagIds: tagIds ?? this.tagIds,
      entryDate: entryDate ?? this.entryDate,
      source: source ?? this.source,
      createdById: createdById ?? this.createdById,
      customValues: customValues ?? this.customValues,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (cashbookId.present) {
      map['cashbook_id'] = Variable<String>(cashbookId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<String>(paymentMethodId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (tagIds.present) {
      map['tag_ids'] = Variable<String>(tagIds.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdById.present) {
      map['created_by_id'] = Variable<String>(createdById.value);
    }
    if (customValues.present) {
      map['custom_values'] = Variable<String>(customValues.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('entryType: $entryType, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('title: $title, ')
          ..write('remarks: $remarks, ')
          ..write('merchant: $merchant, ')
          ..write('tagIds: $tagIds, ')
          ..write('entryDate: $entryDate, ')
          ..write('source: $source, ')
          ..write('createdById: $createdById, ')
          ..write('customValues: $customValues, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntryBillsTable extends EntryBills
    with TableInfo<$EntryBillsTable, EntryBill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryBillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashbookIdMeta = const VerificationMeta(
    'cashbookId',
  );
  @override
  late final GeneratedColumn<String> cashbookId = GeneratedColumn<String>(
    'cashbook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByIdMeta = const VerificationMeta(
    'createdById',
  );
  @override
  late final GeneratedColumn<String> createdById = GeneratedColumn<String>(
    'created_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    entryId,
    cashbookId,
    createdById,
    contentType,
    originalName,
    sizeBytes,
    pageCount,
    width,
    height,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryBill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('cashbook_id')) {
      context.handle(
        _cashbookIdMeta,
        cashbookId.isAcceptableOrUnknown(data['cashbook_id']!, _cashbookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashbookIdMeta);
    }
    if (data.containsKey('created_by_id')) {
      context.handle(
        _createdByIdMeta,
        createdById.isAcceptableOrUnknown(
          data['created_by_id']!,
          _createdByIdMeta,
        ),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryBill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryBill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      cashbookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashbook_id'],
      )!,
      createdById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_id'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
    );
  }

  @override
  $EntryBillsTable createAlias(String alias) {
    return $EntryBillsTable(attachedDatabase, alias);
  }
}

class EntryBill extends DataClass implements Insertable<EntryBill> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String entryId;
  final String cashbookId;
  final String? createdById;

  /// What the server found the file to be: image/jpeg, image/png or application/pdf.
  final String contentType;
  final String originalName;
  final int sizeBytes;
  final int? pageCount;
  final int? width;
  final int? height;
  const EntryBill({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.entryId,
    required this.cashbookId,
    this.createdById,
    required this.contentType,
    required this.originalName,
    required this.sizeBytes,
    this.pageCount,
    this.width,
    this.height,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['entry_id'] = Variable<String>(entryId);
    map['cashbook_id'] = Variable<String>(cashbookId);
    if (!nullToAbsent || createdById != null) {
      map['created_by_id'] = Variable<String>(createdById);
    }
    map['content_type'] = Variable<String>(contentType);
    map['original_name'] = Variable<String>(originalName);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    return map;
  }

  EntryBillsCompanion toCompanion(bool nullToAbsent) {
    return EntryBillsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      entryId: Value(entryId),
      cashbookId: Value(cashbookId),
      createdById: createdById == null && nullToAbsent
          ? const Value.absent()
          : Value(createdById),
      contentType: Value(contentType),
      originalName: Value(originalName),
      sizeBytes: Value(sizeBytes),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
    );
  }

  factory EntryBill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryBill(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      entryId: serializer.fromJson<String>(json['entryId']),
      cashbookId: serializer.fromJson<String>(json['cashbookId']),
      createdById: serializer.fromJson<String?>(json['createdById']),
      contentType: serializer.fromJson<String>(json['contentType']),
      originalName: serializer.fromJson<String>(json['originalName']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'entryId': serializer.toJson<String>(entryId),
      'cashbookId': serializer.toJson<String>(cashbookId),
      'createdById': serializer.toJson<String?>(createdById),
      'contentType': serializer.toJson<String>(contentType),
      'originalName': serializer.toJson<String>(originalName),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'pageCount': serializer.toJson<int?>(pageCount),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
    };
  }

  EntryBill copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? entryId,
    String? cashbookId,
    Value<String?> createdById = const Value.absent(),
    String? contentType,
    String? originalName,
    int? sizeBytes,
    Value<int?> pageCount = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
  }) => EntryBill(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    entryId: entryId ?? this.entryId,
    cashbookId: cashbookId ?? this.cashbookId,
    createdById: createdById.present ? createdById.value : this.createdById,
    contentType: contentType ?? this.contentType,
    originalName: originalName ?? this.originalName,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
  );
  EntryBill copyWithCompanion(EntryBillsCompanion data) {
    return EntryBill(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      cashbookId: data.cashbookId.present
          ? data.cashbookId.value
          : this.cashbookId,
      createdById: data.createdById.present
          ? data.createdById.value
          : this.createdById,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryBill(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('entryId: $entryId, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('createdById: $createdById, ')
          ..write('contentType: $contentType, ')
          ..write('originalName: $originalName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('width: $width, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    entryId,
    cashbookId,
    createdById,
    contentType,
    originalName,
    sizeBytes,
    pageCount,
    width,
    height,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryBill &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.entryId == this.entryId &&
          other.cashbookId == this.cashbookId &&
          other.createdById == this.createdById &&
          other.contentType == this.contentType &&
          other.originalName == this.originalName &&
          other.sizeBytes == this.sizeBytes &&
          other.pageCount == this.pageCount &&
          other.width == this.width &&
          other.height == this.height);
}

class EntryBillsCompanion extends UpdateCompanion<EntryBill> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> entryId;
  final Value<String> cashbookId;
  final Value<String?> createdById;
  final Value<String> contentType;
  final Value<String> originalName;
  final Value<int> sizeBytes;
  final Value<int?> pageCount;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int> rowid;
  const EntryBillsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.entryId = const Value.absent(),
    this.cashbookId = const Value.absent(),
    this.createdById = const Value.absent(),
    this.contentType = const Value.absent(),
    this.originalName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryBillsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String entryId,
    required String cashbookId,
    this.createdById = const Value.absent(),
    required String contentType,
    this.originalName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       entryId = Value(entryId),
       cashbookId = Value(cashbookId),
       contentType = Value(contentType);
  static Insertable<EntryBill> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? entryId,
    Expression<String>? cashbookId,
    Expression<String>? createdById,
    Expression<String>? contentType,
    Expression<String>? originalName,
    Expression<int>? sizeBytes,
    Expression<int>? pageCount,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (entryId != null) 'entry_id': entryId,
      if (cashbookId != null) 'cashbook_id': cashbookId,
      if (createdById != null) 'created_by_id': createdById,
      if (contentType != null) 'content_type': contentType,
      if (originalName != null) 'original_name': originalName,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (pageCount != null) 'page_count': pageCount,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryBillsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? entryId,
    Value<String>? cashbookId,
    Value<String?>? createdById,
    Value<String>? contentType,
    Value<String>? originalName,
    Value<int>? sizeBytes,
    Value<int?>? pageCount,
    Value<int?>? width,
    Value<int?>? height,
    Value<int>? rowid,
  }) {
    return EntryBillsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      entryId: entryId ?? this.entryId,
      cashbookId: cashbookId ?? this.cashbookId,
      createdById: createdById ?? this.createdById,
      contentType: contentType ?? this.contentType,
      originalName: originalName ?? this.originalName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      pageCount: pageCount ?? this.pageCount,
      width: width ?? this.width,
      height: height ?? this.height,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (cashbookId.present) {
      map['cashbook_id'] = Variable<String>(cashbookId.value);
    }
    if (createdById.present) {
      map['created_by_id'] = Variable<String>(createdById.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryBillsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('entryId: $entryId, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('createdById: $createdById, ')
          ..write('contentType: $contentType, ')
          ..write('originalName: $originalName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashbookMembersTable extends CashbookMembers
    with TableInfo<$CashbookMembersTable, CashbookMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashbookMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashbookIdMeta = const VerificationMeta(
    'cashbookId',
  );
  @override
  late final GeneratedColumn<String> cashbookId = GeneratedColumn<String>(
    'cashbook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    memberId,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cashbook_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashbookMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cashbook_id')) {
      context.handle(
        _cashbookIdMeta,
        cashbookId.isAcceptableOrUnknown(data['cashbook_id']!, _cashbookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashbookIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashbookMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashbookMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      cashbookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashbook_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $CashbookMembersTable createAlias(String alias) {
    return $CashbookMembersTable(attachedDatabase, alias);
  }
}

class CashbookMember extends DataClass implements Insertable<CashbookMember> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String cashbookId;
  final String memberId;
  final String role;
  const CashbookMember({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.cashbookId,
    required this.memberId,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['cashbook_id'] = Variable<String>(cashbookId);
    map['member_id'] = Variable<String>(memberId);
    map['role'] = Variable<String>(role);
    return map;
  }

  CashbookMembersCompanion toCompanion(bool nullToAbsent) {
    return CashbookMembersCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      cashbookId: Value(cashbookId),
      memberId: Value(memberId),
      role: Value(role),
    );
  }

  factory CashbookMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashbookMember(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      cashbookId: serializer.fromJson<String>(json['cashbookId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'cashbookId': serializer.toJson<String>(cashbookId),
      'memberId': serializer.toJson<String>(memberId),
      'role': serializer.toJson<String>(role),
    };
  }

  CashbookMember copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? cashbookId,
    String? memberId,
    String? role,
  }) => CashbookMember(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    cashbookId: cashbookId ?? this.cashbookId,
    memberId: memberId ?? this.memberId,
    role: role ?? this.role,
  );
  CashbookMember copyWithCompanion(CashbookMembersCompanion data) {
    return CashbookMember(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      cashbookId: data.cashbookId.present
          ? data.cashbookId.value
          : this.cashbookId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashbookMember(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('memberId: $memberId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    cashbookId,
    memberId,
    role,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashbookMember &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.cashbookId == this.cashbookId &&
          other.memberId == this.memberId &&
          other.role == this.role);
}

class CashbookMembersCompanion extends UpdateCompanion<CashbookMember> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> cashbookId;
  final Value<String> memberId;
  final Value<String> role;
  final Value<int> rowid;
  const CashbookMembersCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.cashbookId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashbookMembersCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String cashbookId,
    required String memberId,
    required String role,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       cashbookId = Value(cashbookId),
       memberId = Value(memberId),
       role = Value(role);
  static Insertable<CashbookMember> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? cashbookId,
    Expression<String>? memberId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (cashbookId != null) 'cashbook_id': cashbookId,
      if (memberId != null) 'member_id': memberId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashbookMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? cashbookId,
    Value<String>? memberId,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return CashbookMembersCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      cashbookId: cashbookId ?? this.cashbookId,
      memberId: memberId ?? this.memberId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (cashbookId.present) {
      map['cashbook_id'] = Variable<String>(cashbookId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashbookMembersCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('memberId: $memberId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceMinorMeta =
      const VerificationMeta('openingBalanceMinor');
  @override
  late final GeneratedColumn<int> openingBalanceMinor = GeneratedColumn<int>(
    'opening_balance_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    kind,
    currency,
    openingBalanceMinor,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('opening_balance_minor')) {
      context.handle(
        _openingBalanceMinorMeta,
        openingBalanceMinor.isAcceptableOrUnknown(
          data['opening_balance_minor']!,
          _openingBalanceMinorMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      openingBalanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance_minor'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String name;
  final String kind;
  final String currency;
  final int openingBalanceMinor;
  final bool isArchived;
  const Account({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.kind,
    required this.currency,
    required this.openingBalanceMinor,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['currency'] = Variable<String>(currency);
    map['opening_balance_minor'] = Variable<int>(openingBalanceMinor);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      kind: Value(kind),
      currency: Value(currency),
      openingBalanceMinor: Value(openingBalanceMinor),
      isArchived: Value(isArchived),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      currency: serializer.fromJson<String>(json['currency']),
      openingBalanceMinor: serializer.fromJson<int>(
        json['openingBalanceMinor'],
      ),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'currency': serializer.toJson<String>(currency),
      'openingBalanceMinor': serializer.toJson<int>(openingBalanceMinor),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Account copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? name,
    String? kind,
    String? currency,
    int? openingBalanceMinor,
    bool? isArchived,
  }) => Account(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    currency: currency ?? this.currency,
    openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
    isArchived: isArchived ?? this.isArchived,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      currency: data.currency.present ? data.currency.value : this.currency,
      openingBalanceMinor: data.openingBalanceMinor.present
          ? data.openingBalanceMinor.value
          : this.openingBalanceMinor,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    kind,
    currency,
    openingBalanceMinor,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.currency == this.currency &&
          other.openingBalanceMinor == this.openingBalanceMinor &&
          other.isArchived == this.isArchived);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> currency;
  final Value<int> openingBalanceMinor;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.currency = const Value.absent(),
    this.openingBalanceMinor = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String kind,
    required String currency,
    this.openingBalanceMinor = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       kind = Value(kind),
       currency = Value(currency);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? currency,
    Expression<int>? openingBalanceMinor,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (currency != null) 'currency': currency,
      if (openingBalanceMinor != null)
        'opening_balance_minor': openingBalanceMinor,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? currency,
    Value<int>? openingBalanceMinor,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currency: currency ?? this.currency,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (openingBalanceMinor.present) {
      map['opening_balance_minor'] = Variable<int>(openingBalanceMinor.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('openingBalanceMinor: $openingBalanceMinor, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    kind,
    isDefault,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String name;
  final String kind;

  /// One of the categories every account starts with. Set by the server only;
  /// the plan's limit on categories counts the others.
  final bool isDefault;

  /// '#RRGGBB' the user chose; null leaves the colour to the app (categoryFill).
  final String? color;
  const Category({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.kind,
    required this.isDefault,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      kind: Value(kind),
      isDefault: Value(isDefault),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'isDefault': serializer.toJson<bool>(isDefault),
      'color': serializer.toJson<String?>(color),
    };
  }

  Category copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? name,
    String? kind,
    bool? isDefault,
    Value<String?> color = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    isDefault: isDefault ?? this.isDefault,
    color: color.present ? color.value : this.color,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('isDefault: $isDefault, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    kind,
    isDefault,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.isDefault == this.isDefault &&
          other.color == this.color);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> name;
  final Value<String> kind;
  final Value<bool> isDefault;
  final Value<String?> color;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String kind,
    this.isDefault = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       kind = Value(kind);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<bool>? isDefault,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (isDefault != null) 'is_default': isDefault,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? name,
    Value<String>? kind,
    Value<bool>? isDefault,
    Value<String?>? color,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      isDefault: isDefault ?? this.isDefault,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('isDefault: $isDefault, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferGroupIdMeta = const VerificationMeta(
    'transferGroupId',
  );
  @override
  late final GeneratedColumn<String> transferGroupId = GeneratedColumn<String>(
    'transfer_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredOnMeta = const VerificationMeta(
    'occurredOn',
  );
  @override
  late final GeneratedColumn<String> occurredOn = GeneratedColumn<String>(
    'occurred_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagIdsMeta = const VerificationMeta('tagIds');
  @override
  late final GeneratedColumn<String> tagIds = GeneratedColumn<String>(
    'tag_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _splitsMeta = const VerificationMeta('splits');
  @override
  late final GeneratedColumn<String> splits = GeneratedColumn<String>(
    'splits',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _occurrenceIdMeta = const VerificationMeta(
    'occurrenceId',
  );
  @override
  late final GeneratedColumn<String> occurrenceId = GeneratedColumn<String>(
    'occurrence_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    accountId,
    categoryId,
    kind,
    amountMinor,
    currency,
    transferGroupId,
    occurredOn,
    note,
    merchant,
    tagIds,
    source,
    splits,
    occurrenceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('transfer_group_id')) {
      context.handle(
        _transferGroupIdMeta,
        transferGroupId.isAcceptableOrUnknown(
          data['transfer_group_id']!,
          _transferGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
        _occurredOnMeta,
        occurredOn.isAcceptableOrUnknown(data['occurred_on']!, _occurredOnMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('tag_ids')) {
      context.handle(
        _tagIdsMeta,
        tagIds.isAcceptableOrUnknown(data['tag_ids']!, _tagIdsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('splits')) {
      context.handle(
        _splitsMeta,
        splits.isAcceptableOrUnknown(data['splits']!, _splitsMeta),
      );
    }
    if (data.containsKey('occurrence_id')) {
      context.handle(
        _occurrenceIdMeta,
        occurrenceId.isAcceptableOrUnknown(
          data['occurrence_id']!,
          _occurrenceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      transferGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_group_id'],
      ),
      occurredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred_on'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      tagIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_ids'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      splits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}splits'],
      )!,
      occurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_id'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String accountId;
  final String? categoryId;
  final String kind;
  final int amountMinor;
  final String currency;
  final String? transferGroupId;
  final String occurredOn;
  final String note;

  /// Who was paid, or who paid; '' when not given (features/tags/merchants.dart).
  final String merchant;

  /// JSON list of the workspace's tag ids (features/tags/tag_ids.dart).
  final String tagIds;
  final String source;

  /// Filed under several categories at once: a JSON list of parts that add up
  /// to the amount (features/personal/allocations.dart). '[]' when not split.
  final String splits;

  /// The occurrence of a recurring rule this transaction settles.
  final String? occurrenceId;
  const Transaction({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.accountId,
    this.categoryId,
    required this.kind,
    required this.amountMinor,
    required this.currency,
    this.transferGroupId,
    required this.occurredOn,
    required this.note,
    required this.merchant,
    required this.tagIds,
    required this.source,
    required this.splits,
    this.occurrenceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['kind'] = Variable<String>(kind);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || transferGroupId != null) {
      map['transfer_group_id'] = Variable<String>(transferGroupId);
    }
    map['occurred_on'] = Variable<String>(occurredOn);
    map['note'] = Variable<String>(note);
    map['merchant'] = Variable<String>(merchant);
    map['tag_ids'] = Variable<String>(tagIds);
    map['source'] = Variable<String>(source);
    map['splits'] = Variable<String>(splits);
    if (!nullToAbsent || occurrenceId != null) {
      map['occurrence_id'] = Variable<String>(occurrenceId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      accountId: Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      kind: Value(kind),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      transferGroupId: transferGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferGroupId),
      occurredOn: Value(occurredOn),
      note: Value(note),
      merchant: Value(merchant),
      tagIds: Value(tagIds),
      source: Value(source),
      splits: Value(splits),
      occurrenceId: occurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceId),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      accountId: serializer.fromJson<String>(json['accountId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      kind: serializer.fromJson<String>(json['kind']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      transferGroupId: serializer.fromJson<String?>(json['transferGroupId']),
      occurredOn: serializer.fromJson<String>(json['occurredOn']),
      note: serializer.fromJson<String>(json['note']),
      merchant: serializer.fromJson<String>(json['merchant']),
      tagIds: serializer.fromJson<String>(json['tagIds']),
      source: serializer.fromJson<String>(json['source']),
      splits: serializer.fromJson<String>(json['splits']),
      occurrenceId: serializer.fromJson<String?>(json['occurrenceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'accountId': serializer.toJson<String>(accountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'kind': serializer.toJson<String>(kind),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'transferGroupId': serializer.toJson<String?>(transferGroupId),
      'occurredOn': serializer.toJson<String>(occurredOn),
      'note': serializer.toJson<String>(note),
      'merchant': serializer.toJson<String>(merchant),
      'tagIds': serializer.toJson<String>(tagIds),
      'source': serializer.toJson<String>(source),
      'splits': serializer.toJson<String>(splits),
      'occurrenceId': serializer.toJson<String?>(occurrenceId),
    };
  }

  Transaction copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? accountId,
    Value<String?> categoryId = const Value.absent(),
    String? kind,
    int? amountMinor,
    String? currency,
    Value<String?> transferGroupId = const Value.absent(),
    String? occurredOn,
    String? note,
    String? merchant,
    String? tagIds,
    String? source,
    String? splits,
    Value<String?> occurrenceId = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    kind: kind ?? this.kind,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    transferGroupId: transferGroupId.present
        ? transferGroupId.value
        : this.transferGroupId,
    occurredOn: occurredOn ?? this.occurredOn,
    note: note ?? this.note,
    merchant: merchant ?? this.merchant,
    tagIds: tagIds ?? this.tagIds,
    source: source ?? this.source,
    splits: splits ?? this.splits,
    occurrenceId: occurrenceId.present ? occurrenceId.value : this.occurrenceId,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      transferGroupId: data.transferGroupId.present
          ? data.transferGroupId.value
          : this.transferGroupId,
      occurredOn: data.occurredOn.present
          ? data.occurredOn.value
          : this.occurredOn,
      note: data.note.present ? data.note.value : this.note,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      tagIds: data.tagIds.present ? data.tagIds.value : this.tagIds,
      source: data.source.present ? data.source.value : this.source,
      splits: data.splits.present ? data.splits.value : this.splits,
      occurrenceId: data.occurrenceId.present
          ? data.occurrenceId.value
          : this.occurrenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('transferGroupId: $transferGroupId, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('note: $note, ')
          ..write('merchant: $merchant, ')
          ..write('tagIds: $tagIds, ')
          ..write('source: $source, ')
          ..write('splits: $splits, ')
          ..write('occurrenceId: $occurrenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    accountId,
    categoryId,
    kind,
    amountMinor,
    currency,
    transferGroupId,
    occurredOn,
    note,
    merchant,
    tagIds,
    source,
    splits,
    occurrenceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.kind == this.kind &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.transferGroupId == this.transferGroupId &&
          other.occurredOn == this.occurredOn &&
          other.note == this.note &&
          other.merchant == this.merchant &&
          other.tagIds == this.tagIds &&
          other.source == this.source &&
          other.splits == this.splits &&
          other.occurrenceId == this.occurrenceId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> accountId;
  final Value<String?> categoryId;
  final Value<String> kind;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String?> transferGroupId;
  final Value<String> occurredOn;
  final Value<String> note;
  final Value<String> merchant;
  final Value<String> tagIds;
  final Value<String> source;
  final Value<String> splits;
  final Value<String?> occurrenceId;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.transferGroupId = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.note = const Value.absent(),
    this.merchant = const Value.absent(),
    this.tagIds = const Value.absent(),
    this.source = const Value.absent(),
    this.splits = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String accountId,
    this.categoryId = const Value.absent(),
    required String kind,
    required int amountMinor,
    required String currency,
    this.transferGroupId = const Value.absent(),
    required String occurredOn,
    this.note = const Value.absent(),
    this.merchant = const Value.absent(),
    this.tagIds = const Value.absent(),
    this.source = const Value.absent(),
    this.splits = const Value.absent(),
    this.occurrenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       accountId = Value(accountId),
       kind = Value(kind),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       occurredOn = Value(occurredOn);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? accountId,
    Expression<String>? categoryId,
    Expression<String>? kind,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? transferGroupId,
    Expression<String>? occurredOn,
    Expression<String>? note,
    Expression<String>? merchant,
    Expression<String>? tagIds,
    Expression<String>? source,
    Expression<String>? splits,
    Expression<String>? occurrenceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (kind != null) 'kind': kind,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (transferGroupId != null) 'transfer_group_id': transferGroupId,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (note != null) 'note': note,
      if (merchant != null) 'merchant': merchant,
      if (tagIds != null) 'tag_ids': tagIds,
      if (source != null) 'source': source,
      if (splits != null) 'splits': splits,
      if (occurrenceId != null) 'occurrence_id': occurrenceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? accountId,
    Value<String?>? categoryId,
    Value<String>? kind,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String?>? transferGroupId,
    Value<String>? occurredOn,
    Value<String>? note,
    Value<String>? merchant,
    Value<String>? tagIds,
    Value<String>? source,
    Value<String>? splits,
    Value<String?>? occurrenceId,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      kind: kind ?? this.kind,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      transferGroupId: transferGroupId ?? this.transferGroupId,
      occurredOn: occurredOn ?? this.occurredOn,
      note: note ?? this.note,
      merchant: merchant ?? this.merchant,
      tagIds: tagIds ?? this.tagIds,
      source: source ?? this.source,
      splits: splits ?? this.splits,
      occurrenceId: occurrenceId ?? this.occurrenceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (transferGroupId.present) {
      map['transfer_group_id'] = Variable<String>(transferGroupId.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<String>(occurredOn.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (tagIds.present) {
      map['tag_ids'] = Variable<String>(tagIds.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (splits.present) {
      map['splits'] = Variable<String>(splits.value);
    }
    if (occurrenceId.present) {
      map['occurrence_id'] = Variable<String>(occurrenceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('transferGroupId: $transferGroupId, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('note: $note, ')
          ..write('merchant: $merchant, ')
          ..write('tagIds: $tagIds, ')
          ..write('source: $source, ')
          ..write('splits: $splits, ')
          ..write('occurrenceId: $occurrenceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    categoryId,
    amountMinor,
    currency,
    month,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      ),
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String categoryId;
  final int amountMinor;
  final String currency;
  final String? month;
  const Budget({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.categoryId,
    required this.amountMinor,
    required this.currency,
    this.month,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['category_id'] = Variable<String>(categoryId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || month != null) {
      map['month'] = Variable<String>(month);
    }
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      categoryId: Value(categoryId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      month: month == null && nullToAbsent
          ? const Value.absent()
          : Value(month),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      month: serializer.fromJson<String?>(json['month']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'categoryId': serializer.toJson<String>(categoryId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'month': serializer.toJson<String?>(month),
    };
  }

  Budget copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? categoryId,
    int? amountMinor,
    String? currency,
    Value<String?> month = const Value.absent(),
  }) => Budget(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    categoryId: categoryId ?? this.categoryId,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    month: month.present ? month.value : this.month,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      month: data.month.present ? data.month.value : this.month,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('month: $month')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    categoryId,
    amountMinor,
    currency,
    month,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.categoryId == this.categoryId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.month == this.month);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> categoryId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String?> month;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.month = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String categoryId,
    required int amountMinor,
    required String currency,
    this.month = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       categoryId = Value(categoryId),
       amountMinor = Value(amountMinor),
       currency = Value(currency);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? categoryId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? month,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (month != null) 'month': month,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? categoryId,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String?>? month,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      categoryId: categoryId ?? this.categoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      month: month ?? this.month,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('month: $month, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _splitsMeta = const VerificationMeta('splits');
  @override
  late final GeneratedColumn<String> splits = GeneratedColumn<String>(
    'splits',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _freqMeta = const VerificationMeta('freq');
  @override
  late final GeneratedColumn<String> freq = GeneratedColumn<String>(
    'freq',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _weekdayMaskMeta = const VerificationMeta(
    'weekdayMask',
  );
  @override
  late final GeneratedColumn<int> weekdayMask = GeneratedColumn<int>(
    'weekday_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monthDayMeta = const VerificationMeta(
    'monthDay',
  );
  @override
  late final GeneratedColumn<int> monthDay = GeneratedColumn<int>(
    'month_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setPosMeta = const VerificationMeta('setPos');
  @override
  late final GeneratedColumn<int> setPos = GeneratedColumn<int>(
    'set_pos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<int> weekStart = GeneratedColumn<int>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _startOnMeta = const VerificationMeta(
    'startOn',
  );
  @override
  late final GeneratedColumn<String> startOn = GeneratedColumn<String>(
    'start_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endOnMeta = const VerificationMeta('endOn');
  @override
  late final GeneratedColumn<String> endOn = GeneratedColumn<String>(
    'end_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxCountMeta = const VerificationMeta(
    'maxCount',
  );
  @override
  late final GeneratedColumn<int> maxCount = GeneratedColumn<int>(
    'max_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirm'),
  );
  static const VerificationMeta _remindDaysBeforeMeta = const VerificationMeta(
    'remindDaysBefore',
  );
  @override
  late final GeneratedColumn<int> remindDaysBefore = GeneratedColumn<int>(
    'remind_days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<String> remindAt = GeneratedColumn<String>(
    'remind_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nextDueOnMeta = const VerificationMeta(
    'nextDueOn',
  );
  @override
  late final GeneratedColumn<String> nextDueOn = GeneratedColumn<String>(
    'next_due_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneCountMeta = const VerificationMeta(
    'doneCount',
  );
  @override
  late final GeneratedColumn<int> doneCount = GeneratedColumn<int>(
    'done_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    kind,
    title,
    accountId,
    toAccountId,
    categoryId,
    amountMinor,
    currency,
    note,
    splits,
    freq,
    interval,
    weekdayMask,
    monthDay,
    setPos,
    weekStart,
    startOn,
    endOn,
    maxCount,
    mode,
    remindDaysBefore,
    remindAt,
    isPaused,
    nextDueOn,
    doneCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('splits')) {
      context.handle(
        _splitsMeta,
        splits.isAcceptableOrUnknown(data['splits']!, _splitsMeta),
      );
    }
    if (data.containsKey('freq')) {
      context.handle(
        _freqMeta,
        freq.isAcceptableOrUnknown(data['freq']!, _freqMeta),
      );
    } else if (isInserting) {
      context.missing(_freqMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('weekday_mask')) {
      context.handle(
        _weekdayMaskMeta,
        weekdayMask.isAcceptableOrUnknown(
          data['weekday_mask']!,
          _weekdayMaskMeta,
        ),
      );
    }
    if (data.containsKey('month_day')) {
      context.handle(
        _monthDayMeta,
        monthDay.isAcceptableOrUnknown(data['month_day']!, _monthDayMeta),
      );
    }
    if (data.containsKey('set_pos')) {
      context.handle(
        _setPosMeta,
        setPos.isAcceptableOrUnknown(data['set_pos']!, _setPosMeta),
      );
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    }
    if (data.containsKey('start_on')) {
      context.handle(
        _startOnMeta,
        startOn.isAcceptableOrUnknown(data['start_on']!, _startOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startOnMeta);
    }
    if (data.containsKey('end_on')) {
      context.handle(
        _endOnMeta,
        endOn.isAcceptableOrUnknown(data['end_on']!, _endOnMeta),
      );
    }
    if (data.containsKey('max_count')) {
      context.handle(
        _maxCountMeta,
        maxCount.isAcceptableOrUnknown(data['max_count']!, _maxCountMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('remind_days_before')) {
      context.handle(
        _remindDaysBeforeMeta,
        remindDaysBefore.isAcceptableOrUnknown(
          data['remind_days_before']!,
          _remindDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    if (data.containsKey('next_due_on')) {
      context.handle(
        _nextDueOnMeta,
        nextDueOn.isAcceptableOrUnknown(data['next_due_on']!, _nextDueOnMeta),
      );
    }
    if (data.containsKey('done_count')) {
      context.handle(
        _doneCountMeta,
        doneCount.isAcceptableOrUnknown(data['done_count']!, _doneCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      splits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}splits'],
      )!,
      freq: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freq'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      weekdayMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday_mask'],
      )!,
      monthDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_day'],
      ),
      setPos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_pos'],
      ),
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_start'],
      )!,
      startOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_on'],
      )!,
      endOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_on'],
      ),
      maxCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_count'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      remindDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_days_before'],
      )!,
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remind_at'],
      ),
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paused'],
      )!,
      nextDueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_due_on'],
      ),
      doneCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}done_count'],
      )!,
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRule extends DataClass implements Insertable<RecurringRule> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String kind;
  final String title;
  final String? accountId;
  final String? toAccountId;
  final String? categoryId;

  /// What the user typed, always positive; null for a reminder with no amount.
  final int? amountMinor;
  final String currency;
  final String note;
  final String splits;

  /// once, daily, weekly, monthly or yearly, every [interval] of them.
  final String freq;
  final int interval;

  /// Days of the week it falls on, Monday as bit 0.
  final int weekdayMask;

  /// 1-31, or -1 for the last day; a month too short uses its last day.
  final int? monthDay;

  /// With [weekdayMask]: the first (1) to fourth (4) or last (-1) such day of the month.
  final int? setPos;

  /// The day weeks start on when counting every [interval] weeks, Monday as 0.
  final int weekStart;
  final String startOn;
  final String? endOn;
  final int? maxCount;

  /// auto: the server records it. confirm: the user is asked first.
  final String mode;
  final int remindDaysBefore;

  /// HH:mm:ss in the user's own time; null uses their usual reminder time.
  final String? remindAt;
  final bool isPaused;

  /// Set by the server.
  final String? nextDueOn;
  final int doneCount;
  const RecurringRule({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.kind,
    required this.title,
    this.accountId,
    this.toAccountId,
    this.categoryId,
    this.amountMinor,
    required this.currency,
    required this.note,
    required this.splits,
    required this.freq,
    required this.interval,
    required this.weekdayMask,
    this.monthDay,
    this.setPos,
    required this.weekStart,
    required this.startOn,
    this.endOn,
    this.maxCount,
    required this.mode,
    required this.remindDaysBefore,
    this.remindAt,
    required this.isPaused,
    this.nextDueOn,
    required this.doneCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    map['currency'] = Variable<String>(currency);
    map['note'] = Variable<String>(note);
    map['splits'] = Variable<String>(splits);
    map['freq'] = Variable<String>(freq);
    map['interval'] = Variable<int>(interval);
    map['weekday_mask'] = Variable<int>(weekdayMask);
    if (!nullToAbsent || monthDay != null) {
      map['month_day'] = Variable<int>(monthDay);
    }
    if (!nullToAbsent || setPos != null) {
      map['set_pos'] = Variable<int>(setPos);
    }
    map['week_start'] = Variable<int>(weekStart);
    map['start_on'] = Variable<String>(startOn);
    if (!nullToAbsent || endOn != null) {
      map['end_on'] = Variable<String>(endOn);
    }
    if (!nullToAbsent || maxCount != null) {
      map['max_count'] = Variable<int>(maxCount);
    }
    map['mode'] = Variable<String>(mode);
    map['remind_days_before'] = Variable<int>(remindDaysBefore);
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<String>(remindAt);
    }
    map['is_paused'] = Variable<bool>(isPaused);
    if (!nullToAbsent || nextDueOn != null) {
      map['next_due_on'] = Variable<String>(nextDueOn);
    }
    map['done_count'] = Variable<int>(doneCount);
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      kind: Value(kind),
      title: Value(title),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      currency: Value(currency),
      note: Value(note),
      splits: Value(splits),
      freq: Value(freq),
      interval: Value(interval),
      weekdayMask: Value(weekdayMask),
      monthDay: monthDay == null && nullToAbsent
          ? const Value.absent()
          : Value(monthDay),
      setPos: setPos == null && nullToAbsent
          ? const Value.absent()
          : Value(setPos),
      weekStart: Value(weekStart),
      startOn: Value(startOn),
      endOn: endOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endOn),
      maxCount: maxCount == null && nullToAbsent
          ? const Value.absent()
          : Value(maxCount),
      mode: Value(mode),
      remindDaysBefore: Value(remindDaysBefore),
      remindAt: remindAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindAt),
      isPaused: Value(isPaused),
      nextDueOn: nextDueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueOn),
      doneCount: Value(doneCount),
    );
  }

  factory RecurringRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRule(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      note: serializer.fromJson<String>(json['note']),
      splits: serializer.fromJson<String>(json['splits']),
      freq: serializer.fromJson<String>(json['freq']),
      interval: serializer.fromJson<int>(json['interval']),
      weekdayMask: serializer.fromJson<int>(json['weekdayMask']),
      monthDay: serializer.fromJson<int?>(json['monthDay']),
      setPos: serializer.fromJson<int?>(json['setPos']),
      weekStart: serializer.fromJson<int>(json['weekStart']),
      startOn: serializer.fromJson<String>(json['startOn']),
      endOn: serializer.fromJson<String?>(json['endOn']),
      maxCount: serializer.fromJson<int?>(json['maxCount']),
      mode: serializer.fromJson<String>(json['mode']),
      remindDaysBefore: serializer.fromJson<int>(json['remindDaysBefore']),
      remindAt: serializer.fromJson<String?>(json['remindAt']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
      nextDueOn: serializer.fromJson<String?>(json['nextDueOn']),
      doneCount: serializer.fromJson<int>(json['doneCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'accountId': serializer.toJson<String?>(accountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'note': serializer.toJson<String>(note),
      'splits': serializer.toJson<String>(splits),
      'freq': serializer.toJson<String>(freq),
      'interval': serializer.toJson<int>(interval),
      'weekdayMask': serializer.toJson<int>(weekdayMask),
      'monthDay': serializer.toJson<int?>(monthDay),
      'setPos': serializer.toJson<int?>(setPos),
      'weekStart': serializer.toJson<int>(weekStart),
      'startOn': serializer.toJson<String>(startOn),
      'endOn': serializer.toJson<String?>(endOn),
      'maxCount': serializer.toJson<int?>(maxCount),
      'mode': serializer.toJson<String>(mode),
      'remindDaysBefore': serializer.toJson<int>(remindDaysBefore),
      'remindAt': serializer.toJson<String?>(remindAt),
      'isPaused': serializer.toJson<bool>(isPaused),
      'nextDueOn': serializer.toJson<String?>(nextDueOn),
      'doneCount': serializer.toJson<int>(doneCount),
    };
  }

  RecurringRule copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? kind,
    String? title,
    Value<String?> accountId = const Value.absent(),
    Value<String?> toAccountId = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<int?> amountMinor = const Value.absent(),
    String? currency,
    String? note,
    String? splits,
    String? freq,
    int? interval,
    int? weekdayMask,
    Value<int?> monthDay = const Value.absent(),
    Value<int?> setPos = const Value.absent(),
    int? weekStart,
    String? startOn,
    Value<String?> endOn = const Value.absent(),
    Value<int?> maxCount = const Value.absent(),
    String? mode,
    int? remindDaysBefore,
    Value<String?> remindAt = const Value.absent(),
    bool? isPaused,
    Value<String?> nextDueOn = const Value.absent(),
    int? doneCount,
  }) => RecurringRule(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    accountId: accountId.present ? accountId.value : this.accountId,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    currency: currency ?? this.currency,
    note: note ?? this.note,
    splits: splits ?? this.splits,
    freq: freq ?? this.freq,
    interval: interval ?? this.interval,
    weekdayMask: weekdayMask ?? this.weekdayMask,
    monthDay: monthDay.present ? monthDay.value : this.monthDay,
    setPos: setPos.present ? setPos.value : this.setPos,
    weekStart: weekStart ?? this.weekStart,
    startOn: startOn ?? this.startOn,
    endOn: endOn.present ? endOn.value : this.endOn,
    maxCount: maxCount.present ? maxCount.value : this.maxCount,
    mode: mode ?? this.mode,
    remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
    remindAt: remindAt.present ? remindAt.value : this.remindAt,
    isPaused: isPaused ?? this.isPaused,
    nextDueOn: nextDueOn.present ? nextDueOn.value : this.nextDueOn,
    doneCount: doneCount ?? this.doneCount,
  );
  RecurringRule copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRule(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      note: data.note.present ? data.note.value : this.note,
      splits: data.splits.present ? data.splits.value : this.splits,
      freq: data.freq.present ? data.freq.value : this.freq,
      interval: data.interval.present ? data.interval.value : this.interval,
      weekdayMask: data.weekdayMask.present
          ? data.weekdayMask.value
          : this.weekdayMask,
      monthDay: data.monthDay.present ? data.monthDay.value : this.monthDay,
      setPos: data.setPos.present ? data.setPos.value : this.setPos,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      startOn: data.startOn.present ? data.startOn.value : this.startOn,
      endOn: data.endOn.present ? data.endOn.value : this.endOn,
      maxCount: data.maxCount.present ? data.maxCount.value : this.maxCount,
      mode: data.mode.present ? data.mode.value : this.mode,
      remindDaysBefore: data.remindDaysBefore.present
          ? data.remindDaysBefore.value
          : this.remindDaysBefore,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
      nextDueOn: data.nextDueOn.present ? data.nextDueOn.value : this.nextDueOn,
      doneCount: data.doneCount.present ? data.doneCount.value : this.doneCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRule(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('note: $note, ')
          ..write('splits: $splits, ')
          ..write('freq: $freq, ')
          ..write('interval: $interval, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('monthDay: $monthDay, ')
          ..write('setPos: $setPos, ')
          ..write('weekStart: $weekStart, ')
          ..write('startOn: $startOn, ')
          ..write('endOn: $endOn, ')
          ..write('maxCount: $maxCount, ')
          ..write('mode: $mode, ')
          ..write('remindDaysBefore: $remindDaysBefore, ')
          ..write('remindAt: $remindAt, ')
          ..write('isPaused: $isPaused, ')
          ..write('nextDueOn: $nextDueOn, ')
          ..write('doneCount: $doneCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    kind,
    title,
    accountId,
    toAccountId,
    categoryId,
    amountMinor,
    currency,
    note,
    splits,
    freq,
    interval,
    weekdayMask,
    monthDay,
    setPos,
    weekStart,
    startOn,
    endOn,
    maxCount,
    mode,
    remindDaysBefore,
    remindAt,
    isPaused,
    nextDueOn,
    doneCount,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRule &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.categoryId == this.categoryId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.note == this.note &&
          other.splits == this.splits &&
          other.freq == this.freq &&
          other.interval == this.interval &&
          other.weekdayMask == this.weekdayMask &&
          other.monthDay == this.monthDay &&
          other.setPos == this.setPos &&
          other.weekStart == this.weekStart &&
          other.startOn == this.startOn &&
          other.endOn == this.endOn &&
          other.maxCount == this.maxCount &&
          other.mode == this.mode &&
          other.remindDaysBefore == this.remindDaysBefore &&
          other.remindAt == this.remindAt &&
          other.isPaused == this.isPaused &&
          other.nextDueOn == this.nextDueOn &&
          other.doneCount == this.doneCount);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRule> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> kind;
  final Value<String> title;
  final Value<String?> accountId;
  final Value<String?> toAccountId;
  final Value<String?> categoryId;
  final Value<int?> amountMinor;
  final Value<String> currency;
  final Value<String> note;
  final Value<String> splits;
  final Value<String> freq;
  final Value<int> interval;
  final Value<int> weekdayMask;
  final Value<int?> monthDay;
  final Value<int?> setPos;
  final Value<int> weekStart;
  final Value<String> startOn;
  final Value<String?> endOn;
  final Value<int?> maxCount;
  final Value<String> mode;
  final Value<int> remindDaysBefore;
  final Value<String?> remindAt;
  final Value<bool> isPaused;
  final Value<String?> nextDueOn;
  final Value<int> doneCount;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.note = const Value.absent(),
    this.splits = const Value.absent(),
    this.freq = const Value.absent(),
    this.interval = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.monthDay = const Value.absent(),
    this.setPos = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.startOn = const Value.absent(),
    this.endOn = const Value.absent(),
    this.maxCount = const Value.absent(),
    this.mode = const Value.absent(),
    this.remindDaysBefore = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.nextDueOn = const Value.absent(),
    this.doneCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String kind,
    this.title = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.note = const Value.absent(),
    this.splits = const Value.absent(),
    required String freq,
    this.interval = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.monthDay = const Value.absent(),
    this.setPos = const Value.absent(),
    this.weekStart = const Value.absent(),
    required String startOn,
    this.endOn = const Value.absent(),
    this.maxCount = const Value.absent(),
    this.mode = const Value.absent(),
    this.remindDaysBefore = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.nextDueOn = const Value.absent(),
    this.doneCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       kind = Value(kind),
       freq = Value(freq),
       startOn = Value(startOn);
  static Insertable<RecurringRule> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? accountId,
    Expression<String>? toAccountId,
    Expression<String>? categoryId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? note,
    Expression<String>? splits,
    Expression<String>? freq,
    Expression<int>? interval,
    Expression<int>? weekdayMask,
    Expression<int>? monthDay,
    Expression<int>? setPos,
    Expression<int>? weekStart,
    Expression<String>? startOn,
    Expression<String>? endOn,
    Expression<int>? maxCount,
    Expression<String>? mode,
    Expression<int>? remindDaysBefore,
    Expression<String>? remindAt,
    Expression<bool>? isPaused,
    Expression<String>? nextDueOn,
    Expression<int>? doneCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (note != null) 'note': note,
      if (splits != null) 'splits': splits,
      if (freq != null) 'freq': freq,
      if (interval != null) 'interval': interval,
      if (weekdayMask != null) 'weekday_mask': weekdayMask,
      if (monthDay != null) 'month_day': monthDay,
      if (setPos != null) 'set_pos': setPos,
      if (weekStart != null) 'week_start': weekStart,
      if (startOn != null) 'start_on': startOn,
      if (endOn != null) 'end_on': endOn,
      if (maxCount != null) 'max_count': maxCount,
      if (mode != null) 'mode': mode,
      if (remindDaysBefore != null) 'remind_days_before': remindDaysBefore,
      if (remindAt != null) 'remind_at': remindAt,
      if (isPaused != null) 'is_paused': isPaused,
      if (nextDueOn != null) 'next_due_on': nextDueOn,
      if (doneCount != null) 'done_count': doneCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? kind,
    Value<String>? title,
    Value<String?>? accountId,
    Value<String?>? toAccountId,
    Value<String?>? categoryId,
    Value<int?>? amountMinor,
    Value<String>? currency,
    Value<String>? note,
    Value<String>? splits,
    Value<String>? freq,
    Value<int>? interval,
    Value<int>? weekdayMask,
    Value<int?>? monthDay,
    Value<int?>? setPos,
    Value<int>? weekStart,
    Value<String>? startOn,
    Value<String?>? endOn,
    Value<int?>? maxCount,
    Value<String>? mode,
    Value<int>? remindDaysBefore,
    Value<String?>? remindAt,
    Value<bool>? isPaused,
    Value<String?>? nextDueOn,
    Value<int>? doneCount,
    Value<int>? rowid,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      splits: splits ?? this.splits,
      freq: freq ?? this.freq,
      interval: interval ?? this.interval,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      monthDay: monthDay ?? this.monthDay,
      setPos: setPos ?? this.setPos,
      weekStart: weekStart ?? this.weekStart,
      startOn: startOn ?? this.startOn,
      endOn: endOn ?? this.endOn,
      maxCount: maxCount ?? this.maxCount,
      mode: mode ?? this.mode,
      remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
      remindAt: remindAt ?? this.remindAt,
      isPaused: isPaused ?? this.isPaused,
      nextDueOn: nextDueOn ?? this.nextDueOn,
      doneCount: doneCount ?? this.doneCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (splits.present) {
      map['splits'] = Variable<String>(splits.value);
    }
    if (freq.present) {
      map['freq'] = Variable<String>(freq.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (weekdayMask.present) {
      map['weekday_mask'] = Variable<int>(weekdayMask.value);
    }
    if (monthDay.present) {
      map['month_day'] = Variable<int>(monthDay.value);
    }
    if (setPos.present) {
      map['set_pos'] = Variable<int>(setPos.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<int>(weekStart.value);
    }
    if (startOn.present) {
      map['start_on'] = Variable<String>(startOn.value);
    }
    if (endOn.present) {
      map['end_on'] = Variable<String>(endOn.value);
    }
    if (maxCount.present) {
      map['max_count'] = Variable<int>(maxCount.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (remindDaysBefore.present) {
      map['remind_days_before'] = Variable<int>(remindDaysBefore.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<String>(remindAt.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    if (nextDueOn.present) {
      map['next_due_on'] = Variable<String>(nextDueOn.value);
    }
    if (doneCount.present) {
      map['done_count'] = Variable<int>(doneCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('note: $note, ')
          ..write('splits: $splits, ')
          ..write('freq: $freq, ')
          ..write('interval: $interval, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('monthDay: $monthDay, ')
          ..write('setPos: $setPos, ')
          ..write('weekStart: $weekStart, ')
          ..write('startOn: $startOn, ')
          ..write('endOn: $endOn, ')
          ..write('maxCount: $maxCount, ')
          ..write('mode: $mode, ')
          ..write('remindDaysBefore: $remindDaysBefore, ')
          ..write('remindAt: $remindAt, ')
          ..write('isPaused: $isPaused, ')
          ..write('nextDueOn: $nextDueOn, ')
          ..write('doneCount: $doneCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringOccurrencesTable extends RecurringOccurrences
    with TableInfo<$RecurringOccurrencesTable, RecurringOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueOnMeta = const VerificationMeta('dueOn');
  @override
  late final GeneratedColumn<String> dueOn = GeneratedColumn<String>(
    'due_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<String> snoozedUntil = GeneratedColumn<String>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    ruleId,
    dueOn,
    status,
    snoozedUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('due_on')) {
      context.handle(
        _dueOnMeta,
        dueOn.isAcceptableOrUnknown(data['due_on']!, _dueOnMeta),
      );
    } else if (isInserting) {
      context.missing(_dueOnMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      dueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_on'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snoozed_until'],
      ),
    );
  }

  @override
  $RecurringOccurrencesTable createAlias(String alias) {
    return $RecurringOccurrencesTable(attachedDatabase, alias);
  }
}

class RecurringOccurrence extends DataClass
    implements Insertable<RecurringOccurrence> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String ruleId;
  final String dueOn;

  /// upcoming, due, done or skipped.
  final String status;
  final String? snoozedUntil;
  const RecurringOccurrence({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.ruleId,
    required this.dueOn,
    required this.status,
    this.snoozedUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['rule_id'] = Variable<String>(ruleId);
    map['due_on'] = Variable<String>(dueOn);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<String>(snoozedUntil);
    }
    return map;
  }

  RecurringOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return RecurringOccurrencesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      ruleId: Value(ruleId),
      dueOn: Value(dueOn),
      status: Value(status),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
    );
  }

  factory RecurringOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringOccurrence(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      dueOn: serializer.fromJson<String>(json['dueOn']),
      status: serializer.fromJson<String>(json['status']),
      snoozedUntil: serializer.fromJson<String?>(json['snoozedUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'ruleId': serializer.toJson<String>(ruleId),
      'dueOn': serializer.toJson<String>(dueOn),
      'status': serializer.toJson<String>(status),
      'snoozedUntil': serializer.toJson<String?>(snoozedUntil),
    };
  }

  RecurringOccurrence copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? ruleId,
    String? dueOn,
    String? status,
    Value<String?> snoozedUntil = const Value.absent(),
  }) => RecurringOccurrence(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    ruleId: ruleId ?? this.ruleId,
    dueOn: dueOn ?? this.dueOn,
    status: status ?? this.status,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
  );
  RecurringOccurrence copyWithCompanion(RecurringOccurrencesCompanion data) {
    return RecurringOccurrence(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      status: data.status.present ? data.status.value : this.status,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringOccurrence(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ruleId: $ruleId, ')
          ..write('dueOn: $dueOn, ')
          ..write('status: $status, ')
          ..write('snoozedUntil: $snoozedUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    ruleId,
    dueOn,
    status,
    snoozedUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringOccurrence &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.ruleId == this.ruleId &&
          other.dueOn == this.dueOn &&
          other.status == this.status &&
          other.snoozedUntil == this.snoozedUntil);
}

class RecurringOccurrencesCompanion
    extends UpdateCompanion<RecurringOccurrence> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> ruleId;
  final Value<String> dueOn;
  final Value<String> status;
  final Value<String?> snoozedUntil;
  final Value<int> rowid;
  const RecurringOccurrencesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringOccurrencesCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String ruleId,
    required String dueOn,
    required String status,
    this.snoozedUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       ruleId = Value(ruleId),
       dueOn = Value(dueOn),
       status = Value(status);
  static Insertable<RecurringOccurrence> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? ruleId,
    Expression<String>? dueOn,
    Expression<String>? status,
    Expression<String>? snoozedUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (ruleId != null) 'rule_id': ruleId,
      if (dueOn != null) 'due_on': dueOn,
      if (status != null) 'status': status,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? ruleId,
    Value<String>? dueOn,
    Value<String>? status,
    Value<String?>? snoozedUntil,
    Value<int>? rowid,
  }) {
    return RecurringOccurrencesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      ruleId: ruleId ?? this.ruleId,
      dueOn: dueOn ?? this.dueOn,
      status: status ?? this.status,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (dueOn.present) {
      map['due_on'] = Variable<String>(dueOn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<String>(snoozedUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ruleId: $ruleId, ')
          ..write('dueOn: $dueOn, ')
          ..write('status: $status, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InboxItemsTable extends InboxItems
    with TableInfo<$InboxItemsTable, InboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String> params = GeneratedColumn<String>(
    'params',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _subjectTableMeta = const VerificationMeta(
    'subjectTable',
  );
  @override
  late final GeneratedColumn<String> subjectTable = GeneratedColumn<String>(
    'subject_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<String> readAt = GeneratedColumn<String>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<String> resolvedAt = GeneratedColumn<String>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    type,
    params,
    subjectTable,
    subjectId,
    dedupeKey,
    readAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('params')) {
      context.handle(
        _paramsMeta,
        params.isAcceptableOrUnknown(data['params']!, _paramsMeta),
      );
    }
    if (data.containsKey('subject_table')) {
      context.handle(
        _subjectTableMeta,
        subjectTable.isAcceptableOrUnknown(
          data['subject_table']!,
          _subjectTableMeta,
        ),
      );
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      params: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params'],
      )!,
      subjectTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_table'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}read_at'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $InboxItemsTable createAlias(String alias) {
    return $InboxItemsTable(attachedDatabase, alias);
  }
}

class InboxItem extends DataClass implements Insertable<InboxItem> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String type;

  /// JSON object the wording is filled from.
  final String params;
  final String subjectTable;
  final String? subjectId;
  final String dedupeKey;
  final String? readAt;
  final String? resolvedAt;
  const InboxItem({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.type,
    required this.params,
    required this.subjectTable,
    this.subjectId,
    required this.dedupeKey,
    this.readAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['type'] = Variable<String>(type);
    map['params'] = Variable<String>(params);
    map['subject_table'] = Variable<String>(subjectTable);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    map['dedupe_key'] = Variable<String>(dedupeKey);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<String>(readAt);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<String>(resolvedAt);
    }
    return map;
  }

  InboxItemsCompanion toCompanion(bool nullToAbsent) {
    return InboxItemsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      type: Value(type),
      params: Value(params),
      subjectTable: Value(subjectTable),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      dedupeKey: Value(dedupeKey),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory InboxItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxItem(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      type: serializer.fromJson<String>(json['type']),
      params: serializer.fromJson<String>(json['params']),
      subjectTable: serializer.fromJson<String>(json['subjectTable']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      readAt: serializer.fromJson<String?>(json['readAt']),
      resolvedAt: serializer.fromJson<String?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'type': serializer.toJson<String>(type),
      'params': serializer.toJson<String>(params),
      'subjectTable': serializer.toJson<String>(subjectTable),
      'subjectId': serializer.toJson<String?>(subjectId),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'readAt': serializer.toJson<String?>(readAt),
      'resolvedAt': serializer.toJson<String?>(resolvedAt),
    };
  }

  InboxItem copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? type,
    String? params,
    String? subjectTable,
    Value<String?> subjectId = const Value.absent(),
    String? dedupeKey,
    Value<String?> readAt = const Value.absent(),
    Value<String?> resolvedAt = const Value.absent(),
  }) => InboxItem(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    type: type ?? this.type,
    params: params ?? this.params,
    subjectTable: subjectTable ?? this.subjectTable,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    dedupeKey: dedupeKey ?? this.dedupeKey,
    readAt: readAt.present ? readAt.value : this.readAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  InboxItem copyWithCompanion(InboxItemsCompanion data) {
    return InboxItem(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      type: data.type.present ? data.type.value : this.type,
      params: data.params.present ? data.params.value : this.params,
      subjectTable: data.subjectTable.present
          ? data.subjectTable.value
          : this.subjectTable,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxItem(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('type: $type, ')
          ..write('params: $params, ')
          ..write('subjectTable: $subjectTable, ')
          ..write('subjectId: $subjectId, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('readAt: $readAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    type,
    params,
    subjectTable,
    subjectId,
    dedupeKey,
    readAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxItem &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.type == this.type &&
          other.params == this.params &&
          other.subjectTable == this.subjectTable &&
          other.subjectId == this.subjectId &&
          other.dedupeKey == this.dedupeKey &&
          other.readAt == this.readAt &&
          other.resolvedAt == this.resolvedAt);
}

class InboxItemsCompanion extends UpdateCompanion<InboxItem> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> type;
  final Value<String> params;
  final Value<String> subjectTable;
  final Value<String?> subjectId;
  final Value<String> dedupeKey;
  final Value<String?> readAt;
  final Value<String?> resolvedAt;
  final Value<int> rowid;
  const InboxItemsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.params = const Value.absent(),
    this.subjectTable = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.readAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InboxItemsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String type,
    this.params = const Value.absent(),
    this.subjectTable = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.readAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       type = Value(type);
  static Insertable<InboxItem> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? type,
    Expression<String>? params,
    Expression<String>? subjectTable,
    Expression<String>? subjectId,
    Expression<String>? dedupeKey,
    Expression<String>? readAt,
    Expression<String>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (type != null) 'type': type,
      if (params != null) 'params': params,
      if (subjectTable != null) 'subject_table': subjectTable,
      if (subjectId != null) 'subject_id': subjectId,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (readAt != null) 'read_at': readAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InboxItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? type,
    Value<String>? params,
    Value<String>? subjectTable,
    Value<String?>? subjectId,
    Value<String>? dedupeKey,
    Value<String?>? readAt,
    Value<String?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return InboxItemsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      type: type ?? this.type,
      params: params ?? this.params,
      subjectTable: subjectTable ?? this.subjectTable,
      subjectId: subjectId ?? this.subjectId,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      readAt: readAt ?? this.readAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    if (subjectTable.present) {
      map['subject_table'] = Variable<String>(subjectTable.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<String>(readAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<String>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('type: $type, ')
          ..write('params: $params, ')
          ..write('subjectTable: $subjectTable, ')
          ..write('subjectId: $subjectId, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('readAt: $readAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMinorMeta = const VerificationMeta(
    'targetMinor',
  );
  @override
  late final GeneratedColumn<int> targetMinor = GeneratedColumn<int>(
    'target_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetOnMeta = const VerificationMeta(
    'targetOn',
  );
  @override
  late final GeneratedColumn<String> targetOn = GeneratedColumn<String>(
    'target_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _reachedAtMeta = const VerificationMeta(
    'reachedAt',
  );
  @override
  late final GeneratedColumn<String> reachedAt = GeneratedColumn<String>(
    'reached_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _milestonesHitMeta = const VerificationMeta(
    'milestonesHit',
  );
  @override
  late final GeneratedColumn<int> milestonesHit = GeneratedColumn<int>(
    'milestones_hit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    accountId,
    name,
    targetMinor,
    currency,
    targetOn,
    icon,
    color,
    status,
    reachedAt,
    milestonesHit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_minor')) {
      context.handle(
        _targetMinorMeta,
        targetMinor.isAcceptableOrUnknown(
          data['target_minor']!,
          _targetMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('target_on')) {
      context.handle(
        _targetOnMeta,
        targetOn.isAcceptableOrUnknown(data['target_on']!, _targetOnMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('reached_at')) {
      context.handle(
        _reachedAtMeta,
        reachedAt.isAcceptableOrUnknown(data['reached_at']!, _reachedAtMeta),
      );
    }
    if (data.containsKey('milestones_hit')) {
      context.handle(
        _milestonesHitMeta,
        milestonesHit.isAcceptableOrUnknown(
          data['milestones_hit']!,
          _milestonesHitMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      targetOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_on'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reached_at'],
      ),
      milestonesHit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}milestones_hit'],
      )!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoal extends DataClass implements Insertable<SavingsGoal> {
  final String id;
  final String workspaceId;
  final int version;
  final int serverSeq;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String accountId;
  final String name;
  final int targetMinor;
  final String currency;

  /// yyyy-MM-dd, or null for a goal with no date.
  final String? targetOn;

  /// A name from the goal icon set (features/goals/goal_style.dart); '' for the default.
  final String icon;
  final String? color;

  /// active, reached (set by the server) or archived.
  final String status;
  final String? reachedAt;

  /// One bit per milestone (25, 50, 75, 100%) the server has told the user about.
  final int milestonesHit;
  const SavingsGoal({
    required this.id,
    required this.workspaceId,
    required this.version,
    required this.serverSeq,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.accountId,
    required this.name,
    required this.targetMinor,
    required this.currency,
    this.targetOn,
    required this.icon,
    this.color,
    required this.status,
    this.reachedAt,
    required this.milestonesHit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['version'] = Variable<int>(version);
    map['server_seq'] = Variable<int>(serverSeq);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['account_id'] = Variable<String>(accountId);
    map['name'] = Variable<String>(name);
    map['target_minor'] = Variable<int>(targetMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || targetOn != null) {
      map['target_on'] = Variable<String>(targetOn);
    }
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reachedAt != null) {
      map['reached_at'] = Variable<String>(reachedAt);
    }
    map['milestones_hit'] = Variable<int>(milestonesHit);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      version: Value(version),
      serverSeq: Value(serverSeq),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      accountId: Value(accountId),
      name: Value(name),
      targetMinor: Value(targetMinor),
      currency: Value(currency),
      targetOn: targetOn == null && nullToAbsent
          ? const Value.absent()
          : Value(targetOn),
      icon: Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      status: Value(status),
      reachedAt: reachedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reachedAt),
      milestonesHit: Value(milestonesHit),
    );
  }

  factory SavingsGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoal(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      version: serializer.fromJson<int>(json['version']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      accountId: serializer.fromJson<String>(json['accountId']),
      name: serializer.fromJson<String>(json['name']),
      targetMinor: serializer.fromJson<int>(json['targetMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      targetOn: serializer.fromJson<String?>(json['targetOn']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      status: serializer.fromJson<String>(json['status']),
      reachedAt: serializer.fromJson<String?>(json['reachedAt']),
      milestonesHit: serializer.fromJson<int>(json['milestonesHit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'version': serializer.toJson<int>(version),
      'serverSeq': serializer.toJson<int>(serverSeq),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'accountId': serializer.toJson<String>(accountId),
      'name': serializer.toJson<String>(name),
      'targetMinor': serializer.toJson<int>(targetMinor),
      'currency': serializer.toJson<String>(currency),
      'targetOn': serializer.toJson<String?>(targetOn),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String?>(color),
      'status': serializer.toJson<String>(status),
      'reachedAt': serializer.toJson<String?>(reachedAt),
      'milestonesHit': serializer.toJson<int>(milestonesHit),
    };
  }

  SavingsGoal copyWith({
    String? id,
    String? workspaceId,
    int? version,
    int? serverSeq,
    String? createdAt,
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    String? accountId,
    String? name,
    int? targetMinor,
    String? currency,
    Value<String?> targetOn = const Value.absent(),
    String? icon,
    Value<String?> color = const Value.absent(),
    String? status,
    Value<String?> reachedAt = const Value.absent(),
    int? milestonesHit,
  }) => SavingsGoal(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    version: version ?? this.version,
    serverSeq: serverSeq ?? this.serverSeq,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    accountId: accountId ?? this.accountId,
    name: name ?? this.name,
    targetMinor: targetMinor ?? this.targetMinor,
    currency: currency ?? this.currency,
    targetOn: targetOn.present ? targetOn.value : this.targetOn,
    icon: icon ?? this.icon,
    color: color.present ? color.value : this.color,
    status: status ?? this.status,
    reachedAt: reachedAt.present ? reachedAt.value : this.reachedAt,
    milestonesHit: milestonesHit ?? this.milestonesHit,
  );
  SavingsGoal copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoal(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      version: data.version.present ? data.version.value : this.version,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      name: data.name.present ? data.name.value : this.name,
      targetMinor: data.targetMinor.present
          ? data.targetMinor.value
          : this.targetMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      targetOn: data.targetOn.present ? data.targetOn.value : this.targetOn,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      status: data.status.present ? data.status.value : this.status,
      reachedAt: data.reachedAt.present ? data.reachedAt.value : this.reachedAt,
      milestonesHit: data.milestonesHit.present
          ? data.milestonesHit.value
          : this.milestonesHit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoal(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('targetMinor: $targetMinor, ')
          ..write('currency: $currency, ')
          ..write('targetOn: $targetOn, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('status: $status, ')
          ..write('reachedAt: $reachedAt, ')
          ..write('milestonesHit: $milestonesHit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    version,
    serverSeq,
    createdAt,
    updatedAt,
    deletedAt,
    accountId,
    name,
    targetMinor,
    currency,
    targetOn,
    icon,
    color,
    status,
    reachedAt,
    milestonesHit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoal &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.version == this.version &&
          other.serverSeq == this.serverSeq &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.accountId == this.accountId &&
          other.name == this.name &&
          other.targetMinor == this.targetMinor &&
          other.currency == this.currency &&
          other.targetOn == this.targetOn &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.status == this.status &&
          other.reachedAt == this.reachedAt &&
          other.milestonesHit == this.milestonesHit);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoal> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<int> version;
  final Value<int> serverSeq;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String> accountId;
  final Value<String> name;
  final Value<int> targetMinor;
  final Value<String> currency;
  final Value<String?> targetOn;
  final Value<String> icon;
  final Value<String?> color;
  final Value<String> status;
  final Value<String?> reachedAt;
  final Value<int> milestonesHit;
  final Value<int> rowid;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.accountId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.targetOn = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.status = const Value.absent(),
    this.reachedAt = const Value.absent(),
    this.milestonesHit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    required String id,
    required String workspaceId,
    this.version = const Value.absent(),
    this.serverSeq = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    required String accountId,
    required String name,
    required int targetMinor,
    required String currency,
    this.targetOn = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.status = const Value.absent(),
    this.reachedAt = const Value.absent(),
    this.milestonesHit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       accountId = Value(accountId),
       name = Value(name),
       targetMinor = Value(targetMinor),
       currency = Value(currency);
  static Insertable<SavingsGoal> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<int>? version,
    Expression<int>? serverSeq,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? accountId,
    Expression<String>? name,
    Expression<int>? targetMinor,
    Expression<String>? currency,
    Expression<String>? targetOn,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? status,
    Expression<String>? reachedAt,
    Expression<int>? milestonesHit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (version != null) 'version': version,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (accountId != null) 'account_id': accountId,
      if (name != null) 'name': name,
      if (targetMinor != null) 'target_minor': targetMinor,
      if (currency != null) 'currency': currency,
      if (targetOn != null) 'target_on': targetOn,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (status != null) 'status': status,
      if (reachedAt != null) 'reached_at': reachedAt,
      if (milestonesHit != null) 'milestones_hit': milestonesHit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<int>? version,
    Value<int>? serverSeq,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String>? accountId,
    Value<String>? name,
    Value<int>? targetMinor,
    Value<String>? currency,
    Value<String?>? targetOn,
    Value<String>? icon,
    Value<String?>? color,
    Value<String>? status,
    Value<String?>? reachedAt,
    Value<int>? milestonesHit,
    Value<int>? rowid,
  }) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      version: version ?? this.version,
      serverSeq: serverSeq ?? this.serverSeq,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      targetMinor: targetMinor ?? this.targetMinor,
      currency: currency ?? this.currency,
      targetOn: targetOn ?? this.targetOn,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      status: status ?? this.status,
      reachedAt: reachedAt ?? this.reachedAt,
      milestonesHit: milestonesHit ?? this.milestonesHit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetMinor.present) {
      map['target_minor'] = Variable<int>(targetMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (targetOn.present) {
      map['target_on'] = Variable<String>(targetOn.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reachedAt.present) {
      map['reached_at'] = Variable<String>(reachedAt.value);
    }
    if (milestonesHit.present) {
      map['milestones_hit'] = Variable<int>(milestonesHit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('version: $version, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('targetMinor: $targetMinor, ')
          ..write('currency: $currency, ')
          ..write('targetOn: $targetOn, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('status: $status, ')
          ..write('reachedAt: $reachedAt, ')
          ..write('milestonesHit: $milestonesHit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableName_Meta = const VerificationMeta(
    'tableName_',
  );
  @override
  late final GeneratedColumn<String> tableName_ = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    mutationId,
    workspaceId,
    tableName_,
    op,
    rowId,
    data,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _tableName_Meta,
        tableName_.isAcceptableOrUnknown(data['table_name']!, _tableName_Meta),
      );
    } else if (isInserting) {
      context.missing(_tableName_Meta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      tableName_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int seq;
  final String mutationId;
  final String workspaceId;
  final String tableName_;
  final String op;
  final String rowId;

  /// JSON object of the columns this change set
  final String data;
  const OutboxData({
    required this.seq,
    required this.mutationId,
    required this.workspaceId,
    required this.tableName_,
    required this.op,
    required this.rowId,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['mutation_id'] = Variable<String>(mutationId);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['table_name'] = Variable<String>(tableName_);
    map['op'] = Variable<String>(op);
    map['row_id'] = Variable<String>(rowId);
    map['data'] = Variable<String>(data);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      mutationId: Value(mutationId),
      workspaceId: Value(workspaceId),
      tableName_: Value(tableName_),
      op: Value(op),
      rowId: Value(rowId),
      data: Value(data),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      seq: serializer.fromJson<int>(json['seq']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      tableName_: serializer.fromJson<String>(json['tableName_']),
      op: serializer.fromJson<String>(json['op']),
      rowId: serializer.fromJson<String>(json['rowId']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'mutationId': serializer.toJson<String>(mutationId),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'tableName_': serializer.toJson<String>(tableName_),
      'op': serializer.toJson<String>(op),
      'rowId': serializer.toJson<String>(rowId),
      'data': serializer.toJson<String>(data),
    };
  }

  OutboxData copyWith({
    int? seq,
    String? mutationId,
    String? workspaceId,
    String? tableName_,
    String? op,
    String? rowId,
    String? data,
  }) => OutboxData(
    seq: seq ?? this.seq,
    mutationId: mutationId ?? this.mutationId,
    workspaceId: workspaceId ?? this.workspaceId,
    tableName_: tableName_ ?? this.tableName_,
    op: op ?? this.op,
    rowId: rowId ?? this.rowId,
    data: data ?? this.data,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      seq: data.seq.present ? data.seq.value : this.seq,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      tableName_: data.tableName_.present
          ? data.tableName_.value
          : this.tableName_,
      op: data.op.present ? data.op.value : this.op,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('seq: $seq, ')
          ..write('mutationId: $mutationId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('tableName_: $tableName_, ')
          ..write('op: $op, ')
          ..write('rowId: $rowId, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(seq, mutationId, workspaceId, tableName_, op, rowId, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.seq == this.seq &&
          other.mutationId == this.mutationId &&
          other.workspaceId == this.workspaceId &&
          other.tableName_ == this.tableName_ &&
          other.op == this.op &&
          other.rowId == this.rowId &&
          other.data == this.data);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> seq;
  final Value<String> mutationId;
  final Value<String> workspaceId;
  final Value<String> tableName_;
  final Value<String> op;
  final Value<String> rowId;
  final Value<String> data;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.tableName_ = const Value.absent(),
    this.op = const Value.absent(),
    this.rowId = const Value.absent(),
    this.data = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String mutationId,
    required String workspaceId,
    required String tableName_,
    required String op,
    required String rowId,
    required String data,
  }) : mutationId = Value(mutationId),
       workspaceId = Value(workspaceId),
       tableName_ = Value(tableName_),
       op = Value(op),
       rowId = Value(rowId),
       data = Value(data);
  static Insertable<OutboxData> custom({
    Expression<int>? seq,
    Expression<String>? mutationId,
    Expression<String>? workspaceId,
    Expression<String>? tableName_,
    Expression<String>? op,
    Expression<String>? rowId,
    Expression<String>? data,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (mutationId != null) 'mutation_id': mutationId,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (tableName_ != null) 'table_name': tableName_,
      if (op != null) 'op': op,
      if (rowId != null) 'row_id': rowId,
      if (data != null) 'data': data,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? mutationId,
    Value<String>? workspaceId,
    Value<String>? tableName_,
    Value<String>? op,
    Value<String>? rowId,
    Value<String>? data,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      mutationId: mutationId ?? this.mutationId,
      workspaceId: workspaceId ?? this.workspaceId,
      tableName_: tableName_ ?? this.tableName_,
      op: op ?? this.op,
      rowId: rowId ?? this.rowId,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (tableName_.present) {
      map['table_name'] = Variable<String>(tableName_.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('mutationId: $mutationId, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('tableName_: $tableName_, ')
          ..write('op: $op, ')
          ..write('rowId: $rowId, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $BillQueueTable extends BillQueue
    with TableInfo<$BillQueueTable, BillQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashbookIdMeta = const VerificationMeta(
    'cashbookId',
  );
  @override
  late final GeneratedColumn<String> cashbookId = GeneratedColumn<String>(
    'cashbook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextTryAtMeta = const VerificationMeta(
    'nextTryAt',
  );
  @override
  late final GeneratedColumn<String> nextTryAt = GeneratedColumn<String>(
    'next_try_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    op,
    workspaceId,
    cashbookId,
    entryId,
    path,
    contentType,
    originalName,
    sizeBytes,
    width,
    height,
    state,
    error,
    attempts,
    nextTryAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bill_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<BillQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('cashbook_id')) {
      context.handle(
        _cashbookIdMeta,
        cashbookId.isAcceptableOrUnknown(data['cashbook_id']!, _cashbookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cashbookIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_try_at')) {
      context.handle(
        _nextTryAtMeta,
        nextTryAt.isAcceptableOrUnknown(data['next_try_at']!, _nextTryAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      cashbookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cashbook_id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextTryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_try_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BillQueueTable createAlias(String alias) {
    return $BillQueueTable(attachedDatabase, alias);
  }
}

class BillQueueData extends DataClass implements Insertable<BillQueueData> {
  /// The bill's id, made here; the server keeps it, so a resend is recognised.
  final String id;

  /// 'upload' or 'remove'.
  final String op;
  final String workspaceId;
  final String cashbookId;
  final String entryId;

  /// The file waiting to go, for an upload.
  final String? path;
  final String contentType;
  final String originalName;
  final int sizeBytes;
  final int? width;
  final int? height;

  /// 'queued' (waiting its turn), 'failed' (the server refused the file) or
  /// 'refused' (the plan has no room for it).
  final String state;

  /// Why it failed: a code from the server, such as bill_unsafe, or a plan feature.
  final String? error;
  final int attempts;

  /// Not tried again before this moment (ISO), after the server could not be reached.
  final String? nextTryAt;
  final String createdAt;
  const BillQueueData({
    required this.id,
    required this.op,
    required this.workspaceId,
    required this.cashbookId,
    required this.entryId,
    this.path,
    required this.contentType,
    required this.originalName,
    required this.sizeBytes,
    this.width,
    this.height,
    required this.state,
    this.error,
    required this.attempts,
    this.nextTryAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['op'] = Variable<String>(op);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['cashbook_id'] = Variable<String>(cashbookId);
    map['entry_id'] = Variable<String>(entryId);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    map['content_type'] = Variable<String>(contentType);
    map['original_name'] = Variable<String>(originalName);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextTryAt != null) {
      map['next_try_at'] = Variable<String>(nextTryAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  BillQueueCompanion toCompanion(bool nullToAbsent) {
    return BillQueueCompanion(
      id: Value(id),
      op: Value(op),
      workspaceId: Value(workspaceId),
      cashbookId: Value(cashbookId),
      entryId: Value(entryId),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      contentType: Value(contentType),
      originalName: Value(originalName),
      sizeBytes: Value(sizeBytes),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      state: Value(state),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      attempts: Value(attempts),
      nextTryAt: nextTryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextTryAt),
      createdAt: Value(createdAt),
    );
  }

  factory BillQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillQueueData(
      id: serializer.fromJson<String>(json['id']),
      op: serializer.fromJson<String>(json['op']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      cashbookId: serializer.fromJson<String>(json['cashbookId']),
      entryId: serializer.fromJson<String>(json['entryId']),
      path: serializer.fromJson<String?>(json['path']),
      contentType: serializer.fromJson<String>(json['contentType']),
      originalName: serializer.fromJson<String>(json['originalName']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      state: serializer.fromJson<String>(json['state']),
      error: serializer.fromJson<String?>(json['error']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextTryAt: serializer.fromJson<String?>(json['nextTryAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'op': serializer.toJson<String>(op),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'cashbookId': serializer.toJson<String>(cashbookId),
      'entryId': serializer.toJson<String>(entryId),
      'path': serializer.toJson<String?>(path),
      'contentType': serializer.toJson<String>(contentType),
      'originalName': serializer.toJson<String>(originalName),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'state': serializer.toJson<String>(state),
      'error': serializer.toJson<String?>(error),
      'attempts': serializer.toJson<int>(attempts),
      'nextTryAt': serializer.toJson<String?>(nextTryAt),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  BillQueueData copyWith({
    String? id,
    String? op,
    String? workspaceId,
    String? cashbookId,
    String? entryId,
    Value<String?> path = const Value.absent(),
    String? contentType,
    String? originalName,
    int? sizeBytes,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    String? state,
    Value<String?> error = const Value.absent(),
    int? attempts,
    Value<String?> nextTryAt = const Value.absent(),
    String? createdAt,
  }) => BillQueueData(
    id: id ?? this.id,
    op: op ?? this.op,
    workspaceId: workspaceId ?? this.workspaceId,
    cashbookId: cashbookId ?? this.cashbookId,
    entryId: entryId ?? this.entryId,
    path: path.present ? path.value : this.path,
    contentType: contentType ?? this.contentType,
    originalName: originalName ?? this.originalName,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    state: state ?? this.state,
    error: error.present ? error.value : this.error,
    attempts: attempts ?? this.attempts,
    nextTryAt: nextTryAt.present ? nextTryAt.value : this.nextTryAt,
    createdAt: createdAt ?? this.createdAt,
  );
  BillQueueData copyWithCompanion(BillQueueCompanion data) {
    return BillQueueData(
      id: data.id.present ? data.id.value : this.id,
      op: data.op.present ? data.op.value : this.op,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      cashbookId: data.cashbookId.present
          ? data.cashbookId.value
          : this.cashbookId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      path: data.path.present ? data.path.value : this.path,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      state: data.state.present ? data.state.value : this.state,
      error: data.error.present ? data.error.value : this.error,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextTryAt: data.nextTryAt.present ? data.nextTryAt.value : this.nextTryAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillQueueData(')
          ..write('id: $id, ')
          ..write('op: $op, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('entryId: $entryId, ')
          ..write('path: $path, ')
          ..write('contentType: $contentType, ')
          ..write('originalName: $originalName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('attempts: $attempts, ')
          ..write('nextTryAt: $nextTryAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    op,
    workspaceId,
    cashbookId,
    entryId,
    path,
    contentType,
    originalName,
    sizeBytes,
    width,
    height,
    state,
    error,
    attempts,
    nextTryAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillQueueData &&
          other.id == this.id &&
          other.op == this.op &&
          other.workspaceId == this.workspaceId &&
          other.cashbookId == this.cashbookId &&
          other.entryId == this.entryId &&
          other.path == this.path &&
          other.contentType == this.contentType &&
          other.originalName == this.originalName &&
          other.sizeBytes == this.sizeBytes &&
          other.width == this.width &&
          other.height == this.height &&
          other.state == this.state &&
          other.error == this.error &&
          other.attempts == this.attempts &&
          other.nextTryAt == this.nextTryAt &&
          other.createdAt == this.createdAt);
}

class BillQueueCompanion extends UpdateCompanion<BillQueueData> {
  final Value<String> id;
  final Value<String> op;
  final Value<String> workspaceId;
  final Value<String> cashbookId;
  final Value<String> entryId;
  final Value<String?> path;
  final Value<String> contentType;
  final Value<String> originalName;
  final Value<int> sizeBytes;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String> state;
  final Value<String?> error;
  final Value<int> attempts;
  final Value<String?> nextTryAt;
  final Value<String> createdAt;
  final Value<int> rowid;
  const BillQueueCompanion({
    this.id = const Value.absent(),
    this.op = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.cashbookId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.path = const Value.absent(),
    this.contentType = const Value.absent(),
    this.originalName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextTryAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillQueueCompanion.insert({
    required String id,
    required String op,
    required String workspaceId,
    required String cashbookId,
    required String entryId,
    this.path = const Value.absent(),
    this.contentType = const Value.absent(),
    this.originalName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextTryAt = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       op = Value(op),
       workspaceId = Value(workspaceId),
       cashbookId = Value(cashbookId),
       entryId = Value(entryId),
       createdAt = Value(createdAt);
  static Insertable<BillQueueData> custom({
    Expression<String>? id,
    Expression<String>? op,
    Expression<String>? workspaceId,
    Expression<String>? cashbookId,
    Expression<String>? entryId,
    Expression<String>? path,
    Expression<String>? contentType,
    Expression<String>? originalName,
    Expression<int>? sizeBytes,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? state,
    Expression<String>? error,
    Expression<int>? attempts,
    Expression<String>? nextTryAt,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (op != null) 'op': op,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (cashbookId != null) 'cashbook_id': cashbookId,
      if (entryId != null) 'entry_id': entryId,
      if (path != null) 'path': path,
      if (contentType != null) 'content_type': contentType,
      if (originalName != null) 'original_name': originalName,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (state != null) 'state': state,
      if (error != null) 'error': error,
      if (attempts != null) 'attempts': attempts,
      if (nextTryAt != null) 'next_try_at': nextTryAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? op,
    Value<String>? workspaceId,
    Value<String>? cashbookId,
    Value<String>? entryId,
    Value<String?>? path,
    Value<String>? contentType,
    Value<String>? originalName,
    Value<int>? sizeBytes,
    Value<int?>? width,
    Value<int?>? height,
    Value<String>? state,
    Value<String?>? error,
    Value<int>? attempts,
    Value<String?>? nextTryAt,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return BillQueueCompanion(
      id: id ?? this.id,
      op: op ?? this.op,
      workspaceId: workspaceId ?? this.workspaceId,
      cashbookId: cashbookId ?? this.cashbookId,
      entryId: entryId ?? this.entryId,
      path: path ?? this.path,
      contentType: contentType ?? this.contentType,
      originalName: originalName ?? this.originalName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      state: state ?? this.state,
      error: error ?? this.error,
      attempts: attempts ?? this.attempts,
      nextTryAt: nextTryAt ?? this.nextTryAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (cashbookId.present) {
      map['cashbook_id'] = Variable<String>(cashbookId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextTryAt.present) {
      map['next_try_at'] = Variable<String>(nextTryAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillQueueCompanion(')
          ..write('id: $id, ')
          ..write('op: $op, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('cashbookId: $cashbookId, ')
          ..write('entryId: $entryId, ')
          ..write('path: $path, ')
          ..write('contentType: $contentType, ')
          ..write('originalName: $originalName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('attempts: $attempts, ')
          ..write('nextTryAt: $nextTryAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sinceMeta = const VerificationMeta('since');
  @override
  late final GeneratedColumn<int> since = GeneratedColumn<int>(
    'since',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [workspaceId, since];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('since')) {
      context.handle(
        _sinceMeta,
        since.isAcceptableOrUnknown(data['since']!, _sinceMeta),
      );
    } else if (isInserting) {
      context.missing(_sinceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      since: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}since'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String workspaceId;
  final int since;
  const SyncCursor({required this.workspaceId, required this.since});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<String>(workspaceId);
    map['since'] = Variable<int>(since);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      workspaceId: Value(workspaceId),
      since: Value(since),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      since: serializer.fromJson<int>(json['since']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<String>(workspaceId),
      'since': serializer.toJson<int>(since),
    };
  }

  SyncCursor copyWith({String? workspaceId, int? since}) => SyncCursor(
    workspaceId: workspaceId ?? this.workspaceId,
    since: since ?? this.since,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      since: data.since.present ? data.since.value : this.since,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('workspaceId: $workspaceId, ')
          ..write('since: $since')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workspaceId, since);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.workspaceId == this.workspaceId &&
          other.since == this.since);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> workspaceId;
  final Value<int> since;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.workspaceId = const Value.absent(),
    this.since = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String workspaceId,
    required int since,
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       since = Value(since);
  static Insertable<SyncCursor> custom({
    Expression<String>? workspaceId,
    Expression<int>? since,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (since != null) 'since': since,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? workspaceId,
    Value<int>? since,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      since: since ?? this.since,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (since.present) {
      map['since'] = Variable<int>(since.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('since: $since, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncFailuresTable extends SyncFailures
    with TableInfo<$SyncFailuresTable, SyncFailure> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncFailuresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tableName_Meta = const VerificationMeta(
    'tableName_',
  );
  @override
  late final GeneratedColumn<String> tableName_ = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tableName_,
    rowId,
    code,
    detail,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_failures';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncFailure> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _tableName_Meta,
        tableName_.isAcceptableOrUnknown(data['table_name']!, _tableName_Meta),
      );
    } else if (isInserting) {
      context.missing(_tableName_Meta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    } else if (isInserting) {
      context.missing(_detailMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncFailure map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncFailure(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tableName_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncFailuresTable createAlias(String alias) {
    return $SyncFailuresTable(attachedDatabase, alias);
  }
}

class SyncFailure extends DataClass implements Insertable<SyncFailure> {
  final int id;
  final String tableName_;
  final String rowId;
  final String code;
  final String detail;
  final String createdAt;
  const SyncFailure({
    required this.id,
    required this.tableName_,
    required this.rowId,
    required this.code,
    required this.detail,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['table_name'] = Variable<String>(tableName_);
    map['row_id'] = Variable<String>(rowId);
    map['code'] = Variable<String>(code);
    map['detail'] = Variable<String>(detail);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  SyncFailuresCompanion toCompanion(bool nullToAbsent) {
    return SyncFailuresCompanion(
      id: Value(id),
      tableName_: Value(tableName_),
      rowId: Value(rowId),
      code: Value(code),
      detail: Value(detail),
      createdAt: Value(createdAt),
    );
  }

  factory SyncFailure.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncFailure(
      id: serializer.fromJson<int>(json['id']),
      tableName_: serializer.fromJson<String>(json['tableName_']),
      rowId: serializer.fromJson<String>(json['rowId']),
      code: serializer.fromJson<String>(json['code']),
      detail: serializer.fromJson<String>(json['detail']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tableName_': serializer.toJson<String>(tableName_),
      'rowId': serializer.toJson<String>(rowId),
      'code': serializer.toJson<String>(code),
      'detail': serializer.toJson<String>(detail),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  SyncFailure copyWith({
    int? id,
    String? tableName_,
    String? rowId,
    String? code,
    String? detail,
    String? createdAt,
  }) => SyncFailure(
    id: id ?? this.id,
    tableName_: tableName_ ?? this.tableName_,
    rowId: rowId ?? this.rowId,
    code: code ?? this.code,
    detail: detail ?? this.detail,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncFailure copyWithCompanion(SyncFailuresCompanion data) {
    return SyncFailure(
      id: data.id.present ? data.id.value : this.id,
      tableName_: data.tableName_.present
          ? data.tableName_.value
          : this.tableName_,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      code: data.code.present ? data.code.value : this.code,
      detail: data.detail.present ? data.detail.value : this.detail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncFailure(')
          ..write('id: $id, ')
          ..write('tableName_: $tableName_, ')
          ..write('rowId: $rowId, ')
          ..write('code: $code, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tableName_, rowId, code, detail, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncFailure &&
          other.id == this.id &&
          other.tableName_ == this.tableName_ &&
          other.rowId == this.rowId &&
          other.code == this.code &&
          other.detail == this.detail &&
          other.createdAt == this.createdAt);
}

class SyncFailuresCompanion extends UpdateCompanion<SyncFailure> {
  final Value<int> id;
  final Value<String> tableName_;
  final Value<String> rowId;
  final Value<String> code;
  final Value<String> detail;
  final Value<String> createdAt;
  const SyncFailuresCompanion({
    this.id = const Value.absent(),
    this.tableName_ = const Value.absent(),
    this.rowId = const Value.absent(),
    this.code = const Value.absent(),
    this.detail = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncFailuresCompanion.insert({
    this.id = const Value.absent(),
    required String tableName_,
    required String rowId,
    required String code,
    required String detail,
    required String createdAt,
  }) : tableName_ = Value(tableName_),
       rowId = Value(rowId),
       code = Value(code),
       detail = Value(detail),
       createdAt = Value(createdAt);
  static Insertable<SyncFailure> custom({
    Expression<int>? id,
    Expression<String>? tableName_,
    Expression<String>? rowId,
    Expression<String>? code,
    Expression<String>? detail,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableName_ != null) 'table_name': tableName_,
      if (rowId != null) 'row_id': rowId,
      if (code != null) 'code': code,
      if (detail != null) 'detail': detail,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncFailuresCompanion copyWith({
    Value<int>? id,
    Value<String>? tableName_,
    Value<String>? rowId,
    Value<String>? code,
    Value<String>? detail,
    Value<String>? createdAt,
  }) {
    return SyncFailuresCompanion(
      id: id ?? this.id,
      tableName_: tableName_ ?? this.tableName_,
      rowId: rowId ?? this.rowId,
      code: code ?? this.code,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tableName_.present) {
      map['table_name'] = Variable<String>(tableName_.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncFailuresCompanion(')
          ..write('id: $id, ')
          ..write('tableName_: $tableName_, ')
          ..write('rowId: $rowId, ')
          ..write('code: $code, ')
          ..write('detail: $detail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $WorkspaceTagsTable workspaceTags = $WorkspaceTagsTable(this);
  late final $CashbooksTable cashbooks = $CashbooksTable(this);
  late final $EntryCategoriesTable entryCategories = $EntryCategoriesTable(
    this,
  );
  late final $PaymentMethodsTable paymentMethods = $PaymentMethodsTable(this);
  late final $EntryFieldsTable entryFields = $EntryFieldsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $EntryBillsTable entryBills = $EntryBillsTable(this);
  late final $CashbookMembersTable cashbookMembers = $CashbookMembersTable(
    this,
  );
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $RecurringOccurrencesTable recurringOccurrences =
      $RecurringOccurrencesTable(this);
  late final $InboxItemsTable inboxItems = $InboxItemsTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $BillQueueTable billQueue = $BillQueueTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncFailuresTable syncFailures = $SyncFailuresTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index entryFieldsBook = Index(
    'entry_fields_book',
    'CREATE INDEX entry_fields_book ON entry_fields (cashbook_id)',
  );
  late final Index entriesBookDate = Index(
    'entries_book_date',
    'CREATE INDEX entries_book_date ON entries (cashbook_id, entry_date)',
  );
  late final Index entryBillsEntry = Index(
    'entry_bills_entry',
    'CREATE INDEX entry_bills_entry ON entry_bills (entry_id)',
  );
  late final Index transactionsAccountFeed = Index(
    'transactions_account_feed',
    'CREATE INDEX transactions_account_feed ON transactions (account_id, occurred_on, created_at, id)',
  );
  late final Index transactionsTransferGroup = Index(
    'transactions_transfer_group',
    'CREATE INDEX transactions_transfer_group ON transactions (transfer_group_id)',
  );
  late final Index recurringOccurrencesDue = Index(
    'recurring_occurrences_due',
    'CREATE INDEX recurring_occurrences_due ON recurring_occurrences (workspace_id, status, due_on)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workspaces,
    workspaceTags,
    cashbooks,
    entryCategories,
    paymentMethods,
    entryFields,
    entries,
    entryBills,
    cashbookMembers,
    accounts,
    categories,
    transactions,
    budgets,
    recurringRules,
    recurringOccurrences,
    inboxItems,
    savingsGoals,
    outbox,
    billQueue,
    syncCursors,
    syncFailures,
    settings,
    entryFieldsBook,
    entriesBookDate,
    entryBillsEntry,
    transactionsAccountFeed,
    transactionsTransferGroup,
    recurringOccurrencesDue,
  ];
}

typedef $$WorkspacesTableCreateCompanionBuilder =
    WorkspacesCompanion Function({
      required String id,
      required String name,
      required String kind,
      required String defaultCurrency,
      Value<bool> isDemo,
      required String role,
      Value<int> rowid,
    });
typedef $$WorkspacesTableUpdateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<String> defaultCurrency,
      Value<bool> isDemo,
      Value<String> role,
      Value<int> rowid,
    });

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDemo => $composableBuilder(
    column: $table.isDemo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDemo => $composableBuilder(
    column: $table.isDemo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get defaultCurrency => $composableBuilder(
    column: $table.defaultCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDemo =>
      $composableBuilder(column: $table.isDemo, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          Workspace,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (
            Workspace,
            BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace>,
          ),
          Workspace,
          PrefetchHooks Function()
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> defaultCurrency = const Value.absent(),
                Value<bool> isDemo = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                name: name,
                kind: kind,
                defaultCurrency: defaultCurrency,
                isDemo: isDemo,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                required String defaultCurrency,
                Value<bool> isDemo = const Value.absent(),
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                defaultCurrency: defaultCurrency,
                isDemo: isDemo,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      Workspace,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (Workspace, BaseReferences<_$AppDatabase, $WorkspacesTable, Workspace>),
      Workspace,
      PrefetchHooks Function()
    >;
typedef $$WorkspaceTagsTableCreateCompanionBuilder =
    WorkspaceTagsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String name,
      Value<String?> color,
      Value<int> rowid,
    });
typedef $$WorkspaceTagsTableUpdateCompanionBuilder =
    WorkspaceTagsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> name,
      Value<String?> color,
      Value<int> rowid,
    });

class $$WorkspaceTagsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspaceTagsTable> {
  $$WorkspaceTagsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkspaceTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspaceTagsTable> {
  $$WorkspaceTagsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspaceTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspaceTagsTable> {
  $$WorkspaceTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$WorkspaceTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspaceTagsTable,
          Tag,
          $$WorkspaceTagsTableFilterComposer,
          $$WorkspaceTagsTableOrderingComposer,
          $$WorkspaceTagsTableAnnotationComposer,
          $$WorkspaceTagsTableCreateCompanionBuilder,
          $$WorkspaceTagsTableUpdateCompanionBuilder,
          (Tag, BaseReferences<_$AppDatabase, $WorkspaceTagsTable, Tag>),
          Tag,
          PrefetchHooks Function()
        > {
  $$WorkspaceTagsTableTableManager(_$AppDatabase db, $WorkspaceTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspaceTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspaceTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspaceTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceTagsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceTagsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkspaceTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspaceTagsTable,
      Tag,
      $$WorkspaceTagsTableFilterComposer,
      $$WorkspaceTagsTableOrderingComposer,
      $$WorkspaceTagsTableAnnotationComposer,
      $$WorkspaceTagsTableCreateCompanionBuilder,
      $$WorkspaceTagsTableUpdateCompanionBuilder,
      (Tag, BaseReferences<_$AppDatabase, $WorkspaceTagsTable, Tag>),
      Tag,
      PrefetchHooks Function()
    >;
typedef $$CashbooksTableCreateCompanionBuilder =
    CashbooksCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String bookName,
      Value<String?> description,
      required String currency,
      Value<int> rowid,
    });
typedef $$CashbooksTableUpdateCompanionBuilder =
    CashbooksCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> bookName,
      Value<String?> description,
      Value<String> currency,
      Value<int> rowid,
    });

class $$CashbooksTableFilterComposer
    extends Composer<_$AppDatabase, $CashbooksTable> {
  $$CashbooksTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashbooksTableOrderingComposer
    extends Composer<_$AppDatabase, $CashbooksTable> {
  $$CashbooksTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashbooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashbooksTable> {
  $$CashbooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);
}

class $$CashbooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashbooksTable,
          Cashbook,
          $$CashbooksTableFilterComposer,
          $$CashbooksTableOrderingComposer,
          $$CashbooksTableAnnotationComposer,
          $$CashbooksTableCreateCompanionBuilder,
          $$CashbooksTableUpdateCompanionBuilder,
          (Cashbook, BaseReferences<_$AppDatabase, $CashbooksTable, Cashbook>),
          Cashbook,
          PrefetchHooks Function()
        > {
  $$CashbooksTableTableManager(_$AppDatabase db, $CashbooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashbooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashbooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashbooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> bookName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashbooksCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                bookName: bookName,
                description: description,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String bookName,
                Value<String?> description = const Value.absent(),
                required String currency,
                Value<int> rowid = const Value.absent(),
              }) => CashbooksCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                bookName: bookName,
                description: description,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashbooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashbooksTable,
      Cashbook,
      $$CashbooksTableFilterComposer,
      $$CashbooksTableOrderingComposer,
      $$CashbooksTableAnnotationComposer,
      $$CashbooksTableCreateCompanionBuilder,
      $$CashbooksTableUpdateCompanionBuilder,
      (Cashbook, BaseReferences<_$AppDatabase, $CashbooksTable, Cashbook>),
      Cashbook,
      PrefetchHooks Function()
    >;
typedef $$EntryCategoriesTableCreateCompanionBuilder =
    EntryCategoriesCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String cashbookId,
      required String categoryName,
      Value<bool> isDefault,
      Value<String?> color,
      Value<int> rowid,
    });
typedef $$EntryCategoriesTableUpdateCompanionBuilder =
    EntryCategoriesCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> cashbookId,
      Value<String> categoryName,
      Value<bool> isDefault,
      Value<String?> color,
      Value<int> rowid,
    });

class $$EntryCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntryCategoriesTable> {
  $$EntryCategoriesTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntryCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryCategoriesTable> {
  $$EntryCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntryCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryCategoriesTable> {
  $$EntryCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$EntryCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryCategoriesTable,
          EntryCategory,
          $$EntryCategoriesTableFilterComposer,
          $$EntryCategoriesTableOrderingComposer,
          $$EntryCategoriesTableAnnotationComposer,
          $$EntryCategoriesTableCreateCompanionBuilder,
          $$EntryCategoriesTableUpdateCompanionBuilder,
          (
            EntryCategory,
            BaseReferences<_$AppDatabase, $EntryCategoriesTable, EntryCategory>,
          ),
          EntryCategory,
          PrefetchHooks Function()
        > {
  $$EntryCategoriesTableTableManager(
    _$AppDatabase db,
    $EntryCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> cashbookId = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryCategoriesCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                categoryName: categoryName,
                isDefault: isDefault,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String cashbookId,
                required String categoryName,
                Value<bool> isDefault = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryCategoriesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                categoryName: categoryName,
                isDefault: isDefault,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntryCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryCategoriesTable,
      EntryCategory,
      $$EntryCategoriesTableFilterComposer,
      $$EntryCategoriesTableOrderingComposer,
      $$EntryCategoriesTableAnnotationComposer,
      $$EntryCategoriesTableCreateCompanionBuilder,
      $$EntryCategoriesTableUpdateCompanionBuilder,
      (
        EntryCategory,
        BaseReferences<_$AppDatabase, $EntryCategoriesTable, EntryCategory>,
      ),
      EntryCategory,
      PrefetchHooks Function()
    >;
typedef $$PaymentMethodsTableCreateCompanionBuilder =
    PaymentMethodsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String cashbookId,
      required String paymentMethodName,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$PaymentMethodsTableUpdateCompanionBuilder =
    PaymentMethodsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> cashbookId,
      Value<String> paymentMethodName,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$PaymentMethodsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethodName => $composableBuilder(
    column: $table.paymentMethodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentMethodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethodName => $composableBuilder(
    column: $table.paymentMethodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentMethodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethodName => $composableBuilder(
    column: $table.paymentMethodName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$PaymentMethodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentMethodsTable,
          PaymentMethod,
          $$PaymentMethodsTableFilterComposer,
          $$PaymentMethodsTableOrderingComposer,
          $$PaymentMethodsTableAnnotationComposer,
          $$PaymentMethodsTableCreateCompanionBuilder,
          $$PaymentMethodsTableUpdateCompanionBuilder,
          (
            PaymentMethod,
            BaseReferences<_$AppDatabase, $PaymentMethodsTable, PaymentMethod>,
          ),
          PaymentMethod,
          PrefetchHooks Function()
        > {
  $$PaymentMethodsTableTableManager(
    _$AppDatabase db,
    $PaymentMethodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> cashbookId = const Value.absent(),
                Value<String> paymentMethodName = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentMethodsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                paymentMethodName: paymentMethodName,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String cashbookId,
                required String paymentMethodName,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentMethodsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                paymentMethodName: paymentMethodName,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentMethodsTable,
      PaymentMethod,
      $$PaymentMethodsTableFilterComposer,
      $$PaymentMethodsTableOrderingComposer,
      $$PaymentMethodsTableAnnotationComposer,
      $$PaymentMethodsTableCreateCompanionBuilder,
      $$PaymentMethodsTableUpdateCompanionBuilder,
      (
        PaymentMethod,
        BaseReferences<_$AppDatabase, $PaymentMethodsTable, PaymentMethod>,
      ),
      PaymentMethod,
      PrefetchHooks Function()
    >;
typedef $$EntryFieldsTableCreateCompanionBuilder =
    EntryFieldsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String cashbookId,
      required String name,
      required String kind,
      Value<String> options,
      Value<bool> isRequired,
      Value<bool> showInList,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$EntryFieldsTableUpdateCompanionBuilder =
    EntryFieldsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> cashbookId,
      Value<String> name,
      Value<String> kind,
      Value<String> options,
      Value<bool> isRequired,
      Value<bool> showInList,
      Value<int> position,
      Value<int> rowid,
    });

class $$EntryFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryFieldsTable> {
  $$EntryFieldsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showInList => $composableBuilder(
    column: $table.showInList,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntryFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryFieldsTable> {
  $$EntryFieldsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showInList => $composableBuilder(
    column: $table.showInList,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntryFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryFieldsTable> {
  $$EntryFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
    column: $table.isRequired,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showInList => $composableBuilder(
    column: $table.showInList,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$EntryFieldsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryFieldsTable,
          EntryField,
          $$EntryFieldsTableFilterComposer,
          $$EntryFieldsTableOrderingComposer,
          $$EntryFieldsTableAnnotationComposer,
          $$EntryFieldsTableCreateCompanionBuilder,
          $$EntryFieldsTableUpdateCompanionBuilder,
          (
            EntryField,
            BaseReferences<_$AppDatabase, $EntryFieldsTable, EntryField>,
          ),
          EntryField,
          PrefetchHooks Function()
        > {
  $$EntryFieldsTableTableManager(_$AppDatabase db, $EntryFieldsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryFieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> cashbookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> options = const Value.absent(),
                Value<bool> isRequired = const Value.absent(),
                Value<bool> showInList = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryFieldsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                name: name,
                kind: kind,
                options: options,
                isRequired: isRequired,
                showInList: showInList,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String cashbookId,
                required String name,
                required String kind,
                Value<String> options = const Value.absent(),
                Value<bool> isRequired = const Value.absent(),
                Value<bool> showInList = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryFieldsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                name: name,
                kind: kind,
                options: options,
                isRequired: isRequired,
                showInList: showInList,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntryFieldsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryFieldsTable,
      EntryField,
      $$EntryFieldsTableFilterComposer,
      $$EntryFieldsTableOrderingComposer,
      $$EntryFieldsTableAnnotationComposer,
      $$EntryFieldsTableCreateCompanionBuilder,
      $$EntryFieldsTableUpdateCompanionBuilder,
      (
        EntryField,
        BaseReferences<_$AppDatabase, $EntryFieldsTable, EntryField>,
      ),
      EntryField,
      PrefetchHooks Function()
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String cashbookId,
      Value<String?> categoryId,
      Value<String?> paymentMethodId,
      required String entryType,
      required int amountMinor,
      required String currency,
      Value<String?> title,
      Value<String?> remarks,
      Value<String> merchant,
      Value<String> tagIds,
      required String entryDate,
      Value<String> source,
      Value<String?> createdById,
      Value<String> customValues,
      Value<int> rowid,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> cashbookId,
      Value<String?> categoryId,
      Value<String?> paymentMethodId,
      Value<String> entryType,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String?> title,
      Value<String?> remarks,
      Value<String> merchant,
      Value<String> tagIds,
      Value<String> entryDate,
      Value<String> source,
      Value<String?> createdById,
      Value<String> customValues,
      Value<int> rowid,
    });

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethodId => $composableBuilder(
    column: $table.paymentMethodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagIds => $composableBuilder(
    column: $table.tagIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethodId => $composableBuilder(
    column: $table.paymentMethodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagIds => $composableBuilder(
    column: $table.tagIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethodId => $composableBuilder(
    column: $table.paymentMethodId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get tagIds =>
      $composableBuilder(column: $table.tagIds, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => column,
  );
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, BaseReferences<_$AppDatabase, $EntriesTable, Entry>),
          Entry,
          PrefetchHooks Function()
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> cashbookId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> paymentMethodId = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> tagIds = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> createdById = const Value.absent(),
                Value<String> customValues = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                categoryId: categoryId,
                paymentMethodId: paymentMethodId,
                entryType: entryType,
                amountMinor: amountMinor,
                currency: currency,
                title: title,
                remarks: remarks,
                merchant: merchant,
                tagIds: tagIds,
                entryDate: entryDate,
                source: source,
                createdById: createdById,
                customValues: customValues,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String cashbookId,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> paymentMethodId = const Value.absent(),
                required String entryType,
                required int amountMinor,
                required String currency,
                Value<String?> title = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> tagIds = const Value.absent(),
                required String entryDate,
                Value<String> source = const Value.absent(),
                Value<String?> createdById = const Value.absent(),
                Value<String> customValues = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                categoryId: categoryId,
                paymentMethodId: paymentMethodId,
                entryType: entryType,
                amountMinor: amountMinor,
                currency: currency,
                title: title,
                remarks: remarks,
                merchant: merchant,
                tagIds: tagIds,
                entryDate: entryDate,
                source: source,
                createdById: createdById,
                customValues: customValues,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, BaseReferences<_$AppDatabase, $EntriesTable, Entry>),
      Entry,
      PrefetchHooks Function()
    >;
typedef $$EntryBillsTableCreateCompanionBuilder =
    EntryBillsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String entryId,
      required String cashbookId,
      Value<String?> createdById,
      required String contentType,
      Value<String> originalName,
      Value<int> sizeBytes,
      Value<int?> pageCount,
      Value<int?> width,
      Value<int?> height,
      Value<int> rowid,
    });
typedef $$EntryBillsTableUpdateCompanionBuilder =
    EntryBillsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> entryId,
      Value<String> cashbookId,
      Value<String?> createdById,
      Value<String> contentType,
      Value<String> originalName,
      Value<int> sizeBytes,
      Value<int?> pageCount,
      Value<int?> width,
      Value<int?> height,
      Value<int> rowid,
    });

class $$EntryBillsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryBillsTable> {
  $$EntryBillsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntryBillsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryBillsTable> {
  $$EntryBillsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntryBillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryBillsTable> {
  $$EntryBillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);
}

class $$EntryBillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryBillsTable,
          EntryBill,
          $$EntryBillsTableFilterComposer,
          $$EntryBillsTableOrderingComposer,
          $$EntryBillsTableAnnotationComposer,
          $$EntryBillsTableCreateCompanionBuilder,
          $$EntryBillsTableUpdateCompanionBuilder,
          (
            EntryBill,
            BaseReferences<_$AppDatabase, $EntryBillsTable, EntryBill>,
          ),
          EntryBill,
          PrefetchHooks Function()
        > {
  $$EntryBillsTableTableManager(_$AppDatabase db, $EntryBillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryBillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryBillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryBillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> cashbookId = const Value.absent(),
                Value<String?> createdById = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryBillsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                entryId: entryId,
                cashbookId: cashbookId,
                createdById: createdById,
                contentType: contentType,
                originalName: originalName,
                sizeBytes: sizeBytes,
                pageCount: pageCount,
                width: width,
                height: height,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String entryId,
                required String cashbookId,
                Value<String?> createdById = const Value.absent(),
                required String contentType,
                Value<String> originalName = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryBillsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                entryId: entryId,
                cashbookId: cashbookId,
                createdById: createdById,
                contentType: contentType,
                originalName: originalName,
                sizeBytes: sizeBytes,
                pageCount: pageCount,
                width: width,
                height: height,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntryBillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryBillsTable,
      EntryBill,
      $$EntryBillsTableFilterComposer,
      $$EntryBillsTableOrderingComposer,
      $$EntryBillsTableAnnotationComposer,
      $$EntryBillsTableCreateCompanionBuilder,
      $$EntryBillsTableUpdateCompanionBuilder,
      (EntryBill, BaseReferences<_$AppDatabase, $EntryBillsTable, EntryBill>),
      EntryBill,
      PrefetchHooks Function()
    >;
typedef $$CashbookMembersTableCreateCompanionBuilder =
    CashbookMembersCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String cashbookId,
      required String memberId,
      required String role,
      Value<int> rowid,
    });
typedef $$CashbookMembersTableUpdateCompanionBuilder =
    CashbookMembersCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> cashbookId,
      Value<String> memberId,
      Value<String> role,
      Value<int> rowid,
    });

class $$CashbookMembersTableFilterComposer
    extends Composer<_$AppDatabase, $CashbookMembersTable> {
  $$CashbookMembersTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashbookMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $CashbookMembersTable> {
  $$CashbookMembersTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashbookMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashbookMembersTable> {
  $$CashbookMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$CashbookMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashbookMembersTable,
          CashbookMember,
          $$CashbookMembersTableFilterComposer,
          $$CashbookMembersTableOrderingComposer,
          $$CashbookMembersTableAnnotationComposer,
          $$CashbookMembersTableCreateCompanionBuilder,
          $$CashbookMembersTableUpdateCompanionBuilder,
          (
            CashbookMember,
            BaseReferences<
              _$AppDatabase,
              $CashbookMembersTable,
              CashbookMember
            >,
          ),
          CashbookMember,
          PrefetchHooks Function()
        > {
  $$CashbookMembersTableTableManager(
    _$AppDatabase db,
    $CashbookMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashbookMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashbookMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashbookMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> cashbookId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashbookMembersCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                memberId: memberId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String cashbookId,
                required String memberId,
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => CashbookMembersCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                cashbookId: cashbookId,
                memberId: memberId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashbookMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashbookMembersTable,
      CashbookMember,
      $$CashbookMembersTableFilterComposer,
      $$CashbookMembersTableOrderingComposer,
      $$CashbookMembersTableAnnotationComposer,
      $$CashbookMembersTableCreateCompanionBuilder,
      $$CashbookMembersTableUpdateCompanionBuilder,
      (
        CashbookMember,
        BaseReferences<_$AppDatabase, $CashbookMembersTable, CashbookMember>,
      ),
      CashbookMember,
      PrefetchHooks Function()
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String name,
      required String kind,
      required String currency,
      Value<int> openingBalanceMinor,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> name,
      Value<String> kind,
      Value<String> currency,
      Value<int> openingBalanceMinor,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceMinor => $composableBuilder(
    column: $table.openingBalanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> openingBalanceMinor = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                kind: kind,
                currency: currency,
                openingBalanceMinor: openingBalanceMinor,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String name,
                required String kind,
                required String currency,
                Value<int> openingBalanceMinor = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                kind: kind,
                currency: currency,
                openingBalanceMinor: openingBalanceMinor,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String name,
      required String kind,
      Value<bool> isDefault,
      Value<String?> color,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> name,
      Value<String> kind,
      Value<bool> isDefault,
      Value<String?> color,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                kind: kind,
                isDefault: isDefault,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String name,
                required String kind,
                Value<bool> isDefault = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                kind: kind,
                isDefault: isDefault,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String accountId,
      Value<String?> categoryId,
      required String kind,
      required int amountMinor,
      required String currency,
      Value<String?> transferGroupId,
      required String occurredOn,
      Value<String> note,
      Value<String> merchant,
      Value<String> tagIds,
      Value<String> source,
      Value<String> splits,
      Value<String?> occurrenceId,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> accountId,
      Value<String?> categoryId,
      Value<String> kind,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String?> transferGroupId,
      Value<String> occurredOn,
      Value<String> note,
      Value<String> merchant,
      Value<String> tagIds,
      Value<String> source,
      Value<String> splits,
      Value<String?> occurrenceId,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagIds => $composableBuilder(
    column: $table.tagIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get splits => $composableBuilder(
    column: $table.splits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagIds => $composableBuilder(
    column: $table.tagIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splits => $composableBuilder(
    column: $table.splits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get tagIds =>
      $composableBuilder(column: $table.tagIds, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get splits =>
      $composableBuilder(column: $table.splits, builder: (column) => column);

  GeneratedColumn<String> get occurrenceId => $composableBuilder(
    column: $table.occurrenceId,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> transferGroupId = const Value.absent(),
                Value<String> occurredOn = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> tagIds = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> splits = const Value.absent(),
                Value<String?> occurrenceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                accountId: accountId,
                categoryId: categoryId,
                kind: kind,
                amountMinor: amountMinor,
                currency: currency,
                transferGroupId: transferGroupId,
                occurredOn: occurredOn,
                note: note,
                merchant: merchant,
                tagIds: tagIds,
                source: source,
                splits: splits,
                occurrenceId: occurrenceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String accountId,
                Value<String?> categoryId = const Value.absent(),
                required String kind,
                required int amountMinor,
                required String currency,
                Value<String?> transferGroupId = const Value.absent(),
                required String occurredOn,
                Value<String> note = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> tagIds = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> splits = const Value.absent(),
                Value<String?> occurrenceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                accountId: accountId,
                categoryId: categoryId,
                kind: kind,
                amountMinor: amountMinor,
                currency: currency,
                transferGroupId: transferGroupId,
                occurredOn: occurredOn,
                note: note,
                merchant: merchant,
                tagIds: tagIds,
                source: source,
                splits: splits,
                occurrenceId: occurrenceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String categoryId,
      required int amountMinor,
      required String currency,
      Value<String?> month,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> categoryId,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String?> month,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> month = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currency: currency,
                month: month,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String categoryId,
                required int amountMinor,
                required String currency,
                Value<String?> month = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currency: currency,
                month: month,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String kind,
      Value<String> title,
      Value<String?> accountId,
      Value<String?> toAccountId,
      Value<String?> categoryId,
      Value<int?> amountMinor,
      Value<String> currency,
      Value<String> note,
      Value<String> splits,
      required String freq,
      Value<int> interval,
      Value<int> weekdayMask,
      Value<int?> monthDay,
      Value<int?> setPos,
      Value<int> weekStart,
      required String startOn,
      Value<String?> endOn,
      Value<int?> maxCount,
      Value<String> mode,
      Value<int> remindDaysBefore,
      Value<String?> remindAt,
      Value<bool> isPaused,
      Value<String?> nextDueOn,
      Value<int> doneCount,
      Value<int> rowid,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> kind,
      Value<String> title,
      Value<String?> accountId,
      Value<String?> toAccountId,
      Value<String?> categoryId,
      Value<int?> amountMinor,
      Value<String> currency,
      Value<String> note,
      Value<String> splits,
      Value<String> freq,
      Value<int> interval,
      Value<int> weekdayMask,
      Value<int?> monthDay,
      Value<int?> setPos,
      Value<int> weekStart,
      Value<String> startOn,
      Value<String?> endOn,
      Value<int?> maxCount,
      Value<String> mode,
      Value<int> remindDaysBefore,
      Value<String?> remindAt,
      Value<bool> isPaused,
      Value<String?> nextDueOn,
      Value<int> doneCount,
      Value<int> rowid,
    });

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get splits => $composableBuilder(
    column: $table.splits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freq => $composableBuilder(
    column: $table.freq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthDay => $composableBuilder(
    column: $table.monthDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setPos => $composableBuilder(
    column: $table.setPos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startOn => $composableBuilder(
    column: $table.startOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endOn => $composableBuilder(
    column: $table.endOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxCount => $composableBuilder(
    column: $table.maxCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindDaysBefore => $composableBuilder(
    column: $table.remindDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextDueOn => $composableBuilder(
    column: $table.nextDueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doneCount => $composableBuilder(
    column: $table.doneCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splits => $composableBuilder(
    column: $table.splits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freq => $composableBuilder(
    column: $table.freq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthDay => $composableBuilder(
    column: $table.monthDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setPos => $composableBuilder(
    column: $table.setPos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startOn => $composableBuilder(
    column: $table.startOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endOn => $composableBuilder(
    column: $table.endOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxCount => $composableBuilder(
    column: $table.maxCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindDaysBefore => $composableBuilder(
    column: $table.remindDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextDueOn => $composableBuilder(
    column: $table.nextDueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doneCount => $composableBuilder(
    column: $table.doneCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get splits =>
      $composableBuilder(column: $table.splits, builder: (column) => column);

  GeneratedColumn<String> get freq =>
      $composableBuilder(column: $table.freq, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthDay =>
      $composableBuilder(column: $table.monthDay, builder: (column) => column);

  GeneratedColumn<int> get setPos =>
      $composableBuilder(column: $table.setPos, builder: (column) => column);

  GeneratedColumn<int> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<String> get startOn =>
      $composableBuilder(column: $table.startOn, builder: (column) => column);

  GeneratedColumn<String> get endOn =>
      $composableBuilder(column: $table.endOn, builder: (column) => column);

  GeneratedColumn<int> get maxCount =>
      $composableBuilder(column: $table.maxCount, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get remindDaysBefore => $composableBuilder(
    column: $table.remindDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  GeneratedColumn<String> get nextDueOn =>
      $composableBuilder(column: $table.nextDueOn, builder: (column) => column);

  GeneratedColumn<int> get doneCount =>
      $composableBuilder(column: $table.doneCount, builder: (column) => column);
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRulesTable,
          RecurringRule,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (
            RecurringRule,
            BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule>,
          ),
          RecurringRule,
          PrefetchHooks Function()
        > {
  $$RecurringRulesTableTableManager(
    _$AppDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> splits = const Value.absent(),
                Value<String> freq = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<int?> monthDay = const Value.absent(),
                Value<int?> setPos = const Value.absent(),
                Value<int> weekStart = const Value.absent(),
                Value<String> startOn = const Value.absent(),
                Value<String?> endOn = const Value.absent(),
                Value<int?> maxCount = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> remindDaysBefore = const Value.absent(),
                Value<String?> remindAt = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<String?> nextDueOn = const Value.absent(),
                Value<int> doneCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                kind: kind,
                title: title,
                accountId: accountId,
                toAccountId: toAccountId,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currency: currency,
                note: note,
                splits: splits,
                freq: freq,
                interval: interval,
                weekdayMask: weekdayMask,
                monthDay: monthDay,
                setPos: setPos,
                weekStart: weekStart,
                startOn: startOn,
                endOn: endOn,
                maxCount: maxCount,
                mode: mode,
                remindDaysBefore: remindDaysBefore,
                remindAt: remindAt,
                isPaused: isPaused,
                nextDueOn: nextDueOn,
                doneCount: doneCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String kind,
                Value<String> title = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> splits = const Value.absent(),
                required String freq,
                Value<int> interval = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<int?> monthDay = const Value.absent(),
                Value<int?> setPos = const Value.absent(),
                Value<int> weekStart = const Value.absent(),
                required String startOn,
                Value<String?> endOn = const Value.absent(),
                Value<int?> maxCount = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> remindDaysBefore = const Value.absent(),
                Value<String?> remindAt = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<String?> nextDueOn = const Value.absent(),
                Value<int> doneCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                kind: kind,
                title: title,
                accountId: accountId,
                toAccountId: toAccountId,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currency: currency,
                note: note,
                splits: splits,
                freq: freq,
                interval: interval,
                weekdayMask: weekdayMask,
                monthDay: monthDay,
                setPos: setPos,
                weekStart: weekStart,
                startOn: startOn,
                endOn: endOn,
                maxCount: maxCount,
                mode: mode,
                remindDaysBefore: remindDaysBefore,
                remindAt: remindAt,
                isPaused: isPaused,
                nextDueOn: nextDueOn,
                doneCount: doneCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRulesTable,
      RecurringRule,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (
        RecurringRule,
        BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRule>,
      ),
      RecurringRule,
      PrefetchHooks Function()
    >;
typedef $$RecurringOccurrencesTableCreateCompanionBuilder =
    RecurringOccurrencesCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String ruleId,
      required String dueOn,
      required String status,
      Value<String?> snoozedUntil,
      Value<int> rowid,
    });
typedef $$RecurringOccurrencesTableUpdateCompanionBuilder =
    RecurringOccurrencesCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> ruleId,
      Value<String> dueOn,
      Value<String> status,
      Value<String?> snoozedUntil,
      Value<int> rowid,
    });

class $$RecurringOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringOccurrencesTable> {
  $$RecurringOccurrencesTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringOccurrencesTable> {
  $$RecurringOccurrencesTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringOccurrencesTable> {
  $$RecurringOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );
}

class $$RecurringOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringOccurrencesTable,
          RecurringOccurrence,
          $$RecurringOccurrencesTableFilterComposer,
          $$RecurringOccurrencesTableOrderingComposer,
          $$RecurringOccurrencesTableAnnotationComposer,
          $$RecurringOccurrencesTableCreateCompanionBuilder,
          $$RecurringOccurrencesTableUpdateCompanionBuilder,
          (
            RecurringOccurrence,
            BaseReferences<
              _$AppDatabase,
              $RecurringOccurrencesTable,
              RecurringOccurrence
            >,
          ),
          RecurringOccurrence,
          PrefetchHooks Function()
        > {
  $$RecurringOccurrencesTableTableManager(
    _$AppDatabase db,
    $RecurringOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringOccurrencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<String> dueOn = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> snoozedUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringOccurrencesCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ruleId: ruleId,
                dueOn: dueOn,
                status: status,
                snoozedUntil: snoozedUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String ruleId,
                required String dueOn,
                required String status,
                Value<String?> snoozedUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringOccurrencesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ruleId: ruleId,
                dueOn: dueOn,
                status: status,
                snoozedUntil: snoozedUntil,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringOccurrencesTable,
      RecurringOccurrence,
      $$RecurringOccurrencesTableFilterComposer,
      $$RecurringOccurrencesTableOrderingComposer,
      $$RecurringOccurrencesTableAnnotationComposer,
      $$RecurringOccurrencesTableCreateCompanionBuilder,
      $$RecurringOccurrencesTableUpdateCompanionBuilder,
      (
        RecurringOccurrence,
        BaseReferences<
          _$AppDatabase,
          $RecurringOccurrencesTable,
          RecurringOccurrence
        >,
      ),
      RecurringOccurrence,
      PrefetchHooks Function()
    >;
typedef $$InboxItemsTableCreateCompanionBuilder =
    InboxItemsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String type,
      Value<String> params,
      Value<String> subjectTable,
      Value<String?> subjectId,
      Value<String> dedupeKey,
      Value<String?> readAt,
      Value<String?> resolvedAt,
      Value<int> rowid,
    });
typedef $$InboxItemsTableUpdateCompanionBuilder =
    InboxItemsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> type,
      Value<String> params,
      Value<String> subjectTable,
      Value<String?> subjectId,
      Value<String> dedupeKey,
      Value<String?> readAt,
      Value<String?> resolvedAt,
      Value<int> rowid,
    });

class $$InboxItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectTable => $composableBuilder(
    column: $table.subjectTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InboxItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectTable => $composableBuilder(
    column: $table.subjectTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InboxItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InboxItemsTable> {
  $$InboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get params =>
      $composableBuilder(column: $table.params, builder: (column) => column);

  GeneratedColumn<String> get subjectTable => $composableBuilder(
    column: $table.subjectTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<String> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<String> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$InboxItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InboxItemsTable,
          InboxItem,
          $$InboxItemsTableFilterComposer,
          $$InboxItemsTableOrderingComposer,
          $$InboxItemsTableAnnotationComposer,
          $$InboxItemsTableCreateCompanionBuilder,
          $$InboxItemsTableUpdateCompanionBuilder,
          (
            InboxItem,
            BaseReferences<_$AppDatabase, $InboxItemsTable, InboxItem>,
          ),
          InboxItem,
          PrefetchHooks Function()
        > {
  $$InboxItemsTableTableManager(_$AppDatabase db, $InboxItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> params = const Value.absent(),
                Value<String> subjectTable = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<String?> readAt = const Value.absent(),
                Value<String?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InboxItemsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                type: type,
                params: params,
                subjectTable: subjectTable,
                subjectId: subjectId,
                dedupeKey: dedupeKey,
                readAt: readAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String type,
                Value<String> params = const Value.absent(),
                Value<String> subjectTable = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<String?> readAt = const Value.absent(),
                Value<String?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InboxItemsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                type: type,
                params: params,
                subjectTable: subjectTable,
                subjectId: subjectId,
                dedupeKey: dedupeKey,
                readAt: readAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InboxItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InboxItemsTable,
      InboxItem,
      $$InboxItemsTableFilterComposer,
      $$InboxItemsTableOrderingComposer,
      $$InboxItemsTableAnnotationComposer,
      $$InboxItemsTableCreateCompanionBuilder,
      $$InboxItemsTableUpdateCompanionBuilder,
      (InboxItem, BaseReferences<_$AppDatabase, $InboxItemsTable, InboxItem>),
      InboxItem,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableCreateCompanionBuilder =
    SavingsGoalsCompanion Function({
      required String id,
      required String workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      required String createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      required String accountId,
      required String name,
      required int targetMinor,
      required String currency,
      Value<String?> targetOn,
      Value<String> icon,
      Value<String?> color,
      Value<String> status,
      Value<String?> reachedAt,
      Value<int> milestonesHit,
      Value<int> rowid,
    });
typedef $$SavingsGoalsTableUpdateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<int> version,
      Value<int> serverSeq,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String> accountId,
      Value<String> name,
      Value<int> targetMinor,
      Value<String> currency,
      Value<String?> targetOn,
      Value<String> icon,
      Value<String?> color,
      Value<String> status,
      Value<String?> reachedAt,
      Value<int> milestonesHit,
      Value<int> rowid,
    });

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
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

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetOn => $composableBuilder(
    column: $table.targetOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reachedAt => $composableBuilder(
    column: $table.reachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get milestonesHit => $composableBuilder(
    column: $table.milestonesHit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
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

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetOn => $composableBuilder(
    column: $table.targetOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reachedAt => $composableBuilder(
    column: $table.reachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get milestonesHit => $composableBuilder(
    column: $table.milestonesHit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetMinor => $composableBuilder(
    column: $table.targetMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get targetOn =>
      $composableBuilder(column: $table.targetOn, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reachedAt =>
      $composableBuilder(column: $table.reachedAt, builder: (column) => column);

  GeneratedColumn<int> get milestonesHit => $composableBuilder(
    column: $table.milestonesHit,
    builder: (column) => column,
  );
}

class $$SavingsGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTable,
          SavingsGoal,
          $$SavingsGoalsTableFilterComposer,
          $$SavingsGoalsTableOrderingComposer,
          $$SavingsGoalsTableAnnotationComposer,
          $$SavingsGoalsTableCreateCompanionBuilder,
          $$SavingsGoalsTableUpdateCompanionBuilder,
          (
            SavingsGoal,
            BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
          ),
          SavingsGoal,
          PrefetchHooks Function()
        > {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> targetOn = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reachedAt = const Value.absent(),
                Value<int> milestonesHit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                accountId: accountId,
                name: name,
                targetMinor: targetMinor,
                currency: currency,
                targetOn: targetOn,
                icon: icon,
                color: color,
                status: status,
                reachedAt: reachedAt,
                milestonesHit: milestonesHit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<int> version = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                required String accountId,
                required String name,
                required int targetMinor,
                required String currency,
                Value<String?> targetOn = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reachedAt = const Value.absent(),
                Value<int> milestonesHit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                version: version,
                serverSeq: serverSeq,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                accountId: accountId,
                name: name,
                targetMinor: targetMinor,
                currency: currency,
                targetOn: targetOn,
                icon: icon,
                color: color,
                status: status,
                reachedAt: reachedAt,
                milestonesHit: milestonesHit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTable,
      SavingsGoal,
      $$SavingsGoalsTableFilterComposer,
      $$SavingsGoalsTableOrderingComposer,
      $$SavingsGoalsTableAnnotationComposer,
      $$SavingsGoalsTableCreateCompanionBuilder,
      $$SavingsGoalsTableUpdateCompanionBuilder,
      (
        SavingsGoal,
        BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoal>,
      ),
      SavingsGoal,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      required String mutationId,
      required String workspaceId,
      required String tableName_,
      required String op,
      required String rowId,
      required String data,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      Value<String> mutationId,
      Value<String> workspaceId,
      Value<String> tableName_,
      Value<String> op,
      Value<String> rowId,
      Value<String> data,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => column,
  );

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> tableName_ = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> data = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                mutationId: mutationId,
                workspaceId: workspaceId,
                tableName_: tableName_,
                op: op,
                rowId: rowId,
                data: data,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String mutationId,
                required String workspaceId,
                required String tableName_,
                required String op,
                required String rowId,
                required String data,
              }) => OutboxCompanion.insert(
                seq: seq,
                mutationId: mutationId,
                workspaceId: workspaceId,
                tableName_: tableName_,
                op: op,
                rowId: rowId,
                data: data,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$BillQueueTableCreateCompanionBuilder =
    BillQueueCompanion Function({
      required String id,
      required String op,
      required String workspaceId,
      required String cashbookId,
      required String entryId,
      Value<String?> path,
      Value<String> contentType,
      Value<String> originalName,
      Value<int> sizeBytes,
      Value<int?> width,
      Value<int?> height,
      Value<String> state,
      Value<String?> error,
      Value<int> attempts,
      Value<String?> nextTryAt,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$BillQueueTableUpdateCompanionBuilder =
    BillQueueCompanion Function({
      Value<String> id,
      Value<String> op,
      Value<String> workspaceId,
      Value<String> cashbookId,
      Value<String> entryId,
      Value<String?> path,
      Value<String> contentType,
      Value<String> originalName,
      Value<int> sizeBytes,
      Value<int?> width,
      Value<int?> height,
      Value<String> state,
      Value<String?> error,
      Value<int> attempts,
      Value<String?> nextTryAt,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$BillQueueTableFilterComposer
    extends Composer<_$AppDatabase, $BillQueueTable> {
  $$BillQueueTableFilterComposer({
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

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextTryAt => $composableBuilder(
    column: $table.nextTryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BillQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $BillQueueTable> {
  $$BillQueueTableOrderingComposer({
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

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextTryAt => $composableBuilder(
    column: $table.nextTryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BillQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $BillQueueTable> {
  $$BillQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cashbookId => $composableBuilder(
    column: $table.cashbookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get nextTryAt =>
      $composableBuilder(column: $table.nextTryAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BillQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BillQueueTable,
          BillQueueData,
          $$BillQueueTableFilterComposer,
          $$BillQueueTableOrderingComposer,
          $$BillQueueTableAnnotationComposer,
          $$BillQueueTableCreateCompanionBuilder,
          $$BillQueueTableUpdateCompanionBuilder,
          (
            BillQueueData,
            BaseReferences<_$AppDatabase, $BillQueueTable, BillQueueData>,
          ),
          BillQueueData,
          PrefetchHooks Function()
        > {
  $$BillQueueTableTableManager(_$AppDatabase db, $BillQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> cashbookId = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> nextTryAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BillQueueCompanion(
                id: id,
                op: op,
                workspaceId: workspaceId,
                cashbookId: cashbookId,
                entryId: entryId,
                path: path,
                contentType: contentType,
                originalName: originalName,
                sizeBytes: sizeBytes,
                width: width,
                height: height,
                state: state,
                error: error,
                attempts: attempts,
                nextTryAt: nextTryAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String op,
                required String workspaceId,
                required String cashbookId,
                required String entryId,
                Value<String?> path = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> nextTryAt = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BillQueueCompanion.insert(
                id: id,
                op: op,
                workspaceId: workspaceId,
                cashbookId: cashbookId,
                entryId: entryId,
                path: path,
                contentType: contentType,
                originalName: originalName,
                sizeBytes: sizeBytes,
                width: width,
                height: height,
                state: state,
                error: error,
                attempts: attempts,
                nextTryAt: nextTryAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BillQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BillQueueTable,
      BillQueueData,
      $$BillQueueTableFilterComposer,
      $$BillQueueTableOrderingComposer,
      $$BillQueueTableAnnotationComposer,
      $$BillQueueTableCreateCompanionBuilder,
      $$BillQueueTableUpdateCompanionBuilder,
      (
        BillQueueData,
        BaseReferences<_$AppDatabase, $BillQueueTable, BillQueueData>,
      ),
      BillQueueData,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String workspaceId,
      required int since,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> workspaceId,
      Value<int> since,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get since => $composableBuilder(
    column: $table.since,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get since => $composableBuilder(
    column: $table.since,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get since =>
      $composableBuilder(column: $table.since, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workspaceId = const Value.absent(),
                Value<int> since = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                workspaceId: workspaceId,
                since: since,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workspaceId,
                required int since,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                workspaceId: workspaceId,
                since: since,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$SyncFailuresTableCreateCompanionBuilder =
    SyncFailuresCompanion Function({
      Value<int> id,
      required String tableName_,
      required String rowId,
      required String code,
      required String detail,
      required String createdAt,
    });
typedef $$SyncFailuresTableUpdateCompanionBuilder =
    SyncFailuresCompanion Function({
      Value<int> id,
      Value<String> tableName_,
      Value<String> rowId,
      Value<String> code,
      Value<String> detail,
      Value<String> createdAt,
    });

class $$SyncFailuresTableFilterComposer
    extends Composer<_$AppDatabase, $SyncFailuresTable> {
  $$SyncFailuresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncFailuresTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncFailuresTable> {
  $$SyncFailuresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncFailuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncFailuresTable> {
  $$SyncFailuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncFailuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncFailuresTable,
          SyncFailure,
          $$SyncFailuresTableFilterComposer,
          $$SyncFailuresTableOrderingComposer,
          $$SyncFailuresTableAnnotationComposer,
          $$SyncFailuresTableCreateCompanionBuilder,
          $$SyncFailuresTableUpdateCompanionBuilder,
          (
            SyncFailure,
            BaseReferences<_$AppDatabase, $SyncFailuresTable, SyncFailure>,
          ),
          SyncFailure,
          PrefetchHooks Function()
        > {
  $$SyncFailuresTableTableManager(_$AppDatabase db, $SyncFailuresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncFailuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncFailuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncFailuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tableName_ = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> detail = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => SyncFailuresCompanion(
                id: id,
                tableName_: tableName_,
                rowId: rowId,
                code: code,
                detail: detail,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tableName_,
                required String rowId,
                required String code,
                required String detail,
                required String createdAt,
              }) => SyncFailuresCompanion.insert(
                id: id,
                tableName_: tableName_,
                rowId: rowId,
                code: code,
                detail: detail,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncFailuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncFailuresTable,
      SyncFailure,
      $$SyncFailuresTableFilterComposer,
      $$SyncFailuresTableOrderingComposer,
      $$SyncFailuresTableAnnotationComposer,
      $$SyncFailuresTableCreateCompanionBuilder,
      $$SyncFailuresTableUpdateCompanionBuilder,
      (
        SyncFailure,
        BaseReferences<_$AppDatabase, $SyncFailuresTable, SyncFailure>,
      ),
      SyncFailure,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$WorkspaceTagsTableTableManager get workspaceTags =>
      $$WorkspaceTagsTableTableManager(_db, _db.workspaceTags);
  $$CashbooksTableTableManager get cashbooks =>
      $$CashbooksTableTableManager(_db, _db.cashbooks);
  $$EntryCategoriesTableTableManager get entryCategories =>
      $$EntryCategoriesTableTableManager(_db, _db.entryCategories);
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(_db, _db.paymentMethods);
  $$EntryFieldsTableTableManager get entryFields =>
      $$EntryFieldsTableTableManager(_db, _db.entryFields);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$EntryBillsTableTableManager get entryBills =>
      $$EntryBillsTableTableManager(_db, _db.entryBills);
  $$CashbookMembersTableTableManager get cashbookMembers =>
      $$CashbookMembersTableTableManager(_db, _db.cashbookMembers);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$RecurringOccurrencesTableTableManager get recurringOccurrences =>
      $$RecurringOccurrencesTableTableManager(_db, _db.recurringOccurrences);
  $$InboxItemsTableTableManager get inboxItems =>
      $$InboxItemsTableTableManager(_db, _db.inboxItems);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$BillQueueTableTableManager get billQueue =>
      $$BillQueueTableTableManager(_db, _db.billQueue);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncFailuresTableTableManager get syncFailures =>
      $$SyncFailuresTableTableManager(_db, _db.syncFailures);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
