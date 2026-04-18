// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class ChildModel extends _ChildModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ChildModel(
    ObjectId id,
    String syncId,
    String name,
    String gender,
    double height,
    double weight,
    DateTime birthDate,
    DateTime createdAt,
    DateTime updatedAt, {
    bool isSynced = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ChildModel>({
        'is_synced': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'sync_id', syncId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'gender', gender);
    RealmObjectBase.set(this, 'height', height);
    RealmObjectBase.set(this, 'weight', weight);
    RealmObjectBase.set(this, 'birth_date', birthDate);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
    RealmObjectBase.set(this, 'is_synced', isSynced);
  }

  ChildModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get syncId => RealmObjectBase.get<String>(this, 'sync_id') as String;
  @override
  set syncId(String value) => RealmObjectBase.set(this, 'sync_id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get gender => RealmObjectBase.get<String>(this, 'gender') as String;
  @override
  set gender(String value) => RealmObjectBase.set(this, 'gender', value);

  @override
  double get height => RealmObjectBase.get<double>(this, 'height') as double;
  @override
  set height(double value) => RealmObjectBase.set(this, 'height', value);

  @override
  double get weight => RealmObjectBase.get<double>(this, 'weight') as double;
  @override
  set weight(double value) => RealmObjectBase.set(this, 'weight', value);

  @override
  DateTime get birthDate =>
      RealmObjectBase.get<DateTime>(this, 'birth_date') as DateTime;
  @override
  set birthDate(DateTime value) =>
      RealmObjectBase.set(this, 'birth_date', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'created_at') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'created_at', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updated_at') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updated_at', value);

  @override
  bool get isSynced => RealmObjectBase.get<bool>(this, 'is_synced') as bool;
  @override
  set isSynced(bool value) => RealmObjectBase.set(this, 'is_synced', value);

  @override
  Stream<RealmObjectChanges<ChildModel>> get changes =>
      RealmObjectBase.getChanges<ChildModel>(this);

  @override
  Stream<RealmObjectChanges<ChildModel>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ChildModel>(this, keyPaths);

  @override
  ChildModel freeze() => RealmObjectBase.freezeObject<ChildModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'sync_id': syncId.toEJson(),
      'name': name.toEJson(),
      'gender': gender.toEJson(),
      'height': height.toEJson(),
      'weight': weight.toEJson(),
      'birth_date': birthDate.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
      'is_synced': isSynced.toEJson(),
    };
  }

  static EJsonValue _toEJson(ChildModel value) => value.toEJson();
  static ChildModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'sync_id': EJsonValue syncId,
        'name': EJsonValue name,
        'gender': EJsonValue gender,
        'height': EJsonValue height,
        'weight': EJsonValue weight,
        'birth_date': EJsonValue birthDate,
        'created_at': EJsonValue createdAt,
        'updated_at': EJsonValue updatedAt,
      } =>
        ChildModel(
          fromEJson(id),
          fromEJson(syncId),
          fromEJson(name),
          fromEJson(gender),
          fromEJson(height),
          fromEJson(weight),
          fromEJson(birthDate),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          isSynced: fromEJson(ejson['is_synced'], defaultValue: false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ChildModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ChildModel, 'ChildModel', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('syncId', RealmPropertyType.string,
          mapTo: 'sync_id', indexType: RealmIndexType.regular),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('gender', RealmPropertyType.string),
      SchemaProperty('height', RealmPropertyType.double),
      SchemaProperty('weight', RealmPropertyType.double),
      SchemaProperty('birthDate', RealmPropertyType.timestamp,
          mapTo: 'birth_date'),
      SchemaProperty('createdAt', RealmPropertyType.timestamp,
          mapTo: 'created_at'),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp,
          mapTo: 'updated_at'),
      SchemaProperty('isSynced', RealmPropertyType.bool, mapTo: 'is_synced'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
