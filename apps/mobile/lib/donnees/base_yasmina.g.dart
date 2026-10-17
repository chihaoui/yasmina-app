// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_yasmina.dart';

// ignore_for_file: type=lint
class Profils extends Table with TableInfo<Profils, ProfilEnfant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Profils(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _prenomMeta = const VerificationMeta('prenom');
  late final GeneratedColumn<String> prenom = GeneratedColumn<String>(
    'prenom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL COLLATE NOCASE UNIQUE CHECK (length(prenom) BETWEEN 1 AND 20 AND prenom = trim(prenom))',
  );
  static const VerificationMeta _niveauMeta = const VerificationMeta('niveau');
  late final GeneratedColumn<int> niveau = GeneratedColumn<int>(
    'niveau',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (niveau BETWEEN 1 AND 6)',
  );
  late final GeneratedColumnWithTypeConverter<Avatar, String> avatar =
      GeneratedColumn<String>(
        'avatar',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Avatar>(Profils.$converteravatar);
  late final GeneratedColumnWithTypeConverter<FormeAdresse, String>
  formeAdresse = GeneratedColumn<String>(
    'forme_adresse',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  ).withConverter<FormeAdresse>(Profils.$converterformeAdresse);
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
    'cree_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _modifieLeMeta = const VerificationMeta(
    'modifieLe',
  );
  late final GeneratedColumn<DateTime> modifieLe = GeneratedColumn<DateTime>(
    'modifie_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    prenom,
    niveau,
    avatar,
    formeAdresse,
    creeLe,
    modifieLe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profils';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfilEnfant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prenom')) {
      context.handle(
        _prenomMeta,
        prenom.isAcceptableOrUnknown(data['prenom']!, _prenomMeta),
      );
    } else if (isInserting) {
      context.missing(_prenomMeta);
    }
    if (data.containsKey('niveau')) {
      context.handle(
        _niveauMeta,
        niveau.isAcceptableOrUnknown(data['niveau']!, _niveauMeta),
      );
    } else if (isInserting) {
      context.missing(_niveauMeta);
    }
    if (data.containsKey('cree_le')) {
      context.handle(
        _creeLeMeta,
        creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta),
      );
    } else if (isInserting) {
      context.missing(_creeLeMeta);
    }
    if (data.containsKey('modifie_le')) {
      context.handle(
        _modifieLeMeta,
        modifieLe.isAcceptableOrUnknown(data['modifie_le']!, _modifieLeMeta),
      );
    } else if (isInserting) {
      context.missing(_modifieLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfilEnfant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfilEnfant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      prenom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prenom'],
      )!,
      niveau: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}niveau'],
      )!,
      avatar: Profils.$converteravatar.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}avatar'],
        )!,
      ),
      formeAdresse: Profils.$converterformeAdresse.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forme_adresse'],
        )!,
      ),
      creeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cree_le'],
      )!,
      modifieLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modifie_le'],
      )!,
    );
  }

  @override
  Profils createAlias(String alias) {
    return Profils(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Avatar, String, String> $converteravatar =
      const EnumNameConverter<Avatar>(Avatar.values);
  static JsonTypeConverter2<FormeAdresse, String, String>
  $converterformeAdresse = const EnumNameConverter<FormeAdresse>(
    FormeAdresse.values,
  );
  @override
  bool get dontWriteConstraints => true;
}

class ProfilEnfant extends DataClass implements Insertable<ProfilEnfant> {
  final int id;
  final String prenom;
  final int niveau;
  final Avatar avatar;
  final FormeAdresse formeAdresse;
  final DateTime creeLe;
  final DateTime modifieLe;
  const ProfilEnfant({
    required this.id,
    required this.prenom,
    required this.niveau,
    required this.avatar,
    required this.formeAdresse,
    required this.creeLe,
    required this.modifieLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prenom'] = Variable<String>(prenom);
    map['niveau'] = Variable<int>(niveau);
    {
      map['avatar'] = Variable<String>(Profils.$converteravatar.toSql(avatar));
    }
    {
      map['forme_adresse'] = Variable<String>(
        Profils.$converterformeAdresse.toSql(formeAdresse),
      );
    }
    map['cree_le'] = Variable<DateTime>(creeLe);
    map['modifie_le'] = Variable<DateTime>(modifieLe);
    return map;
  }

  ProfilsCompanion toCompanion(bool nullToAbsent) {
    return ProfilsCompanion(
      id: Value(id),
      prenom: Value(prenom),
      niveau: Value(niveau),
      avatar: Value(avatar),
      formeAdresse: Value(formeAdresse),
      creeLe: Value(creeLe),
      modifieLe: Value(modifieLe),
    );
  }

  factory ProfilEnfant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfilEnfant(
      id: serializer.fromJson<int>(json['id']),
      prenom: serializer.fromJson<String>(json['prenom']),
      niveau: serializer.fromJson<int>(json['niveau']),
      avatar: Profils.$converteravatar.fromJson(
        serializer.fromJson<String>(json['avatar']),
      ),
      formeAdresse: Profils.$converterformeAdresse.fromJson(
        serializer.fromJson<String>(json['forme_adresse']),
      ),
      creeLe: serializer.fromJson<DateTime>(json['cree_le']),
      modifieLe: serializer.fromJson<DateTime>(json['modifie_le']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prenom': serializer.toJson<String>(prenom),
      'niveau': serializer.toJson<int>(niveau),
      'avatar': serializer.toJson<String>(
        Profils.$converteravatar.toJson(avatar),
      ),
      'forme_adresse': serializer.toJson<String>(
        Profils.$converterformeAdresse.toJson(formeAdresse),
      ),
      'cree_le': serializer.toJson<DateTime>(creeLe),
      'modifie_le': serializer.toJson<DateTime>(modifieLe),
    };
  }

  ProfilEnfant copyWith({
    int? id,
    String? prenom,
    int? niveau,
    Avatar? avatar,
    FormeAdresse? formeAdresse,
    DateTime? creeLe,
    DateTime? modifieLe,
  }) => ProfilEnfant(
    id: id ?? this.id,
    prenom: prenom ?? this.prenom,
    niveau: niveau ?? this.niveau,
    avatar: avatar ?? this.avatar,
    formeAdresse: formeAdresse ?? this.formeAdresse,
    creeLe: creeLe ?? this.creeLe,
    modifieLe: modifieLe ?? this.modifieLe,
  );
  ProfilEnfant copyWithCompanion(ProfilsCompanion data) {
    return ProfilEnfant(
      id: data.id.present ? data.id.value : this.id,
      prenom: data.prenom.present ? data.prenom.value : this.prenom,
      niveau: data.niveau.present ? data.niveau.value : this.niveau,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      formeAdresse: data.formeAdresse.present
          ? data.formeAdresse.value
          : this.formeAdresse,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
      modifieLe: data.modifieLe.present ? data.modifieLe.value : this.modifieLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfilEnfant(')
          ..write('id: $id, ')
          ..write('prenom: $prenom, ')
          ..write('niveau: $niveau, ')
          ..write('avatar: $avatar, ')
          ..write('formeAdresse: $formeAdresse, ')
          ..write('creeLe: $creeLe, ')
          ..write('modifieLe: $modifieLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, prenom, niveau, avatar, formeAdresse, creeLe, modifieLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfilEnfant &&
          other.id == this.id &&
          other.prenom == this.prenom &&
          other.niveau == this.niveau &&
          other.avatar == this.avatar &&
          other.formeAdresse == this.formeAdresse &&
          other.creeLe == this.creeLe &&
          other.modifieLe == this.modifieLe);
}

class ProfilsCompanion extends UpdateCompanion<ProfilEnfant> {
  final Value<int> id;
  final Value<String> prenom;
  final Value<int> niveau;
  final Value<Avatar> avatar;
  final Value<FormeAdresse> formeAdresse;
  final Value<DateTime> creeLe;
  final Value<DateTime> modifieLe;
  const ProfilsCompanion({
    this.id = const Value.absent(),
    this.prenom = const Value.absent(),
    this.niveau = const Value.absent(),
    this.avatar = const Value.absent(),
    this.formeAdresse = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.modifieLe = const Value.absent(),
  });
  ProfilsCompanion.insert({
    this.id = const Value.absent(),
    required String prenom,
    required int niveau,
    required Avatar avatar,
    required FormeAdresse formeAdresse,
    required DateTime creeLe,
    required DateTime modifieLe,
  }) : prenom = Value(prenom),
       niveau = Value(niveau),
       avatar = Value(avatar),
       formeAdresse = Value(formeAdresse),
       creeLe = Value(creeLe),
       modifieLe = Value(modifieLe);
  static Insertable<ProfilEnfant> custom({
    Expression<int>? id,
    Expression<String>? prenom,
    Expression<int>? niveau,
    Expression<String>? avatar,
    Expression<String>? formeAdresse,
    Expression<DateTime>? creeLe,
    Expression<DateTime>? modifieLe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prenom != null) 'prenom': prenom,
      if (niveau != null) 'niveau': niveau,
      if (avatar != null) 'avatar': avatar,
      if (formeAdresse != null) 'forme_adresse': formeAdresse,
      if (creeLe != null) 'cree_le': creeLe,
      if (modifieLe != null) 'modifie_le': modifieLe,
    });
  }

  ProfilsCompanion copyWith({
    Value<int>? id,
    Value<String>? prenom,
    Value<int>? niveau,
    Value<Avatar>? avatar,
    Value<FormeAdresse>? formeAdresse,
    Value<DateTime>? creeLe,
    Value<DateTime>? modifieLe,
  }) {
    return ProfilsCompanion(
      id: id ?? this.id,
      prenom: prenom ?? this.prenom,
      niveau: niveau ?? this.niveau,
      avatar: avatar ?? this.avatar,
      formeAdresse: formeAdresse ?? this.formeAdresse,
      creeLe: creeLe ?? this.creeLe,
      modifieLe: modifieLe ?? this.modifieLe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prenom.present) {
      map['prenom'] = Variable<String>(prenom.value);
    }
    if (niveau.present) {
      map['niveau'] = Variable<int>(niveau.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(
        Profils.$converteravatar.toSql(avatar.value),
      );
    }
    if (formeAdresse.present) {
      map['forme_adresse'] = Variable<String>(
        Profils.$converterformeAdresse.toSql(formeAdresse.value),
      );
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    if (modifieLe.present) {
      map['modifie_le'] = Variable<DateTime>(modifieLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilsCompanion(')
          ..write('id: $id, ')
          ..write('prenom: $prenom, ')
          ..write('niveau: $niveau, ')
          ..write('avatar: $avatar, ')
          ..write('formeAdresse: $formeAdresse, ')
          ..write('creeLe: $creeLe, ')
          ..write('modifieLe: $modifieLe')
          ..write(')'))
        .toString();
  }
}

class HistoriqueNiveaux extends Table
    with TableInfo<HistoriqueNiveaux, PeriodeNiveau> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  HistoriqueNiveaux(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _profilIdMeta = const VerificationMeta(
    'profilId',
  );
  late final GeneratedColumn<int> profilId = GeneratedColumn<int>(
    'profil_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profils(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _niveauMeta = const VerificationMeta('niveau');
  late final GeneratedColumn<int> niveau = GeneratedColumn<int>(
    'niveau',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (niveau BETWEEN 1 AND 6)',
  );
  static const VerificationMeta _debutMeta = const VerificationMeta('debut');
  late final GeneratedColumn<DateTime> debut = GeneratedColumn<DateTime>(
    'debut',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _finMeta = const VerificationMeta('fin');
  late final GeneratedColumn<DateTime> fin = GeneratedColumn<DateTime>(
    'fin',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [id, profilId, niveau, debut, fin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historique_niveaux';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodeNiveau> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profil_id')) {
      context.handle(
        _profilIdMeta,
        profilId.isAcceptableOrUnknown(data['profil_id']!, _profilIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profilIdMeta);
    }
    if (data.containsKey('niveau')) {
      context.handle(
        _niveauMeta,
        niveau.isAcceptableOrUnknown(data['niveau']!, _niveauMeta),
      );
    } else if (isInserting) {
      context.missing(_niveauMeta);
    }
    if (data.containsKey('debut')) {
      context.handle(
        _debutMeta,
        debut.isAcceptableOrUnknown(data['debut']!, _debutMeta),
      );
    } else if (isInserting) {
      context.missing(_debutMeta);
    }
    if (data.containsKey('fin')) {
      context.handle(
        _finMeta,
        fin.isAcceptableOrUnknown(data['fin']!, _finMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeriodeNiveau map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodeNiveau(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profilId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profil_id'],
      )!,
      niveau: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}niveau'],
      )!,
      debut: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}debut'],
      )!,
      fin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fin'],
      ),
    );
  }

  @override
  HistoriqueNiveaux createAlias(String alias) {
    return HistoriqueNiveaux(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PeriodeNiveau extends DataClass implements Insertable<PeriodeNiveau> {
  final int id;
  final int profilId;
  final int niveau;
  final DateTime debut;
  final DateTime? fin;
  const PeriodeNiveau({
    required this.id,
    required this.profilId,
    required this.niveau,
    required this.debut,
    this.fin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profil_id'] = Variable<int>(profilId);
    map['niveau'] = Variable<int>(niveau);
    map['debut'] = Variable<DateTime>(debut);
    if (!nullToAbsent || fin != null) {
      map['fin'] = Variable<DateTime>(fin);
    }
    return map;
  }

  HistoriqueNiveauxCompanion toCompanion(bool nullToAbsent) {
    return HistoriqueNiveauxCompanion(
      id: Value(id),
      profilId: Value(profilId),
      niveau: Value(niveau),
      debut: Value(debut),
      fin: fin == null && nullToAbsent ? const Value.absent() : Value(fin),
    );
  }

  factory PeriodeNiveau.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodeNiveau(
      id: serializer.fromJson<int>(json['id']),
      profilId: serializer.fromJson<int>(json['profil_id']),
      niveau: serializer.fromJson<int>(json['niveau']),
      debut: serializer.fromJson<DateTime>(json['debut']),
      fin: serializer.fromJson<DateTime?>(json['fin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profil_id': serializer.toJson<int>(profilId),
      'niveau': serializer.toJson<int>(niveau),
      'debut': serializer.toJson<DateTime>(debut),
      'fin': serializer.toJson<DateTime?>(fin),
    };
  }

  PeriodeNiveau copyWith({
    int? id,
    int? profilId,
    int? niveau,
    DateTime? debut,
    Value<DateTime?> fin = const Value.absent(),
  }) => PeriodeNiveau(
    id: id ?? this.id,
    profilId: profilId ?? this.profilId,
    niveau: niveau ?? this.niveau,
    debut: debut ?? this.debut,
    fin: fin.present ? fin.value : this.fin,
  );
  PeriodeNiveau copyWithCompanion(HistoriqueNiveauxCompanion data) {
    return PeriodeNiveau(
      id: data.id.present ? data.id.value : this.id,
      profilId: data.profilId.present ? data.profilId.value : this.profilId,
      niveau: data.niveau.present ? data.niveau.value : this.niveau,
      debut: data.debut.present ? data.debut.value : this.debut,
      fin: data.fin.present ? data.fin.value : this.fin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodeNiveau(')
          ..write('id: $id, ')
          ..write('profilId: $profilId, ')
          ..write('niveau: $niveau, ')
          ..write('debut: $debut, ')
          ..write('fin: $fin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, profilId, niveau, debut, fin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodeNiveau &&
          other.id == this.id &&
          other.profilId == this.profilId &&
          other.niveau == this.niveau &&
          other.debut == this.debut &&
          other.fin == this.fin);
}

class HistoriqueNiveauxCompanion extends UpdateCompanion<PeriodeNiveau> {
  final Value<int> id;
  final Value<int> profilId;
  final Value<int> niveau;
  final Value<DateTime> debut;
  final Value<DateTime?> fin;
  const HistoriqueNiveauxCompanion({
    this.id = const Value.absent(),
    this.profilId = const Value.absent(),
    this.niveau = const Value.absent(),
    this.debut = const Value.absent(),
    this.fin = const Value.absent(),
  });
  HistoriqueNiveauxCompanion.insert({
    this.id = const Value.absent(),
    required int profilId,
    required int niveau,
    required DateTime debut,
    this.fin = const Value.absent(),
  }) : profilId = Value(profilId),
       niveau = Value(niveau),
       debut = Value(debut);
  static Insertable<PeriodeNiveau> custom({
    Expression<int>? id,
    Expression<int>? profilId,
    Expression<int>? niveau,
    Expression<DateTime>? debut,
    Expression<DateTime>? fin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profilId != null) 'profil_id': profilId,
      if (niveau != null) 'niveau': niveau,
      if (debut != null) 'debut': debut,
      if (fin != null) 'fin': fin,
    });
  }

  HistoriqueNiveauxCompanion copyWith({
    Value<int>? id,
    Value<int>? profilId,
    Value<int>? niveau,
    Value<DateTime>? debut,
    Value<DateTime?>? fin,
  }) {
    return HistoriqueNiveauxCompanion(
      id: id ?? this.id,
      profilId: profilId ?? this.profilId,
      niveau: niveau ?? this.niveau,
      debut: debut ?? this.debut,
      fin: fin ?? this.fin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profilId.present) {
      map['profil_id'] = Variable<int>(profilId.value);
    }
    if (niveau.present) {
      map['niveau'] = Variable<int>(niveau.value);
    }
    if (debut.present) {
      map['debut'] = Variable<DateTime>(debut.value);
    }
    if (fin.present) {
      map['fin'] = Variable<DateTime>(fin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoriqueNiveauxCompanion(')
          ..write('id: $id, ')
          ..write('profilId: $profilId, ')
          ..write('niveau: $niveau, ')
          ..write('debut: $debut, ')
          ..write('fin: $fin')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseYasmina extends GeneratedDatabase {
  _$BaseYasmina(QueryExecutor e) : super(e);
  $BaseYasminaManager get managers => $BaseYasminaManager(this);
  late final Profils profils = Profils(this);
  late final HistoriqueNiveaux historiqueNiveaux = HistoriqueNiveaux(this);
  late final Index historiqueProfil = Index(
    'historique_profil',
    'CREATE INDEX historique_profil ON historique_niveaux (profil_id)',
  );
  late final Index historiqueUnSeulEnCours = Index(
    'historique_un_seul_en_cours',
    'CREATE UNIQUE INDEX historique_un_seul_en_cours ON historique_niveaux (profil_id) WHERE fin IS NULL',
  );
  late final Trigger limiteCinqProfils = Trigger(
    'CREATE TRIGGER limite_cinq_profils BEFORE INSERT ON profils WHEN (SELECT COUNT(*) FROM profils) >= 5 BEGIN SELECT RAISE (ABORT, \'limite_profils\');END',
    'limite_cinq_profils',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profils,
    historiqueNiveaux,
    historiqueProfil,
    historiqueUnSeulEnCours,
    limiteCinqProfils,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profils',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('historique_niveaux', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profils',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $ProfilsCreateCompanionBuilder = ProfilsCompanion Function({
  Value<int> id,
  required String prenom,
  required int niveau,
  required Avatar avatar,
  required FormeAdresse formeAdresse,
  required DateTime creeLe,
  required DateTime modifieLe,
});
typedef $ProfilsUpdateCompanionBuilder = ProfilsCompanion Function({
  Value<int> id,
  Value<String> prenom,
  Value<int> niveau,
  Value<Avatar> avatar,
  Value<FormeAdresse> formeAdresse,
  Value<DateTime> creeLe,
  Value<DateTime> modifieLe,
});

final class $ProfilsReferences
    extends BaseReferences<_$BaseYasmina, Profils, ProfilEnfant> {
  $ProfilsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<HistoriqueNiveaux, List<PeriodeNiveau>>
  _historiqueNiveauxRefsTable(_$BaseYasmina db) =>
      MultiTypedResultKey.fromTable(
        db.historiqueNiveaux,
        aliasName: 'profils__id__historique_niveaux__profil_id',
      );

  $HistoriqueNiveauxProcessedTableManager get historiqueNiveauxRefs {
    final manager = $HistoriqueNiveauxTableManager(
      $_db,
      $_db.historiqueNiveaux,
    ).filter((f) => f.profilId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historiqueNiveauxRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ProfilsFilterComposer extends Composer<_$BaseYasmina, Profils> {
  $ProfilsFilterComposer({
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

  ColumnFilters<String> get prenom => $composableBuilder(
    column: $table.prenom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get niveau => $composableBuilder(
    column: $table.niveau,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Avatar, Avatar, String> get avatar =>
      $composableBuilder(
        column: $table.avatar,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<FormeAdresse, FormeAdresse, String>
  get formeAdresse => $composableBuilder(
    column: $table.formeAdresse,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifieLe => $composableBuilder(
    column: $table.modifieLe,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> historiqueNiveauxRefs(
    Expression<bool> Function($HistoriqueNiveauxFilterComposer f) f,
  ) {
    final $HistoriqueNiveauxFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historiqueNiveaux,
      getReferencedColumn: (t) => t.profilId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HistoriqueNiveauxFilterComposer(
            $db: $db,
            $table: $db.historiqueNiveaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ProfilsOrderingComposer extends Composer<_$BaseYasmina, Profils> {
  $ProfilsOrderingComposer({
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

  ColumnOrderings<String> get prenom => $composableBuilder(
    column: $table.prenom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get niveau => $composableBuilder(
    column: $table.niveau,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formeAdresse => $composableBuilder(
    column: $table.formeAdresse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifieLe => $composableBuilder(
    column: $table.modifieLe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ProfilsAnnotationComposer extends Composer<_$BaseYasmina, Profils> {
  $ProfilsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prenom =>
      $composableBuilder(column: $table.prenom, builder: (column) => column);

  GeneratedColumn<int> get niveau =>
      $composableBuilder(column: $table.niveau, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Avatar, String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FormeAdresse, String> get formeAdresse =>
      $composableBuilder(
        column: $table.formeAdresse,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);

  GeneratedColumn<DateTime> get modifieLe =>
      $composableBuilder(column: $table.modifieLe, builder: (column) => column);

  Expression<T> historiqueNiveauxRefs<T extends Object>(
    Expression<T> Function($HistoriqueNiveauxAnnotationComposer a) f,
  ) {
    final $HistoriqueNiveauxAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historiqueNiveaux,
      getReferencedColumn: (t) => t.profilId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $HistoriqueNiveauxAnnotationComposer(
            $db: $db,
            $table: $db.historiqueNiveaux,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ProfilsTableManager
    extends
        RootTableManager<
          _$BaseYasmina,
          Profils,
          ProfilEnfant,
          $ProfilsFilterComposer,
          $ProfilsOrderingComposer,
          $ProfilsAnnotationComposer,
          $ProfilsCreateCompanionBuilder,
          $ProfilsUpdateCompanionBuilder,
          (ProfilEnfant, $ProfilsReferences),
          ProfilEnfant,
          PrefetchHooks Function({bool historiqueNiveauxRefs})
        > {
  $ProfilsTableManager(_$BaseYasmina db, Profils table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProfilsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProfilsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProfilsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> prenom = const Value.absent(),
                Value<int> niveau = const Value.absent(),
                Value<Avatar> avatar = const Value.absent(),
                Value<FormeAdresse> formeAdresse = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
                Value<DateTime> modifieLe = const Value.absent(),
              }) => ProfilsCompanion(
                id: id,
                prenom: prenom,
                niveau: niveau,
                avatar: avatar,
                formeAdresse: formeAdresse,
                creeLe: creeLe,
                modifieLe: modifieLe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String prenom,
                required int niveau,
                required Avatar avatar,
                required FormeAdresse formeAdresse,
                required DateTime creeLe,
                required DateTime modifieLe,
              }) => ProfilsCompanion.insert(
                id: id,
                prenom: prenom,
                niveau: niveau,
                avatar: avatar,
                formeAdresse: formeAdresse,
                creeLe: creeLe,
                modifieLe: modifieLe,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Profils, ProfilEnfant>(table),
                  $ProfilsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({historiqueNiveauxRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (historiqueNiveauxRefs) db.historiqueNiveaux,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (historiqueNiveauxRefs)
                    await $_getPrefetchedData<
                      ProfilEnfant,
                      Profils,
                      PeriodeNiveau
                    >(
                      currentTable: table,
                      referencedTable: $ProfilsReferences
                          ._historiqueNiveauxRefsTable(db),
                      managerFromTypedResult: (p0) => $ProfilsReferences(
                        db,
                        table,
                        p0,
                      ).historiqueNiveauxRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profilId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $ProfilsProcessedTableManager =
    ProcessedTableManager<
      _$BaseYasmina,
      Profils,
      ProfilEnfant,
      $ProfilsFilterComposer,
      $ProfilsOrderingComposer,
      $ProfilsAnnotationComposer,
      $ProfilsCreateCompanionBuilder,
      $ProfilsUpdateCompanionBuilder,
      (ProfilEnfant, $ProfilsReferences),
      ProfilEnfant,
      PrefetchHooks Function({bool historiqueNiveauxRefs})
    >;
typedef $HistoriqueNiveauxCreateCompanionBuilder =
    HistoriqueNiveauxCompanion Function({
      Value<int> id,
      required int profilId,
      required int niveau,
      required DateTime debut,
      Value<DateTime?> fin,
    });
typedef $HistoriqueNiveauxUpdateCompanionBuilder =
    HistoriqueNiveauxCompanion Function({
      Value<int> id,
      Value<int> profilId,
      Value<int> niveau,
      Value<DateTime> debut,
      Value<DateTime?> fin,
    });

final class $HistoriqueNiveauxReferences
    extends BaseReferences<_$BaseYasmina, HistoriqueNiveaux, PeriodeNiveau> {
  $HistoriqueNiveauxReferences(super.$_db, super.$_table, super.$_typedResult);

  static Profils _profilIdTable(_$BaseYasmina db) =>
      db.profils.createAlias('historique_niveaux__profil_id__profils__id');

  $ProfilsProcessedTableManager get profilId {
    final $_column = $_itemColumn<int>('profil_id')!;

    final manager = $ProfilsTableManager(
      $_db,
      $_db.profils,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profilIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $HistoriqueNiveauxFilterComposer
    extends Composer<_$BaseYasmina, HistoriqueNiveaux> {
  $HistoriqueNiveauxFilterComposer({
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

  ColumnFilters<int> get niveau => $composableBuilder(
    column: $table.niveau,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get debut => $composableBuilder(
    column: $table.debut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnFilters(column),
  );

  $ProfilsFilterComposer get profilId {
    final $ProfilsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profilId,
      referencedTable: $db.profils,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilsFilterComposer(
            $db: $db,
            $table: $db.profils,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $HistoriqueNiveauxOrderingComposer
    extends Composer<_$BaseYasmina, HistoriqueNiveaux> {
  $HistoriqueNiveauxOrderingComposer({
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

  ColumnOrderings<int> get niveau => $composableBuilder(
    column: $table.niveau,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get debut => $composableBuilder(
    column: $table.debut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnOrderings(column),
  );

  $ProfilsOrderingComposer get profilId {
    final $ProfilsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profilId,
      referencedTable: $db.profils,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilsOrderingComposer(
            $db: $db,
            $table: $db.profils,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $HistoriqueNiveauxAnnotationComposer
    extends Composer<_$BaseYasmina, HistoriqueNiveaux> {
  $HistoriqueNiveauxAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get niveau =>
      $composableBuilder(column: $table.niveau, builder: (column) => column);

  GeneratedColumn<DateTime> get debut =>
      $composableBuilder(column: $table.debut, builder: (column) => column);

  GeneratedColumn<DateTime> get fin =>
      $composableBuilder(column: $table.fin, builder: (column) => column);

  $ProfilsAnnotationComposer get profilId {
    final $ProfilsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profilId,
      referencedTable: $db.profils,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilsAnnotationComposer(
            $db: $db,
            $table: $db.profils,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $HistoriqueNiveauxTableManager
    extends
        RootTableManager<
          _$BaseYasmina,
          HistoriqueNiveaux,
          PeriodeNiveau,
          $HistoriqueNiveauxFilterComposer,
          $HistoriqueNiveauxOrderingComposer,
          $HistoriqueNiveauxAnnotationComposer,
          $HistoriqueNiveauxCreateCompanionBuilder,
          $HistoriqueNiveauxUpdateCompanionBuilder,
          (PeriodeNiveau, $HistoriqueNiveauxReferences),
          PeriodeNiveau,
          PrefetchHooks Function({bool profilId})
        > {
  $HistoriqueNiveauxTableManager(_$BaseYasmina db, HistoriqueNiveaux table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $HistoriqueNiveauxFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $HistoriqueNiveauxOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $HistoriqueNiveauxAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profilId = const Value.absent(),
                Value<int> niveau = const Value.absent(),
                Value<DateTime> debut = const Value.absent(),
                Value<DateTime?> fin = const Value.absent(),
              }) => HistoriqueNiveauxCompanion(
                id: id,
                profilId: profilId,
                niveau: niveau,
                debut: debut,
                fin: fin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profilId,
                required int niveau,
                required DateTime debut,
                Value<DateTime?> fin = const Value.absent(),
              }) => HistoriqueNiveauxCompanion.insert(
                id: id,
                profilId: profilId,
                niveau: niveau,
                debut: debut,
                fin: fin,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<HistoriqueNiveaux, PeriodeNiveau>(table),
                  $HistoriqueNiveauxReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profilId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profilId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profilId,
                        referencedTable: $HistoriqueNiveauxReferences
                            ._profilIdTable(db),
                        referencedColumn: $HistoriqueNiveauxReferences
                            ._profilIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $HistoriqueNiveauxProcessedTableManager =
    ProcessedTableManager<
      _$BaseYasmina,
      HistoriqueNiveaux,
      PeriodeNiveau,
      $HistoriqueNiveauxFilterComposer,
      $HistoriqueNiveauxOrderingComposer,
      $HistoriqueNiveauxAnnotationComposer,
      $HistoriqueNiveauxCreateCompanionBuilder,
      $HistoriqueNiveauxUpdateCompanionBuilder,
      (PeriodeNiveau, $HistoriqueNiveauxReferences),
      PeriodeNiveau,
      PrefetchHooks Function({bool profilId})
    >;

class $BaseYasminaManager {
  final _$BaseYasmina _db;
  $BaseYasminaManager(this._db);
  $ProfilsTableManager get profils => $ProfilsTableManager(_db, _db.profils);
  $HistoriqueNiveauxTableManager get historiqueNiveaux =>
      $HistoriqueNiveauxTableManager(_db, _db.historiqueNiveaux);
}
