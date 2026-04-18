// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_log_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class EventLogModel extends _EventLogModel
    with RealmEntity, RealmObjectBase, RealmObject {
  EventLogModel(
    ObjectId id,
    String syncId,
    ObjectId childId,
    String eventType,
    DateTime startTime,
    bool isSynced,
    DateTime createdAt,
    DateTime updatedAt, {
    String? subType,
    DateTime? endTime,
    String? note,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'sync_id', syncId);
    RealmObjectBase.set(this, 'child_id', childId);
    RealmObjectBase.set(this, 'event_type', eventType);
    RealmObjectBase.set(this, 'sub_type', subType);
    RealmObjectBase.set(this, 'start_time', startTime);
    RealmObjectBase.set(this, 'end_time', endTime);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'is_synced', isSynced);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  EventLogModel._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get syncId => RealmObjectBase.get<String>(this, 'sync_id') as String;
  @override
  set syncId(String value) => RealmObjectBase.set(this, 'sync_id', value);

  @override
  ObjectId get childId =>
      RealmObjectBase.get<ObjectId>(this, 'child_id') as ObjectId;
  @override
  set childId(ObjectId value) => RealmObjectBase.set(this, 'child_id', value);

  @override
  String get eventType =>
      RealmObjectBase.get<String>(this, 'event_type') as String;
  @override
  set eventType(String value) => RealmObjectBase.set(this, 'event_type', value);

  @override
  String? get subType =>
      RealmObjectBase.get<String>(this, 'sub_type') as String?;
  @override
  set subType(String? value) => RealmObjectBase.set(this, 'sub_type', value);

  @override
  DateTime get startTime =>
      RealmObjectBase.get<DateTime>(this, 'start_time') as DateTime;
  @override
  set startTime(DateTime value) =>
      RealmObjectBase.set(this, 'start_time', value);

  @override
  DateTime? get endTime =>
      RealmObjectBase.get<DateTime>(this, 'end_time') as DateTime?;
  @override
  set endTime(DateTime? value) => RealmObjectBase.set(this, 'end_time', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  bool get isSynced => RealmObjectBase.get<bool>(this, 'is_synced') as bool;
  @override
  set isSynced(bool value) => RealmObjectBase.set(this, 'is_synced', value);

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
  Stream<RealmObjectChanges<EventLogModel>> get changes =>
      RealmObjectBase.getChanges<EventLogModel>(this);

  @override
  Stream<RealmObjectChanges<EventLogModel>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<EventLogModel>(this, keyPaths);

  @override
  EventLogModel freeze() => RealmObjectBase.freezeObject<EventLogModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'sync_id': syncId.toEJson(),
      'child_id': childId.toEJson(),
      'event_type': eventType.toEJson(),
      'sub_type': subType.toEJson(),
      'start_time': startTime.toEJson(),
      'end_time': endTime.toEJson(),
      'note': note.toEJson(),
      'is_synced': isSynced.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(EventLogModel value) => value.toEJson();
  static EventLogModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'sync_id': EJsonValue syncId,
        'child_id': EJsonValue childId,
        'event_type': EJsonValue eventType,
        'start_time': EJsonValue startTime,
        'is_synced': EJsonValue isSynced,
        'created_at': EJsonValue createdAt,
        'updated_at': EJsonValue updatedAt,
      } =>
        EventLogModel(
          fromEJson(id),
          fromEJson(syncId),
          fromEJson(childId),
          fromEJson(eventType),
          fromEJson(startTime),
          fromEJson(isSynced),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          subType: fromEJson(ejson['sub_type']),
          endTime: fromEJson(ejson['end_time']),
          note: fromEJson(ejson['note']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(EventLogModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, EventLogModel, 'EventLogModel', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('syncId', RealmPropertyType.string,
          mapTo: 'sync_id', indexType: RealmIndexType.regular),
      SchemaProperty('childId', RealmPropertyType.objectid,
          mapTo: 'child_id', indexType: RealmIndexType.regular),
      SchemaProperty('eventType', RealmPropertyType.string,
          mapTo: 'event_type', indexType: RealmIndexType.regular),
      SchemaProperty('subType', RealmPropertyType.string,
          mapTo: 'sub_type', optional: true),
      SchemaProperty('startTime', RealmPropertyType.timestamp,
          mapTo: 'start_time'),
      SchemaProperty('endTime', RealmPropertyType.timestamp,
          mapTo: 'end_time', optional: true),
      SchemaProperty('note', RealmPropertyType.string, optional: true),
      SchemaProperty('isSynced', RealmPropertyType.bool, mapTo: 'is_synced'),
      SchemaProperty('createdAt', RealmPropertyType.timestamp,
          mapTo: 'created_at'),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp,
          mapTo: 'updated_at'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
