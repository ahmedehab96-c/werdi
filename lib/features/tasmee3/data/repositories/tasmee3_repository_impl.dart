import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:werdi/features/tasmee3/domain/models/ayah_range.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_result.dart';
import 'package:werdi/features/tasmee3/domain/models/tasmee3_session.dart';
import 'package:werdi/features/tasmee3/domain/repositories/tasmee3_repository.dart';

class LocalTasmee3Repository implements Tasmee3Repository {
  static const _key = 'tasmee3_sessions_v2';
  static const _maxSessions = 50;

  @override
  Future<List<Tasmee3Session>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final sessions = <Tasmee3Session>[];
    for (final item in raw) {
      try {
        sessions.add(_fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {}
    }
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  @override
  Future<void> saveSession(Tasmee3Session session) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.insert(0, jsonEncode(_toJson(session)));
    if (raw.length > _maxSessions) raw.removeRange(_maxSessions, raw.length);
    await prefs.setStringList(_key, raw);
  }

  Map<String, dynamic> _toJson(Tasmee3Session s) => {
        'id': s.id,
        'surahName': s.surahName,
        'ayahStart': s.ayahRange.start,
        'ayahEnd': s.ayahRange.end,
        'date': s.date.toIso8601String(),
        'grades': s.result.grades
            .map((k, v) => MapEntry(k.toString(), v.name)),
      };

  Tasmee3Session _fromJson(Map<String, dynamic> json) => Tasmee3Session(
        id: json['id'] as String,
        surahName: json['surahName'] as String,
        ayahRange: AyahRange(
          start: json['ayahStart'] as int,
          end: json['ayahEnd'] as int,
        ),
        date: DateTime.parse(json['date'] as String),
        result: Tasmee3Result(
          grades: (json['grades'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(
              int.parse(k),
              AyahGrade.values.byName(v as String),
            ),
          ),
        ),
      );
}

typedef Tasmee3RepositoryImpl = LocalTasmee3Repository;
