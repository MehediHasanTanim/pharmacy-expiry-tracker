// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxIdMeta = const VerificationMeta('taxId');
  @override
  late final GeneratedColumn<String> taxId = GeneratedColumn<String>(
    'tax_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentTermsDaysMeta = const VerificationMeta(
    'paymentTermsDays',
  );
  @override
  late final GeneratedColumn<int> paymentTermsDays = GeneratedColumn<int>(
    'payment_terms_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    contactPerson,
    phone,
    email,
    address,
    taxId,
    paymentTermsDays,
    notes,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supplier> instance, {
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
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('tax_id')) {
      context.handle(
        _taxIdMeta,
        taxId.isAcceptableOrUnknown(data['tax_id']!, _taxIdMeta),
      );
    }
    if (data.containsKey('payment_terms_days')) {
      context.handle(
        _paymentTermsDaysMeta,
        paymentTermsDays.isAcceptableOrUnknown(
          data['payment_terms_days']!,
          _paymentTermsDaysMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      taxId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_id'],
      ),
      paymentTermsDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_terms_days'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final int? paymentTermsDays;
  final String? notes;
  final bool isArchived;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.paymentTermsDays,
    this.notes,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || taxId != null) {
      map['tax_id'] = Variable<String>(taxId);
    }
    if (!nullToAbsent || paymentTermsDays != null) {
      map['payment_terms_days'] = Variable<int>(paymentTermsDays);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      taxId: taxId == null && nullToAbsent
          ? const Value.absent()
          : Value(taxId),
      paymentTermsDays: paymentTermsDays == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentTermsDays),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Supplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      taxId: serializer.fromJson<String?>(json['taxId']),
      paymentTermsDays: serializer.fromJson<int?>(json['paymentTermsDays']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'taxId': serializer.toJson<String?>(taxId),
      'paymentTermsDays': serializer.toJson<int?>(paymentTermsDays),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    Value<String?> contactPerson = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> taxId = const Value.absent(),
    Value<int?> paymentTermsDays = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => Supplier(
    id: id ?? this.id,
    name: name ?? this.name,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    taxId: taxId.present ? taxId.value : this.taxId,
    paymentTermsDays: paymentTermsDays.present
        ? paymentTermsDays.value
        : this.paymentTermsDays,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      taxId: data.taxId.present ? data.taxId.value : this.taxId,
      paymentTermsDays: data.paymentTermsDays.present
          ? data.paymentTermsDays.value
          : this.paymentTermsDays,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('taxId: $taxId, ')
          ..write('paymentTermsDays: $paymentTermsDays, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    contactPerson,
    phone,
    email,
    address,
    taxId,
    paymentTermsDays,
    notes,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactPerson == this.contactPerson &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.taxId == this.taxId &&
          other.paymentTermsDays == this.paymentTermsDays &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> contactPerson;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> taxId;
  final Value<int?> paymentTermsDays;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.taxId = const Value.absent(),
    this.paymentTermsDays = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    this.contactPerson = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.taxId = const Value.absent(),
    this.paymentTermsDays = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Supplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contactPerson,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? taxId,
    Expression<int>? paymentTermsDays,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (taxId != null) 'tax_id': taxId,
      if (paymentTermsDays != null) 'payment_terms_days': paymentTermsDays,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? contactPerson,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? taxId,
    Value<int?>? paymentTermsDays,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      paymentTermsDays: paymentTermsDays ?? this.paymentTermsDays,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
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
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (taxId.present) {
      map['tax_id'] = Variable<String>(taxId.value);
    }
    if (paymentTermsDays.present) {
      map['payment_terms_days'] = Variable<int>(paymentTermsDays.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('taxId: $taxId, ')
          ..write('paymentTermsDays: $paymentTermsDays, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, Medicine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genericNameMeta = const VerificationMeta(
    'genericName',
  );
  @override
  late final GeneratedColumn<String> genericName = GeneratedColumn<String>(
    'generic_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
    'strength',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dosageFormMeta = const VerificationMeta(
    'dosageForm',
  );
  @override
  late final GeneratedColumn<String> dosageForm = GeneratedColumn<String>(
    'dosage_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('piece'),
  );
  static const VerificationMeta _packSizeMeta = const VerificationMeta(
    'packSize',
  );
  @override
  late final GeneratedColumn<int> packSize = GeneratedColumn<int>(
    'pack_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<int> reorderLevel = GeneratedColumn<int>(
    'reorder_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _preferredSupplierIdMeta =
      const VerificationMeta('preferredSupplierId');
  @override
  late final GeneratedColumn<String> preferredSupplierId =
      GeneratedColumn<String>(
        'preferred_supplier_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES suppliers (id)',
        ),
      );
  static const VerificationMeta _alertWindowDaysMeta = const VerificationMeta(
    'alertWindowDays',
  );
  @override
  late final GeneratedColumn<int> alertWindowDays = GeneratedColumn<int>(
    'alert_window_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storageConditionMeta = const VerificationMeta(
    'storageCondition',
  );
  @override
  late final GeneratedColumn<String> storageCondition = GeneratedColumn<String>(
    'storage_condition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    brandName,
    genericName,
    strength,
    dosageForm,
    unit,
    packSize,
    manufacturer,
    category,
    reorderLevel,
    preferredSupplierId,
    alertWindowDays,
    storageCondition,
    notes,
    isArchived,
    searchText,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medicine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    } else if (isInserting) {
      context.missing(_brandNameMeta);
    }
    if (data.containsKey('generic_name')) {
      context.handle(
        _genericNameMeta,
        genericName.isAcceptableOrUnknown(
          data['generic_name']!,
          _genericNameMeta,
        ),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('dosage_form')) {
      context.handle(
        _dosageFormMeta,
        dosageForm.isAcceptableOrUnknown(data['dosage_form']!, _dosageFormMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('pack_size')) {
      context.handle(
        _packSizeMeta,
        packSize.isAcceptableOrUnknown(data['pack_size']!, _packSizeMeta),
      );
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    if (data.containsKey('preferred_supplier_id')) {
      context.handle(
        _preferredSupplierIdMeta,
        preferredSupplierId.isAcceptableOrUnknown(
          data['preferred_supplier_id']!,
          _preferredSupplierIdMeta,
        ),
      );
    }
    if (data.containsKey('alert_window_days')) {
      context.handle(
        _alertWindowDaysMeta,
        alertWindowDays.isAcceptableOrUnknown(
          data['alert_window_days']!,
          _alertWindowDaysMeta,
        ),
      );
    }
    if (data.containsKey('storage_condition')) {
      context.handle(
        _storageConditionMeta,
        storageCondition.isAcceptableOrUnknown(
          data['storage_condition']!,
          _storageConditionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medicine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medicine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      )!,
      genericName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generic_name'],
      ),
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength'],
      ),
      dosageForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage_form'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      packSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pack_size'],
      ),
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reorder_level'],
      )!,
      preferredSupplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_supplier_id'],
      ),
      alertWindowDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}alert_window_days'],
      ),
      storageCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_condition'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }
}

class Medicine extends DataClass implements Insertable<Medicine> {
  final String id;
  final String brandName;
  final String? genericName;
  final String? strength;
  final String dosageForm;
  final String unit;
  final int? packSize;
  final String? manufacturer;
  final String? category;
  final int reorderLevel;
  final String? preferredSupplierId;

  /// Null means "use the global near-expiry window".
  final int? alertWindowDays;
  final String? storageCondition;
  final String? notes;
  final bool isArchived;

  /// Normalised brand + generic name used for search.
  final String searchText;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const Medicine({
    required this.id,
    required this.brandName,
    this.genericName,
    this.strength,
    required this.dosageForm,
    required this.unit,
    this.packSize,
    this.manufacturer,
    this.category,
    required this.reorderLevel,
    this.preferredSupplierId,
    this.alertWindowDays,
    this.storageCondition,
    this.notes,
    required this.isArchived,
    required this.searchText,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['brand_name'] = Variable<String>(brandName);
    if (!nullToAbsent || genericName != null) {
      map['generic_name'] = Variable<String>(genericName);
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    map['dosage_form'] = Variable<String>(dosageForm);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || packSize != null) {
      map['pack_size'] = Variable<int>(packSize);
    }
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['reorder_level'] = Variable<int>(reorderLevel);
    if (!nullToAbsent || preferredSupplierId != null) {
      map['preferred_supplier_id'] = Variable<String>(preferredSupplierId);
    }
    if (!nullToAbsent || alertWindowDays != null) {
      map['alert_window_days'] = Variable<int>(alertWindowDays);
    }
    if (!nullToAbsent || storageCondition != null) {
      map['storage_condition'] = Variable<String>(storageCondition);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['search_text'] = Variable<String>(searchText);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      id: Value(id),
      brandName: Value(brandName),
      genericName: genericName == null && nullToAbsent
          ? const Value.absent()
          : Value(genericName),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      dosageForm: Value(dosageForm),
      unit: Value(unit),
      packSize: packSize == null && nullToAbsent
          ? const Value.absent()
          : Value(packSize),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      reorderLevel: Value(reorderLevel),
      preferredSupplierId: preferredSupplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredSupplierId),
      alertWindowDays: alertWindowDays == null && nullToAbsent
          ? const Value.absent()
          : Value(alertWindowDays),
      storageCondition: storageCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(storageCondition),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isArchived: Value(isArchived),
      searchText: Value(searchText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Medicine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medicine(
      id: serializer.fromJson<String>(json['id']),
      brandName: serializer.fromJson<String>(json['brandName']),
      genericName: serializer.fromJson<String?>(json['genericName']),
      strength: serializer.fromJson<String?>(json['strength']),
      dosageForm: serializer.fromJson<String>(json['dosageForm']),
      unit: serializer.fromJson<String>(json['unit']),
      packSize: serializer.fromJson<int?>(json['packSize']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      category: serializer.fromJson<String?>(json['category']),
      reorderLevel: serializer.fromJson<int>(json['reorderLevel']),
      preferredSupplierId: serializer.fromJson<String?>(
        json['preferredSupplierId'],
      ),
      alertWindowDays: serializer.fromJson<int?>(json['alertWindowDays']),
      storageCondition: serializer.fromJson<String?>(json['storageCondition']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      searchText: serializer.fromJson<String>(json['searchText']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'brandName': serializer.toJson<String>(brandName),
      'genericName': serializer.toJson<String?>(genericName),
      'strength': serializer.toJson<String?>(strength),
      'dosageForm': serializer.toJson<String>(dosageForm),
      'unit': serializer.toJson<String>(unit),
      'packSize': serializer.toJson<int?>(packSize),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'category': serializer.toJson<String?>(category),
      'reorderLevel': serializer.toJson<int>(reorderLevel),
      'preferredSupplierId': serializer.toJson<String?>(preferredSupplierId),
      'alertWindowDays': serializer.toJson<int?>(alertWindowDays),
      'storageCondition': serializer.toJson<String?>(storageCondition),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'searchText': serializer.toJson<String>(searchText),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Medicine copyWith({
    String? id,
    String? brandName,
    Value<String?> genericName = const Value.absent(),
    Value<String?> strength = const Value.absent(),
    String? dosageForm,
    String? unit,
    Value<int?> packSize = const Value.absent(),
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> category = const Value.absent(),
    int? reorderLevel,
    Value<String?> preferredSupplierId = const Value.absent(),
    Value<int?> alertWindowDays = const Value.absent(),
    Value<String?> storageCondition = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
    String? searchText,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => Medicine(
    id: id ?? this.id,
    brandName: brandName ?? this.brandName,
    genericName: genericName.present ? genericName.value : this.genericName,
    strength: strength.present ? strength.value : this.strength,
    dosageForm: dosageForm ?? this.dosageForm,
    unit: unit ?? this.unit,
    packSize: packSize.present ? packSize.value : this.packSize,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    category: category.present ? category.value : this.category,
    reorderLevel: reorderLevel ?? this.reorderLevel,
    preferredSupplierId: preferredSupplierId.present
        ? preferredSupplierId.value
        : this.preferredSupplierId,
    alertWindowDays: alertWindowDays.present
        ? alertWindowDays.value
        : this.alertWindowDays,
    storageCondition: storageCondition.present
        ? storageCondition.value
        : this.storageCondition,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
    searchText: searchText ?? this.searchText,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Medicine copyWithCompanion(MedicinesCompanion data) {
    return Medicine(
      id: data.id.present ? data.id.value : this.id,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      genericName: data.genericName.present
          ? data.genericName.value
          : this.genericName,
      strength: data.strength.present ? data.strength.value : this.strength,
      dosageForm: data.dosageForm.present
          ? data.dosageForm.value
          : this.dosageForm,
      unit: data.unit.present ? data.unit.value : this.unit,
      packSize: data.packSize.present ? data.packSize.value : this.packSize,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      category: data.category.present ? data.category.value : this.category,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      preferredSupplierId: data.preferredSupplierId.present
          ? data.preferredSupplierId.value
          : this.preferredSupplierId,
      alertWindowDays: data.alertWindowDays.present
          ? data.alertWindowDays.value
          : this.alertWindowDays,
      storageCondition: data.storageCondition.present
          ? data.storageCondition.value
          : this.storageCondition,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medicine(')
          ..write('id: $id, ')
          ..write('brandName: $brandName, ')
          ..write('genericName: $genericName, ')
          ..write('strength: $strength, ')
          ..write('dosageForm: $dosageForm, ')
          ..write('unit: $unit, ')
          ..write('packSize: $packSize, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('category: $category, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('preferredSupplierId: $preferredSupplierId, ')
          ..write('alertWindowDays: $alertWindowDays, ')
          ..write('storageCondition: $storageCondition, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('searchText: $searchText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    brandName,
    genericName,
    strength,
    dosageForm,
    unit,
    packSize,
    manufacturer,
    category,
    reorderLevel,
    preferredSupplierId,
    alertWindowDays,
    storageCondition,
    notes,
    isArchived,
    searchText,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medicine &&
          other.id == this.id &&
          other.brandName == this.brandName &&
          other.genericName == this.genericName &&
          other.strength == this.strength &&
          other.dosageForm == this.dosageForm &&
          other.unit == this.unit &&
          other.packSize == this.packSize &&
          other.manufacturer == this.manufacturer &&
          other.category == this.category &&
          other.reorderLevel == this.reorderLevel &&
          other.preferredSupplierId == this.preferredSupplierId &&
          other.alertWindowDays == this.alertWindowDays &&
          other.storageCondition == this.storageCondition &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.searchText == this.searchText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class MedicinesCompanion extends UpdateCompanion<Medicine> {
  final Value<String> id;
  final Value<String> brandName;
  final Value<String?> genericName;
  final Value<String?> strength;
  final Value<String> dosageForm;
  final Value<String> unit;
  final Value<int?> packSize;
  final Value<String?> manufacturer;
  final Value<String?> category;
  final Value<int> reorderLevel;
  final Value<String?> preferredSupplierId;
  final Value<int?> alertWindowDays;
  final Value<String?> storageCondition;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<String> searchText;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.brandName = const Value.absent(),
    this.genericName = const Value.absent(),
    this.strength = const Value.absent(),
    this.dosageForm = const Value.absent(),
    this.unit = const Value.absent(),
    this.packSize = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.category = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.preferredSupplierId = const Value.absent(),
    this.alertWindowDays = const Value.absent(),
    this.storageCondition = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.searchText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicinesCompanion.insert({
    required String id,
    required String brandName,
    this.genericName = const Value.absent(),
    this.strength = const Value.absent(),
    this.dosageForm = const Value.absent(),
    this.unit = const Value.absent(),
    this.packSize = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.category = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.preferredSupplierId = const Value.absent(),
    this.alertWindowDays = const Value.absent(),
    this.storageCondition = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    required String searchText,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       brandName = Value(brandName),
       searchText = Value(searchText),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Medicine> custom({
    Expression<String>? id,
    Expression<String>? brandName,
    Expression<String>? genericName,
    Expression<String>? strength,
    Expression<String>? dosageForm,
    Expression<String>? unit,
    Expression<int>? packSize,
    Expression<String>? manufacturer,
    Expression<String>? category,
    Expression<int>? reorderLevel,
    Expression<String>? preferredSupplierId,
    Expression<int>? alertWindowDays,
    Expression<String>? storageCondition,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<String>? searchText,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (brandName != null) 'brand_name': brandName,
      if (genericName != null) 'generic_name': genericName,
      if (strength != null) 'strength': strength,
      if (dosageForm != null) 'dosage_form': dosageForm,
      if (unit != null) 'unit': unit,
      if (packSize != null) 'pack_size': packSize,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (category != null) 'category': category,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (preferredSupplierId != null)
        'preferred_supplier_id': preferredSupplierId,
      if (alertWindowDays != null) 'alert_window_days': alertWindowDays,
      if (storageCondition != null) 'storage_condition': storageCondition,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (searchText != null) 'search_text': searchText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicinesCompanion copyWith({
    Value<String>? id,
    Value<String>? brandName,
    Value<String?>? genericName,
    Value<String?>? strength,
    Value<String>? dosageForm,
    Value<String>? unit,
    Value<int?>? packSize,
    Value<String?>? manufacturer,
    Value<String?>? category,
    Value<int>? reorderLevel,
    Value<String?>? preferredSupplierId,
    Value<int?>? alertWindowDays,
    Value<String?>? storageCondition,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<String>? searchText,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return MedicinesCompanion(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      genericName: genericName ?? this.genericName,
      strength: strength ?? this.strength,
      dosageForm: dosageForm ?? this.dosageForm,
      unit: unit ?? this.unit,
      packSize: packSize ?? this.packSize,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      preferredSupplierId: preferredSupplierId ?? this.preferredSupplierId,
      alertWindowDays: alertWindowDays ?? this.alertWindowDays,
      storageCondition: storageCondition ?? this.storageCondition,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      searchText: searchText ?? this.searchText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (genericName.present) {
      map['generic_name'] = Variable<String>(genericName.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (dosageForm.present) {
      map['dosage_form'] = Variable<String>(dosageForm.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (packSize.present) {
      map['pack_size'] = Variable<int>(packSize.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<int>(reorderLevel.value);
    }
    if (preferredSupplierId.present) {
      map['preferred_supplier_id'] = Variable<String>(
        preferredSupplierId.value,
      );
    }
    if (alertWindowDays.present) {
      map['alert_window_days'] = Variable<int>(alertWindowDays.value);
    }
    if (storageCondition.present) {
      map['storage_condition'] = Variable<String>(storageCondition.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('id: $id, ')
          ..write('brandName: $brandName, ')
          ..write('genericName: $genericName, ')
          ..write('strength: $strength, ')
          ..write('dosageForm: $dosageForm, ')
          ..write('unit: $unit, ')
          ..write('packSize: $packSize, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('category: $category, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('preferredSupplierId: $preferredSupplierId, ')
          ..write('alertWindowDays: $alertWindowDays, ')
          ..write('storageCondition: $storageCondition, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('searchText: $searchText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicineBarcodesTable extends MedicineBarcodes
    with TableInfo<$MedicineBarcodesTable, MedicineBarcode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicineBarcodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id)',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _symbologyMeta = const VerificationMeta(
    'symbology',
  );
  @override
  late final GeneratedColumn<String> symbology = GeneratedColumn<String>(
    'symbology',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, medicineId, value, symbology];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicine_barcodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicineBarcode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('symbology')) {
      context.handle(
        _symbologyMeta,
        symbology.isAcceptableOrUnknown(data['symbology']!, _symbologyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicineBarcode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicineBarcode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      symbology: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbology'],
      ),
    );
  }

  @override
  $MedicineBarcodesTable createAlias(String alias) {
    return $MedicineBarcodesTable(attachedDatabase, alias);
  }
}

class MedicineBarcode extends DataClass implements Insertable<MedicineBarcode> {
  final String id;
  final String medicineId;
  final String value;
  final String? symbology;
  const MedicineBarcode({
    required this.id,
    required this.medicineId,
    required this.value,
    this.symbology,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medicine_id'] = Variable<String>(medicineId);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || symbology != null) {
      map['symbology'] = Variable<String>(symbology);
    }
    return map;
  }

  MedicineBarcodesCompanion toCompanion(bool nullToAbsent) {
    return MedicineBarcodesCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      value: Value(value),
      symbology: symbology == null && nullToAbsent
          ? const Value.absent()
          : Value(symbology),
    );
  }

  factory MedicineBarcode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicineBarcode(
      id: serializer.fromJson<String>(json['id']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      value: serializer.fromJson<String>(json['value']),
      symbology: serializer.fromJson<String?>(json['symbology']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicineId': serializer.toJson<String>(medicineId),
      'value': serializer.toJson<String>(value),
      'symbology': serializer.toJson<String?>(symbology),
    };
  }

  MedicineBarcode copyWith({
    String? id,
    String? medicineId,
    String? value,
    Value<String?> symbology = const Value.absent(),
  }) => MedicineBarcode(
    id: id ?? this.id,
    medicineId: medicineId ?? this.medicineId,
    value: value ?? this.value,
    symbology: symbology.present ? symbology.value : this.symbology,
  );
  MedicineBarcode copyWithCompanion(MedicineBarcodesCompanion data) {
    return MedicineBarcode(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      value: data.value.present ? data.value.value : this.value,
      symbology: data.symbology.present ? data.symbology.value : this.symbology,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicineBarcode(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('value: $value, ')
          ..write('symbology: $symbology')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, medicineId, value, symbology);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineBarcode &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.value == this.value &&
          other.symbology == this.symbology);
}

class MedicineBarcodesCompanion extends UpdateCompanion<MedicineBarcode> {
  final Value<String> id;
  final Value<String> medicineId;
  final Value<String> value;
  final Value<String?> symbology;
  final Value<int> rowid;
  const MedicineBarcodesCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.value = const Value.absent(),
    this.symbology = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicineBarcodesCompanion.insert({
    required String id,
    required String medicineId,
    required String value,
    this.symbology = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicineId = Value(medicineId),
       value = Value(value);
  static Insertable<MedicineBarcode> custom({
    Expression<String>? id,
    Expression<String>? medicineId,
    Expression<String>? value,
    Expression<String>? symbology,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (value != null) 'value': value,
      if (symbology != null) 'symbology': symbology,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicineBarcodesCompanion copyWith({
    Value<String>? id,
    Value<String>? medicineId,
    Value<String>? value,
    Value<String?>? symbology,
    Value<int>? rowid,
  }) {
    return MedicineBarcodesCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      value: value ?? this.value,
      symbology: symbology ?? this.symbology,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (symbology.present) {
      map['symbology'] = Variable<String>(symbology.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicineBarcodesCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('value: $value, ')
          ..write('symbology: $symbology, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierInvoicesTable extends SupplierInvoices
    with TableInfo<$SupplierInvoicesTable, SupplierInvoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceDateMeta = const VerificationMeta(
    'invoiceDate',
  );
  @override
  late final GeneratedColumn<String> invoiceDate = GeneratedColumn<String>(
    'invoice_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMinorMeta = const VerificationMeta(
    'totalMinor',
  );
  @override
  late final GeneratedColumn<int> totalMinor = GeneratedColumn<int>(
    'total_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindersSnoozedUntilMeta =
      const VerificationMeta('remindersSnoozedUntil');
  @override
  late final GeneratedColumn<String> remindersSnoozedUntil =
      GeneratedColumn<String>(
        'reminders_snoozed_until',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    invoiceNumber,
    invoiceDate,
    dueDate,
    totalMinor,
    notes,
    remindersSnoozedUntil,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierInvoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
        _invoiceDateMeta,
        invoiceDate.isAcceptableOrUnknown(
          data['invoice_date']!,
          _invoiceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('total_minor')) {
      context.handle(
        _totalMinorMeta,
        totalMinor.isAcceptableOrUnknown(data['total_minor']!, _totalMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMinorMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('reminders_snoozed_until')) {
      context.handle(
        _remindersSnoozedUntilMeta,
        remindersSnoozedUntil.isAcceptableOrUnknown(
          data['reminders_snoozed_until']!,
          _remindersSnoozedUntilMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierInvoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierInvoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      ),
      invoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
      totalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      remindersSnoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminders_snoozed_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SupplierInvoicesTable createAlias(String alias) {
    return $SupplierInvoicesTable(attachedDatabase, alias);
  }
}

class SupplierInvoice extends DataClass implements Insertable<SupplierInvoice> {
  final String id;
  final String supplierId;
  final String? invoiceNumber;
  final String invoiceDate;
  final String? dueDate;
  final int totalMinor;
  final String? notes;
  final String? remindersSnoozedUntil;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const SupplierInvoice({
    required this.id,
    required this.supplierId,
    this.invoiceNumber,
    required this.invoiceDate,
    this.dueDate,
    required this.totalMinor,
    this.notes,
    this.remindersSnoozedUntil,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    map['invoice_date'] = Variable<String>(invoiceDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    map['total_minor'] = Variable<int>(totalMinor);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || remindersSnoozedUntil != null) {
      map['reminders_snoozed_until'] = Variable<String>(remindersSnoozedUntil);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SupplierInvoicesCompanion toCompanion(bool nullToAbsent) {
    return SupplierInvoicesCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      invoiceDate: Value(invoiceDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      totalMinor: Value(totalMinor),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      remindersSnoozedUntil: remindersSnoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(remindersSnoozedUntil),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SupplierInvoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierInvoice(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      invoiceDate: serializer.fromJson<String>(json['invoiceDate']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      totalMinor: serializer.fromJson<int>(json['totalMinor']),
      notes: serializer.fromJson<String?>(json['notes']),
      remindersSnoozedUntil: serializer.fromJson<String?>(
        json['remindersSnoozedUntil'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'invoiceDate': serializer.toJson<String>(invoiceDate),
      'dueDate': serializer.toJson<String?>(dueDate),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'notes': serializer.toJson<String?>(notes),
      'remindersSnoozedUntil': serializer.toJson<String?>(
        remindersSnoozedUntil,
      ),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  SupplierInvoice copyWith({
    String? id,
    String? supplierId,
    Value<String?> invoiceNumber = const Value.absent(),
    String? invoiceDate,
    Value<String?> dueDate = const Value.absent(),
    int? totalMinor,
    Value<String?> notes = const Value.absent(),
    Value<String?> remindersSnoozedUntil = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => SupplierInvoice(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    invoiceNumber: invoiceNumber.present
        ? invoiceNumber.value
        : this.invoiceNumber,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    totalMinor: totalMinor ?? this.totalMinor,
    notes: notes.present ? notes.value : this.notes,
    remindersSnoozedUntil: remindersSnoozedUntil.present
        ? remindersSnoozedUntil.value
        : this.remindersSnoozedUntil,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SupplierInvoice copyWithCompanion(SupplierInvoicesCompanion data) {
    return SupplierInvoice(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      invoiceDate: data.invoiceDate.present
          ? data.invoiceDate.value
          : this.invoiceDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      totalMinor: data.totalMinor.present
          ? data.totalMinor.value
          : this.totalMinor,
      notes: data.notes.present ? data.notes.value : this.notes,
      remindersSnoozedUntil: data.remindersSnoozedUntil.present
          ? data.remindersSnoozedUntil.value
          : this.remindersSnoozedUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierInvoice(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('notes: $notes, ')
          ..write('remindersSnoozedUntil: $remindersSnoozedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    invoiceNumber,
    invoiceDate,
    dueDate,
    totalMinor,
    notes,
    remindersSnoozedUntil,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierInvoice &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.invoiceDate == this.invoiceDate &&
          other.dueDate == this.dueDate &&
          other.totalMinor == this.totalMinor &&
          other.notes == this.notes &&
          other.remindersSnoozedUntil == this.remindersSnoozedUntil &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SupplierInvoicesCompanion extends UpdateCompanion<SupplierInvoice> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String?> invoiceNumber;
  final Value<String> invoiceDate;
  final Value<String?> dueDate;
  final Value<int> totalMinor;
  final Value<String?> notes;
  final Value<String?> remindersSnoozedUntil;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const SupplierInvoicesCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.notes = const Value.absent(),
    this.remindersSnoozedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierInvoicesCompanion.insert({
    required String id,
    required String supplierId,
    this.invoiceNumber = const Value.absent(),
    required String invoiceDate,
    this.dueDate = const Value.absent(),
    required int totalMinor,
    this.notes = const Value.absent(),
    this.remindersSnoozedUntil = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       invoiceDate = Value(invoiceDate),
       totalMinor = Value(totalMinor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SupplierInvoice> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? invoiceNumber,
    Expression<String>? invoiceDate,
    Expression<String>? dueDate,
    Expression<int>? totalMinor,
    Expression<String>? notes,
    Expression<String>? remindersSnoozedUntil,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (dueDate != null) 'due_date': dueDate,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (notes != null) 'notes': notes,
      if (remindersSnoozedUntil != null)
        'reminders_snoozed_until': remindersSnoozedUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierInvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<String?>? invoiceNumber,
    Value<String>? invoiceDate,
    Value<String?>? dueDate,
    Value<int>? totalMinor,
    Value<String?>? notes,
    Value<String?>? remindersSnoozedUntil,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SupplierInvoicesCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      totalMinor: totalMinor ?? this.totalMinor,
      notes: notes ?? this.notes,
      remindersSnoozedUntil:
          remindersSnoozedUntil ?? this.remindersSnoozedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<String>(invoiceDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (remindersSnoozedUntil.present) {
      map['reminders_snoozed_until'] = Variable<String>(
        remindersSnoozedUntil.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierInvoicesCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('notes: $notes, ')
          ..write('remindersSnoozedUntil: $remindersSnoozedUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, Batche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id)',
    ),
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<String> expiryDate = GeneratedColumn<String>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryPrecisionMeta = const VerificationMeta(
    'expiryPrecision',
  );
  @override
  late final GeneratedColumn<String> expiryPrecision = GeneratedColumn<String>(
    'expiry_precision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityReceivedMeta = const VerificationMeta(
    'quantityReceived',
  );
  @override
  late final GeneratedColumn<int> quantityReceived = GeneratedColumn<int>(
    'quantity_received',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityOnHandMeta = const VerificationMeta(
    'quantityOnHand',
  );
  @override
  late final GeneratedColumn<int> quantityOnHand = GeneratedColumn<int>(
    'quantity_on_hand',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceMinorMeta = const VerificationMeta(
    'costPriceMinor',
  );
  @override
  late final GeneratedColumn<int> costPriceMinor = GeneratedColumn<int>(
    'cost_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellingPriceMinorMeta = const VerificationMeta(
    'sellingPriceMinor',
  );
  @override
  late final GeneratedColumn<int> sellingPriceMinor = GeneratedColumn<int>(
    'selling_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedDateMeta = const VerificationMeta(
    'receivedDate',
  );
  @override
  late final GeneratedColumn<String> receivedDate = GeneratedColumn<String>(
    'received_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_invoices (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
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
  static const VerificationMeta _handledAtMeta = const VerificationMeta(
    'handledAt',
  );
  @override
  late final GeneratedColumn<int> handledAt = GeneratedColumn<int>(
    'handled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineId,
    batchNumber,
    expiryDate,
    expiryPrecision,
    quantityReceived,
    quantityOnHand,
    costPriceMinor,
    sellingPriceMinor,
    receivedDate,
    supplierId,
    invoiceId,
    status,
    snoozedUntil,
    handledAt,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Batche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('expiry_precision')) {
      context.handle(
        _expiryPrecisionMeta,
        expiryPrecision.isAcceptableOrUnknown(
          data['expiry_precision']!,
          _expiryPrecisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expiryPrecisionMeta);
    }
    if (data.containsKey('quantity_received')) {
      context.handle(
        _quantityReceivedMeta,
        quantityReceived.isAcceptableOrUnknown(
          data['quantity_received']!,
          _quantityReceivedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityReceivedMeta);
    }
    if (data.containsKey('quantity_on_hand')) {
      context.handle(
        _quantityOnHandMeta,
        quantityOnHand.isAcceptableOrUnknown(
          data['quantity_on_hand']!,
          _quantityOnHandMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityOnHandMeta);
    }
    if (data.containsKey('cost_price_minor')) {
      context.handle(
        _costPriceMinorMeta,
        costPriceMinor.isAcceptableOrUnknown(
          data['cost_price_minor']!,
          _costPriceMinorMeta,
        ),
      );
    }
    if (data.containsKey('selling_price_minor')) {
      context.handle(
        _sellingPriceMinorMeta,
        sellingPriceMinor.isAcceptableOrUnknown(
          data['selling_price_minor']!,
          _sellingPriceMinorMeta,
        ),
      );
    }
    if (data.containsKey('received_date')) {
      context.handle(
        _receivedDateMeta,
        receivedDate.isAcceptableOrUnknown(
          data['received_date']!,
          _receivedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedDateMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
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
    if (data.containsKey('handled_at')) {
      context.handle(
        _handledAtMeta,
        handledAt.isAcceptableOrUnknown(data['handled_at']!, _handledAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {medicineId, batchNumber, expiryDate},
  ];
  @override
  Batche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Batche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expiry_date'],
      )!,
      expiryPrecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expiry_precision'],
      )!,
      quantityReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_received'],
      )!,
      quantityOnHand: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_on_hand'],
      )!,
      costPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_price_minor'],
      ),
      sellingPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selling_price_minor'],
      ),
      receivedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_date'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snoozed_until'],
      ),
      handledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}handled_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class Batche extends DataClass implements Insertable<Batche> {
  final String id;
  final String medicineId;
  final String batchNumber;

  /// `YYYY-MM-DD`; last day of the month when [expiryPrecision] is `MONTH`.
  final String expiryDate;

  /// `MONTH` | `DAY`.
  final String expiryPrecision;
  final int quantityReceived;
  final int quantityOnHand;
  final int? costPriceMinor;
  final int? sellingPriceMinor;
  final String receivedDate;
  final String? supplierId;
  final String? invoiceId;

  /// `ACTIVE` | `DEPLETED` | `RETURNED` | `DISCARDED`.
  final String status;
  final String? snoozedUntil;
  final int? handledAt;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const Batche({
    required this.id,
    required this.medicineId,
    required this.batchNumber,
    required this.expiryDate,
    required this.expiryPrecision,
    required this.quantityReceived,
    required this.quantityOnHand,
    this.costPriceMinor,
    this.sellingPriceMinor,
    required this.receivedDate,
    this.supplierId,
    this.invoiceId,
    required this.status,
    this.snoozedUntil,
    this.handledAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medicine_id'] = Variable<String>(medicineId);
    map['batch_number'] = Variable<String>(batchNumber);
    map['expiry_date'] = Variable<String>(expiryDate);
    map['expiry_precision'] = Variable<String>(expiryPrecision);
    map['quantity_received'] = Variable<int>(quantityReceived);
    map['quantity_on_hand'] = Variable<int>(quantityOnHand);
    if (!nullToAbsent || costPriceMinor != null) {
      map['cost_price_minor'] = Variable<int>(costPriceMinor);
    }
    if (!nullToAbsent || sellingPriceMinor != null) {
      map['selling_price_minor'] = Variable<int>(sellingPriceMinor);
    }
    map['received_date'] = Variable<String>(receivedDate);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || invoiceId != null) {
      map['invoice_id'] = Variable<String>(invoiceId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<String>(snoozedUntil);
    }
    if (!nullToAbsent || handledAt != null) {
      map['handled_at'] = Variable<int>(handledAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      batchNumber: Value(batchNumber),
      expiryDate: Value(expiryDate),
      expiryPrecision: Value(expiryPrecision),
      quantityReceived: Value(quantityReceived),
      quantityOnHand: Value(quantityOnHand),
      costPriceMinor: costPriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(costPriceMinor),
      sellingPriceMinor: sellingPriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(sellingPriceMinor),
      receivedDate: Value(receivedDate),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      invoiceId: invoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceId),
      status: Value(status),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      handledAt: handledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(handledAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Batche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Batche(
      id: serializer.fromJson<String>(json['id']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      expiryDate: serializer.fromJson<String>(json['expiryDate']),
      expiryPrecision: serializer.fromJson<String>(json['expiryPrecision']),
      quantityReceived: serializer.fromJson<int>(json['quantityReceived']),
      quantityOnHand: serializer.fromJson<int>(json['quantityOnHand']),
      costPriceMinor: serializer.fromJson<int?>(json['costPriceMinor']),
      sellingPriceMinor: serializer.fromJson<int?>(json['sellingPriceMinor']),
      receivedDate: serializer.fromJson<String>(json['receivedDate']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      invoiceId: serializer.fromJson<String?>(json['invoiceId']),
      status: serializer.fromJson<String>(json['status']),
      snoozedUntil: serializer.fromJson<String?>(json['snoozedUntil']),
      handledAt: serializer.fromJson<int?>(json['handledAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicineId': serializer.toJson<String>(medicineId),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'expiryDate': serializer.toJson<String>(expiryDate),
      'expiryPrecision': serializer.toJson<String>(expiryPrecision),
      'quantityReceived': serializer.toJson<int>(quantityReceived),
      'quantityOnHand': serializer.toJson<int>(quantityOnHand),
      'costPriceMinor': serializer.toJson<int?>(costPriceMinor),
      'sellingPriceMinor': serializer.toJson<int?>(sellingPriceMinor),
      'receivedDate': serializer.toJson<String>(receivedDate),
      'supplierId': serializer.toJson<String?>(supplierId),
      'invoiceId': serializer.toJson<String?>(invoiceId),
      'status': serializer.toJson<String>(status),
      'snoozedUntil': serializer.toJson<String?>(snoozedUntil),
      'handledAt': serializer.toJson<int?>(handledAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  Batche copyWith({
    String? id,
    String? medicineId,
    String? batchNumber,
    String? expiryDate,
    String? expiryPrecision,
    int? quantityReceived,
    int? quantityOnHand,
    Value<int?> costPriceMinor = const Value.absent(),
    Value<int?> sellingPriceMinor = const Value.absent(),
    String? receivedDate,
    Value<String?> supplierId = const Value.absent(),
    Value<String?> invoiceId = const Value.absent(),
    String? status,
    Value<String?> snoozedUntil = const Value.absent(),
    Value<int?> handledAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => Batche(
    id: id ?? this.id,
    medicineId: medicineId ?? this.medicineId,
    batchNumber: batchNumber ?? this.batchNumber,
    expiryDate: expiryDate ?? this.expiryDate,
    expiryPrecision: expiryPrecision ?? this.expiryPrecision,
    quantityReceived: quantityReceived ?? this.quantityReceived,
    quantityOnHand: quantityOnHand ?? this.quantityOnHand,
    costPriceMinor: costPriceMinor.present
        ? costPriceMinor.value
        : this.costPriceMinor,
    sellingPriceMinor: sellingPriceMinor.present
        ? sellingPriceMinor.value
        : this.sellingPriceMinor,
    receivedDate: receivedDate ?? this.receivedDate,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    invoiceId: invoiceId.present ? invoiceId.value : this.invoiceId,
    status: status ?? this.status,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    handledAt: handledAt.present ? handledAt.value : this.handledAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Batche copyWithCompanion(BatchesCompanion data) {
    return Batche(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      expiryPrecision: data.expiryPrecision.present
          ? data.expiryPrecision.value
          : this.expiryPrecision,
      quantityReceived: data.quantityReceived.present
          ? data.quantityReceived.value
          : this.quantityReceived,
      quantityOnHand: data.quantityOnHand.present
          ? data.quantityOnHand.value
          : this.quantityOnHand,
      costPriceMinor: data.costPriceMinor.present
          ? data.costPriceMinor.value
          : this.costPriceMinor,
      sellingPriceMinor: data.sellingPriceMinor.present
          ? data.sellingPriceMinor.value
          : this.sellingPriceMinor,
      receivedDate: data.receivedDate.present
          ? data.receivedDate.value
          : this.receivedDate,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      status: data.status.present ? data.status.value : this.status,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      handledAt: data.handledAt.present ? data.handledAt.value : this.handledAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Batche(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('expiryPrecision: $expiryPrecision, ')
          ..write('quantityReceived: $quantityReceived, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('costPriceMinor: $costPriceMinor, ')
          ..write('sellingPriceMinor: $sellingPriceMinor, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('supplierId: $supplierId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('status: $status, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('handledAt: $handledAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicineId,
    batchNumber,
    expiryDate,
    expiryPrecision,
    quantityReceived,
    quantityOnHand,
    costPriceMinor,
    sellingPriceMinor,
    receivedDate,
    supplierId,
    invoiceId,
    status,
    snoozedUntil,
    handledAt,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Batche &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.batchNumber == this.batchNumber &&
          other.expiryDate == this.expiryDate &&
          other.expiryPrecision == this.expiryPrecision &&
          other.quantityReceived == this.quantityReceived &&
          other.quantityOnHand == this.quantityOnHand &&
          other.costPriceMinor == this.costPriceMinor &&
          other.sellingPriceMinor == this.sellingPriceMinor &&
          other.receivedDate == this.receivedDate &&
          other.supplierId == this.supplierId &&
          other.invoiceId == this.invoiceId &&
          other.status == this.status &&
          other.snoozedUntil == this.snoozedUntil &&
          other.handledAt == this.handledAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class BatchesCompanion extends UpdateCompanion<Batche> {
  final Value<String> id;
  final Value<String> medicineId;
  final Value<String> batchNumber;
  final Value<String> expiryDate;
  final Value<String> expiryPrecision;
  final Value<int> quantityReceived;
  final Value<int> quantityOnHand;
  final Value<int?> costPriceMinor;
  final Value<int?> sellingPriceMinor;
  final Value<String> receivedDate;
  final Value<String?> supplierId;
  final Value<String?> invoiceId;
  final Value<String> status;
  final Value<String?> snoozedUntil;
  final Value<int?> handledAt;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.expiryPrecision = const Value.absent(),
    this.quantityReceived = const Value.absent(),
    this.quantityOnHand = const Value.absent(),
    this.costPriceMinor = const Value.absent(),
    this.sellingPriceMinor = const Value.absent(),
    this.receivedDate = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.handledAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchesCompanion.insert({
    required String id,
    required String medicineId,
    required String batchNumber,
    required String expiryDate,
    required String expiryPrecision,
    required int quantityReceived,
    required int quantityOnHand,
    this.costPriceMinor = const Value.absent(),
    this.sellingPriceMinor = const Value.absent(),
    required String receivedDate,
    this.supplierId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.handledAt = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicineId = Value(medicineId),
       batchNumber = Value(batchNumber),
       expiryDate = Value(expiryDate),
       expiryPrecision = Value(expiryPrecision),
       quantityReceived = Value(quantityReceived),
       quantityOnHand = Value(quantityOnHand),
       receivedDate = Value(receivedDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Batche> custom({
    Expression<String>? id,
    Expression<String>? medicineId,
    Expression<String>? batchNumber,
    Expression<String>? expiryDate,
    Expression<String>? expiryPrecision,
    Expression<int>? quantityReceived,
    Expression<int>? quantityOnHand,
    Expression<int>? costPriceMinor,
    Expression<int>? sellingPriceMinor,
    Expression<String>? receivedDate,
    Expression<String>? supplierId,
    Expression<String>? invoiceId,
    Expression<String>? status,
    Expression<String>? snoozedUntil,
    Expression<int>? handledAt,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (expiryPrecision != null) 'expiry_precision': expiryPrecision,
      if (quantityReceived != null) 'quantity_received': quantityReceived,
      if (quantityOnHand != null) 'quantity_on_hand': quantityOnHand,
      if (costPriceMinor != null) 'cost_price_minor': costPriceMinor,
      if (sellingPriceMinor != null) 'selling_price_minor': sellingPriceMinor,
      if (receivedDate != null) 'received_date': receivedDate,
      if (supplierId != null) 'supplier_id': supplierId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (status != null) 'status': status,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (handledAt != null) 'handled_at': handledAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? medicineId,
    Value<String>? batchNumber,
    Value<String>? expiryDate,
    Value<String>? expiryPrecision,
    Value<int>? quantityReceived,
    Value<int>? quantityOnHand,
    Value<int?>? costPriceMinor,
    Value<int?>? sellingPriceMinor,
    Value<String>? receivedDate,
    Value<String?>? supplierId,
    Value<String?>? invoiceId,
    Value<String>? status,
    Value<String?>? snoozedUntil,
    Value<int?>? handledAt,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      expiryPrecision: expiryPrecision ?? this.expiryPrecision,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      costPriceMinor: costPriceMinor ?? this.costPriceMinor,
      sellingPriceMinor: sellingPriceMinor ?? this.sellingPriceMinor,
      receivedDate: receivedDate ?? this.receivedDate,
      supplierId: supplierId ?? this.supplierId,
      invoiceId: invoiceId ?? this.invoiceId,
      status: status ?? this.status,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      handledAt: handledAt ?? this.handledAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<String>(expiryDate.value);
    }
    if (expiryPrecision.present) {
      map['expiry_precision'] = Variable<String>(expiryPrecision.value);
    }
    if (quantityReceived.present) {
      map['quantity_received'] = Variable<int>(quantityReceived.value);
    }
    if (quantityOnHand.present) {
      map['quantity_on_hand'] = Variable<int>(quantityOnHand.value);
    }
    if (costPriceMinor.present) {
      map['cost_price_minor'] = Variable<int>(costPriceMinor.value);
    }
    if (sellingPriceMinor.present) {
      map['selling_price_minor'] = Variable<int>(sellingPriceMinor.value);
    }
    if (receivedDate.present) {
      map['received_date'] = Variable<String>(receivedDate.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<String>(snoozedUntil.value);
    }
    if (handledAt.present) {
      map['handled_at'] = Variable<int>(handledAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('expiryPrecision: $expiryPrecision, ')
          ..write('quantityReceived: $quantityReceived, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('costPriceMinor: $costPriceMinor, ')
          ..write('sellingPriceMinor: $sellingPriceMinor, ')
          ..write('receivedDate: $receivedDate, ')
          ..write('supplierId: $supplierId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('status: $status, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('handledAt: $handledAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierReturnsTable extends SupplierReturns
    with TableInfo<$SupplierReturnsTable, SupplierReturn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _returnedOnMeta = const VerificationMeta(
    'returnedOn',
  );
  @override
  late final GeneratedColumn<String> returnedOn = GeneratedColumn<String>(
    'returned_on',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    returnedOn,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierReturn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('returned_on')) {
      context.handle(
        _returnedOnMeta,
        returnedOn.isAcceptableOrUnknown(data['returned_on']!, _returnedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_returnedOnMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  SupplierReturn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierReturn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      returnedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}returned_on'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SupplierReturnsTable createAlias(String alias) {
    return $SupplierReturnsTable(attachedDatabase, alias);
  }
}

class SupplierReturn extends DataClass implements Insertable<SupplierReturn> {
  final String id;
  final String supplierId;
  final String returnedOn;
  final String? note;
  final int createdAt;
  const SupplierReturn({
    required this.id,
    required this.supplierId,
    required this.returnedOn,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    map['returned_on'] = Variable<String>(returnedOn);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SupplierReturnsCompanion toCompanion(bool nullToAbsent) {
    return SupplierReturnsCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      returnedOn: Value(returnedOn),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory SupplierReturn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierReturn(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      returnedOn: serializer.fromJson<String>(json['returnedOn']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'returnedOn': serializer.toJson<String>(returnedOn),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SupplierReturn copyWith({
    String? id,
    String? supplierId,
    String? returnedOn,
    Value<String?> note = const Value.absent(),
    int? createdAt,
  }) => SupplierReturn(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    returnedOn: returnedOn ?? this.returnedOn,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  SupplierReturn copyWithCompanion(SupplierReturnsCompanion data) {
    return SupplierReturn(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      returnedOn: data.returnedOn.present
          ? data.returnedOn.value
          : this.returnedOn,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReturn(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('returnedOn: $returnedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, supplierId, returnedOn, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierReturn &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.returnedOn == this.returnedOn &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class SupplierReturnsCompanion extends UpdateCompanion<SupplierReturn> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String> returnedOn;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SupplierReturnsCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.returnedOn = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierReturnsCompanion.insert({
    required String id,
    required String supplierId,
    required String returnedOn,
    this.note = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       returnedOn = Value(returnedOn),
       createdAt = Value(createdAt);
  static Insertable<SupplierReturn> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? returnedOn,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (returnedOn != null) 'returned_on': returnedOn,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierReturnsCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<String>? returnedOn,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SupplierReturnsCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      returnedOn: returnedOn ?? this.returnedOn,
      note: note ?? this.note,
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
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (returnedOn.present) {
      map['returned_on'] = Variable<String>(returnedOn.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReturnsCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('returnedOn: $returnedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockAdjustmentsTable extends StockAdjustments
    with TableInfo<$StockAdjustmentsTable, StockAdjustment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockAdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES batches (id)',
    ),
  );
  static const VerificationMeta _deltaQtyMeta = const VerificationMeta(
    'deltaQty',
  );
  @override
  late final GeneratedColumn<int> deltaQty = GeneratedColumn<int>(
    'delta_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueImpactMinorMeta = const VerificationMeta(
    'valueImpactMinor',
  );
  @override
  late final GeneratedColumn<int> valueImpactMinor = GeneratedColumn<int>(
    'value_impact_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _returnIdMeta = const VerificationMeta(
    'returnId',
  );
  @override
  late final GeneratedColumn<String> returnId = GeneratedColumn<String>(
    'return_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_returns (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    deltaQty,
    reason,
    note,
    valueImpactMinor,
    returnId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockAdjustment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('delta_qty')) {
      context.handle(
        _deltaQtyMeta,
        deltaQty.isAcceptableOrUnknown(data['delta_qty']!, _deltaQtyMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaQtyMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('value_impact_minor')) {
      context.handle(
        _valueImpactMinorMeta,
        valueImpactMinor.isAcceptableOrUnknown(
          data['value_impact_minor']!,
          _valueImpactMinorMeta,
        ),
      );
    }
    if (data.containsKey('return_id')) {
      context.handle(
        _returnIdMeta,
        returnId.isAcceptableOrUnknown(data['return_id']!, _returnIdMeta),
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
  StockAdjustment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockAdjustment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      deltaQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta_qty'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      valueImpactMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_impact_minor'],
      ),
      returnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockAdjustmentsTable createAlias(String alias) {
    return $StockAdjustmentsTable(attachedDatabase, alias);
  }
}

class StockAdjustment extends DataClass implements Insertable<StockAdjustment> {
  final String id;
  final String batchId;
  final int deltaQty;

  /// RECEIVED | SOLD | DAMAGED | DISCARDED_EXPIRED | RETURNED | CORRECTION
  /// | OTHER.
  final String reason;
  final String? note;
  final int? valueImpactMinor;
  final String? returnId;
  final int createdAt;
  const StockAdjustment({
    required this.id,
    required this.batchId,
    required this.deltaQty,
    required this.reason,
    this.note,
    this.valueImpactMinor,
    this.returnId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['delta_qty'] = Variable<int>(deltaQty);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || valueImpactMinor != null) {
      map['value_impact_minor'] = Variable<int>(valueImpactMinor);
    }
    if (!nullToAbsent || returnId != null) {
      map['return_id'] = Variable<String>(returnId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  StockAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return StockAdjustmentsCompanion(
      id: Value(id),
      batchId: Value(batchId),
      deltaQty: Value(deltaQty),
      reason: Value(reason),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      valueImpactMinor: valueImpactMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(valueImpactMinor),
      returnId: returnId == null && nullToAbsent
          ? const Value.absent()
          : Value(returnId),
      createdAt: Value(createdAt),
    );
  }

  factory StockAdjustment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockAdjustment(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      deltaQty: serializer.fromJson<int>(json['deltaQty']),
      reason: serializer.fromJson<String>(json['reason']),
      note: serializer.fromJson<String?>(json['note']),
      valueImpactMinor: serializer.fromJson<int?>(json['valueImpactMinor']),
      returnId: serializer.fromJson<String?>(json['returnId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String>(batchId),
      'deltaQty': serializer.toJson<int>(deltaQty),
      'reason': serializer.toJson<String>(reason),
      'note': serializer.toJson<String?>(note),
      'valueImpactMinor': serializer.toJson<int?>(valueImpactMinor),
      'returnId': serializer.toJson<String?>(returnId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  StockAdjustment copyWith({
    String? id,
    String? batchId,
    int? deltaQty,
    String? reason,
    Value<String?> note = const Value.absent(),
    Value<int?> valueImpactMinor = const Value.absent(),
    Value<String?> returnId = const Value.absent(),
    int? createdAt,
  }) => StockAdjustment(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    deltaQty: deltaQty ?? this.deltaQty,
    reason: reason ?? this.reason,
    note: note.present ? note.value : this.note,
    valueImpactMinor: valueImpactMinor.present
        ? valueImpactMinor.value
        : this.valueImpactMinor,
    returnId: returnId.present ? returnId.value : this.returnId,
    createdAt: createdAt ?? this.createdAt,
  );
  StockAdjustment copyWithCompanion(StockAdjustmentsCompanion data) {
    return StockAdjustment(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      deltaQty: data.deltaQty.present ? data.deltaQty.value : this.deltaQty,
      reason: data.reason.present ? data.reason.value : this.reason,
      note: data.note.present ? data.note.value : this.note,
      valueImpactMinor: data.valueImpactMinor.present
          ? data.valueImpactMinor.value
          : this.valueImpactMinor,
      returnId: data.returnId.present ? data.returnId.value : this.returnId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockAdjustment(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('deltaQty: $deltaQty, ')
          ..write('reason: $reason, ')
          ..write('note: $note, ')
          ..write('valueImpactMinor: $valueImpactMinor, ')
          ..write('returnId: $returnId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    deltaQty,
    reason,
    note,
    valueImpactMinor,
    returnId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockAdjustment &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.deltaQty == this.deltaQty &&
          other.reason == this.reason &&
          other.note == this.note &&
          other.valueImpactMinor == this.valueImpactMinor &&
          other.returnId == this.returnId &&
          other.createdAt == this.createdAt);
}

class StockAdjustmentsCompanion extends UpdateCompanion<StockAdjustment> {
  final Value<String> id;
  final Value<String> batchId;
  final Value<int> deltaQty;
  final Value<String> reason;
  final Value<String?> note;
  final Value<int?> valueImpactMinor;
  final Value<String?> returnId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const StockAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.deltaQty = const Value.absent(),
    this.reason = const Value.absent(),
    this.note = const Value.absent(),
    this.valueImpactMinor = const Value.absent(),
    this.returnId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockAdjustmentsCompanion.insert({
    required String id,
    required String batchId,
    required int deltaQty,
    required String reason,
    this.note = const Value.absent(),
    this.valueImpactMinor = const Value.absent(),
    this.returnId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       batchId = Value(batchId),
       deltaQty = Value(deltaQty),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<StockAdjustment> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<int>? deltaQty,
    Expression<String>? reason,
    Expression<String>? note,
    Expression<int>? valueImpactMinor,
    Expression<String>? returnId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (deltaQty != null) 'delta_qty': deltaQty,
      if (reason != null) 'reason': reason,
      if (note != null) 'note': note,
      if (valueImpactMinor != null) 'value_impact_minor': valueImpactMinor,
      if (returnId != null) 'return_id': returnId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockAdjustmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? batchId,
    Value<int>? deltaQty,
    Value<String>? reason,
    Value<String?>? note,
    Value<int?>? valueImpactMinor,
    Value<String?>? returnId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return StockAdjustmentsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      deltaQty: deltaQty ?? this.deltaQty,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      valueImpactMinor: valueImpactMinor ?? this.valueImpactMinor,
      returnId: returnId ?? this.returnId,
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
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (deltaQty.present) {
      map['delta_qty'] = Variable<int>(deltaQty.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (valueImpactMinor.present) {
      map['value_impact_minor'] = Variable<int>(valueImpactMinor.value);
    }
    if (returnId.present) {
      map['return_id'] = Variable<String>(returnId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('deltaQty: $deltaQty, ')
          ..write('reason: $reason, ')
          ..write('note: $note, ')
          ..write('valueImpactMinor: $valueImpactMinor, ')
          ..write('returnId: $returnId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierPaymentsTable extends SupplierPayments
    with TableInfo<$SupplierPaymentsTable, SupplierPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_invoices (id)',
    ),
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
  static const VerificationMeta _paidOnMeta = const VerificationMeta('paidOn');
  @override
  late final GeneratedColumn<String> paidOn = GeneratedColumn<String>(
    'paid_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    invoiceId,
    amountMinor,
    paidOn,
    method,
    reference,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
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
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('paid_on')) {
      context.handle(
        _paidOnMeta,
        paidOn.isAcceptableOrUnknown(data['paid_on']!, _paidOnMeta),
      );
    } else if (isInserting) {
      context.missing(_paidOnMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      paidOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_on'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SupplierPaymentsTable createAlias(String alias) {
    return $SupplierPaymentsTable(attachedDatabase, alias);
  }
}

class SupplierPayment extends DataClass implements Insertable<SupplierPayment> {
  final String id;
  final String supplierId;
  final String? invoiceId;
  final int amountMinor;
  final String paidOn;
  final String? method;
  final String? reference;
  final int createdAt;
  final int? deletedAt;
  const SupplierPayment({
    required this.id,
    required this.supplierId,
    this.invoiceId,
    required this.amountMinor,
    required this.paidOn,
    this.method,
    this.reference,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    if (!nullToAbsent || invoiceId != null) {
      map['invoice_id'] = Variable<String>(invoiceId);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['paid_on'] = Variable<String>(paidOn);
    if (!nullToAbsent || method != null) {
      map['method'] = Variable<String>(method);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SupplierPaymentsCompanion toCompanion(bool nullToAbsent) {
    return SupplierPaymentsCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      invoiceId: invoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceId),
      amountMinor: Value(amountMinor),
      paidOn: Value(paidOn),
      method: method == null && nullToAbsent
          ? const Value.absent()
          : Value(method),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SupplierPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierPayment(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      invoiceId: serializer.fromJson<String?>(json['invoiceId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      paidOn: serializer.fromJson<String>(json['paidOn']),
      method: serializer.fromJson<String?>(json['method']),
      reference: serializer.fromJson<String?>(json['reference']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'invoiceId': serializer.toJson<String?>(invoiceId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'paidOn': serializer.toJson<String>(paidOn),
      'method': serializer.toJson<String?>(method),
      'reference': serializer.toJson<String?>(reference),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  SupplierPayment copyWith({
    String? id,
    String? supplierId,
    Value<String?> invoiceId = const Value.absent(),
    int? amountMinor,
    String? paidOn,
    Value<String?> method = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => SupplierPayment(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    invoiceId: invoiceId.present ? invoiceId.value : this.invoiceId,
    amountMinor: amountMinor ?? this.amountMinor,
    paidOn: paidOn ?? this.paidOn,
    method: method.present ? method.value : this.method,
    reference: reference.present ? reference.value : this.reference,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SupplierPayment copyWithCompanion(SupplierPaymentsCompanion data) {
    return SupplierPayment(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      paidOn: data.paidOn.present ? data.paidOn.value : this.paidOn,
      method: data.method.present ? data.method.value : this.method,
      reference: data.reference.present ? data.reference.value : this.reference,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierPayment(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('paidOn: $paidOn, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    invoiceId,
    amountMinor,
    paidOn,
    method,
    reference,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierPayment &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.invoiceId == this.invoiceId &&
          other.amountMinor == this.amountMinor &&
          other.paidOn == this.paidOn &&
          other.method == this.method &&
          other.reference == this.reference &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class SupplierPaymentsCompanion extends UpdateCompanion<SupplierPayment> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String?> invoiceId;
  final Value<int> amountMinor;
  final Value<String> paidOn;
  final Value<String?> method;
  final Value<String?> reference;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const SupplierPaymentsCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.paidOn = const Value.absent(),
    this.method = const Value.absent(),
    this.reference = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierPaymentsCompanion.insert({
    required String id,
    required String supplierId,
    this.invoiceId = const Value.absent(),
    required int amountMinor,
    required String paidOn,
    this.method = const Value.absent(),
    this.reference = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       amountMinor = Value(amountMinor),
       paidOn = Value(paidOn),
       createdAt = Value(createdAt);
  static Insertable<SupplierPayment> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? invoiceId,
    Expression<int>? amountMinor,
    Expression<String>? paidOn,
    Expression<String>? method,
    Expression<String>? reference,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (paidOn != null) 'paid_on': paidOn,
      if (method != null) 'method': method,
      if (reference != null) 'reference': reference,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<String?>? invoiceId,
    Value<int>? amountMinor,
    Value<String>? paidOn,
    Value<String?>? method,
    Value<String?>? reference,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SupplierPaymentsCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      invoiceId: invoiceId ?? this.invoiceId,
      amountMinor: amountMinor ?? this.amountMinor,
      paidOn: paidOn ?? this.paidOn,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (paidOn.present) {
      map['paid_on'] = Variable<String>(paidOn.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('paidOn: $paidOn, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierCreditsTable extends SupplierCredits
    with TableInfo<$SupplierCreditsTable, SupplierCredit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierCreditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_invoices (id)',
    ),
  );
  static const VerificationMeta _returnIdMeta = const VerificationMeta(
    'returnId',
  );
  @override
  late final GeneratedColumn<String> returnId = GeneratedColumn<String>(
    'return_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_returns (id)',
    ),
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
  static const VerificationMeta _issuedOnMeta = const VerificationMeta(
    'issuedOn',
  );
  @override
  late final GeneratedColumn<String> issuedOn = GeneratedColumn<String>(
    'issued_on',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    invoiceId,
    returnId,
    amountMinor,
    issuedOn,
    note,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_credits';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierCredit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    }
    if (data.containsKey('return_id')) {
      context.handle(
        _returnIdMeta,
        returnId.isAcceptableOrUnknown(data['return_id']!, _returnIdMeta),
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
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('issued_on')) {
      context.handle(
        _issuedOnMeta,
        issuedOn.isAcceptableOrUnknown(data['issued_on']!, _issuedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedOnMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierCredit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierCredit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      ),
      returnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_id'],
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      issuedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issued_on'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SupplierCreditsTable createAlias(String alias) {
    return $SupplierCreditsTable(attachedDatabase, alias);
  }
}

class SupplierCredit extends DataClass implements Insertable<SupplierCredit> {
  final String id;
  final String supplierId;
  final String? invoiceId;
  final String? returnId;
  final int amountMinor;
  final String issuedOn;
  final String? note;
  final int createdAt;
  final int? deletedAt;
  const SupplierCredit({
    required this.id,
    required this.supplierId,
    this.invoiceId,
    this.returnId,
    required this.amountMinor,
    required this.issuedOn,
    this.note,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    if (!nullToAbsent || invoiceId != null) {
      map['invoice_id'] = Variable<String>(invoiceId);
    }
    if (!nullToAbsent || returnId != null) {
      map['return_id'] = Variable<String>(returnId);
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    map['issued_on'] = Variable<String>(issuedOn);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SupplierCreditsCompanion toCompanion(bool nullToAbsent) {
    return SupplierCreditsCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      invoiceId: invoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceId),
      returnId: returnId == null && nullToAbsent
          ? const Value.absent()
          : Value(returnId),
      amountMinor: Value(amountMinor),
      issuedOn: Value(issuedOn),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SupplierCredit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierCredit(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      invoiceId: serializer.fromJson<String?>(json['invoiceId']),
      returnId: serializer.fromJson<String?>(json['returnId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      issuedOn: serializer.fromJson<String>(json['issuedOn']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'invoiceId': serializer.toJson<String?>(invoiceId),
      'returnId': serializer.toJson<String?>(returnId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'issuedOn': serializer.toJson<String>(issuedOn),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  SupplierCredit copyWith({
    String? id,
    String? supplierId,
    Value<String?> invoiceId = const Value.absent(),
    Value<String?> returnId = const Value.absent(),
    int? amountMinor,
    String? issuedOn,
    Value<String?> note = const Value.absent(),
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => SupplierCredit(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    invoiceId: invoiceId.present ? invoiceId.value : this.invoiceId,
    returnId: returnId.present ? returnId.value : this.returnId,
    amountMinor: amountMinor ?? this.amountMinor,
    issuedOn: issuedOn ?? this.issuedOn,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SupplierCredit copyWithCompanion(SupplierCreditsCompanion data) {
    return SupplierCredit(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      returnId: data.returnId.present ? data.returnId.value : this.returnId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      issuedOn: data.issuedOn.present ? data.issuedOn.value : this.issuedOn,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierCredit(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('returnId: $returnId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('issuedOn: $issuedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    invoiceId,
    returnId,
    amountMinor,
    issuedOn,
    note,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierCredit &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.invoiceId == this.invoiceId &&
          other.returnId == this.returnId &&
          other.amountMinor == this.amountMinor &&
          other.issuedOn == this.issuedOn &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class SupplierCreditsCompanion extends UpdateCompanion<SupplierCredit> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String?> invoiceId;
  final Value<String?> returnId;
  final Value<int> amountMinor;
  final Value<String> issuedOn;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const SupplierCreditsCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.returnId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.issuedOn = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierCreditsCompanion.insert({
    required String id,
    required String supplierId,
    this.invoiceId = const Value.absent(),
    this.returnId = const Value.absent(),
    required int amountMinor,
    required String issuedOn,
    this.note = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       amountMinor = Value(amountMinor),
       issuedOn = Value(issuedOn),
       createdAt = Value(createdAt);
  static Insertable<SupplierCredit> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? invoiceId,
    Expression<String>? returnId,
    Expression<int>? amountMinor,
    Expression<String>? issuedOn,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (returnId != null) 'return_id': returnId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (issuedOn != null) 'issued_on': issuedOn,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierCreditsCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<String?>? invoiceId,
    Value<String?>? returnId,
    Value<int>? amountMinor,
    Value<String>? issuedOn,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SupplierCreditsCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      invoiceId: invoiceId ?? this.invoiceId,
      returnId: returnId ?? this.returnId,
      amountMinor: amountMinor ?? this.amountMinor,
      issuedOn: issuedOn ?? this.issuedOn,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (returnId.present) {
      map['return_id'] = Variable<String>(returnId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (issuedOn.present) {
      map['issued_on'] = Variable<String>(issuedOn.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierCreditsCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('returnId: $returnId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('issuedOn: $issuedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierReturnLinesTable extends SupplierReturnLines
    with TableInfo<$SupplierReturnLinesTable, SupplierReturnLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierReturnLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returnIdMeta = const VerificationMeta(
    'returnId',
  );
  @override
  late final GeneratedColumn<String> returnId = GeneratedColumn<String>(
    'return_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_returns (id)',
    ),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES batches (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMinorMeta = const VerificationMeta(
    'valueMinor',
  );
  @override
  late final GeneratedColumn<int> valueMinor = GeneratedColumn<int>(
    'value_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    returnId,
    batchId,
    quantity,
    valueMinor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_return_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierReturnLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('return_id')) {
      context.handle(
        _returnIdMeta,
        returnId.isAcceptableOrUnknown(data['return_id']!, _returnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_returnIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('value_minor')) {
      context.handle(
        _valueMinorMeta,
        valueMinor.isAcceptableOrUnknown(data['value_minor']!, _valueMinorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierReturnLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierReturnLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      returnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      valueMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_minor'],
      ),
    );
  }

  @override
  $SupplierReturnLinesTable createAlias(String alias) {
    return $SupplierReturnLinesTable(attachedDatabase, alias);
  }
}

class SupplierReturnLine extends DataClass
    implements Insertable<SupplierReturnLine> {
  final String id;
  final String returnId;
  final String batchId;
  final int quantity;
  final int? valueMinor;
  const SupplierReturnLine({
    required this.id,
    required this.returnId,
    required this.batchId,
    required this.quantity,
    this.valueMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['return_id'] = Variable<String>(returnId);
    map['batch_id'] = Variable<String>(batchId);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || valueMinor != null) {
      map['value_minor'] = Variable<int>(valueMinor);
    }
    return map;
  }

  SupplierReturnLinesCompanion toCompanion(bool nullToAbsent) {
    return SupplierReturnLinesCompanion(
      id: Value(id),
      returnId: Value(returnId),
      batchId: Value(batchId),
      quantity: Value(quantity),
      valueMinor: valueMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(valueMinor),
    );
  }

  factory SupplierReturnLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierReturnLine(
      id: serializer.fromJson<String>(json['id']),
      returnId: serializer.fromJson<String>(json['returnId']),
      batchId: serializer.fromJson<String>(json['batchId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      valueMinor: serializer.fromJson<int?>(json['valueMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'returnId': serializer.toJson<String>(returnId),
      'batchId': serializer.toJson<String>(batchId),
      'quantity': serializer.toJson<int>(quantity),
      'valueMinor': serializer.toJson<int?>(valueMinor),
    };
  }

  SupplierReturnLine copyWith({
    String? id,
    String? returnId,
    String? batchId,
    int? quantity,
    Value<int?> valueMinor = const Value.absent(),
  }) => SupplierReturnLine(
    id: id ?? this.id,
    returnId: returnId ?? this.returnId,
    batchId: batchId ?? this.batchId,
    quantity: quantity ?? this.quantity,
    valueMinor: valueMinor.present ? valueMinor.value : this.valueMinor,
  );
  SupplierReturnLine copyWithCompanion(SupplierReturnLinesCompanion data) {
    return SupplierReturnLine(
      id: data.id.present ? data.id.value : this.id,
      returnId: data.returnId.present ? data.returnId.value : this.returnId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      valueMinor: data.valueMinor.present
          ? data.valueMinor.value
          : this.valueMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReturnLine(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('batchId: $batchId, ')
          ..write('quantity: $quantity, ')
          ..write('valueMinor: $valueMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, returnId, batchId, quantity, valueMinor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierReturnLine &&
          other.id == this.id &&
          other.returnId == this.returnId &&
          other.batchId == this.batchId &&
          other.quantity == this.quantity &&
          other.valueMinor == this.valueMinor);
}

class SupplierReturnLinesCompanion extends UpdateCompanion<SupplierReturnLine> {
  final Value<String> id;
  final Value<String> returnId;
  final Value<String> batchId;
  final Value<int> quantity;
  final Value<int?> valueMinor;
  final Value<int> rowid;
  const SupplierReturnLinesCompanion({
    this.id = const Value.absent(),
    this.returnId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.valueMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierReturnLinesCompanion.insert({
    required String id,
    required String returnId,
    required String batchId,
    required int quantity,
    this.valueMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       returnId = Value(returnId),
       batchId = Value(batchId),
       quantity = Value(quantity);
  static Insertable<SupplierReturnLine> custom({
    Expression<String>? id,
    Expression<String>? returnId,
    Expression<String>? batchId,
    Expression<int>? quantity,
    Expression<int>? valueMinor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (returnId != null) 'return_id': returnId,
      if (batchId != null) 'batch_id': batchId,
      if (quantity != null) 'quantity': quantity,
      if (valueMinor != null) 'value_minor': valueMinor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierReturnLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? returnId,
    Value<String>? batchId,
    Value<int>? quantity,
    Value<int?>? valueMinor,
    Value<int>? rowid,
  }) {
    return SupplierReturnLinesCompanion(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
      batchId: batchId ?? this.batchId,
      quantity: quantity ?? this.quantity,
      valueMinor: valueMinor ?? this.valueMinor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (returnId.present) {
      map['return_id'] = Variable<String>(returnId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (valueMinor.present) {
      map['value_minor'] = Variable<int>(valueMinor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierReturnLinesCompanion(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('batchId: $batchId, ')
          ..write('quantity: $quantity, ')
          ..write('valueMinor: $valueMinor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReorderOrdersTable extends ReorderOrders
    with TableInfo<$ReorderOrdersTable, ReorderOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReorderOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id)',
    ),
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderedOnMeta = const VerificationMeta(
    'orderedOn',
  );
  @override
  late final GeneratedColumn<String> orderedOn = GeneratedColumn<String>(
    'ordered_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedOnMeta = const VerificationMeta(
    'expectedOn',
  );
  @override
  late final GeneratedColumn<String> expectedOn = GeneratedColumn<String>(
    'expected_on',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineId,
    supplierId,
    quantity,
    orderedOn,
    expectedOn,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reorder_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReorderOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('ordered_on')) {
      context.handle(
        _orderedOnMeta,
        orderedOn.isAcceptableOrUnknown(data['ordered_on']!, _orderedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_orderedOnMeta);
    }
    if (data.containsKey('expected_on')) {
      context.handle(
        _expectedOnMeta,
        expectedOn.isAcceptableOrUnknown(data['expected_on']!, _expectedOnMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
  ReorderOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReorderOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      orderedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ordered_on'],
      )!,
      expectedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_on'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReorderOrdersTable createAlias(String alias) {
    return $ReorderOrdersTable(attachedDatabase, alias);
  }
}

class ReorderOrder extends DataClass implements Insertable<ReorderOrder> {
  final String id;
  final String medicineId;
  final String? supplierId;
  final int quantity;
  final String orderedOn;
  final String? expectedOn;

  /// `ORDERED` | `RECEIVED` | `CANCELLED`.
  final String status;
  final int createdAt;
  const ReorderOrder({
    required this.id,
    required this.medicineId,
    this.supplierId,
    required this.quantity,
    required this.orderedOn,
    this.expectedOn,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medicine_id'] = Variable<String>(medicineId);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['quantity'] = Variable<int>(quantity);
    map['ordered_on'] = Variable<String>(orderedOn);
    if (!nullToAbsent || expectedOn != null) {
      map['expected_on'] = Variable<String>(expectedOn);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ReorderOrdersCompanion toCompanion(bool nullToAbsent) {
    return ReorderOrdersCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      quantity: Value(quantity),
      orderedOn: Value(orderedOn),
      expectedOn: expectedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedOn),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory ReorderOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReorderOrder(
      id: serializer.fromJson<String>(json['id']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      orderedOn: serializer.fromJson<String>(json['orderedOn']),
      expectedOn: serializer.fromJson<String?>(json['expectedOn']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicineId': serializer.toJson<String>(medicineId),
      'supplierId': serializer.toJson<String?>(supplierId),
      'quantity': serializer.toJson<int>(quantity),
      'orderedOn': serializer.toJson<String>(orderedOn),
      'expectedOn': serializer.toJson<String?>(expectedOn),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ReorderOrder copyWith({
    String? id,
    String? medicineId,
    Value<String?> supplierId = const Value.absent(),
    int? quantity,
    String? orderedOn,
    Value<String?> expectedOn = const Value.absent(),
    String? status,
    int? createdAt,
  }) => ReorderOrder(
    id: id ?? this.id,
    medicineId: medicineId ?? this.medicineId,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    quantity: quantity ?? this.quantity,
    orderedOn: orderedOn ?? this.orderedOn,
    expectedOn: expectedOn.present ? expectedOn.value : this.expectedOn,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  ReorderOrder copyWithCompanion(ReorderOrdersCompanion data) {
    return ReorderOrder(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      orderedOn: data.orderedOn.present ? data.orderedOn.value : this.orderedOn,
      expectedOn: data.expectedOn.present
          ? data.expectedOn.value
          : this.expectedOn,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReorderOrder(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('supplierId: $supplierId, ')
          ..write('quantity: $quantity, ')
          ..write('orderedOn: $orderedOn, ')
          ..write('expectedOn: $expectedOn, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicineId,
    supplierId,
    quantity,
    orderedOn,
    expectedOn,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReorderOrder &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.supplierId == this.supplierId &&
          other.quantity == this.quantity &&
          other.orderedOn == this.orderedOn &&
          other.expectedOn == this.expectedOn &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class ReorderOrdersCompanion extends UpdateCompanion<ReorderOrder> {
  final Value<String> id;
  final Value<String> medicineId;
  final Value<String?> supplierId;
  final Value<int> quantity;
  final Value<String> orderedOn;
  final Value<String?> expectedOn;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ReorderOrdersCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.orderedOn = const Value.absent(),
    this.expectedOn = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReorderOrdersCompanion.insert({
    required String id,
    required String medicineId,
    this.supplierId = const Value.absent(),
    required int quantity,
    required String orderedOn,
    this.expectedOn = const Value.absent(),
    required String status,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicineId = Value(medicineId),
       quantity = Value(quantity),
       orderedOn = Value(orderedOn),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<ReorderOrder> custom({
    Expression<String>? id,
    Expression<String>? medicineId,
    Expression<String>? supplierId,
    Expression<int>? quantity,
    Expression<String>? orderedOn,
    Expression<String>? expectedOn,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (quantity != null) 'quantity': quantity,
      if (orderedOn != null) 'ordered_on': orderedOn,
      if (expectedOn != null) 'expected_on': expectedOn,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReorderOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? medicineId,
    Value<String?>? supplierId,
    Value<int>? quantity,
    Value<String>? orderedOn,
    Value<String?>? expectedOn,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ReorderOrdersCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      supplierId: supplierId ?? this.supplierId,
      quantity: quantity ?? this.quantity,
      orderedOn: orderedOn ?? this.orderedOn,
      expectedOn: expectedOn ?? this.expectedOn,
      status: status ?? this.status,
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
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (orderedOn.present) {
      map['ordered_on'] = Variable<String>(orderedOn.value);
    }
    if (expectedOn.present) {
      map['expected_on'] = Variable<String>(expectedOn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReorderOrdersCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('supplierId: $supplierId, ')
          ..write('quantity: $quantity, ')
          ..write('orderedOn: $orderedOn, ')
          ..write('expectedOn: $expectedOn, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReorderReminderStateTable extends ReorderReminderState
    with TableInfo<$ReorderReminderStateTable, ReorderReminderStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReorderReminderStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id)',
    ),
  );
  static const VerificationMeta _lastNotifiedOnMeta = const VerificationMeta(
    'lastNotifiedOn',
  );
  @override
  late final GeneratedColumn<String> lastNotifiedOn = GeneratedColumn<String>(
    'last_notified_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    medicineId,
    lastNotifiedOn,
    snoozedUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reorder_reminder_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReorderReminderStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('last_notified_on')) {
      context.handle(
        _lastNotifiedOnMeta,
        lastNotifiedOn.isAcceptableOrUnknown(
          data['last_notified_on']!,
          _lastNotifiedOnMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {medicineId};
  @override
  ReorderReminderStateData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReorderReminderStateData(
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      lastNotifiedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_notified_on'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snoozed_until'],
      ),
    );
  }

  @override
  $ReorderReminderStateTable createAlias(String alias) {
    return $ReorderReminderStateTable(attachedDatabase, alias);
  }
}

class ReorderReminderStateData extends DataClass
    implements Insertable<ReorderReminderStateData> {
  final String medicineId;
  final String? lastNotifiedOn;
  final String? snoozedUntil;
  const ReorderReminderStateData({
    required this.medicineId,
    this.lastNotifiedOn,
    this.snoozedUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['medicine_id'] = Variable<String>(medicineId);
    if (!nullToAbsent || lastNotifiedOn != null) {
      map['last_notified_on'] = Variable<String>(lastNotifiedOn);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<String>(snoozedUntil);
    }
    return map;
  }

  ReorderReminderStateCompanion toCompanion(bool nullToAbsent) {
    return ReorderReminderStateCompanion(
      medicineId: Value(medicineId),
      lastNotifiedOn: lastNotifiedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastNotifiedOn),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
    );
  }

  factory ReorderReminderStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReorderReminderStateData(
      medicineId: serializer.fromJson<String>(json['medicineId']),
      lastNotifiedOn: serializer.fromJson<String?>(json['lastNotifiedOn']),
      snoozedUntil: serializer.fromJson<String?>(json['snoozedUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'medicineId': serializer.toJson<String>(medicineId),
      'lastNotifiedOn': serializer.toJson<String?>(lastNotifiedOn),
      'snoozedUntil': serializer.toJson<String?>(snoozedUntil),
    };
  }

  ReorderReminderStateData copyWith({
    String? medicineId,
    Value<String?> lastNotifiedOn = const Value.absent(),
    Value<String?> snoozedUntil = const Value.absent(),
  }) => ReorderReminderStateData(
    medicineId: medicineId ?? this.medicineId,
    lastNotifiedOn: lastNotifiedOn.present
        ? lastNotifiedOn.value
        : this.lastNotifiedOn,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
  );
  ReorderReminderStateData copyWithCompanion(
    ReorderReminderStateCompanion data,
  ) {
    return ReorderReminderStateData(
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      lastNotifiedOn: data.lastNotifiedOn.present
          ? data.lastNotifiedOn.value
          : this.lastNotifiedOn,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReorderReminderStateData(')
          ..write('medicineId: $medicineId, ')
          ..write('lastNotifiedOn: $lastNotifiedOn, ')
          ..write('snoozedUntil: $snoozedUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(medicineId, lastNotifiedOn, snoozedUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReorderReminderStateData &&
          other.medicineId == this.medicineId &&
          other.lastNotifiedOn == this.lastNotifiedOn &&
          other.snoozedUntil == this.snoozedUntil);
}

class ReorderReminderStateCompanion
    extends UpdateCompanion<ReorderReminderStateData> {
  final Value<String> medicineId;
  final Value<String?> lastNotifiedOn;
  final Value<String?> snoozedUntil;
  final Value<int> rowid;
  const ReorderReminderStateCompanion({
    this.medicineId = const Value.absent(),
    this.lastNotifiedOn = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReorderReminderStateCompanion.insert({
    required String medicineId,
    this.lastNotifiedOn = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : medicineId = Value(medicineId);
  static Insertable<ReorderReminderStateData> custom({
    Expression<String>? medicineId,
    Expression<String>? lastNotifiedOn,
    Expression<String>? snoozedUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (medicineId != null) 'medicine_id': medicineId,
      if (lastNotifiedOn != null) 'last_notified_on': lastNotifiedOn,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReorderReminderStateCompanion copyWith({
    Value<String>? medicineId,
    Value<String?>? lastNotifiedOn,
    Value<String?>? snoozedUntil,
    Value<int>? rowid,
  }) {
    return ReorderReminderStateCompanion(
      medicineId: medicineId ?? this.medicineId,
      lastNotifiedOn: lastNotifiedOn ?? this.lastNotifiedOn,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (lastNotifiedOn.present) {
      map['last_notified_on'] = Variable<String>(lastNotifiedOn.value);
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
    return (StringBuffer('ReorderReminderStateCompanion(')
          ..write('medicineId: $medicineId, ')
          ..write('lastNotifiedOn: $lastNotifiedOn, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledAlertsTable extends ScheduledAlerts
    with TableInfo<$ScheduledAlertsTable, ScheduledAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<int> fireAt = GeneratedColumn<int>(
    'fire_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _osIdMeta = const VerificationMeta('osId');
  @override
  late final GeneratedColumn<int> osId = GeneratedColumn<int>(
    'os_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    fireAt,
    osId,
    payload,
    contentHash,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduledAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(
        _fireAtMeta,
        fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('os_id')) {
      context.handle(
        _osIdMeta,
        osId.isAcceptableOrUnknown(data['os_id']!, _osIdMeta),
      );
    } else if (isInserting) {
      context.missing(_osIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      fireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fire_at'],
      )!,
      osId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}os_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $ScheduledAlertsTable createAlias(String alias) {
    return $ScheduledAlertsTable(attachedDatabase, alias);
  }
}

class ScheduledAlert extends DataClass implements Insertable<ScheduledAlert> {
  /// Deterministic logical key, e.g. `lead:2026-11-17`.
  final String id;

  /// EXPIRY_LEAD | EXPIRY_DAY | DIGEST | PAYMENT | REORDER | BACKUP.
  final String kind;

  /// UTC epoch milliseconds.
  final int fireAt;

  /// 31-bit id handed to the OS scheduler.
  final int osId;
  final String payload;
  final String contentHash;

  /// `PENDING` | `FIRED` | `CANCELLED`.
  final String state;
  const ScheduledAlert({
    required this.id,
    required this.kind,
    required this.fireAt,
    required this.osId,
    required this.payload,
    required this.contentHash,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['fire_at'] = Variable<int>(fireAt);
    map['os_id'] = Variable<int>(osId);
    map['payload'] = Variable<String>(payload);
    map['content_hash'] = Variable<String>(contentHash);
    map['state'] = Variable<String>(state);
    return map;
  }

  ScheduledAlertsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledAlertsCompanion(
      id: Value(id),
      kind: Value(kind),
      fireAt: Value(fireAt),
      osId: Value(osId),
      payload: Value(payload),
      contentHash: Value(contentHash),
      state: Value(state),
    );
  }

  factory ScheduledAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledAlert(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      fireAt: serializer.fromJson<int>(json['fireAt']),
      osId: serializer.fromJson<int>(json['osId']),
      payload: serializer.fromJson<String>(json['payload']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'fireAt': serializer.toJson<int>(fireAt),
      'osId': serializer.toJson<int>(osId),
      'payload': serializer.toJson<String>(payload),
      'contentHash': serializer.toJson<String>(contentHash),
      'state': serializer.toJson<String>(state),
    };
  }

  ScheduledAlert copyWith({
    String? id,
    String? kind,
    int? fireAt,
    int? osId,
    String? payload,
    String? contentHash,
    String? state,
  }) => ScheduledAlert(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    fireAt: fireAt ?? this.fireAt,
    osId: osId ?? this.osId,
    payload: payload ?? this.payload,
    contentHash: contentHash ?? this.contentHash,
    state: state ?? this.state,
  );
  ScheduledAlert copyWithCompanion(ScheduledAlertsCompanion data) {
    return ScheduledAlert(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      osId: data.osId.present ? data.osId.value : this.osId,
      payload: data.payload.present ? data.payload.value : this.payload,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledAlert(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('fireAt: $fireAt, ')
          ..write('osId: $osId, ')
          ..write('payload: $payload, ')
          ..write('contentHash: $contentHash, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, fireAt, osId, payload, contentHash, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledAlert &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.fireAt == this.fireAt &&
          other.osId == this.osId &&
          other.payload == this.payload &&
          other.contentHash == this.contentHash &&
          other.state == this.state);
}

class ScheduledAlertsCompanion extends UpdateCompanion<ScheduledAlert> {
  final Value<String> id;
  final Value<String> kind;
  final Value<int> fireAt;
  final Value<int> osId;
  final Value<String> payload;
  final Value<String> contentHash;
  final Value<String> state;
  final Value<int> rowid;
  const ScheduledAlertsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.osId = const Value.absent(),
    this.payload = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduledAlertsCompanion.insert({
    required String id,
    required String kind,
    required int fireAt,
    required int osId,
    required String payload,
    required String contentHash,
    required String state,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       fireAt = Value(fireAt),
       osId = Value(osId),
       payload = Value(payload),
       contentHash = Value(contentHash),
       state = Value(state);
  static Insertable<ScheduledAlert> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<int>? fireAt,
    Expression<int>? osId,
    Expression<String>? payload,
    Expression<String>? contentHash,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (fireAt != null) 'fire_at': fireAt,
      if (osId != null) 'os_id': osId,
      if (payload != null) 'payload': payload,
      if (contentHash != null) 'content_hash': contentHash,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduledAlertsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<int>? fireAt,
    Value<int>? osId,
    Value<String>? payload,
    Value<String>? contentHash,
    Value<String>? state,
    Value<int>? rowid,
  }) {
    return ScheduledAlertsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      fireAt: fireAt ?? this.fireAt,
      osId: osId ?? this.osId,
      payload: payload ?? this.payload,
      contentHash: contentHash ?? this.contentHash,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<int>(fireAt.value);
    }
    if (osId.present) {
      map['os_id'] = Variable<int>(osId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
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
    return (StringBuffer('ScheduledAlertsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('fireAt: $fireAt, ')
          ..write('osId: $osId, ')
          ..write('payload: $payload, ')
          ..write('contentHash: $contentHash, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertLogTable extends AlertLog
    with TableInfo<$AlertLogTable, AlertLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
    'route',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firedAtMeta = const VerificationMeta(
    'firedAt',
  );
  @override
  late final GeneratedColumn<int> firedAt = GeneratedColumn<int>(
    'fired_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<int> openedAt = GeneratedColumn<int>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    body,
    route,
    firedAt,
    openedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('route')) {
      context.handle(
        _routeMeta,
        route.isAcceptableOrUnknown(data['route']!, _routeMeta),
      );
    }
    if (data.containsKey('fired_at')) {
      context.handle(
        _firedAtMeta,
        firedAt.isAcceptableOrUnknown(data['fired_at']!, _firedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_firedAtMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      route: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route'],
      ),
      firedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fired_at'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opened_at'],
      ),
    );
  }

  @override
  $AlertLogTable createAlias(String alias) {
    return $AlertLogTable(attachedDatabase, alias);
  }
}

class AlertLogData extends DataClass implements Insertable<AlertLogData> {
  final String id;
  final String kind;
  final String title;
  final String body;
  final String? route;
  final int firedAt;
  final int? openedAt;
  const AlertLogData({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.route,
    required this.firedAt,
    this.openedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || route != null) {
      map['route'] = Variable<String>(route);
    }
    map['fired_at'] = Variable<int>(firedAt);
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<int>(openedAt);
    }
    return map;
  }

  AlertLogCompanion toCompanion(bool nullToAbsent) {
    return AlertLogCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      body: Value(body),
      route: route == null && nullToAbsent
          ? const Value.absent()
          : Value(route),
      firedAt: Value(firedAt),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
    );
  }

  factory AlertLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertLogData(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      route: serializer.fromJson<String?>(json['route']),
      firedAt: serializer.fromJson<int>(json['firedAt']),
      openedAt: serializer.fromJson<int?>(json['openedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'route': serializer.toJson<String?>(route),
      'firedAt': serializer.toJson<int>(firedAt),
      'openedAt': serializer.toJson<int?>(openedAt),
    };
  }

  AlertLogData copyWith({
    String? id,
    String? kind,
    String? title,
    String? body,
    Value<String?> route = const Value.absent(),
    int? firedAt,
    Value<int?> openedAt = const Value.absent(),
  }) => AlertLogData(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    body: body ?? this.body,
    route: route.present ? route.value : this.route,
    firedAt: firedAt ?? this.firedAt,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
  );
  AlertLogData copyWithCompanion(AlertLogCompanion data) {
    return AlertLogData(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      route: data.route.present ? data.route.value : this.route,
      firedAt: data.firedAt.present ? data.firedAt.value : this.firedAt,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertLogData(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('route: $route, ')
          ..write('firedAt: $firedAt, ')
          ..write('openedAt: $openedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, title, body, route, firedAt, openedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertLogData &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.body == this.body &&
          other.route == this.route &&
          other.firedAt == this.firedAt &&
          other.openedAt == this.openedAt);
}

class AlertLogCompanion extends UpdateCompanion<AlertLogData> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> route;
  final Value<int> firedAt;
  final Value<int?> openedAt;
  final Value<int> rowid;
  const AlertLogCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.route = const Value.absent(),
    this.firedAt = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertLogCompanion.insert({
    required String id,
    required String kind,
    required String title,
    required String body,
    this.route = const Value.absent(),
    required int firedAt,
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       title = Value(title),
       body = Value(body),
       firedAt = Value(firedAt);
  static Insertable<AlertLogData> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? route,
    Expression<int>? firedAt,
    Expression<int>? openedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (route != null) 'route': route,
      if (firedAt != null) 'fired_at': firedAt,
      if (openedAt != null) 'opened_at': openedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertLogCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? route,
    Value<int>? firedAt,
    Value<int?>? openedAt,
    Value<int>? rowid,
  }) {
    return AlertLogCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      firedAt: firedAt ?? this.firedAt,
      openedAt: openedAt ?? this.openedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (firedAt.present) {
      map['fired_at'] = Variable<int>(firedAt.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<int>(openedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertLogCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('route: $route, ')
          ..write('firedAt: $firedAt, ')
          ..write('openedAt: $openedAt, ')
          ..write('rowid: $rowid')
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
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $MedicineBarcodesTable medicineBarcodes = $MedicineBarcodesTable(
    this,
  );
  late final $SupplierInvoicesTable supplierInvoices = $SupplierInvoicesTable(
    this,
  );
  late final $BatchesTable batches = $BatchesTable(this);
  late final $SupplierReturnsTable supplierReturns = $SupplierReturnsTable(
    this,
  );
  late final $StockAdjustmentsTable stockAdjustments = $StockAdjustmentsTable(
    this,
  );
  late final $SupplierPaymentsTable supplierPayments = $SupplierPaymentsTable(
    this,
  );
  late final $SupplierCreditsTable supplierCredits = $SupplierCreditsTable(
    this,
  );
  late final $SupplierReturnLinesTable supplierReturnLines =
      $SupplierReturnLinesTable(this);
  late final $ReorderOrdersTable reorderOrders = $ReorderOrdersTable(this);
  late final $ReorderReminderStateTable reorderReminderState =
      $ReorderReminderStateTable(this);
  late final $ScheduledAlertsTable scheduledAlerts = $ScheduledAlertsTable(
    this,
  );
  late final $AlertLogTable alertLog = $AlertLogTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index idxMedSearch = Index(
    'idx_med_search',
    'CREATE INDEX idx_med_search ON medicines (search_text)',
  );
  late final Index idxBatchExpiry = Index(
    'idx_batch_expiry',
    'CREATE INDEX idx_batch_expiry ON batches (expiry_date)',
  );
  late final Index idxBatchMed = Index(
    'idx_batch_med',
    'CREATE INDEX idx_batch_med ON batches (medicine_id)',
  );
  late final Index idxBatchSupplier = Index(
    'idx_batch_supplier',
    'CREATE INDEX idx_batch_supplier ON batches (supplier_id)',
  );
  late final Index idxInvDue = Index(
    'idx_inv_due',
    'CREATE INDEX idx_inv_due ON supplier_invoices (due_date)',
  );
  late final Index idxAlertFire = Index(
    'idx_alert_fire',
    'CREATE INDEX idx_alert_fire ON scheduled_alerts (fire_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    suppliers,
    medicines,
    medicineBarcodes,
    supplierInvoices,
    batches,
    supplierReturns,
    stockAdjustments,
    supplierPayments,
    supplierCredits,
    supplierReturnLines,
    reorderOrders,
    reorderReminderState,
    scheduledAlerts,
    alertLog,
    settings,
    idxMedSearch,
    idxBatchExpiry,
    idxBatchMed,
    idxBatchSupplier,
    idxInvDue,
    idxAlertFire,
  ];
}

typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String name,
  Value<String?> contactPerson,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String?> taxId,
  Value<int?> paymentTermsDays,
  Value<String?> notes,
  Value<bool> isArchived,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> contactPerson,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String?> taxId,
  Value<int?> paymentTermsDays,
  Value<String?> notes,
  Value<bool> isArchived,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$SuppliersTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliersTable, Supplier> {
  $$SuppliersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicinesTable, List<Medicine>>
  _medicinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicines,
    aliasName: 'suppliers__id__medicines__preferred_supplier_id',
  );

  $$MedicinesTableProcessedTableManager get medicinesRefs {
    final manager = $$MedicinesTableTableManager($_db, $_db.medicines).filter(
      (f) => f.preferredSupplierId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_medicinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierInvoicesTable, List<SupplierInvoice>>
  _supplierInvoicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierInvoices,
    aliasName: 'suppliers__id__supplier_invoices__supplier_id',
  );

  $$SupplierInvoicesTableProcessedTableManager get supplierInvoicesRefs {
    final manager = $$SupplierInvoicesTableTableManager(
      $_db,
      $_db.supplierInvoices,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierInvoicesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BatchesTable, List<Batche>> _batchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.batches,
    aliasName: 'suppliers__id__batches__supplier_id',
  );

  $$BatchesTableProcessedTableManager get batchesRefs {
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierReturnsTable, List<SupplierReturn>>
  _supplierReturnsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierReturns,
    aliasName: 'suppliers__id__supplier_returns__supplier_id',
  );

  $$SupplierReturnsTableProcessedTableManager get supplierReturnsRefs {
    final manager = $$SupplierReturnsTableTableManager(
      $_db,
      $_db.supplierReturns,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierReturnsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierPaymentsTable, List<SupplierPayment>>
  _supplierPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierPayments,
    aliasName: 'suppliers__id__supplier_payments__supplier_id',
  );

  $$SupplierPaymentsTableProcessedTableManager get supplierPaymentsRefs {
    final manager = $$SupplierPaymentsTableTableManager(
      $_db,
      $_db.supplierPayments,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierCreditsTable, List<SupplierCredit>>
  _supplierCreditsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierCredits,
    aliasName: 'suppliers__id__supplier_credits__supplier_id',
  );

  $$SupplierCreditsTableProcessedTableManager get supplierCreditsRefs {
    final manager = $$SupplierCreditsTableTableManager(
      $_db,
      $_db.supplierCredits,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierCreditsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReorderOrdersTable, List<ReorderOrder>>
  _reorderOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reorderOrders,
    aliasName: 'suppliers__id__reorder_orders__supplier_id',
  );

  $$ReorderOrdersTableProcessedTableManager get reorderOrdersRefs {
    final manager = $$ReorderOrdersTableTableManager(
      $_db,
      $_db.reorderOrders,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reorderOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
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

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentTermsDays => $composableBuilder(
    column: $table.paymentTermsDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicinesRefs(
    Expression<bool> Function($$MedicinesTableFilterComposer f) f,
  ) {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.preferredSupplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierInvoicesRefs(
    Expression<bool> Function($$SupplierInvoicesTableFilterComposer f) f,
  ) {
    final $$SupplierInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> batchesRefs(
    Expression<bool> Function($$BatchesTableFilterComposer f) f,
  ) {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierReturnsRefs(
    Expression<bool> Function($$SupplierReturnsTableFilterComposer f) f,
  ) {
    final $$SupplierReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableFilterComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierPaymentsRefs(
    Expression<bool> Function($$SupplierPaymentsTableFilterComposer f) f,
  ) {
    final $$SupplierPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierCreditsRefs(
    Expression<bool> Function($$SupplierCreditsTableFilterComposer f) f,
  ) {
    final $$SupplierCreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierCredits,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierCreditsTableFilterComposer(
            $db: $db,
            $table: $db.supplierCredits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reorderOrdersRefs(
    Expression<bool> Function($$ReorderOrdersTableFilterComposer f) f,
  ) {
    final $$ReorderOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reorderOrders,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReorderOrdersTableFilterComposer(
            $db: $db,
            $table: $db.reorderOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
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

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentTermsDays => $composableBuilder(
    column: $table.paymentTermsDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
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

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get taxId =>
      $composableBuilder(column: $table.taxId, builder: (column) => column);

  GeneratedColumn<int> get paymentTermsDays => $composableBuilder(
    column: $table.paymentTermsDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> medicinesRefs<T extends Object>(
    Expression<T> Function($$MedicinesTableAnnotationComposer a) f,
  ) {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.preferredSupplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierInvoicesRefs<T extends Object>(
    Expression<T> Function($$SupplierInvoicesTableAnnotationComposer a) f,
  ) {
    final $$SupplierInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> batchesRefs<T extends Object>(
    Expression<T> Function($$BatchesTableAnnotationComposer a) f,
  ) {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierReturnsRefs<T extends Object>(
    Expression<T> Function($$SupplierReturnsTableAnnotationComposer a) f,
  ) {
    final $$SupplierReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierPaymentsRefs<T extends Object>(
    Expression<T> Function($$SupplierPaymentsTableAnnotationComposer a) f,
  ) {
    final $$SupplierPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierCreditsRefs<T extends Object>(
    Expression<T> Function($$SupplierCreditsTableAnnotationComposer a) f,
  ) {
    final $$SupplierCreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierCredits,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierCreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierCredits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reorderOrdersRefs<T extends Object>(
    Expression<T> Function($$ReorderOrdersTableAnnotationComposer a) f,
  ) {
    final $$ReorderOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reorderOrders,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReorderOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.reorderOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          Supplier,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (Supplier, $$SuppliersTableReferences),
          Supplier,
          PrefetchHooks Function({
            bool medicinesRefs,
            bool supplierInvoicesRefs,
            bool batchesRefs,
            bool supplierReturnsRefs,
            bool supplierPaymentsRefs,
            bool supplierCreditsRefs,
            bool reorderOrdersRefs,
          })
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> taxId = const Value.absent(),
                Value<int?> paymentTermsDays = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                address: address,
                taxId: taxId,
                paymentTermsDays: paymentTermsDays,
                notes: notes,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> taxId = const Value.absent(),
                Value<int?> paymentTermsDays = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                contactPerson: contactPerson,
                phone: phone,
                email: email,
                address: address,
                taxId: taxId,
                paymentTermsDays: paymentTermsDays,
                notes: notes,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuppliersTable, Supplier>(table),
                  $$SuppliersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicinesRefs = false,
                supplierInvoicesRefs = false,
                batchesRefs = false,
                supplierReturnsRefs = false,
                supplierPaymentsRefs = false,
                supplierCreditsRefs = false,
                reorderOrdersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicinesRefs) db.medicines,
                    if (supplierInvoicesRefs) db.supplierInvoices,
                    if (batchesRefs) db.batches,
                    if (supplierReturnsRefs) db.supplierReturns,
                    if (supplierPaymentsRefs) db.supplierPayments,
                    if (supplierCreditsRefs) db.supplierCredits,
                    if (reorderOrdersRefs) db.reorderOrders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicinesRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          Medicine
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._medicinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).medicinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.preferredSupplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierInvoicesRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          SupplierInvoice
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._supplierInvoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierInvoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (batchesRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          Batche
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._batchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).batchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierReturnsRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          SupplierReturn
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._supplierReturnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierReturnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierPaymentsRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          SupplierPayment
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._supplierPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierCreditsRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          SupplierCredit
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._supplierCreditsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierCreditsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reorderOrdersRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          ReorderOrder
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._reorderOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).reorderOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
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

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      Supplier,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (Supplier, $$SuppliersTableReferences),
      Supplier,
      PrefetchHooks Function({
        bool medicinesRefs,
        bool supplierInvoicesRefs,
        bool batchesRefs,
        bool supplierReturnsRefs,
        bool supplierPaymentsRefs,
        bool supplierCreditsRefs,
        bool reorderOrdersRefs,
      })
    >;
typedef $$MedicinesTableCreateCompanionBuilder = MedicinesCompanion Function({
  required String id,
  required String brandName,
  Value<String?> genericName,
  Value<String?> strength,
  Value<String> dosageForm,
  Value<String> unit,
  Value<int?> packSize,
  Value<String?> manufacturer,
  Value<String?> category,
  Value<int> reorderLevel,
  Value<String?> preferredSupplierId,
  Value<int?> alertWindowDays,
  Value<String?> storageCondition,
  Value<String?> notes,
  Value<bool> isArchived,
  required String searchText,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$MedicinesTableUpdateCompanionBuilder = MedicinesCompanion Function({
  Value<String> id,
  Value<String> brandName,
  Value<String?> genericName,
  Value<String?> strength,
  Value<String> dosageForm,
  Value<String> unit,
  Value<int?> packSize,
  Value<String?> manufacturer,
  Value<String?> category,
  Value<int> reorderLevel,
  Value<String?> preferredSupplierId,
  Value<int?> alertWindowDays,
  Value<String?> storageCondition,
  Value<String?> notes,
  Value<bool> isArchived,
  Value<String> searchText,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$MedicinesTableReferences
    extends BaseReferences<_$AppDatabase, $MedicinesTable, Medicine> {
  $$MedicinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SuppliersTable _preferredSupplierIdTable(_$AppDatabase db) => db
      .suppliers
      .createAlias('medicines__preferred_supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager? get preferredSupplierId {
    final $_column = $_itemColumn<String>('preferred_supplier_id');
    if ($_column == null) return null;
    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_preferredSupplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MedicineBarcodesTable, List<MedicineBarcode>>
  _medicineBarcodesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicineBarcodes,
    aliasName: 'medicines__id__medicine_barcodes__medicine_id',
  );

  $$MedicineBarcodesTableProcessedTableManager get medicineBarcodesRefs {
    final manager = $$MedicineBarcodesTableTableManager(
      $_db,
      $_db.medicineBarcodes,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicineBarcodesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BatchesTable, List<Batche>> _batchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.batches,
    aliasName: 'medicines__id__batches__medicine_id',
  );

  $$BatchesTableProcessedTableManager get batchesRefs {
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReorderOrdersTable, List<ReorderOrder>>
  _reorderOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reorderOrders,
    aliasName: 'medicines__id__reorder_orders__medicine_id',
  );

  $$ReorderOrdersTableProcessedTableManager get reorderOrdersRefs {
    final manager = $$ReorderOrdersTableTableManager(
      $_db,
      $_db.reorderOrders,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reorderOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ReorderReminderStateTable,
    List<ReorderReminderStateData>
  >
  _reorderReminderStateRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reorderReminderState,
        aliasName: 'medicines__id__reorder_reminder_state__medicine_id',
      );

  $$ReorderReminderStateTableProcessedTableManager
  get reorderReminderStateRefs {
    final manager = $$ReorderReminderStateTableTableManager(
      $_db,
      $_db.reorderReminderState,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reorderReminderStateRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicinesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableFilterComposer({
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

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packSize => $composableBuilder(
    column: $table.packSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alertWindowDays => $composableBuilder(
    column: $table.alertWindowDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageCondition => $composableBuilder(
    column: $table.storageCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get preferredSupplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preferredSupplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> medicineBarcodesRefs(
    Expression<bool> Function($$MedicineBarcodesTableFilterComposer f) f,
  ) {
    final $$MedicineBarcodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicineBarcodes,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicineBarcodesTableFilterComposer(
            $db: $db,
            $table: $db.medicineBarcodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> batchesRefs(
    Expression<bool> Function($$BatchesTableFilterComposer f) f,
  ) {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reorderOrdersRefs(
    Expression<bool> Function($$ReorderOrdersTableFilterComposer f) f,
  ) {
    final $$ReorderOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reorderOrders,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReorderOrdersTableFilterComposer(
            $db: $db,
            $table: $db.reorderOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reorderReminderStateRefs(
    Expression<bool> Function($$ReorderReminderStateTableFilterComposer f) f,
  ) {
    final $$ReorderReminderStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reorderReminderState,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReorderReminderStateTableFilterComposer(
            $db: $db,
            $table: $db.reorderReminderState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableOrderingComposer({
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

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packSize => $composableBuilder(
    column: $table.packSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alertWindowDays => $composableBuilder(
    column: $table.alertWindowDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageCondition => $composableBuilder(
    column: $table.storageCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get preferredSupplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preferredSupplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<String> get genericName => $composableBuilder(
    column: $table.genericName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get dosageForm => $composableBuilder(
    column: $table.dosageForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get packSize =>
      $composableBuilder(column: $table.packSize, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get alertWindowDays => $composableBuilder(
    column: $table.alertWindowDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storageCondition => $composableBuilder(
    column: $table.storageCondition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get preferredSupplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preferredSupplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> medicineBarcodesRefs<T extends Object>(
    Expression<T> Function($$MedicineBarcodesTableAnnotationComposer a) f,
  ) {
    final $$MedicineBarcodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicineBarcodes,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicineBarcodesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicineBarcodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> batchesRefs<T extends Object>(
    Expression<T> Function($$BatchesTableAnnotationComposer a) f,
  ) {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reorderOrdersRefs<T extends Object>(
    Expression<T> Function($$ReorderOrdersTableAnnotationComposer a) f,
  ) {
    final $$ReorderOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reorderOrders,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReorderOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.reorderOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reorderReminderStateRefs<T extends Object>(
    Expression<T> Function($$ReorderReminderStateTableAnnotationComposer a) f,
  ) {
    final $$ReorderReminderStateTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reorderReminderState,
          getReferencedColumn: (t) => t.medicineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReorderReminderStateTableAnnotationComposer(
                $db: $db,
                $table: $db.reorderReminderState,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MedicinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesTable,
          Medicine,
          $$MedicinesTableFilterComposer,
          $$MedicinesTableOrderingComposer,
          $$MedicinesTableAnnotationComposer,
          $$MedicinesTableCreateCompanionBuilder,
          $$MedicinesTableUpdateCompanionBuilder,
          (Medicine, $$MedicinesTableReferences),
          Medicine,
          PrefetchHooks Function({
            bool preferredSupplierId,
            bool medicineBarcodesRefs,
            bool batchesRefs,
            bool reorderOrdersRefs,
            bool reorderReminderStateRefs,
          })
        > {
  $$MedicinesTableTableManager(_$AppDatabase db, $MedicinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> brandName = const Value.absent(),
                Value<String?> genericName = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String> dosageForm = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> packSize = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> reorderLevel = const Value.absent(),
                Value<String?> preferredSupplierId = const Value.absent(),
                Value<int?> alertWindowDays = const Value.absent(),
                Value<String?> storageCondition = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion(
                id: id,
                brandName: brandName,
                genericName: genericName,
                strength: strength,
                dosageForm: dosageForm,
                unit: unit,
                packSize: packSize,
                manufacturer: manufacturer,
                category: category,
                reorderLevel: reorderLevel,
                preferredSupplierId: preferredSupplierId,
                alertWindowDays: alertWindowDays,
                storageCondition: storageCondition,
                notes: notes,
                isArchived: isArchived,
                searchText: searchText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String brandName,
                Value<String?> genericName = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String> dosageForm = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> packSize = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> reorderLevel = const Value.absent(),
                Value<String?> preferredSupplierId = const Value.absent(),
                Value<int?> alertWindowDays = const Value.absent(),
                Value<String?> storageCondition = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required String searchText,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion.insert(
                id: id,
                brandName: brandName,
                genericName: genericName,
                strength: strength,
                dosageForm: dosageForm,
                unit: unit,
                packSize: packSize,
                manufacturer: manufacturer,
                category: category,
                reorderLevel: reorderLevel,
                preferredSupplierId: preferredSupplierId,
                alertWindowDays: alertWindowDays,
                storageCondition: storageCondition,
                notes: notes,
                isArchived: isArchived,
                searchText: searchText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicinesTable, Medicine>(table),
                  $$MedicinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                preferredSupplierId = false,
                medicineBarcodesRefs = false,
                batchesRefs = false,
                reorderOrdersRefs = false,
                reorderReminderStateRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicineBarcodesRefs) db.medicineBarcodes,
                    if (batchesRefs) db.batches,
                    if (reorderOrdersRefs) db.reorderOrders,
                    if (reorderReminderStateRefs) db.reorderReminderState,
                  ],
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
                        if (preferredSupplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.preferredSupplierId,
                            referencedTable: $$MedicinesTableReferences
                                ._preferredSupplierIdTable(db),
                            referencedColumn: $$MedicinesTableReferences
                                ._preferredSupplierIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicineBarcodesRefs)
                        await $_getPrefetchedData<
                          Medicine,
                          $MedicinesTable,
                          MedicineBarcode
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._medicineBarcodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).medicineBarcodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (batchesRefs)
                        await $_getPrefetchedData<
                          Medicine,
                          $MedicinesTable,
                          Batche
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._batchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).batchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reorderOrdersRefs)
                        await $_getPrefetchedData<
                          Medicine,
                          $MedicinesTable,
                          ReorderOrder
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._reorderOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).reorderOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reorderReminderStateRefs)
                        await $_getPrefetchedData<
                          Medicine,
                          $MedicinesTable,
                          ReorderReminderStateData
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._reorderReminderStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).reorderReminderStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
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

typedef $$MedicinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesTable,
      Medicine,
      $$MedicinesTableFilterComposer,
      $$MedicinesTableOrderingComposer,
      $$MedicinesTableAnnotationComposer,
      $$MedicinesTableCreateCompanionBuilder,
      $$MedicinesTableUpdateCompanionBuilder,
      (Medicine, $$MedicinesTableReferences),
      Medicine,
      PrefetchHooks Function({
        bool preferredSupplierId,
        bool medicineBarcodesRefs,
        bool batchesRefs,
        bool reorderOrdersRefs,
        bool reorderReminderStateRefs,
      })
    >;
typedef $$MedicineBarcodesTableCreateCompanionBuilder =
    MedicineBarcodesCompanion Function({
      required String id,
      required String medicineId,
      required String value,
      Value<String?> symbology,
      Value<int> rowid,
    });
typedef $$MedicineBarcodesTableUpdateCompanionBuilder =
    MedicineBarcodesCompanion Function({
      Value<String> id,
      Value<String> medicineId,
      Value<String> value,
      Value<String?> symbology,
      Value<int> rowid,
    });

final class $$MedicineBarcodesTableReferences
    extends
        BaseReferences<_$AppDatabase, $MedicineBarcodesTable, MedicineBarcode> {
  $$MedicineBarcodesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) =>
      db.medicines.createAlias('medicine_barcodes__medicine_id__medicines__id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicineBarcodesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicineBarcodesTable> {
  $$MedicineBarcodesTableFilterComposer({
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

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbology => $composableBuilder(
    column: $table.symbology,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicineBarcodesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicineBarcodesTable> {
  $$MedicineBarcodesTableOrderingComposer({
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

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbology => $composableBuilder(
    column: $table.symbology,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicineBarcodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicineBarcodesTable> {
  $$MedicineBarcodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get symbology =>
      $composableBuilder(column: $table.symbology, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicineBarcodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicineBarcodesTable,
          MedicineBarcode,
          $$MedicineBarcodesTableFilterComposer,
          $$MedicineBarcodesTableOrderingComposer,
          $$MedicineBarcodesTableAnnotationComposer,
          $$MedicineBarcodesTableCreateCompanionBuilder,
          $$MedicineBarcodesTableUpdateCompanionBuilder,
          (MedicineBarcode, $$MedicineBarcodesTableReferences),
          MedicineBarcode,
          PrefetchHooks Function({bool medicineId})
        > {
  $$MedicineBarcodesTableTableManager(
    _$AppDatabase db,
    $MedicineBarcodesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicineBarcodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicineBarcodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicineBarcodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> symbology = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicineBarcodesCompanion(
                id: id,
                medicineId: medicineId,
                value: value,
                symbology: symbology,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicineId,
                required String value,
                Value<String?> symbology = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicineBarcodesCompanion.insert(
                id: id,
                medicineId: medicineId,
                value: value,
                symbology: symbology,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicineBarcodesTable, MedicineBarcode>(table),
                  $$MedicineBarcodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicineId = false}) {
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
                    if (medicineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicineId,
                        referencedTable: $$MedicineBarcodesTableReferences
                            ._medicineIdTable(db),
                        referencedColumn: $$MedicineBarcodesTableReferences
                            ._medicineIdTable(db)
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

typedef $$MedicineBarcodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicineBarcodesTable,
      MedicineBarcode,
      $$MedicineBarcodesTableFilterComposer,
      $$MedicineBarcodesTableOrderingComposer,
      $$MedicineBarcodesTableAnnotationComposer,
      $$MedicineBarcodesTableCreateCompanionBuilder,
      $$MedicineBarcodesTableUpdateCompanionBuilder,
      (MedicineBarcode, $$MedicineBarcodesTableReferences),
      MedicineBarcode,
      PrefetchHooks Function({bool medicineId})
    >;
typedef $$SupplierInvoicesTableCreateCompanionBuilder =
    SupplierInvoicesCompanion Function({
      required String id,
      required String supplierId,
      Value<String?> invoiceNumber,
      required String invoiceDate,
      Value<String?> dueDate,
      required int totalMinor,
      Value<String?> notes,
      Value<String?> remindersSnoozedUntil,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$SupplierInvoicesTableUpdateCompanionBuilder =
    SupplierInvoicesCompanion Function({
      Value<String> id,
      Value<String> supplierId,
      Value<String?> invoiceNumber,
      Value<String> invoiceDate,
      Value<String?> dueDate,
      Value<int> totalMinor,
      Value<String?> notes,
      Value<String?> remindersSnoozedUntil,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$SupplierInvoicesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SupplierInvoicesTable, SupplierInvoice> {
  $$SupplierInvoicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('supplier_invoices__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BatchesTable, List<Batche>> _batchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.batches,
    aliasName: 'supplier_invoices__id__batches__invoice_id',
  );

  $$BatchesTableProcessedTableManager get batchesRefs {
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierPaymentsTable, List<SupplierPayment>>
  _supplierPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierPayments,
    aliasName: 'supplier_invoices__id__supplier_payments__invoice_id',
  );

  $$SupplierPaymentsTableProcessedTableManager get supplierPaymentsRefs {
    final manager = $$SupplierPaymentsTableTableManager(
      $_db,
      $_db.supplierPayments,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierCreditsTable, List<SupplierCredit>>
  _supplierCreditsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierCredits,
    aliasName: 'supplier_invoices__id__supplier_credits__invoice_id',
  );

  $$SupplierCreditsTableProcessedTableManager get supplierCreditsRefs {
    final manager = $$SupplierCreditsTableTableManager(
      $_db,
      $_db.supplierCredits,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierCreditsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupplierInvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierInvoicesTable> {
  $$SupplierInvoicesTableFilterComposer({
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

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remindersSnoozedUntil => $composableBuilder(
    column: $table.remindersSnoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> batchesRefs(
    Expression<bool> Function($$BatchesTableFilterComposer f) f,
  ) {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierPaymentsRefs(
    Expression<bool> Function($$SupplierPaymentsTableFilterComposer f) f,
  ) {
    final $$SupplierPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierCreditsRefs(
    Expression<bool> Function($$SupplierCreditsTableFilterComposer f) f,
  ) {
    final $$SupplierCreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierCredits,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierCreditsTableFilterComposer(
            $db: $db,
            $table: $db.supplierCredits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SupplierInvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierInvoicesTable> {
  $$SupplierInvoicesTableOrderingComposer({
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

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remindersSnoozedUntil => $composableBuilder(
    column: $table.remindersSnoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierInvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierInvoicesTable> {
  $$SupplierInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get remindersSnoozedUntil => $composableBuilder(
    column: $table.remindersSnoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> batchesRefs<T extends Object>(
    Expression<T> Function($$BatchesTableAnnotationComposer a) f,
  ) {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierPaymentsRefs<T extends Object>(
    Expression<T> Function($$SupplierPaymentsTableAnnotationComposer a) f,
  ) {
    final $$SupplierPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierCreditsRefs<T extends Object>(
    Expression<T> Function($$SupplierCreditsTableAnnotationComposer a) f,
  ) {
    final $$SupplierCreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierCredits,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierCreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierCredits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SupplierInvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierInvoicesTable,
          SupplierInvoice,
          $$SupplierInvoicesTableFilterComposer,
          $$SupplierInvoicesTableOrderingComposer,
          $$SupplierInvoicesTableAnnotationComposer,
          $$SupplierInvoicesTableCreateCompanionBuilder,
          $$SupplierInvoicesTableUpdateCompanionBuilder,
          (SupplierInvoice, $$SupplierInvoicesTableReferences),
          SupplierInvoice,
          PrefetchHooks Function({
            bool supplierId,
            bool batchesRefs,
            bool supplierPaymentsRefs,
            bool supplierCreditsRefs,
          })
        > {
  $$SupplierInvoicesTableTableManager(
    _$AppDatabase db,
    $SupplierInvoicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierInvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierInvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierInvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<String> invoiceDate = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<int> totalMinor = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> remindersSnoozedUntil = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierInvoicesCompanion(
                id: id,
                supplierId: supplierId,
                invoiceNumber: invoiceNumber,
                invoiceDate: invoiceDate,
                dueDate: dueDate,
                totalMinor: totalMinor,
                notes: notes,
                remindersSnoozedUntil: remindersSnoozedUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                Value<String?> invoiceNumber = const Value.absent(),
                required String invoiceDate,
                Value<String?> dueDate = const Value.absent(),
                required int totalMinor,
                Value<String?> notes = const Value.absent(),
                Value<String?> remindersSnoozedUntil = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierInvoicesCompanion.insert(
                id: id,
                supplierId: supplierId,
                invoiceNumber: invoiceNumber,
                invoiceDate: invoiceDate,
                dueDate: dueDate,
                totalMinor: totalMinor,
                notes: notes,
                remindersSnoozedUntil: remindersSnoozedUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierInvoicesTable, SupplierInvoice>(table),
                  $$SupplierInvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                batchesRefs = false,
                supplierPaymentsRefs = false,
                supplierCreditsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (batchesRefs) db.batches,
                    if (supplierPaymentsRefs) db.supplierPayments,
                    if (supplierCreditsRefs) db.supplierCredits,
                  ],
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
                        if (supplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$SupplierInvoicesTableReferences
                                ._supplierIdTable(db),
                            referencedColumn: $$SupplierInvoicesTableReferences
                                ._supplierIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (batchesRefs)
                        await $_getPrefetchedData<
                          SupplierInvoice,
                          $SupplierInvoicesTable,
                          Batche
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierInvoicesTableReferences
                              ._batchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).batchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierPaymentsRefs)
                        await $_getPrefetchedData<
                          SupplierInvoice,
                          $SupplierInvoicesTable,
                          SupplierPayment
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierInvoicesTableReferences
                              ._supplierPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierCreditsRefs)
                        await $_getPrefetchedData<
                          SupplierInvoice,
                          $SupplierInvoicesTable,
                          SupplierCredit
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierInvoicesTableReferences
                              ._supplierCreditsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierCreditsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
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

typedef $$SupplierInvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierInvoicesTable,
      SupplierInvoice,
      $$SupplierInvoicesTableFilterComposer,
      $$SupplierInvoicesTableOrderingComposer,
      $$SupplierInvoicesTableAnnotationComposer,
      $$SupplierInvoicesTableCreateCompanionBuilder,
      $$SupplierInvoicesTableUpdateCompanionBuilder,
      (SupplierInvoice, $$SupplierInvoicesTableReferences),
      SupplierInvoice,
      PrefetchHooks Function({
        bool supplierId,
        bool batchesRefs,
        bool supplierPaymentsRefs,
        bool supplierCreditsRefs,
      })
    >;
typedef $$BatchesTableCreateCompanionBuilder = BatchesCompanion Function({
  required String id,
  required String medicineId,
  required String batchNumber,
  required String expiryDate,
  required String expiryPrecision,
  required int quantityReceived,
  required int quantityOnHand,
  Value<int?> costPriceMinor,
  Value<int?> sellingPriceMinor,
  required String receivedDate,
  Value<String?> supplierId,
  Value<String?> invoiceId,
  Value<String> status,
  Value<String?> snoozedUntil,
  Value<int?> handledAt,
  Value<String?> notes,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$BatchesTableUpdateCompanionBuilder = BatchesCompanion Function({
  Value<String> id,
  Value<String> medicineId,
  Value<String> batchNumber,
  Value<String> expiryDate,
  Value<String> expiryPrecision,
  Value<int> quantityReceived,
  Value<int> quantityOnHand,
  Value<int?> costPriceMinor,
  Value<int?> sellingPriceMinor,
  Value<String> receivedDate,
  Value<String?> supplierId,
  Value<String?> invoiceId,
  Value<String> status,
  Value<String?> snoozedUntil,
  Value<int?> handledAt,
  Value<String?> notes,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$BatchesTableReferences
    extends BaseReferences<_$AppDatabase, $BatchesTable, Batche> {
  $$BatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) =>
      db.medicines.createAlias('batches__medicine_id__medicines__id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('batches__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager? get supplierId {
    final $_column = $_itemColumn<String>('supplier_id');
    if ($_column == null) return null;
    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupplierInvoicesTable _invoiceIdTable(_$AppDatabase db) => db
      .supplierInvoices
      .createAlias('batches__invoice_id__supplier_invoices__id');

  $$SupplierInvoicesTableProcessedTableManager? get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id');
    if ($_column == null) return null;
    final manager = $$SupplierInvoicesTableTableManager(
      $_db,
      $_db.supplierInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockAdjustmentsTable, List<StockAdjustment>>
  _stockAdjustmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockAdjustments,
    aliasName: 'batches__id__stock_adjustments__batch_id',
  );

  $$StockAdjustmentsTableProcessedTableManager get stockAdjustmentsRefs {
    final manager = $$StockAdjustmentsTableTableManager(
      $_db,
      $_db.stockAdjustments,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockAdjustmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupplierReturnLinesTable,
    List<SupplierReturnLine>
  >
  _supplierReturnLinesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierReturnLines,
        aliasName: 'batches__id__supplier_return_lines__batch_id',
      );

  $$SupplierReturnLinesTableProcessedTableManager get supplierReturnLinesRefs {
    final manager = $$SupplierReturnLinesTableTableManager(
      $_db,
      $_db.supplierReturnLines,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierReturnLinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
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

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiryPrecision => $composableBuilder(
    column: $table.expiryPrecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costPriceMinor => $composableBuilder(
    column: $table.costPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellingPriceMinor => $composableBuilder(
    column: $table.sellingPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
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

  ColumnFilters<int> get handledAt => $composableBuilder(
    column: $table.handledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableFilterComposer get invoiceId {
    final $$SupplierInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockAdjustmentsRefs(
    Expression<bool> Function($$StockAdjustmentsTableFilterComposer f) f,
  ) {
    final $$StockAdjustmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockAdjustments,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockAdjustmentsTableFilterComposer(
            $db: $db,
            $table: $db.stockAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierReturnLinesRefs(
    Expression<bool> Function($$SupplierReturnLinesTableFilterComposer f) f,
  ) {
    final $$SupplierReturnLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierReturnLines,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnLinesTableFilterComposer(
            $db: $db,
            $table: $db.supplierReturnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
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

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryPrecision => $composableBuilder(
    column: $table.expiryPrecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costPriceMinor => $composableBuilder(
    column: $table.costPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellingPriceMinor => $composableBuilder(
    column: $table.sellingPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
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

  ColumnOrderings<int> get handledAt => $composableBuilder(
    column: $table.handledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableOrderingComposer get invoiceId {
    final $$SupplierInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expiryPrecision => $composableBuilder(
    column: $table.expiryPrecision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityOnHand => $composableBuilder(
    column: $table.quantityOnHand,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costPriceMinor => $composableBuilder(
    column: $table.costPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellingPriceMinor => $composableBuilder(
    column: $table.sellingPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receivedDate => $composableBuilder(
    column: $table.receivedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get handledAt =>
      $composableBuilder(column: $table.handledAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableAnnotationComposer get invoiceId {
    final $$SupplierInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockAdjustmentsRefs<T extends Object>(
    Expression<T> Function($$StockAdjustmentsTableAnnotationComposer a) f,
  ) {
    final $$StockAdjustmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockAdjustments,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockAdjustmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierReturnLinesRefs<T extends Object>(
    Expression<T> Function($$SupplierReturnLinesTableAnnotationComposer a) f,
  ) {
    final $$SupplierReturnLinesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierReturnLines,
          getReferencedColumn: (t) => t.batchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReturnLinesTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierReturnLines,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          Batche,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (Batche, $$BatchesTableReferences),
          Batche,
          PrefetchHooks Function({
            bool medicineId,
            bool supplierId,
            bool invoiceId,
            bool stockAdjustmentsRefs,
            bool supplierReturnLinesRefs,
          })
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<String> batchNumber = const Value.absent(),
                Value<String> expiryDate = const Value.absent(),
                Value<String> expiryPrecision = const Value.absent(),
                Value<int> quantityReceived = const Value.absent(),
                Value<int> quantityOnHand = const Value.absent(),
                Value<int?> costPriceMinor = const Value.absent(),
                Value<int?> sellingPriceMinor = const Value.absent(),
                Value<String> receivedDate = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> invoiceId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> snoozedUntil = const Value.absent(),
                Value<int?> handledAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                medicineId: medicineId,
                batchNumber: batchNumber,
                expiryDate: expiryDate,
                expiryPrecision: expiryPrecision,
                quantityReceived: quantityReceived,
                quantityOnHand: quantityOnHand,
                costPriceMinor: costPriceMinor,
                sellingPriceMinor: sellingPriceMinor,
                receivedDate: receivedDate,
                supplierId: supplierId,
                invoiceId: invoiceId,
                status: status,
                snoozedUntil: snoozedUntil,
                handledAt: handledAt,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicineId,
                required String batchNumber,
                required String expiryDate,
                required String expiryPrecision,
                required int quantityReceived,
                required int quantityOnHand,
                Value<int?> costPriceMinor = const Value.absent(),
                Value<int?> sellingPriceMinor = const Value.absent(),
                required String receivedDate,
                Value<String?> supplierId = const Value.absent(),
                Value<String?> invoiceId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> snoozedUntil = const Value.absent(),
                Value<int?> handledAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                medicineId: medicineId,
                batchNumber: batchNumber,
                expiryDate: expiryDate,
                expiryPrecision: expiryPrecision,
                quantityReceived: quantityReceived,
                quantityOnHand: quantityOnHand,
                costPriceMinor: costPriceMinor,
                sellingPriceMinor: sellingPriceMinor,
                receivedDate: receivedDate,
                supplierId: supplierId,
                invoiceId: invoiceId,
                status: status,
                snoozedUntil: snoozedUntil,
                handledAt: handledAt,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BatchesTable, Batche>(table),
                  $$BatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicineId = false,
                supplierId = false,
                invoiceId = false,
                stockAdjustmentsRefs = false,
                supplierReturnLinesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockAdjustmentsRefs) db.stockAdjustments,
                    if (supplierReturnLinesRefs) db.supplierReturnLines,
                  ],
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
                        if (medicineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.medicineId,
                            referencedTable: $$BatchesTableReferences
                                ._medicineIdTable(db),
                            referencedColumn: $$BatchesTableReferences
                                ._medicineIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (supplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$BatchesTableReferences
                                ._supplierIdTable(db),
                            referencedColumn: $$BatchesTableReferences
                                ._supplierIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (invoiceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.invoiceId,
                            referencedTable: $$BatchesTableReferences
                                ._invoiceIdTable(db),
                            referencedColumn: $$BatchesTableReferences
                                ._invoiceIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockAdjustmentsRefs)
                        await $_getPrefetchedData<
                          Batche,
                          $BatchesTable,
                          StockAdjustment
                        >(
                          currentTable: table,
                          referencedTable: $$BatchesTableReferences
                              ._stockAdjustmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).stockAdjustmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierReturnLinesRefs)
                        await $_getPrefetchedData<
                          Batche,
                          $BatchesTable,
                          SupplierReturnLine
                        >(
                          currentTable: table,
                          referencedTable: $$BatchesTableReferences
                              ._supplierReturnLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierReturnLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
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

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      Batche,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (Batche, $$BatchesTableReferences),
      Batche,
      PrefetchHooks Function({
        bool medicineId,
        bool supplierId,
        bool invoiceId,
        bool stockAdjustmentsRefs,
        bool supplierReturnLinesRefs,
      })
    >;
typedef $$SupplierReturnsTableCreateCompanionBuilder =
    SupplierReturnsCompanion Function({
      required String id,
      required String supplierId,
      required String returnedOn,
      Value<String?> note,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SupplierReturnsTableUpdateCompanionBuilder =
    SupplierReturnsCompanion Function({
      Value<String> id,
      Value<String> supplierId,
      Value<String> returnedOn,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$SupplierReturnsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SupplierReturnsTable, SupplierReturn> {
  $$SupplierReturnsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('supplier_returns__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockAdjustmentsTable, List<StockAdjustment>>
  _stockAdjustmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockAdjustments,
    aliasName: 'supplier_returns__id__stock_adjustments__return_id',
  );

  $$StockAdjustmentsTableProcessedTableManager get stockAdjustmentsRefs {
    final manager = $$StockAdjustmentsTableTableManager(
      $_db,
      $_db.stockAdjustments,
    ).filter((f) => f.returnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockAdjustmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierCreditsTable, List<SupplierCredit>>
  _supplierCreditsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierCredits,
    aliasName: 'supplier_returns__id__supplier_credits__return_id',
  );

  $$SupplierCreditsTableProcessedTableManager get supplierCreditsRefs {
    final manager = $$SupplierCreditsTableTableManager(
      $_db,
      $_db.supplierCredits,
    ).filter((f) => f.returnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierCreditsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupplierReturnLinesTable,
    List<SupplierReturnLine>
  >
  _supplierReturnLinesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierReturnLines,
        aliasName: 'supplier_returns__id__supplier_return_lines__return_id',
      );

  $$SupplierReturnLinesTableProcessedTableManager get supplierReturnLinesRefs {
    final manager = $$SupplierReturnLinesTableTableManager(
      $_db,
      $_db.supplierReturnLines,
    ).filter((f) => f.returnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierReturnLinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupplierReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierReturnsTable> {
  $$SupplierReturnsTableFilterComposer({
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

  ColumnFilters<String> get returnedOn => $composableBuilder(
    column: $table.returnedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockAdjustmentsRefs(
    Expression<bool> Function($$StockAdjustmentsTableFilterComposer f) f,
  ) {
    final $$StockAdjustmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockAdjustments,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockAdjustmentsTableFilterComposer(
            $db: $db,
            $table: $db.stockAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierCreditsRefs(
    Expression<bool> Function($$SupplierCreditsTableFilterComposer f) f,
  ) {
    final $$SupplierCreditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierCredits,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierCreditsTableFilterComposer(
            $db: $db,
            $table: $db.supplierCredits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierReturnLinesRefs(
    Expression<bool> Function($$SupplierReturnLinesTableFilterComposer f) f,
  ) {
    final $$SupplierReturnLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierReturnLines,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnLinesTableFilterComposer(
            $db: $db,
            $table: $db.supplierReturnLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SupplierReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierReturnsTable> {
  $$SupplierReturnsTableOrderingComposer({
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

  ColumnOrderings<String> get returnedOn => $composableBuilder(
    column: $table.returnedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierReturnsTable> {
  $$SupplierReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get returnedOn => $composableBuilder(
    column: $table.returnedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockAdjustmentsRefs<T extends Object>(
    Expression<T> Function($$StockAdjustmentsTableAnnotationComposer a) f,
  ) {
    final $$StockAdjustmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockAdjustments,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockAdjustmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierCreditsRefs<T extends Object>(
    Expression<T> Function($$SupplierCreditsTableAnnotationComposer a) f,
  ) {
    final $$SupplierCreditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierCredits,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierCreditsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierCredits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierReturnLinesRefs<T extends Object>(
    Expression<T> Function($$SupplierReturnLinesTableAnnotationComposer a) f,
  ) {
    final $$SupplierReturnLinesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierReturnLines,
          getReferencedColumn: (t) => t.returnId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierReturnLinesTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierReturnLines,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupplierReturnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierReturnsTable,
          SupplierReturn,
          $$SupplierReturnsTableFilterComposer,
          $$SupplierReturnsTableOrderingComposer,
          $$SupplierReturnsTableAnnotationComposer,
          $$SupplierReturnsTableCreateCompanionBuilder,
          $$SupplierReturnsTableUpdateCompanionBuilder,
          (SupplierReturn, $$SupplierReturnsTableReferences),
          SupplierReturn,
          PrefetchHooks Function({
            bool supplierId,
            bool stockAdjustmentsRefs,
            bool supplierCreditsRefs,
            bool supplierReturnLinesRefs,
          })
        > {
  $$SupplierReturnsTableTableManager(
    _$AppDatabase db,
    $SupplierReturnsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String> returnedOn = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReturnsCompanion(
                id: id,
                supplierId: supplierId,
                returnedOn: returnedOn,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                required String returnedOn,
                Value<String?> note = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SupplierReturnsCompanion.insert(
                id: id,
                supplierId: supplierId,
                returnedOn: returnedOn,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierReturnsTable, SupplierReturn>(table),
                  $$SupplierReturnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                stockAdjustmentsRefs = false,
                supplierCreditsRefs = false,
                supplierReturnLinesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockAdjustmentsRefs) db.stockAdjustments,
                    if (supplierCreditsRefs) db.supplierCredits,
                    if (supplierReturnLinesRefs) db.supplierReturnLines,
                  ],
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
                        if (supplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$SupplierReturnsTableReferences
                                ._supplierIdTable(db),
                            referencedColumn: $$SupplierReturnsTableReferences
                                ._supplierIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockAdjustmentsRefs)
                        await $_getPrefetchedData<
                          SupplierReturn,
                          $SupplierReturnsTable,
                          StockAdjustment
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierReturnsTableReferences
                              ._stockAdjustmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierReturnsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockAdjustmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.returnId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierCreditsRefs)
                        await $_getPrefetchedData<
                          SupplierReturn,
                          $SupplierReturnsTable,
                          SupplierCredit
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierReturnsTableReferences
                              ._supplierCreditsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierReturnsTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierCreditsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.returnId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierReturnLinesRefs)
                        await $_getPrefetchedData<
                          SupplierReturn,
                          $SupplierReturnsTable,
                          SupplierReturnLine
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierReturnsTableReferences
                              ._supplierReturnLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierReturnsTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierReturnLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.returnId == item.id,
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

typedef $$SupplierReturnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierReturnsTable,
      SupplierReturn,
      $$SupplierReturnsTableFilterComposer,
      $$SupplierReturnsTableOrderingComposer,
      $$SupplierReturnsTableAnnotationComposer,
      $$SupplierReturnsTableCreateCompanionBuilder,
      $$SupplierReturnsTableUpdateCompanionBuilder,
      (SupplierReturn, $$SupplierReturnsTableReferences),
      SupplierReturn,
      PrefetchHooks Function({
        bool supplierId,
        bool stockAdjustmentsRefs,
        bool supplierCreditsRefs,
        bool supplierReturnLinesRefs,
      })
    >;
typedef $$StockAdjustmentsTableCreateCompanionBuilder =
    StockAdjustmentsCompanion Function({
      required String id,
      required String batchId,
      required int deltaQty,
      required String reason,
      Value<String?> note,
      Value<int?> valueImpactMinor,
      Value<String?> returnId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$StockAdjustmentsTableUpdateCompanionBuilder =
    StockAdjustmentsCompanion Function({
      Value<String> id,
      Value<String> batchId,
      Value<int> deltaQty,
      Value<String> reason,
      Value<String?> note,
      Value<int?> valueImpactMinor,
      Value<String?> returnId,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$StockAdjustmentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $StockAdjustmentsTable, StockAdjustment> {
  $$StockAdjustmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BatchesTable _batchIdTable(_$AppDatabase db) =>
      db.batches.createAlias('stock_adjustments__batch_id__batches__id');

  $$BatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<String>('batch_id')!;

    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupplierReturnsTable _returnIdTable(_$AppDatabase db) => db
      .supplierReturns
      .createAlias('stock_adjustments__return_id__supplier_returns__id');

  $$SupplierReturnsTableProcessedTableManager? get returnId {
    final $_column = $_itemColumn<String>('return_id');
    if ($_column == null) return null;
    final manager = $$SupplierReturnsTableTableManager(
      $_db,
      $_db.supplierReturns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_returnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockAdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $StockAdjustmentsTable> {
  $$StockAdjustmentsTableFilterComposer({
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

  ColumnFilters<int> get deltaQty => $composableBuilder(
    column: $table.deltaQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valueImpactMinor => $composableBuilder(
    column: $table.valueImpactMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BatchesTableFilterComposer get batchId {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierReturnsTableFilterComposer get returnId {
    final $$SupplierReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableFilterComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockAdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockAdjustmentsTable> {
  $$StockAdjustmentsTableOrderingComposer({
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

  ColumnOrderings<int> get deltaQty => $composableBuilder(
    column: $table.deltaQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueImpactMinor => $composableBuilder(
    column: $table.valueImpactMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BatchesTableOrderingComposer get batchId {
    final $$BatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableOrderingComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierReturnsTableOrderingComposer get returnId {
    final $$SupplierReturnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableOrderingComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockAdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockAdjustmentsTable> {
  $$StockAdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get deltaQty =>
      $composableBuilder(column: $table.deltaQty, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get valueImpactMinor => $composableBuilder(
    column: $table.valueImpactMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BatchesTableAnnotationComposer get batchId {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierReturnsTableAnnotationComposer get returnId {
    final $$SupplierReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockAdjustmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockAdjustmentsTable,
          StockAdjustment,
          $$StockAdjustmentsTableFilterComposer,
          $$StockAdjustmentsTableOrderingComposer,
          $$StockAdjustmentsTableAnnotationComposer,
          $$StockAdjustmentsTableCreateCompanionBuilder,
          $$StockAdjustmentsTableUpdateCompanionBuilder,
          (StockAdjustment, $$StockAdjustmentsTableReferences),
          StockAdjustment,
          PrefetchHooks Function({bool batchId, bool returnId})
        > {
  $$StockAdjustmentsTableTableManager(
    _$AppDatabase db,
    $StockAdjustmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockAdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockAdjustmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockAdjustmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<int> deltaQty = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> valueImpactMinor = const Value.absent(),
                Value<String?> returnId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockAdjustmentsCompanion(
                id: id,
                batchId: batchId,
                deltaQty: deltaQty,
                reason: reason,
                note: note,
                valueImpactMinor: valueImpactMinor,
                returnId: returnId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String batchId,
                required int deltaQty,
                required String reason,
                Value<String?> note = const Value.absent(),
                Value<int?> valueImpactMinor = const Value.absent(),
                Value<String?> returnId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StockAdjustmentsCompanion.insert(
                id: id,
                batchId: batchId,
                deltaQty: deltaQty,
                reason: reason,
                note: note,
                valueImpactMinor: valueImpactMinor,
                returnId: returnId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockAdjustmentsTable, StockAdjustment>(table),
                  $$StockAdjustmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({batchId = false, returnId = false}) {
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
                    if (batchId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.batchId,
                        referencedTable: $$StockAdjustmentsTableReferences
                            ._batchIdTable(db),
                        referencedColumn: $$StockAdjustmentsTableReferences
                            ._batchIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (returnId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.returnId,
                        referencedTable: $$StockAdjustmentsTableReferences
                            ._returnIdTable(db),
                        referencedColumn: $$StockAdjustmentsTableReferences
                            ._returnIdTable(db)
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

typedef $$StockAdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockAdjustmentsTable,
      StockAdjustment,
      $$StockAdjustmentsTableFilterComposer,
      $$StockAdjustmentsTableOrderingComposer,
      $$StockAdjustmentsTableAnnotationComposer,
      $$StockAdjustmentsTableCreateCompanionBuilder,
      $$StockAdjustmentsTableUpdateCompanionBuilder,
      (StockAdjustment, $$StockAdjustmentsTableReferences),
      StockAdjustment,
      PrefetchHooks Function({bool batchId, bool returnId})
    >;
typedef $$SupplierPaymentsTableCreateCompanionBuilder =
    SupplierPaymentsCompanion Function({
      required String id,
      required String supplierId,
      Value<String?> invoiceId,
      required int amountMinor,
      required String paidOn,
      Value<String?> method,
      Value<String?> reference,
      required int createdAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$SupplierPaymentsTableUpdateCompanionBuilder =
    SupplierPaymentsCompanion Function({
      Value<String> id,
      Value<String> supplierId,
      Value<String?> invoiceId,
      Value<int> amountMinor,
      Value<String> paidOn,
      Value<String?> method,
      Value<String?> reference,
      Value<int> createdAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$SupplierPaymentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SupplierPaymentsTable, SupplierPayment> {
  $$SupplierPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('supplier_payments__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupplierInvoicesTable _invoiceIdTable(_$AppDatabase db) => db
      .supplierInvoices
      .createAlias('supplier_payments__invoice_id__supplier_invoices__id');

  $$SupplierInvoicesTableProcessedTableManager? get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id');
    if ($_column == null) return null;
    final manager = $$SupplierInvoicesTableTableManager(
      $_db,
      $_db.supplierInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableFilterComposer({
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

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableFilterComposer get invoiceId {
    final $$SupplierInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableOrderingComposer get invoiceId {
    final $$SupplierInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paidOn =>
      $composableBuilder(column: $table.paidOn, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableAnnotationComposer get invoiceId {
    final $$SupplierInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierPaymentsTable,
          SupplierPayment,
          $$SupplierPaymentsTableFilterComposer,
          $$SupplierPaymentsTableOrderingComposer,
          $$SupplierPaymentsTableAnnotationComposer,
          $$SupplierPaymentsTableCreateCompanionBuilder,
          $$SupplierPaymentsTableUpdateCompanionBuilder,
          (SupplierPayment, $$SupplierPaymentsTableReferences),
          SupplierPayment,
          PrefetchHooks Function({bool supplierId, bool invoiceId})
        > {
  $$SupplierPaymentsTableTableManager(
    _$AppDatabase db,
    $SupplierPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String?> invoiceId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> paidOn = const Value.absent(),
                Value<String?> method = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierPaymentsCompanion(
                id: id,
                supplierId: supplierId,
                invoiceId: invoiceId,
                amountMinor: amountMinor,
                paidOn: paidOn,
                method: method,
                reference: reference,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                Value<String?> invoiceId = const Value.absent(),
                required int amountMinor,
                required String paidOn,
                Value<String?> method = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierPaymentsCompanion.insert(
                id: id,
                supplierId: supplierId,
                invoiceId: invoiceId,
                amountMinor: amountMinor,
                paidOn: paidOn,
                method: method,
                reference: reference,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierPaymentsTable, SupplierPayment>(table),
                  $$SupplierPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({supplierId = false, invoiceId = false}) {
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
                    if (supplierId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.supplierId,
                        referencedTable: $$SupplierPaymentsTableReferences
                            ._supplierIdTable(db),
                        referencedColumn: $$SupplierPaymentsTableReferences
                            ._supplierIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (invoiceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.invoiceId,
                        referencedTable: $$SupplierPaymentsTableReferences
                            ._invoiceIdTable(db),
                        referencedColumn: $$SupplierPaymentsTableReferences
                            ._invoiceIdTable(db)
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

typedef $$SupplierPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierPaymentsTable,
      SupplierPayment,
      $$SupplierPaymentsTableFilterComposer,
      $$SupplierPaymentsTableOrderingComposer,
      $$SupplierPaymentsTableAnnotationComposer,
      $$SupplierPaymentsTableCreateCompanionBuilder,
      $$SupplierPaymentsTableUpdateCompanionBuilder,
      (SupplierPayment, $$SupplierPaymentsTableReferences),
      SupplierPayment,
      PrefetchHooks Function({bool supplierId, bool invoiceId})
    >;
typedef $$SupplierCreditsTableCreateCompanionBuilder =
    SupplierCreditsCompanion Function({
      required String id,
      required String supplierId,
      Value<String?> invoiceId,
      Value<String?> returnId,
      required int amountMinor,
      required String issuedOn,
      Value<String?> note,
      required int createdAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$SupplierCreditsTableUpdateCompanionBuilder =
    SupplierCreditsCompanion Function({
      Value<String> id,
      Value<String> supplierId,
      Value<String?> invoiceId,
      Value<String?> returnId,
      Value<int> amountMinor,
      Value<String> issuedOn,
      Value<String?> note,
      Value<int> createdAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

final class $$SupplierCreditsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SupplierCreditsTable, SupplierCredit> {
  $$SupplierCreditsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('supplier_credits__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupplierInvoicesTable _invoiceIdTable(_$AppDatabase db) => db
      .supplierInvoices
      .createAlias('supplier_credits__invoice_id__supplier_invoices__id');

  $$SupplierInvoicesTableProcessedTableManager? get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id');
    if ($_column == null) return null;
    final manager = $$SupplierInvoicesTableTableManager(
      $_db,
      $_db.supplierInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupplierReturnsTable _returnIdTable(_$AppDatabase db) => db
      .supplierReturns
      .createAlias('supplier_credits__return_id__supplier_returns__id');

  $$SupplierReturnsTableProcessedTableManager? get returnId {
    final $_column = $_itemColumn<String>('return_id');
    if ($_column == null) return null;
    final manager = $$SupplierReturnsTableTableManager(
      $_db,
      $_db.supplierReturns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_returnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierCreditsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierCreditsTable> {
  $$SupplierCreditsTableFilterComposer({
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

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuedOn => $composableBuilder(
    column: $table.issuedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableFilterComposer get invoiceId {
    final $$SupplierInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierReturnsTableFilterComposer get returnId {
    final $$SupplierReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableFilterComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierCreditsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierCreditsTable> {
  $$SupplierCreditsTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuedOn => $composableBuilder(
    column: $table.issuedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableOrderingComposer get invoiceId {
    final $$SupplierInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierReturnsTableOrderingComposer get returnId {
    final $$SupplierReturnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableOrderingComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierCreditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierCreditsTable> {
  $$SupplierCreditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issuedOn =>
      $composableBuilder(column: $table.issuedOn, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierInvoicesTableAnnotationComposer get invoiceId {
    final $$SupplierInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.supplierInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierReturnsTableAnnotationComposer get returnId {
    final $$SupplierReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierCreditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierCreditsTable,
          SupplierCredit,
          $$SupplierCreditsTableFilterComposer,
          $$SupplierCreditsTableOrderingComposer,
          $$SupplierCreditsTableAnnotationComposer,
          $$SupplierCreditsTableCreateCompanionBuilder,
          $$SupplierCreditsTableUpdateCompanionBuilder,
          (SupplierCredit, $$SupplierCreditsTableReferences),
          SupplierCredit,
          PrefetchHooks Function({
            bool supplierId,
            bool invoiceId,
            bool returnId,
          })
        > {
  $$SupplierCreditsTableTableManager(
    _$AppDatabase db,
    $SupplierCreditsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierCreditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierCreditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierCreditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String?> invoiceId = const Value.absent(),
                Value<String?> returnId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> issuedOn = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierCreditsCompanion(
                id: id,
                supplierId: supplierId,
                invoiceId: invoiceId,
                returnId: returnId,
                amountMinor: amountMinor,
                issuedOn: issuedOn,
                note: note,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                Value<String?> invoiceId = const Value.absent(),
                Value<String?> returnId = const Value.absent(),
                required int amountMinor,
                required String issuedOn,
                Value<String?> note = const Value.absent(),
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierCreditsCompanion.insert(
                id: id,
                supplierId: supplierId,
                invoiceId: invoiceId,
                returnId: returnId,
                amountMinor: amountMinor,
                issuedOn: issuedOn,
                note: note,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierCreditsTable, SupplierCredit>(table),
                  $$SupplierCreditsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({supplierId = false, invoiceId = false, returnId = false}) {
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
                        if (supplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$SupplierCreditsTableReferences
                                ._supplierIdTable(db),
                            referencedColumn: $$SupplierCreditsTableReferences
                                ._supplierIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (invoiceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.invoiceId,
                            referencedTable: $$SupplierCreditsTableReferences
                                ._invoiceIdTable(db),
                            referencedColumn: $$SupplierCreditsTableReferences
                                ._invoiceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (returnId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.returnId,
                            referencedTable: $$SupplierCreditsTableReferences
                                ._returnIdTable(db),
                            referencedColumn: $$SupplierCreditsTableReferences
                                ._returnIdTable(db)
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

typedef $$SupplierCreditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierCreditsTable,
      SupplierCredit,
      $$SupplierCreditsTableFilterComposer,
      $$SupplierCreditsTableOrderingComposer,
      $$SupplierCreditsTableAnnotationComposer,
      $$SupplierCreditsTableCreateCompanionBuilder,
      $$SupplierCreditsTableUpdateCompanionBuilder,
      (SupplierCredit, $$SupplierCreditsTableReferences),
      SupplierCredit,
      PrefetchHooks Function({bool supplierId, bool invoiceId, bool returnId})
    >;
typedef $$SupplierReturnLinesTableCreateCompanionBuilder =
    SupplierReturnLinesCompanion Function({
      required String id,
      required String returnId,
      required String batchId,
      required int quantity,
      Value<int?> valueMinor,
      Value<int> rowid,
    });
typedef $$SupplierReturnLinesTableUpdateCompanionBuilder =
    SupplierReturnLinesCompanion Function({
      Value<String> id,
      Value<String> returnId,
      Value<String> batchId,
      Value<int> quantity,
      Value<int?> valueMinor,
      Value<int> rowid,
    });

final class $$SupplierReturnLinesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupplierReturnLinesTable,
          SupplierReturnLine
        > {
  $$SupplierReturnLinesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SupplierReturnsTable _returnIdTable(_$AppDatabase db) => db
      .supplierReturns
      .createAlias('supplier_return_lines__return_id__supplier_returns__id');

  $$SupplierReturnsTableProcessedTableManager get returnId {
    final $_column = $_itemColumn<String>('return_id')!;

    final manager = $$SupplierReturnsTableTableManager(
      $_db,
      $_db.supplierReturns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_returnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BatchesTable _batchIdTable(_$AppDatabase db) =>
      db.batches.createAlias('supplier_return_lines__batch_id__batches__id');

  $$BatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<String>('batch_id')!;

    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierReturnLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierReturnLinesTable> {
  $$SupplierReturnLinesTableFilterComposer({
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

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valueMinor => $composableBuilder(
    column: $table.valueMinor,
    builder: (column) => ColumnFilters(column),
  );

  $$SupplierReturnsTableFilterComposer get returnId {
    final $$SupplierReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableFilterComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableFilterComposer get batchId {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierReturnLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierReturnLinesTable> {
  $$SupplierReturnLinesTableOrderingComposer({
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

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueMinor => $composableBuilder(
    column: $table.valueMinor,
    builder: (column) => ColumnOrderings(column),
  );

  $$SupplierReturnsTableOrderingComposer get returnId {
    final $$SupplierReturnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableOrderingComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableOrderingComposer get batchId {
    final $$BatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableOrderingComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierReturnLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierReturnLinesTable> {
  $$SupplierReturnLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get valueMinor => $composableBuilder(
    column: $table.valueMinor,
    builder: (column) => column,
  );

  $$SupplierReturnsTableAnnotationComposer get returnId {
    final $$SupplierReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.supplierReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableAnnotationComposer get batchId {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierReturnLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierReturnLinesTable,
          SupplierReturnLine,
          $$SupplierReturnLinesTableFilterComposer,
          $$SupplierReturnLinesTableOrderingComposer,
          $$SupplierReturnLinesTableAnnotationComposer,
          $$SupplierReturnLinesTableCreateCompanionBuilder,
          $$SupplierReturnLinesTableUpdateCompanionBuilder,
          (SupplierReturnLine, $$SupplierReturnLinesTableReferences),
          SupplierReturnLine,
          PrefetchHooks Function({bool returnId, bool batchId})
        > {
  $$SupplierReturnLinesTableTableManager(
    _$AppDatabase db,
    $SupplierReturnLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierReturnLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierReturnLinesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupplierReturnLinesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> returnId = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int?> valueMinor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReturnLinesCompanion(
                id: id,
                returnId: returnId,
                batchId: batchId,
                quantity: quantity,
                valueMinor: valueMinor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String returnId,
                required String batchId,
                required int quantity,
                Value<int?> valueMinor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierReturnLinesCompanion.insert(
                id: id,
                returnId: returnId,
                batchId: batchId,
                quantity: quantity,
                valueMinor: valueMinor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierReturnLinesTable, SupplierReturnLine>(
                    table,
                  ),
                  $$SupplierReturnLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({returnId = false, batchId = false}) {
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
                    if (returnId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.returnId,
                        referencedTable: $$SupplierReturnLinesTableReferences
                            ._returnIdTable(db),
                        referencedColumn: $$SupplierReturnLinesTableReferences
                            ._returnIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (batchId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.batchId,
                        referencedTable: $$SupplierReturnLinesTableReferences
                            ._batchIdTable(db),
                        referencedColumn: $$SupplierReturnLinesTableReferences
                            ._batchIdTable(db)
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

typedef $$SupplierReturnLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierReturnLinesTable,
      SupplierReturnLine,
      $$SupplierReturnLinesTableFilterComposer,
      $$SupplierReturnLinesTableOrderingComposer,
      $$SupplierReturnLinesTableAnnotationComposer,
      $$SupplierReturnLinesTableCreateCompanionBuilder,
      $$SupplierReturnLinesTableUpdateCompanionBuilder,
      (SupplierReturnLine, $$SupplierReturnLinesTableReferences),
      SupplierReturnLine,
      PrefetchHooks Function({bool returnId, bool batchId})
    >;
typedef $$ReorderOrdersTableCreateCompanionBuilder =
    ReorderOrdersCompanion Function({
      required String id,
      required String medicineId,
      Value<String?> supplierId,
      required int quantity,
      required String orderedOn,
      Value<String?> expectedOn,
      required String status,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ReorderOrdersTableUpdateCompanionBuilder =
    ReorderOrdersCompanion Function({
      Value<String> id,
      Value<String> medicineId,
      Value<String?> supplierId,
      Value<int> quantity,
      Value<String> orderedOn,
      Value<String?> expectedOn,
      Value<String> status,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$ReorderOrdersTableReferences
    extends BaseReferences<_$AppDatabase, $ReorderOrdersTable, ReorderOrder> {
  $$ReorderOrdersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) =>
      db.medicines.createAlias('reorder_orders__medicine_id__medicines__id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('reorder_orders__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager? get supplierId {
    final $_column = $_itemColumn<String>('supplier_id');
    if ($_column == null) return null;
    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReorderOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $ReorderOrdersTable> {
  $$ReorderOrdersTableFilterComposer({
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

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderedOn => $composableBuilder(
    column: $table.orderedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedOn => $composableBuilder(
    column: $table.expectedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReorderOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $ReorderOrdersTable> {
  $$ReorderOrdersTableOrderingComposer({
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

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderedOn => $composableBuilder(
    column: $table.orderedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedOn => $composableBuilder(
    column: $table.expectedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReorderOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReorderOrdersTable> {
  $$ReorderOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get orderedOn =>
      $composableBuilder(column: $table.orderedOn, builder: (column) => column);

  GeneratedColumn<String> get expectedOn => $composableBuilder(
    column: $table.expectedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReorderOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReorderOrdersTable,
          ReorderOrder,
          $$ReorderOrdersTableFilterComposer,
          $$ReorderOrdersTableOrderingComposer,
          $$ReorderOrdersTableAnnotationComposer,
          $$ReorderOrdersTableCreateCompanionBuilder,
          $$ReorderOrdersTableUpdateCompanionBuilder,
          (ReorderOrder, $$ReorderOrdersTableReferences),
          ReorderOrder,
          PrefetchHooks Function({bool medicineId, bool supplierId})
        > {
  $$ReorderOrdersTableTableManager(_$AppDatabase db, $ReorderOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReorderOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReorderOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReorderOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> orderedOn = const Value.absent(),
                Value<String?> expectedOn = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReorderOrdersCompanion(
                id: id,
                medicineId: medicineId,
                supplierId: supplierId,
                quantity: quantity,
                orderedOn: orderedOn,
                expectedOn: expectedOn,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicineId,
                Value<String?> supplierId = const Value.absent(),
                required int quantity,
                required String orderedOn,
                Value<String?> expectedOn = const Value.absent(),
                required String status,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReorderOrdersCompanion.insert(
                id: id,
                medicineId: medicineId,
                supplierId: supplierId,
                quantity: quantity,
                orderedOn: orderedOn,
                expectedOn: expectedOn,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReorderOrdersTable, ReorderOrder>(table),
                  $$ReorderOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicineId = false, supplierId = false}) {
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
                    if (medicineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicineId,
                        referencedTable: $$ReorderOrdersTableReferences
                            ._medicineIdTable(db),
                        referencedColumn: $$ReorderOrdersTableReferences
                            ._medicineIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (supplierId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.supplierId,
                        referencedTable: $$ReorderOrdersTableReferences
                            ._supplierIdTable(db),
                        referencedColumn: $$ReorderOrdersTableReferences
                            ._supplierIdTable(db)
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

typedef $$ReorderOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReorderOrdersTable,
      ReorderOrder,
      $$ReorderOrdersTableFilterComposer,
      $$ReorderOrdersTableOrderingComposer,
      $$ReorderOrdersTableAnnotationComposer,
      $$ReorderOrdersTableCreateCompanionBuilder,
      $$ReorderOrdersTableUpdateCompanionBuilder,
      (ReorderOrder, $$ReorderOrdersTableReferences),
      ReorderOrder,
      PrefetchHooks Function({bool medicineId, bool supplierId})
    >;
typedef $$ReorderReminderStateTableCreateCompanionBuilder =
    ReorderReminderStateCompanion Function({
      required String medicineId,
      Value<String?> lastNotifiedOn,
      Value<String?> snoozedUntil,
      Value<int> rowid,
    });
typedef $$ReorderReminderStateTableUpdateCompanionBuilder =
    ReorderReminderStateCompanion Function({
      Value<String> medicineId,
      Value<String?> lastNotifiedOn,
      Value<String?> snoozedUntil,
      Value<int> rowid,
    });

final class $$ReorderReminderStateTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReorderReminderStateTable,
          ReorderReminderStateData
        > {
  $$ReorderReminderStateTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) => db.medicines
      .createAlias('reorder_reminder_state__medicine_id__medicines__id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReorderReminderStateTableFilterComposer
    extends Composer<_$AppDatabase, $ReorderReminderStateTable> {
  $$ReorderReminderStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lastNotifiedOn => $composableBuilder(
    column: $table.lastNotifiedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReorderReminderStateTableOrderingComposer
    extends Composer<_$AppDatabase, $ReorderReminderStateTable> {
  $$ReorderReminderStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lastNotifiedOn => $composableBuilder(
    column: $table.lastNotifiedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReorderReminderStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReorderReminderStateTable> {
  $$ReorderReminderStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lastNotifiedOn => $composableBuilder(
    column: $table.lastNotifiedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReorderReminderStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReorderReminderStateTable,
          ReorderReminderStateData,
          $$ReorderReminderStateTableFilterComposer,
          $$ReorderReminderStateTableOrderingComposer,
          $$ReorderReminderStateTableAnnotationComposer,
          $$ReorderReminderStateTableCreateCompanionBuilder,
          $$ReorderReminderStateTableUpdateCompanionBuilder,
          (ReorderReminderStateData, $$ReorderReminderStateTableReferences),
          ReorderReminderStateData,
          PrefetchHooks Function({bool medicineId})
        > {
  $$ReorderReminderStateTableTableManager(
    _$AppDatabase db,
    $ReorderReminderStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReorderReminderStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReorderReminderStateTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReorderReminderStateTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> medicineId = const Value.absent(),
                Value<String?> lastNotifiedOn = const Value.absent(),
                Value<String?> snoozedUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReorderReminderStateCompanion(
                medicineId: medicineId,
                lastNotifiedOn: lastNotifiedOn,
                snoozedUntil: snoozedUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String medicineId,
                Value<String?> lastNotifiedOn = const Value.absent(),
                Value<String?> snoozedUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReorderReminderStateCompanion.insert(
                medicineId: medicineId,
                lastNotifiedOn: lastNotifiedOn,
                snoozedUntil: snoozedUntil,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ReorderReminderStateTable,
                    ReorderReminderStateData
                  >(table),
                  $$ReorderReminderStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicineId = false}) {
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
                    if (medicineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicineId,
                        referencedTable: $$ReorderReminderStateTableReferences
                            ._medicineIdTable(db),
                        referencedColumn: $$ReorderReminderStateTableReferences
                            ._medicineIdTable(db)
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

typedef $$ReorderReminderStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReorderReminderStateTable,
      ReorderReminderStateData,
      $$ReorderReminderStateTableFilterComposer,
      $$ReorderReminderStateTableOrderingComposer,
      $$ReorderReminderStateTableAnnotationComposer,
      $$ReorderReminderStateTableCreateCompanionBuilder,
      $$ReorderReminderStateTableUpdateCompanionBuilder,
      (ReorderReminderStateData, $$ReorderReminderStateTableReferences),
      ReorderReminderStateData,
      PrefetchHooks Function({bool medicineId})
    >;
typedef $$ScheduledAlertsTableCreateCompanionBuilder =
    ScheduledAlertsCompanion Function({
      required String id,
      required String kind,
      required int fireAt,
      required int osId,
      required String payload,
      required String contentHash,
      required String state,
      Value<int> rowid,
    });
typedef $$ScheduledAlertsTableUpdateCompanionBuilder =
    ScheduledAlertsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<int> fireAt,
      Value<int> osId,
      Value<String> payload,
      Value<String> contentHash,
      Value<String> state,
      Value<int> rowid,
    });

class $$ScheduledAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledAlertsTable> {
  $$ScheduledAlertsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get osId => $composableBuilder(
    column: $table.osId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduledAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledAlertsTable> {
  $$ScheduledAlertsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get osId => $composableBuilder(
    column: $table.osId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduledAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledAlertsTable> {
  $$ScheduledAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<int> get osId =>
      $composableBuilder(column: $table.osId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$ScheduledAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduledAlertsTable,
          ScheduledAlert,
          $$ScheduledAlertsTableFilterComposer,
          $$ScheduledAlertsTableOrderingComposer,
          $$ScheduledAlertsTableAnnotationComposer,
          $$ScheduledAlertsTableCreateCompanionBuilder,
          $$ScheduledAlertsTableUpdateCompanionBuilder,
          (
            ScheduledAlert,
            BaseReferences<
              _$AppDatabase,
              $ScheduledAlertsTable,
              ScheduledAlert
            >,
          ),
          ScheduledAlert,
          PrefetchHooks Function()
        > {
  $$ScheduledAlertsTableTableManager(
    _$AppDatabase db,
    $ScheduledAlertsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> fireAt = const Value.absent(),
                Value<int> osId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduledAlertsCompanion(
                id: id,
                kind: kind,
                fireAt: fireAt,
                osId: osId,
                payload: payload,
                contentHash: contentHash,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required int fireAt,
                required int osId,
                required String payload,
                required String contentHash,
                required String state,
                Value<int> rowid = const Value.absent(),
              }) => ScheduledAlertsCompanion.insert(
                id: id,
                kind: kind,
                fireAt: fireAt,
                osId: osId,
                payload: payload,
                contentHash: contentHash,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduledAlertsTable, ScheduledAlert>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ScheduledAlertsTable,
                    ScheduledAlert
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduledAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduledAlertsTable,
      ScheduledAlert,
      $$ScheduledAlertsTableFilterComposer,
      $$ScheduledAlertsTableOrderingComposer,
      $$ScheduledAlertsTableAnnotationComposer,
      $$ScheduledAlertsTableCreateCompanionBuilder,
      $$ScheduledAlertsTableUpdateCompanionBuilder,
      (
        ScheduledAlert,
        BaseReferences<_$AppDatabase, $ScheduledAlertsTable, ScheduledAlert>,
      ),
      ScheduledAlert,
      PrefetchHooks Function()
    >;
typedef $$AlertLogTableCreateCompanionBuilder = AlertLogCompanion Function({
  required String id,
  required String kind,
  required String title,
  required String body,
  Value<String?> route,
  required int firedAt,
  Value<int?> openedAt,
  Value<int> rowid,
});
typedef $$AlertLogTableUpdateCompanionBuilder = AlertLogCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> title,
  Value<String> body,
  Value<String?> route,
  Value<int> firedAt,
  Value<int?> openedAt,
  Value<int> rowid,
});

class $$AlertLogTableFilterComposer
    extends Composer<_$AppDatabase, $AlertLogTable> {
  $$AlertLogTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertLogTable> {
  $$AlertLogTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertLogTable> {
  $$AlertLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<int> get firedAt =>
      $composableBuilder(column: $table.firedAt, builder: (column) => column);

  GeneratedColumn<int> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);
}

class $$AlertLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertLogTable,
          AlertLogData,
          $$AlertLogTableFilterComposer,
          $$AlertLogTableOrderingComposer,
          $$AlertLogTableAnnotationComposer,
          $$AlertLogTableCreateCompanionBuilder,
          $$AlertLogTableUpdateCompanionBuilder,
          (
            AlertLogData,
            BaseReferences<_$AppDatabase, $AlertLogTable, AlertLogData>,
          ),
          AlertLogData,
          PrefetchHooks Function()
        > {
  $$AlertLogTableTableManager(_$AppDatabase db, $AlertLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> route = const Value.absent(),
                Value<int> firedAt = const Value.absent(),
                Value<int?> openedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertLogCompanion(
                id: id,
                kind: kind,
                title: title,
                body: body,
                route: route,
                firedAt: firedAt,
                openedAt: openedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String title,
                required String body,
                Value<String?> route = const Value.absent(),
                required int firedAt,
                Value<int?> openedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertLogCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                body: body,
                route: route,
                firedAt: firedAt,
                openedAt: openedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlertLogTable, AlertLogData>(table),
                  BaseReferences<_$AppDatabase, $AlertLogTable, AlertLogData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertLogTable,
      AlertLogData,
      $$AlertLogTableFilterComposer,
      $$AlertLogTableOrderingComposer,
      $$AlertLogTableAnnotationComposer,
      $$AlertLogTableCreateCompanionBuilder,
      $$AlertLogTableUpdateCompanionBuilder,
      (
        AlertLogData,
        BaseReferences<_$AppDatabase, $AlertLogTable, AlertLogData>,
      ),
      AlertLogData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
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
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
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
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
  $$MedicineBarcodesTableTableManager get medicineBarcodes =>
      $$MedicineBarcodesTableTableManager(_db, _db.medicineBarcodes);
  $$SupplierInvoicesTableTableManager get supplierInvoices =>
      $$SupplierInvoicesTableTableManager(_db, _db.supplierInvoices);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$SupplierReturnsTableTableManager get supplierReturns =>
      $$SupplierReturnsTableTableManager(_db, _db.supplierReturns);
  $$StockAdjustmentsTableTableManager get stockAdjustments =>
      $$StockAdjustmentsTableTableManager(_db, _db.stockAdjustments);
  $$SupplierPaymentsTableTableManager get supplierPayments =>
      $$SupplierPaymentsTableTableManager(_db, _db.supplierPayments);
  $$SupplierCreditsTableTableManager get supplierCredits =>
      $$SupplierCreditsTableTableManager(_db, _db.supplierCredits);
  $$SupplierReturnLinesTableTableManager get supplierReturnLines =>
      $$SupplierReturnLinesTableTableManager(_db, _db.supplierReturnLines);
  $$ReorderOrdersTableTableManager get reorderOrders =>
      $$ReorderOrdersTableTableManager(_db, _db.reorderOrders);
  $$ReorderReminderStateTableTableManager get reorderReminderState =>
      $$ReorderReminderStateTableTableManager(_db, _db.reorderReminderState);
  $$ScheduledAlertsTableTableManager get scheduledAlerts =>
      $$ScheduledAlertsTableTableManager(_db, _db.scheduledAlerts);
  $$AlertLogTableTableManager get alertLog =>
      $$AlertLogTableTableManager(_db, _db.alertLog);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
