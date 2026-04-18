import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/notifications/notification_service.dart';

class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.type,
    required this.scheduledAt,
    required this.title,
    required this.body,
  });

  final int id;
  final String type;
  final DateTime scheduledAt;
  final String title;
  final String body;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'scheduledAt': scheduledAt.toIso8601String(),
      'title': title,
      'body': body,
    };
  }

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] as int,
      type: json['type'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderController, AsyncValue<List<ReminderItem>>>(
  (ref) => ReminderController()..load(),
);

class ReminderController extends StateNotifier<AsyncValue<List<ReminderItem>>> {
  ReminderController() : super(const AsyncLoading());

  static const _storageKey = 'active_reminders_v1';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_storageKey) ?? <String>[];
      final items = raw
          .map((e) =>
              ReminderItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addReminder({
    required String type,
    required Duration after,
  }) async {
    try {
      final permissionGranted =
          await NotificationService.instance.requestPermissions();
      if (!permissionGranted) {
        throw Exception('Bildirim izni verilmedi.');
      }

      final id = _generateId();
      final scheduledAt = DateTime.now().add(after);
      final title = _titleByType(type);
      final body = _bodyByType(type);

      await NotificationService.instance.scheduleReminder(
        id,
        title,
        body,
        scheduledAt,
      );

      final current = state.valueOrNull ?? <ReminderItem>[];
      final next = [
        ...current,
        ReminderItem(
          id: id,
          type: type,
          scheduledAt: scheduledAt,
          title: title,
          body: body,
        ),
      ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      await _persist(next);
      await HapticFeedback.lightImpact();
      state = AsyncData(next);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> removeReminder(int id) async {
    try {
      await NotificationService.instance.cancelReminder(id);
      final current = state.valueOrNull ?? <ReminderItem>[];
      final next = current.where((e) => e.id != id).toList();
      await _persist(next);
      state = AsyncData(next);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> _persist(List<ReminderItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      items.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  int _generateId() =>
      DateTime.now().millisecondsSinceEpoch + Random().nextInt(999);

  String _titleByType(String type) => '$type hatirlatmasi';

  String _bodyByType(String type) {
    switch (type) {
      case 'Beslenme':
        return 'Beslenme zamani geldi.';
      case 'Uyku':
        return 'Uyku rutini icin uygun zaman.';
      case 'Ilac':
        return 'Ilac hatirlatma zamani.';
      default:
        return 'Planlanan hatirlatmaniz var.';
    }
  }
}
