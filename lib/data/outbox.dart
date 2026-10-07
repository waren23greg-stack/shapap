import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class OutboxEvent {
  final String id; // UUID = idempotency key for a future backend
  final String patientId;
  final String type; // DISCHARGE, DISCHARGE_TRUST, EMERGENCY_SOS
  final DateTime createdAt;
  final bool synced;

  const OutboxEvent({
    required this.id,
    required this.patientId,
    required this.type,
    required this.createdAt,
    this.synced = false,
  });

  OutboxEvent copyWith({bool? synced}) => OutboxEvent(
        id: id,
        patientId: patientId,
        type: type,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'synced': synced,
      };

  factory OutboxEvent.fromJson(Map<String, dynamic> j) => OutboxEvent(
        id: j['id'] as String,
        patientId: j['patientId'] as String,
        type: j['type'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        synced: j['synced'] as bool,
      );
}

class OutboxNotifier extends Notifier<List<OutboxEvent>> {
  static const _key = 'outbox_v1';

  @override
  List<OutboxEvent> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    state = (jsonDecode(raw) as List)
        .map((e) => OutboxEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  Future<void> queue(String patientId, String type) async {
    state = [
      ...state,
      OutboxEvent(
        id: const Uuid().v4(),
        patientId: patientId,
        type: type,
        createdAt: DateTime.now(),
      ),
    ];
    await _save();
  }

  Future<void> markAllSynced() async {
    state = [for (final e in state) e.copyWith(synced: true)];
    await _save();
  }

  Future<void> clear() async {
    state = [];
    await _save();
  }
}

final outboxProvider =
    NotifierProvider<OutboxNotifier, List<OutboxEvent>>(OutboxNotifier.new);

final pendingCountProvider = Provider<int>(
    (ref) => ref.watch(outboxProvider).where((e) => !e.synced).length);