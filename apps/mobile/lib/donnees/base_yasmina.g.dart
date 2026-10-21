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

class ResultatsExercices extends Table
    with TableInfo<ResultatsExercices, ResultatExercice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ResultatsExercices(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _etapeIdMeta = const VerificationMeta(
    'etapeId',
  );
  late final GeneratedColumn<String> etapeId = GeneratedColumn<String>(
    'etape_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sequenceIdMeta = const VerificationMeta(
    'sequenceId',
  );
  late final GeneratedColumn<String> sequenceId = GeneratedColumn<String>(
    'sequence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _exerciceIdMeta = const VerificationMeta(
    'exerciceId',
  );
  late final GeneratedColumn<String> exerciceId = GeneratedColumn<String>(
    'exercice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _essaisMeta = const VerificationMeta('essais');
  late final GeneratedColumn<int> essais = GeneratedColumn<int>(
    'essais',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (essais >= 0)',
  );
  static const VerificationMeta _reussiMeta = const VerificationMeta('reussi');
  late final GeneratedColumn<bool> reussi = GeneratedColumn<bool>(
    'reussi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _reveleMeta = const VerificationMeta('revele');
  late final GeneratedColumn<bool> revele = GeneratedColumn<bool>(
    'revele',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _joueLeMeta = const VerificationMeta('joueLe');
  late final GeneratedColumn<DateTime> joueLe = GeneratedColumn<DateTime>(
    'joue_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profilId,
    etapeId,
    sequenceId,
    exerciceId,
    essais,
    reussi,
    revele,
    joueLe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resultats_exercices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResultatExercice> instance, {
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
    if (data.containsKey('etape_id')) {
      context.handle(
        _etapeIdMeta,
        etapeId.isAcceptableOrUnknown(data['etape_id']!, _etapeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_etapeIdMeta);
    }
    if (data.containsKey('sequence_id')) {
      context.handle(
        _sequenceIdMeta,
        sequenceId.isAcceptableOrUnknown(data['sequence_id']!, _sequenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceIdMeta);
    }
    if (data.containsKey('exercice_id')) {
      context.handle(
        _exerciceIdMeta,
        exerciceId.isAcceptableOrUnknown(data['exercice_id']!, _exerciceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciceIdMeta);
    }
    if (data.containsKey('essais')) {
      context.handle(
        _essaisMeta,
        essais.isAcceptableOrUnknown(data['essais']!, _essaisMeta),
      );
    } else if (isInserting) {
      context.missing(_essaisMeta);
    }
    if (data.containsKey('reussi')) {
      context.handle(
        _reussiMeta,
        reussi.isAcceptableOrUnknown(data['reussi']!, _reussiMeta),
      );
    } else if (isInserting) {
      context.missing(_reussiMeta);
    }
    if (data.containsKey('revele')) {
      context.handle(
        _reveleMeta,
        revele.isAcceptableOrUnknown(data['revele']!, _reveleMeta),
      );
    } else if (isInserting) {
      context.missing(_reveleMeta);
    }
    if (data.containsKey('joue_le')) {
      context.handle(
        _joueLeMeta,
        joueLe.isAcceptableOrUnknown(data['joue_le']!, _joueLeMeta),
      );
    } else if (isInserting) {
      context.missing(_joueLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResultatExercice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResultatExercice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profilId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profil_id'],
      )!,
      etapeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etape_id'],
      )!,
      sequenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sequence_id'],
      )!,
      exerciceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercice_id'],
      )!,
      essais: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}essais'],
      )!,
      reussi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reussi'],
      )!,
      revele: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}revele'],
      )!,
      joueLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joue_le'],
      )!,
    );
  }

  @override
  ResultatsExercices createAlias(String alias) {
    return ResultatsExercices(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ResultatExercice extends DataClass
    implements Insertable<ResultatExercice> {
  final int id;
  final int profilId;
  final String etapeId;
  final String sequenceId;
  final String exerciceId;
  final int essais;
  final bool reussi;
  final bool revele;
  final DateTime joueLe;
  const ResultatExercice({
    required this.id,
    required this.profilId,
    required this.etapeId,
    required this.sequenceId,
    required this.exerciceId,
    required this.essais,
    required this.reussi,
    required this.revele,
    required this.joueLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profil_id'] = Variable<int>(profilId);
    map['etape_id'] = Variable<String>(etapeId);
    map['sequence_id'] = Variable<String>(sequenceId);
    map['exercice_id'] = Variable<String>(exerciceId);
    map['essais'] = Variable<int>(essais);
    map['reussi'] = Variable<bool>(reussi);
    map['revele'] = Variable<bool>(revele);
    map['joue_le'] = Variable<DateTime>(joueLe);
    return map;
  }

  ResultatsExercicesCompanion toCompanion(bool nullToAbsent) {
    return ResultatsExercicesCompanion(
      id: Value(id),
      profilId: Value(profilId),
      etapeId: Value(etapeId),
      sequenceId: Value(sequenceId),
      exerciceId: Value(exerciceId),
      essais: Value(essais),
      reussi: Value(reussi),
      revele: Value(revele),
      joueLe: Value(joueLe),
    );
  }

  factory ResultatExercice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResultatExercice(
      id: serializer.fromJson<int>(json['id']),
      profilId: serializer.fromJson<int>(json['profil_id']),
      etapeId: serializer.fromJson<String>(json['etape_id']),
      sequenceId: serializer.fromJson<String>(json['sequence_id']),
      exerciceId: serializer.fromJson<String>(json['exercice_id']),
      essais: serializer.fromJson<int>(json['essais']),
      reussi: serializer.fromJson<bool>(json['reussi']),
      revele: serializer.fromJson<bool>(json['revele']),
      joueLe: serializer.fromJson<DateTime>(json['joue_le']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profil_id': serializer.toJson<int>(profilId),
      'etape_id': serializer.toJson<String>(etapeId),
      'sequence_id': serializer.toJson<String>(sequenceId),
      'exercice_id': serializer.toJson<String>(exerciceId),
      'essais': serializer.toJson<int>(essais),
      'reussi': serializer.toJson<bool>(reussi),
      'revele': serializer.toJson<bool>(revele),
      'joue_le': serializer.toJson<DateTime>(joueLe),
    };
  }

  ResultatExercice copyWith({
    int? id,
    int? profilId,
    String? etapeId,
    String? sequenceId,
    String? exerciceId,
    int? essais,
    bool? reussi,
    bool? revele,
    DateTime? joueLe,
  }) => ResultatExercice(
    id: id ?? this.id,
    profilId: profilId ?? this.profilId,
    etapeId: etapeId ?? this.etapeId,
    sequenceId: sequenceId ?? this.sequenceId,
    exerciceId: exerciceId ?? this.exerciceId,
    essais: essais ?? this.essais,
    reussi: reussi ?? this.reussi,
    revele: revele ?? this.revele,
    joueLe: joueLe ?? this.joueLe,
  );
  ResultatExercice copyWithCompanion(ResultatsExercicesCompanion data) {
    return ResultatExercice(
      id: data.id.present ? data.id.value : this.id,
      profilId: data.profilId.present ? data.profilId.value : this.profilId,
      etapeId: data.etapeId.present ? data.etapeId.value : this.etapeId,
      sequenceId: data.sequenceId.present
          ? data.sequenceId.value
          : this.sequenceId,
      exerciceId: data.exerciceId.present
          ? data.exerciceId.value
          : this.exerciceId,
      essais: data.essais.present ? data.essais.value : this.essais,
      reussi: data.reussi.present ? data.reussi.value : this.reussi,
      revele: data.revele.present ? data.revele.value : this.revele,
      joueLe: data.joueLe.present ? data.joueLe.value : this.joueLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResultatExercice(')
          ..write('id: $id, ')
          ..write('profilId: $profilId, ')
          ..write('etapeId: $etapeId, ')
          ..write('sequenceId: $sequenceId, ')
          ..write('exerciceId: $exerciceId, ')
          ..write('essais: $essais, ')
          ..write('reussi: $reussi, ')
          ..write('revele: $revele, ')
          ..write('joueLe: $joueLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profilId,
    etapeId,
    sequenceId,
    exerciceId,
    essais,
    reussi,
    revele,
    joueLe,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResultatExercice &&
          other.id == this.id &&
          other.profilId == this.profilId &&
          other.etapeId == this.etapeId &&
          other.sequenceId == this.sequenceId &&
          other.exerciceId == this.exerciceId &&
          other.essais == this.essais &&
          other.reussi == this.reussi &&
          other.revele == this.revele &&
          other.joueLe == this.joueLe);
}

class ResultatsExercicesCompanion extends UpdateCompanion<ResultatExercice> {
  final Value<int> id;
  final Value<int> profilId;
  final Value<String> etapeId;
  final Value<String> sequenceId;
  final Value<String> exerciceId;
  final Value<int> essais;
  final Value<bool> reussi;
  final Value<bool> revele;
  final Value<DateTime> joueLe;
  const ResultatsExercicesCompanion({
    this.id = const Value.absent(),
    this.profilId = const Value.absent(),
    this.etapeId = const Value.absent(),
    this.sequenceId = const Value.absent(),
    this.exerciceId = const Value.absent(),
    this.essais = const Value.absent(),
    this.reussi = const Value.absent(),
    this.revele = const Value.absent(),
    this.joueLe = const Value.absent(),
  });
  ResultatsExercicesCompanion.insert({
    this.id = const Value.absent(),
    required int profilId,
    required String etapeId,
    required String sequenceId,
    required String exerciceId,
    required int essais,
    required bool reussi,
    required bool revele,
    required DateTime joueLe,
  }) : profilId = Value(profilId),
       etapeId = Value(etapeId),
       sequenceId = Value(sequenceId),
       exerciceId = Value(exerciceId),
       essais = Value(essais),
       reussi = Value(reussi),
       revele = Value(revele),
       joueLe = Value(joueLe);
  static Insertable<ResultatExercice> custom({
    Expression<int>? id,
    Expression<int>? profilId,
    Expression<String>? etapeId,
    Expression<String>? sequenceId,
    Expression<String>? exerciceId,
    Expression<int>? essais,
    Expression<bool>? reussi,
    Expression<bool>? revele,
    Expression<DateTime>? joueLe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profilId != null) 'profil_id': profilId,
      if (etapeId != null) 'etape_id': etapeId,
      if (sequenceId != null) 'sequence_id': sequenceId,
      if (exerciceId != null) 'exercice_id': exerciceId,
      if (essais != null) 'essais': essais,
      if (reussi != null) 'reussi': reussi,
      if (revele != null) 'revele': revele,
      if (joueLe != null) 'joue_le': joueLe,
    });
  }

  ResultatsExercicesCompanion copyWith({
    Value<int>? id,
    Value<int>? profilId,
    Value<String>? etapeId,
    Value<String>? sequenceId,
    Value<String>? exerciceId,
    Value<int>? essais,
    Value<bool>? reussi,
    Value<bool>? revele,
    Value<DateTime>? joueLe,
  }) {
    return ResultatsExercicesCompanion(
      id: id ?? this.id,
      profilId: profilId ?? this.profilId,
      etapeId: etapeId ?? this.etapeId,
      sequenceId: sequenceId ?? this.sequenceId,
      exerciceId: exerciceId ?? this.exerciceId,
      essais: essais ?? this.essais,
      reussi: reussi ?? this.reussi,
      revele: revele ?? this.revele,
      joueLe: joueLe ?? this.joueLe,
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
    if (etapeId.present) {
      map['etape_id'] = Variable<String>(etapeId.value);
    }
    if (sequenceId.present) {
      map['sequence_id'] = Variable<String>(sequenceId.value);
    }
    if (exerciceId.present) {
      map['exercice_id'] = Variable<String>(exerciceId.value);
    }
    if (essais.present) {
      map['essais'] = Variable<int>(essais.value);
    }
    if (reussi.present) {
      map['reussi'] = Variable<bool>(reussi.value);
    }
    if (revele.present) {
      map['revele'] = Variable<bool>(revele.value);
    }
    if (joueLe.present) {
      map['joue_le'] = Variable<DateTime>(joueLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResultatsExercicesCompanion(')
          ..write('id: $id, ')
          ..write('profilId: $profilId, ')
          ..write('etapeId: $etapeId, ')
          ..write('sequenceId: $sequenceId, ')
          ..write('exerciceId: $exerciceId, ')
          ..write('essais: $essais, ')
          ..write('reussi: $reussi, ')
          ..write('revele: $revele, ')
          ..write('joueLe: $joueLe')
          ..write(')'))
        .toString();
  }
}

class EtatsEtapes extends Table with TableInfo<EtatsEtapes, EtatEtapeProfil> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  EtatsEtapes(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _etapeIdMeta = const VerificationMeta(
    'etapeId',
  );
  late final GeneratedColumn<String> etapeId = GeneratedColumn<String>(
    'etape_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _faiteMeta = const VerificationMeta('faite');
  late final GeneratedColumn<bool> faite = GeneratedColumn<bool>(
    'faite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _indexRepriseMeta = const VerificationMeta(
    'indexReprise',
  );
  late final GeneratedColumn<int> indexReprise = GeneratedColumn<int>(
    'index_reprise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (index_reprise >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _reussisMeta = const VerificationMeta(
    'reussis',
  );
  late final GeneratedColumn<int> reussis = GeneratedColumn<int>(
    'reussis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (reussis >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (total >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _meilleursReussisMeta = const VerificationMeta(
    'meilleursReussis',
  );
  late final GeneratedColumn<int> meilleursReussis = GeneratedColumn<int>(
    'meilleurs_reussis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (meilleurs_reussis >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _commenceLeMeta = const VerificationMeta(
    'commenceLe',
  );
  late final GeneratedColumn<DateTime> commenceLe = GeneratedColumn<DateTime>(
    'commence_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _termineLeMeta = const VerificationMeta(
    'termineLe',
  );
  late final GeneratedColumn<DateTime> termineLe = GeneratedColumn<DateTime>(
    'termine_le',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
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
    profilId,
    etapeId,
    faite,
    indexReprise,
    reussis,
    total,
    meilleursReussis,
    commenceLe,
    termineLe,
    modifieLe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etats_etapes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EtatEtapeProfil> instance, {
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
    if (data.containsKey('etape_id')) {
      context.handle(
        _etapeIdMeta,
        etapeId.isAcceptableOrUnknown(data['etape_id']!, _etapeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_etapeIdMeta);
    }
    if (data.containsKey('faite')) {
      context.handle(
        _faiteMeta,
        faite.isAcceptableOrUnknown(data['faite']!, _faiteMeta),
      );
    }
    if (data.containsKey('index_reprise')) {
      context.handle(
        _indexRepriseMeta,
        indexReprise.isAcceptableOrUnknown(
          data['index_reprise']!,
          _indexRepriseMeta,
        ),
      );
    }
    if (data.containsKey('reussis')) {
      context.handle(
        _reussisMeta,
        reussis.isAcceptableOrUnknown(data['reussis']!, _reussisMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('meilleurs_reussis')) {
      context.handle(
        _meilleursReussisMeta,
        meilleursReussis.isAcceptableOrUnknown(
          data['meilleurs_reussis']!,
          _meilleursReussisMeta,
        ),
      );
    }
    if (data.containsKey('commence_le')) {
      context.handle(
        _commenceLeMeta,
        commenceLe.isAcceptableOrUnknown(data['commence_le']!, _commenceLeMeta),
      );
    } else if (isInserting) {
      context.missing(_commenceLeMeta);
    }
    if (data.containsKey('termine_le')) {
      context.handle(
        _termineLeMeta,
        termineLe.isAcceptableOrUnknown(data['termine_le']!, _termineLeMeta),
      );
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
  EtatEtapeProfil map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EtatEtapeProfil(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profilId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profil_id'],
      )!,
      etapeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etape_id'],
      )!,
      faite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}faite'],
      )!,
      indexReprise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}index_reprise'],
      )!,
      reussis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reussis'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      meilleursReussis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meilleurs_reussis'],
      )!,
      commenceLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}commence_le'],
      )!,
      termineLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}termine_le'],
      ),
      modifieLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modifie_le'],
      )!,
    );
  }

  @override
  EtatsEtapes createAlias(String alias) {
    return EtatsEtapes(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class EtatEtapeProfil extends DataClass implements Insertable<EtatEtapeProfil> {
  final int id;
  final int profilId;
  final String etapeId;
  final bool faite;
  final int indexReprise;
  final int reussis;
  final int total;
  final int meilleursReussis;
  final DateTime commenceLe;
  final DateTime? termineLe;
  final DateTime modifieLe;
  const EtatEtapeProfil({
    required this.id,
    required this.profilId,
    required this.etapeId,
    required this.faite,
    required this.indexReprise,
    required this.reussis,
    required this.total,
    required this.meilleursReussis,
    required this.commenceLe,
    this.termineLe,
    required this.modifieLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profil_id'] = Variable<int>(profilId);
    map['etape_id'] = Variable<String>(etapeId);
    map['faite'] = Variable<bool>(faite);
    map['index_reprise'] = Variable<int>(indexReprise);
    map['reussis'] = Variable<int>(reussis);
    map['total'] = Variable<int>(total);
    map['meilleurs_reussis'] = Variable<int>(meilleursReussis);
    map['commence_le'] = Variable<DateTime>(commenceLe);
    if (!nullToAbsent || termineLe != null) {
      map['termine_le'] = Variable<DateTime>(termineLe);
    }
    map['modifie_le'] = Variable<DateTime>(modifieLe);
    return map;
  }

  EtatsEtapesCompanion toCompanion(bool nullToAbsent) {
    return EtatsEtapesCompanion(
      id: Value(id),
      profilId: Value(profilId),
      etapeId: Value(etapeId),
      faite: Value(faite),
      indexReprise: Value(indexReprise),
      reussis: Value(reussis),
      total: Value(total),
      meilleursReussis: Value(meilleursReussis),
      commenceLe: Value(commenceLe),
      termineLe: termineLe == null && nullToAbsent
          ? const Value.absent()
          : Value(termineLe),
      modifieLe: Value(modifieLe),
    );
  }

  factory EtatEtapeProfil.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EtatEtapeProfil(
      id: serializer.fromJson<int>(json['id']),
      profilId: serializer.fromJson<int>(json['profil_id']),
      etapeId: serializer.fromJson<String>(json['etape_id']),
      faite: serializer.fromJson<bool>(json['faite']),
      indexReprise: serializer.fromJson<int>(json['index_reprise']),
      reussis: serializer.fromJson<int>(json['reussis']),
      total: serializer.fromJson<int>(json['total']),
      meilleursReussis: serializer.fromJson<int>(json['meilleurs_reussis']),
      commenceLe: serializer.fromJson<DateTime>(json['commence_le']),
      termineLe: serializer.fromJson<DateTime?>(json['termine_le']),
      modifieLe: serializer.fromJson<DateTime>(json['modifie_le']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profil_id': serializer.toJson<int>(profilId),
      'etape_id': serializer.toJson<String>(etapeId),
      'faite': serializer.toJson<bool>(faite),
      'index_reprise': serializer.toJson<int>(indexReprise),
      'reussis': serializer.toJson<int>(reussis),
      'total': serializer.toJson<int>(total),
      'meilleurs_reussis': serializer.toJson<int>(meilleursReussis),
      'commence_le': serializer.toJson<DateTime>(commenceLe),
      'termine_le': serializer.toJson<DateTime?>(termineLe),
      'modifie_le': serializer.toJson<DateTime>(modifieLe),
    };
  }

  EtatEtapeProfil copyWith({
    int? id,
    int? profilId,
    String? etapeId,
    bool? faite,
    int? indexReprise,
    int? reussis,
    int? total,
    int? meilleursReussis,
    DateTime? commenceLe,
    Value<DateTime?> termineLe = const Value.absent(),
    DateTime? modifieLe,
  }) => EtatEtapeProfil(
    id: id ?? this.id,
    profilId: profilId ?? this.profilId,
    etapeId: etapeId ?? this.etapeId,
    faite: faite ?? this.faite,
    indexReprise: indexReprise ?? this.indexReprise,
    reussis: reussis ?? this.reussis,
    total: total ?? this.total,
    meilleursReussis: meilleursReussis ?? this.meilleursReussis,
    commenceLe: commenceLe ?? this.commenceLe,
    termineLe: termineLe.present ? termineLe.value : this.termineLe,
    modifieLe: modifieLe ?? this.modifieLe,
  );
  EtatEtapeProfil copyWithCompanion(EtatsEtapesCompanion data) {
    return EtatEtapeProfil(
      id: data.id.present ? data.id.value : this.id,
      profilId: data.profilId.present ? data.profilId.value : this.profilId,
      etapeId: data.etapeId.present ? data.etapeId.value : this.etapeId,
      faite: data.faite.present ? data.faite.value : this.faite,
      indexReprise: data.indexReprise.present
          ? data.indexReprise.value
          : this.indexReprise,
      reussis: data.reussis.present ? data.reussis.value : this.reussis,
      total: data.total.present ? data.total.value : this.total,
      meilleursReussis: data.meilleursReussis.present
          ? data.meilleursReussis.value
          : this.meilleursReussis,
      commenceLe: data.commenceLe.present
          ? data.commenceLe.value
          : this.commenceLe,
      termineLe: data.termineLe.present ? data.termineLe.value : this.termineLe,
      modifieLe: data.modifieLe.present ? data.modifieLe.value : this.modifieLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EtatEtapeProfil(')
          ..write('id: $id, ')
          ..write('profilId: $profilId, ')
          ..write('etapeId: $etapeId, ')
          ..write('faite: $faite, ')
          ..write('indexReprise: $indexReprise, ')
          ..write('reussis: $reussis, ')
          ..write('total: $total, ')
          ..write('meilleursReussis: $meilleursReussis, ')
          ..write('commenceLe: $commenceLe, ')
          ..write('termineLe: $termineLe, ')
          ..write('modifieLe: $modifieLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profilId,
    etapeId,
    faite,
    indexReprise,
    reussis,
    total,
    meilleursReussis,
    commenceLe,
    termineLe,
    modifieLe,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EtatEtapeProfil &&
          other.id == this.id &&
          other.profilId == this.profilId &&
          other.etapeId == this.etapeId &&
          other.faite == this.faite &&
          other.indexReprise == this.indexReprise &&
          other.reussis == this.reussis &&
          other.total == this.total &&
          other.meilleursReussis == this.meilleursReussis &&
          other.commenceLe == this.commenceLe &&
          other.termineLe == this.termineLe &&
          other.modifieLe == this.modifieLe);
}

class EtatsEtapesCompanion extends UpdateCompanion<EtatEtapeProfil> {
  final Value<int> id;
  final Value<int> profilId;
  final Value<String> etapeId;
  final Value<bool> faite;
  final Value<int> indexReprise;
  final Value<int> reussis;
  final Value<int> total;
  final Value<int> meilleursReussis;
  final Value<DateTime> commenceLe;
  final Value<DateTime?> termineLe;
  final Value<DateTime> modifieLe;
  const EtatsEtapesCompanion({
    this.id = const Value.absent(),
    this.profilId = const Value.absent(),
    this.etapeId = const Value.absent(),
    this.faite = const Value.absent(),
    this.indexReprise = const Value.absent(),
    this.reussis = const Value.absent(),
    this.total = const Value.absent(),
    this.meilleursReussis = const Value.absent(),
    this.commenceLe = const Value.absent(),
    this.termineLe = const Value.absent(),
    this.modifieLe = const Value.absent(),
  });
  EtatsEtapesCompanion.insert({
    this.id = const Value.absent(),
    required int profilId,
    required String etapeId,
    this.faite = const Value.absent(),
    this.indexReprise = const Value.absent(),
    this.reussis = const Value.absent(),
    this.total = const Value.absent(),
    this.meilleursReussis = const Value.absent(),
    required DateTime commenceLe,
    this.termineLe = const Value.absent(),
    required DateTime modifieLe,
  }) : profilId = Value(profilId),
       etapeId = Value(etapeId),
       commenceLe = Value(commenceLe),
       modifieLe = Value(modifieLe);
  static Insertable<EtatEtapeProfil> custom({
    Expression<int>? id,
    Expression<int>? profilId,
    Expression<String>? etapeId,
    Expression<bool>? faite,
    Expression<int>? indexReprise,
    Expression<int>? reussis,
    Expression<int>? total,
    Expression<int>? meilleursReussis,
    Expression<DateTime>? commenceLe,
    Expression<DateTime>? termineLe,
    Expression<DateTime>? modifieLe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profilId != null) 'profil_id': profilId,
      if (etapeId != null) 'etape_id': etapeId,
      if (faite != null) 'faite': faite,
      if (indexReprise != null) 'index_reprise': indexReprise,
      if (reussis != null) 'reussis': reussis,
      if (total != null) 'total': total,
      if (meilleursReussis != null) 'meilleurs_reussis': meilleursReussis,
      if (commenceLe != null) 'commence_le': commenceLe,
      if (termineLe != null) 'termine_le': termineLe,
      if (modifieLe != null) 'modifie_le': modifieLe,
    });
  }

  EtatsEtapesCompanion copyWith({
    Value<int>? id,
    Value<int>? profilId,
    Value<String>? etapeId,
    Value<bool>? faite,
    Value<int>? indexReprise,
    Value<int>? reussis,
    Value<int>? total,
    Value<int>? meilleursReussis,
    Value<DateTime>? commenceLe,
    Value<DateTime?>? termineLe,
    Value<DateTime>? modifieLe,
  }) {
    return EtatsEtapesCompanion(
      id: id ?? this.id,
      profilId: profilId ?? this.profilId,
      etapeId: etapeId ?? this.etapeId,
      faite: faite ?? this.faite,
      indexReprise: indexReprise ?? this.indexReprise,
      reussis: reussis ?? this.reussis,
      total: total ?? this.total,
      meilleursReussis: meilleursReussis ?? this.meilleursReussis,
      commenceLe: commenceLe ?? this.commenceLe,
      termineLe: termineLe ?? this.termineLe,
      modifieLe: modifieLe ?? this.modifieLe,
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
    if (etapeId.present) {
      map['etape_id'] = Variable<String>(etapeId.value);
    }
    if (faite.present) {
      map['faite'] = Variable<bool>(faite.value);
    }
    if (indexReprise.present) {
      map['index_reprise'] = Variable<int>(indexReprise.value);
    }
    if (reussis.present) {
      map['reussis'] = Variable<int>(reussis.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (meilleursReussis.present) {
      map['meilleurs_reussis'] = Variable<int>(meilleursReussis.value);
    }
    if (commenceLe.present) {
      map['commence_le'] = Variable<DateTime>(commenceLe.value);
    }
    if (termineLe.present) {
      map['termine_le'] = Variable<DateTime>(termineLe.value);
    }
    if (modifieLe.present) {
      map['modifie_le'] = Variable<DateTime>(modifieLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtatsEtapesCompanion(')
          ..write('id: $id, ')
          ..write('profilId: $profilId, ')
          ..write('etapeId: $etapeId, ')
          ..write('faite: $faite, ')
          ..write('indexReprise: $indexReprise, ')
          ..write('reussis: $reussis, ')
          ..write('total: $total, ')
          ..write('meilleursReussis: $meilleursReussis, ')
          ..write('commenceLe: $commenceLe, ')
          ..write('termineLe: $termineLe, ')
          ..write('modifieLe: $modifieLe')
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
  late final ResultatsExercices resultatsExercices = ResultatsExercices(this);
  late final Index resultatsExercicesUnique = Index(
    'resultats_exercices_unique',
    'CREATE UNIQUE INDEX resultats_exercices_unique ON resultats_exercices (profil_id, exercice_id)',
  );
  late final Index resultatsExercicesEtape = Index(
    'resultats_exercices_etape',
    'CREATE INDEX resultats_exercices_etape ON resultats_exercices (profil_id, etape_id)',
  );
  late final EtatsEtapes etatsEtapes = EtatsEtapes(this);
  late final Index etatsEtapesUnique = Index(
    'etats_etapes_unique',
    'CREATE UNIQUE INDEX etats_etapes_unique ON etats_etapes (profil_id, etape_id)',
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
    resultatsExercices,
    resultatsExercicesUnique,
    resultatsExercicesEtape,
    etatsEtapes,
    etatsEtapesUnique,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profils',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resultats_exercices', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profils',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('etats_etapes', kind: UpdateKind.delete)],
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

  static MultiTypedResultKey<ResultatsExercices, List<ResultatExercice>>
  _resultatsExercicesRefsTable(_$BaseYasmina db) =>
      MultiTypedResultKey.fromTable(
        db.resultatsExercices,
        aliasName: 'profils__id__resultats_exercices__profil_id',
      );

  $ResultatsExercicesProcessedTableManager get resultatsExercicesRefs {
    final manager = $ResultatsExercicesTableManager(
      $_db,
      $_db.resultatsExercices,
    ).filter((f) => f.profilId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _resultatsExercicesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<EtatsEtapes, List<EtatEtapeProfil>>
  _etatsEtapesRefsTable(_$BaseYasmina db) => MultiTypedResultKey.fromTable(
    db.etatsEtapes,
    aliasName: 'profils__id__etats_etapes__profil_id',
  );

  $EtatsEtapesProcessedTableManager get etatsEtapesRefs {
    final manager = $EtatsEtapesTableManager(
      $_db,
      $_db.etatsEtapes,
    ).filter((f) => f.profilId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_etatsEtapesRefsTable($_db));
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

  Expression<bool> resultatsExercicesRefs(
    Expression<bool> Function($ResultatsExercicesFilterComposer f) f,
  ) {
    final $ResultatsExercicesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resultatsExercices,
      getReferencedColumn: (t) => t.profilId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ResultatsExercicesFilterComposer(
            $db: $db,
            $table: $db.resultatsExercices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> etatsEtapesRefs(
    Expression<bool> Function($EtatsEtapesFilterComposer f) f,
  ) {
    final $EtatsEtapesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.etatsEtapes,
      getReferencedColumn: (t) => t.profilId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EtatsEtapesFilterComposer(
            $db: $db,
            $table: $db.etatsEtapes,
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

  Expression<T> resultatsExercicesRefs<T extends Object>(
    Expression<T> Function($ResultatsExercicesAnnotationComposer a) f,
  ) {
    final $ResultatsExercicesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resultatsExercices,
      getReferencedColumn: (t) => t.profilId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ResultatsExercicesAnnotationComposer(
            $db: $db,
            $table: $db.resultatsExercices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> etatsEtapesRefs<T extends Object>(
    Expression<T> Function($EtatsEtapesAnnotationComposer a) f,
  ) {
    final $EtatsEtapesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.etatsEtapes,
      getReferencedColumn: (t) => t.profilId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EtatsEtapesAnnotationComposer(
            $db: $db,
            $table: $db.etatsEtapes,
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
          PrefetchHooks Function({
            bool historiqueNiveauxRefs,
            bool resultatsExercicesRefs,
            bool etatsEtapesRefs,
          })
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
          prefetchHooksCallback:
              ({
                historiqueNiveauxRefs = false,
                resultatsExercicesRefs = false,
                etatsEtapesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (historiqueNiveauxRefs) db.historiqueNiveaux,
                    if (resultatsExercicesRefs) db.resultatsExercices,
                    if (etatsEtapesRefs) db.etatsEtapes,
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profilId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resultatsExercicesRefs)
                        await $_getPrefetchedData<
                          ProfilEnfant,
                          Profils,
                          ResultatExercice
                        >(
                          currentTable: table,
                          referencedTable: $ProfilsReferences
                              ._resultatsExercicesRefsTable(db),
                          managerFromTypedResult: (p0) => $ProfilsReferences(
                            db,
                            table,
                            p0,
                          ).resultatsExercicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profilId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (etatsEtapesRefs)
                        await $_getPrefetchedData<
                          ProfilEnfant,
                          Profils,
                          EtatEtapeProfil
                        >(
                          currentTable: table,
                          referencedTable: $ProfilsReferences
                              ._etatsEtapesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ProfilsReferences(db, table, p0).etatsEtapesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profilId == item.id,
                              ),
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
      PrefetchHooks Function({
        bool historiqueNiveauxRefs,
        bool resultatsExercicesRefs,
        bool etatsEtapesRefs,
      })
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
typedef $ResultatsExercicesCreateCompanionBuilder =
    ResultatsExercicesCompanion Function({
      Value<int> id,
      required int profilId,
      required String etapeId,
      required String sequenceId,
      required String exerciceId,
      required int essais,
      required bool reussi,
      required bool revele,
      required DateTime joueLe,
    });
typedef $ResultatsExercicesUpdateCompanionBuilder =
    ResultatsExercicesCompanion Function({
      Value<int> id,
      Value<int> profilId,
      Value<String> etapeId,
      Value<String> sequenceId,
      Value<String> exerciceId,
      Value<int> essais,
      Value<bool> reussi,
      Value<bool> revele,
      Value<DateTime> joueLe,
    });

final class $ResultatsExercicesReferences
    extends
        BaseReferences<_$BaseYasmina, ResultatsExercices, ResultatExercice> {
  $ResultatsExercicesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Profils _profilIdTable(_$BaseYasmina db) =>
      db.profils.createAlias('resultats_exercices__profil_id__profils__id');

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

class $ResultatsExercicesFilterComposer
    extends Composer<_$BaseYasmina, ResultatsExercices> {
  $ResultatsExercicesFilterComposer({
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

  ColumnFilters<String> get etapeId => $composableBuilder(
    column: $table.etapeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sequenceId => $composableBuilder(
    column: $table.sequenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciceId => $composableBuilder(
    column: $table.exerciceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get essais => $composableBuilder(
    column: $table.essais,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reussi => $composableBuilder(
    column: $table.reussi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get revele => $composableBuilder(
    column: $table.revele,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joueLe => $composableBuilder(
    column: $table.joueLe,
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

class $ResultatsExercicesOrderingComposer
    extends Composer<_$BaseYasmina, ResultatsExercices> {
  $ResultatsExercicesOrderingComposer({
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

  ColumnOrderings<String> get etapeId => $composableBuilder(
    column: $table.etapeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sequenceId => $composableBuilder(
    column: $table.sequenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciceId => $composableBuilder(
    column: $table.exerciceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get essais => $composableBuilder(
    column: $table.essais,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reussi => $composableBuilder(
    column: $table.reussi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get revele => $composableBuilder(
    column: $table.revele,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joueLe => $composableBuilder(
    column: $table.joueLe,
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

class $ResultatsExercicesAnnotationComposer
    extends Composer<_$BaseYasmina, ResultatsExercices> {
  $ResultatsExercicesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get etapeId =>
      $composableBuilder(column: $table.etapeId, builder: (column) => column);

  GeneratedColumn<String> get sequenceId => $composableBuilder(
    column: $table.sequenceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciceId => $composableBuilder(
    column: $table.exerciceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get essais =>
      $composableBuilder(column: $table.essais, builder: (column) => column);

  GeneratedColumn<bool> get reussi =>
      $composableBuilder(column: $table.reussi, builder: (column) => column);

  GeneratedColumn<bool> get revele =>
      $composableBuilder(column: $table.revele, builder: (column) => column);

  GeneratedColumn<DateTime> get joueLe =>
      $composableBuilder(column: $table.joueLe, builder: (column) => column);

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

class $ResultatsExercicesTableManager
    extends
        RootTableManager<
          _$BaseYasmina,
          ResultatsExercices,
          ResultatExercice,
          $ResultatsExercicesFilterComposer,
          $ResultatsExercicesOrderingComposer,
          $ResultatsExercicesAnnotationComposer,
          $ResultatsExercicesCreateCompanionBuilder,
          $ResultatsExercicesUpdateCompanionBuilder,
          (ResultatExercice, $ResultatsExercicesReferences),
          ResultatExercice,
          PrefetchHooks Function({bool profilId})
        > {
  $ResultatsExercicesTableManager(_$BaseYasmina db, ResultatsExercices table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ResultatsExercicesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ResultatsExercicesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ResultatsExercicesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profilId = const Value.absent(),
                Value<String> etapeId = const Value.absent(),
                Value<String> sequenceId = const Value.absent(),
                Value<String> exerciceId = const Value.absent(),
                Value<int> essais = const Value.absent(),
                Value<bool> reussi = const Value.absent(),
                Value<bool> revele = const Value.absent(),
                Value<DateTime> joueLe = const Value.absent(),
              }) => ResultatsExercicesCompanion(
                id: id,
                profilId: profilId,
                etapeId: etapeId,
                sequenceId: sequenceId,
                exerciceId: exerciceId,
                essais: essais,
                reussi: reussi,
                revele: revele,
                joueLe: joueLe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profilId,
                required String etapeId,
                required String sequenceId,
                required String exerciceId,
                required int essais,
                required bool reussi,
                required bool revele,
                required DateTime joueLe,
              }) => ResultatsExercicesCompanion.insert(
                id: id,
                profilId: profilId,
                etapeId: etapeId,
                sequenceId: sequenceId,
                exerciceId: exerciceId,
                essais: essais,
                reussi: reussi,
                revele: revele,
                joueLe: joueLe,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ResultatsExercices, ResultatExercice>(table),
                  $ResultatsExercicesReferences(db, table, e),
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
                        referencedTable: $ResultatsExercicesReferences
                            ._profilIdTable(db),
                        referencedColumn: $ResultatsExercicesReferences
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

typedef $ResultatsExercicesProcessedTableManager =
    ProcessedTableManager<
      _$BaseYasmina,
      ResultatsExercices,
      ResultatExercice,
      $ResultatsExercicesFilterComposer,
      $ResultatsExercicesOrderingComposer,
      $ResultatsExercicesAnnotationComposer,
      $ResultatsExercicesCreateCompanionBuilder,
      $ResultatsExercicesUpdateCompanionBuilder,
      (ResultatExercice, $ResultatsExercicesReferences),
      ResultatExercice,
      PrefetchHooks Function({bool profilId})
    >;
typedef $EtatsEtapesCreateCompanionBuilder = EtatsEtapesCompanion Function({
  Value<int> id,
  required int profilId,
  required String etapeId,
  Value<bool> faite,
  Value<int> indexReprise,
  Value<int> reussis,
  Value<int> total,
  Value<int> meilleursReussis,
  required DateTime commenceLe,
  Value<DateTime?> termineLe,
  required DateTime modifieLe,
});
typedef $EtatsEtapesUpdateCompanionBuilder = EtatsEtapesCompanion Function({
  Value<int> id,
  Value<int> profilId,
  Value<String> etapeId,
  Value<bool> faite,
  Value<int> indexReprise,
  Value<int> reussis,
  Value<int> total,
  Value<int> meilleursReussis,
  Value<DateTime> commenceLe,
  Value<DateTime?> termineLe,
  Value<DateTime> modifieLe,
});

final class $EtatsEtapesReferences
    extends BaseReferences<_$BaseYasmina, EtatsEtapes, EtatEtapeProfil> {
  $EtatsEtapesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Profils _profilIdTable(_$BaseYasmina db) =>
      db.profils.createAlias('etats_etapes__profil_id__profils__id');

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

class $EtatsEtapesFilterComposer extends Composer<_$BaseYasmina, EtatsEtapes> {
  $EtatsEtapesFilterComposer({
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

  ColumnFilters<String> get etapeId => $composableBuilder(
    column: $table.etapeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get faite => $composableBuilder(
    column: $table.faite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indexReprise => $composableBuilder(
    column: $table.indexReprise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reussis => $composableBuilder(
    column: $table.reussis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get meilleursReussis => $composableBuilder(
    column: $table.meilleursReussis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get commenceLe => $composableBuilder(
    column: $table.commenceLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get termineLe => $composableBuilder(
    column: $table.termineLe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifieLe => $composableBuilder(
    column: $table.modifieLe,
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

class $EtatsEtapesOrderingComposer
    extends Composer<_$BaseYasmina, EtatsEtapes> {
  $EtatsEtapesOrderingComposer({
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

  ColumnOrderings<String> get etapeId => $composableBuilder(
    column: $table.etapeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get faite => $composableBuilder(
    column: $table.faite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indexReprise => $composableBuilder(
    column: $table.indexReprise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reussis => $composableBuilder(
    column: $table.reussis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get meilleursReussis => $composableBuilder(
    column: $table.meilleursReussis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get commenceLe => $composableBuilder(
    column: $table.commenceLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get termineLe => $composableBuilder(
    column: $table.termineLe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifieLe => $composableBuilder(
    column: $table.modifieLe,
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

class $EtatsEtapesAnnotationComposer
    extends Composer<_$BaseYasmina, EtatsEtapes> {
  $EtatsEtapesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get etapeId =>
      $composableBuilder(column: $table.etapeId, builder: (column) => column);

  GeneratedColumn<bool> get faite =>
      $composableBuilder(column: $table.faite, builder: (column) => column);

  GeneratedColumn<int> get indexReprise => $composableBuilder(
    column: $table.indexReprise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reussis =>
      $composableBuilder(column: $table.reussis, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get meilleursReussis => $composableBuilder(
    column: $table.meilleursReussis,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get commenceLe => $composableBuilder(
    column: $table.commenceLe,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get termineLe =>
      $composableBuilder(column: $table.termineLe, builder: (column) => column);

  GeneratedColumn<DateTime> get modifieLe =>
      $composableBuilder(column: $table.modifieLe, builder: (column) => column);

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

class $EtatsEtapesTableManager
    extends
        RootTableManager<
          _$BaseYasmina,
          EtatsEtapes,
          EtatEtapeProfil,
          $EtatsEtapesFilterComposer,
          $EtatsEtapesOrderingComposer,
          $EtatsEtapesAnnotationComposer,
          $EtatsEtapesCreateCompanionBuilder,
          $EtatsEtapesUpdateCompanionBuilder,
          (EtatEtapeProfil, $EtatsEtapesReferences),
          EtatEtapeProfil,
          PrefetchHooks Function({bool profilId})
        > {
  $EtatsEtapesTableManager(_$BaseYasmina db, EtatsEtapes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EtatsEtapesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EtatsEtapesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EtatsEtapesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profilId = const Value.absent(),
                Value<String> etapeId = const Value.absent(),
                Value<bool> faite = const Value.absent(),
                Value<int> indexReprise = const Value.absent(),
                Value<int> reussis = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> meilleursReussis = const Value.absent(),
                Value<DateTime> commenceLe = const Value.absent(),
                Value<DateTime?> termineLe = const Value.absent(),
                Value<DateTime> modifieLe = const Value.absent(),
              }) => EtatsEtapesCompanion(
                id: id,
                profilId: profilId,
                etapeId: etapeId,
                faite: faite,
                indexReprise: indexReprise,
                reussis: reussis,
                total: total,
                meilleursReussis: meilleursReussis,
                commenceLe: commenceLe,
                termineLe: termineLe,
                modifieLe: modifieLe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profilId,
                required String etapeId,
                Value<bool> faite = const Value.absent(),
                Value<int> indexReprise = const Value.absent(),
                Value<int> reussis = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> meilleursReussis = const Value.absent(),
                required DateTime commenceLe,
                Value<DateTime?> termineLe = const Value.absent(),
                required DateTime modifieLe,
              }) => EtatsEtapesCompanion.insert(
                id: id,
                profilId: profilId,
                etapeId: etapeId,
                faite: faite,
                indexReprise: indexReprise,
                reussis: reussis,
                total: total,
                meilleursReussis: meilleursReussis,
                commenceLe: commenceLe,
                termineLe: termineLe,
                modifieLe: modifieLe,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<EtatsEtapes, EtatEtapeProfil>(table),
                  $EtatsEtapesReferences(db, table, e),
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
                        referencedTable: $EtatsEtapesReferences._profilIdTable(
                          db,
                        ),
                        referencedColumn: $EtatsEtapesReferences
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

typedef $EtatsEtapesProcessedTableManager =
    ProcessedTableManager<
      _$BaseYasmina,
      EtatsEtapes,
      EtatEtapeProfil,
      $EtatsEtapesFilterComposer,
      $EtatsEtapesOrderingComposer,
      $EtatsEtapesAnnotationComposer,
      $EtatsEtapesCreateCompanionBuilder,
      $EtatsEtapesUpdateCompanionBuilder,
      (EtatEtapeProfil, $EtatsEtapesReferences),
      EtatEtapeProfil,
      PrefetchHooks Function({bool profilId})
    >;

class $BaseYasminaManager {
  final _$BaseYasmina _db;
  $BaseYasminaManager(this._db);
  $ProfilsTableManager get profils => $ProfilsTableManager(_db, _db.profils);
  $HistoriqueNiveauxTableManager get historiqueNiveaux =>
      $HistoriqueNiveauxTableManager(_db, _db.historiqueNiveaux);
  $ResultatsExercicesTableManager get resultatsExercices =>
      $ResultatsExercicesTableManager(_db, _db.resultatsExercices);
  $EtatsEtapesTableManager get etatsEtapes =>
      $EtatsEtapesTableManager(_db, _db.etatsEtapes);
}
