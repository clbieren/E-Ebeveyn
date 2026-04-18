// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class UserModel extends _UserModel
    with RealmEntity, RealmObjectBase, RealmObject {
  UserModel(
    ObjectId id,
    DateTime createdAt, {
    String? supabaseId,
    String? email,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'supabase_id', supabaseId);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'created_at', createdAt);
  }

  UserModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get supabaseId =>
      RealmObjectBase.get<String>(this, 'supabase_id') as String?;
  @override
  set supabaseId(String? value) =>
      RealmObjectBase.set(this, 'supabase_id', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'created_at') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'created_at', value);

  @override
  Stream<RealmObjectChanges<UserModel>> get changes =>
      RealmObjectBase.getChanges<UserModel>(this);

  @override
  Stream<RealmObjectChanges<UserModel>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<UserModel>(this, keyPaths);

  @override
  UserModel freeze() => RealmObjectBase.freezeObject<UserModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'supabase_id': supabaseId.toEJson(),
      'email': email.toEJson(),
      'created_at': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(UserModel value) => value.toEJson();
  static UserModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'created_at': EJsonValue createdAt,
      } =>
        UserModel(
          fromEJson(id),
          fromEJson(createdAt),
          supabaseId: fromEJson(ejson['supabase_id']),
          email: fromEJson(ejson['email']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UserModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, UserModel, 'UserModel', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('supabaseId', RealmPropertyType.string,
          mapTo: 'supabase_id', optional: true),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.timestamp,
          mapTo: 'created_at'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
