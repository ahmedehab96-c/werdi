import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:werdi/core/utils/arabic_text_normalizer.dart';

class AppDatabase extends GeneratedDatabase {
  AppDatabase() : super(_openConnection());

  bool _initialized = false;

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _createSchemaIfNeeded();
    _initialized = true;
  }

  Future<void> _createSchemaIfNeeded() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS quran_ayahs (
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        text_uthmani TEXT NOT NULL,
        text_simple TEXT,
        source TEXT NOT NULL DEFAULT 'local',
        cached_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (surah_number, ayah_number)
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS bookmarks_surah (
        surah_number INTEGER NOT NULL PRIMARY KEY,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS bookmarks_ayah (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        surah_name_arabic TEXT NOT NULL DEFAULT '',
        preview_text TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS review_items (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        priority TEXT NOT NULL,
        surah_number INTEGER,
        ayah_start INTEGER,
        ayah_end INTEGER,
        reviewed INTEGER NOT NULL DEFAULT 0,
        difficult INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS memorization_progress (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        progress REAL NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    ''');
  }

  Future<int> countReviewItems() async {
    await ensureInitialized();
    final result = await customSelect(
      'SELECT COUNT(*) AS count FROM review_items',
    ).getSingle();
    return result.read<int>('count');
  }

  Future<List<QueryRow>> getReviewItems() async {
    await ensureInitialized();
    return customSelect(
      '''
      SELECT id, title, subtitle, priority, surah_number, ayah_start, ayah_end,
             reviewed, difficult, updated_at
      FROM review_items
      ORDER BY datetime(updated_at) DESC
      ''',
    ).get();
  }

  Future<void> upsertReviewItem({
    required String id,
    required String title,
    required String subtitle,
    required String priority,
    required int? surahNumber,
    required int? ayahStart,
    required int? ayahEnd,
    required bool reviewed,
    required bool difficult,
  }) async {
    await ensureInitialized();
    await customStatement(
      '''
      INSERT INTO review_items (
        id, title, subtitle, priority, surah_number, ayah_start, ayah_end,
        reviewed, difficult, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        title=excluded.title,
        subtitle=excluded.subtitle,
        priority=excluded.priority,
        surah_number=excluded.surah_number,
        ayah_start=excluded.ayah_start,
        ayah_end=excluded.ayah_end,
        reviewed=excluded.reviewed,
        difficult=excluded.difficult,
        updated_at=excluded.updated_at
      ''',
      <Object?>[
        id,
        title,
        subtitle,
        priority,
        surahNumber,
        ayahStart,
        ayahEnd,
        reviewed ? 1 : 0,
        difficult ? 1 : 0,
        DateTime.now().toIso8601String(),
      ],
    );
  }

  Future<void> replaceSurahAyahs({
    required int surahNumber,
    required List<({
      int ayahNumber,
      String textUthmani,
      String? textSimple,
      String source,
    })> ayahs,
  }) async {
    await ensureInitialized();
    await transaction(() async {
      await customStatement(
        'DELETE FROM quran_ayahs WHERE surah_number = ?',
        <Object?>[surahNumber],
      );
      for (final ayah in ayahs) {
        await customStatement(
          '''
          INSERT INTO quran_ayahs (
            surah_number, ayah_number, text_uthmani, text_simple, source, cached_at
          )
          VALUES (?, ?, ?, ?, ?, ?)
          ''',
          <Object?>[
            surahNumber,
            ayah.ayahNumber,
            ayah.textUthmani,
            ayah.textSimple ?? ArabicTextNormalizer.normalize(ayah.textUthmani),
            ayah.source,
            DateTime.now().toIso8601String(),
          ],
        );
      }
    });
  }

  Future<List<QueryRow>> getSurahAyahs(int surahNumber) async {
    await ensureInitialized();
    return customSelect(
      '''
      SELECT surah_number, ayah_number, text_uthmani, source, cached_at
      FROM quran_ayahs
      WHERE surah_number = ?
      ORDER BY ayah_number ASC
      ''',
      variables: <Variable<Object>>[Variable<int>(surahNumber)],
    ).get();
  }

  Future<List<QueryRow>> searchAyahs({
    required String query,
    int limit = 30,
  }) async {
    await ensureInitialized();
    final rawQuery = query.trim();
    final normalizedQuery = ArabicTextNormalizer.normalize(query);
    if (rawQuery.isEmpty || normalizedQuery.isEmpty) return const [];
    return customSelect(
      '''
      SELECT surah_number, ayah_number, text_uthmani
      FROM quran_ayahs
      WHERE text_uthmani LIKE ? OR text_simple LIKE ?
      ORDER BY surah_number ASC, ayah_number ASC
      LIMIT ?
      ''',
      variables: <Variable<Object>>[
        Variable<String>('%$rawQuery%'),
        Variable<String>('%$normalizedQuery%'),
        Variable<int>(limit),
      ],
    ).get();
  }

  Future<void> clearExpiredSurahAyahs({required Duration ttl}) async {
    await ensureInitialized();
    final cutoff = DateTime.now().subtract(ttl).toIso8601String();
    await customStatement(
      '''
      DELETE FROM quran_ayahs
      WHERE datetime(cached_at) < datetime(?)
      ''',
      <Object?>[cutoff],
    );
  }

  Future<void> replaceBookmarksCache({
    required Set<int> surahIds,
    required List<({
      int surahNumber,
      String surahNameArabic,
      int ayahNumber,
      String previewText,
    })> ayahs,
  }) async {
    await ensureInitialized();
    await transaction(() async {
      await customStatement('DELETE FROM bookmarks_surah');
      await customStatement('DELETE FROM bookmarks_ayah');
      for (final id in surahIds) {
        await customStatement(
          'INSERT INTO bookmarks_surah (surah_number, created_at) VALUES (?, ?)',
          <Object?>[id, DateTime.now().toIso8601String()],
        );
      }
      for (final ayah in ayahs) {
        await customStatement(
          '''
          INSERT INTO bookmarks_ayah (
            surah_number, ayah_number, surah_name_arabic, preview_text, created_at
          ) VALUES (?, ?, ?, ?, ?)
          ''',
          <Object?>[
            ayah.surahNumber,
            ayah.ayahNumber,
            ayah.surahNameArabic,
            ayah.previewText,
            DateTime.now().toIso8601String(),
          ],
        );
      }
    });
  }

  Future<({Set<int> surahIds, List<QueryRow> ayahRows})> getBookmarksCache() async {
    await ensureInitialized();
    final surahRows = await customSelect(
      'SELECT surah_number FROM bookmarks_surah',
    ).get();
    final ayahRows = await customSelect(
      '''
      SELECT surah_number, ayah_number, surah_name_arabic, preview_text
      FROM bookmarks_ayah
      ORDER BY id DESC
      ''',
    ).get();
    final surahIds = surahRows.map((r) => r.read<int>('surah_number')).toSet();
    return (surahIds: surahIds, ayahRows: ayahRows);
  }

  Future<void> enqueueSyncOperation({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    await ensureInitialized();
    await customStatement(
      '''
      INSERT INTO sync_queue (type, payload_json, created_at)
      VALUES (?, ?, ?)
      ''',
      <Object?>[
        type,
        jsonEncode(payload),
        DateTime.now().toIso8601String(),
      ],
    );
    await customStatement(
      '''
      DELETE FROM sync_queue
      WHERE id NOT IN (
        SELECT id FROM sync_queue ORDER BY id DESC LIMIT 500
      )
      ''',
    );
  }

  Future<List<({int id, String type, Map<String, dynamic> payload})>>
      getSyncQueueItems() async {
    await ensureInitialized();
    final rows = await customSelect(
      '''
      SELECT id, type, payload_json
      FROM sync_queue
      ORDER BY id ASC
      ''',
    ).get();
    return rows.map((row) {
      final payloadRaw = row.read<String>('payload_json');
      final payloadDecoded = jsonDecode(payloadRaw);
      final payload = payloadDecoded is Map<String, dynamic>
          ? payloadDecoded
          : <String, dynamic>{};
      return (
        id: row.read<int>('id'),
        type: row.read<String>('type'),
        payload: payload,
      );
    }).toList();
  }

  Future<void> replaceSyncQueueItems(
    List<({String type, Map<String, dynamic> payload})> items,
  ) async {
    await ensureInitialized();
    await transaction(() async {
      await customStatement('DELETE FROM sync_queue');
      for (final item in items) {
        await enqueueSyncOperation(type: item.type, payload: item.payload);
      }
    });
  }

  Future<String?> getAppSetting(String key) async {
    await ensureInitialized();
    final rows = await customSelect(
      'SELECT value FROM app_settings WHERE key = ? LIMIT 1',
      variables: <Variable<Object>>[Variable<String>(key)],
    ).get();
    if (rows.isEmpty) return null;
    return rows.first.read<String>('value');
  }

  Future<void> setAppSetting({
    required String key,
    required String value,
  }) async {
    await ensureInitialized();
    await customStatement(
      '''
      INSERT INTO app_settings (key, value, updated_at)
      VALUES (?, ?, ?)
      ON CONFLICT(key) DO UPDATE SET
        value = excluded.value,
        updated_at = excluded.updated_at
      ''',
      <Object?>[
        key,
        value,
        DateTime.now().toIso8601String(),
      ],
    );
  }

  Future<void> addMemorizationProgress({
    required String userId,
    required int surahNumber,
    required int ayahNumber,
    required double progress,
  }) async {
    await ensureInitialized();
    await customStatement(
      '''
      INSERT INTO memorization_progress (
        user_id, surah_number, ayah_number, progress, updated_at
      ) VALUES (?, ?, ?, ?, ?)
      ''',
      <Object?>[
        userId,
        surahNumber,
        ayahNumber,
        progress,
        DateTime.now().toIso8601String(),
      ],
    );
  }

  Future<int> countMemorizationToday({required String userId}) async {
    await ensureInitialized();
    final today = DateTime.now();
    final start =
        DateTime(today.year, today.month, today.day).toIso8601String();
    final rows = await customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM memorization_progress
      WHERE user_id = ? AND datetime(updated_at) >= datetime(?)
      ''',
      variables: <Variable<Object>>[
        Variable<String>(userId),
        Variable<String>(start),
      ],
    ).getSingle();
    return rows.read<int>('count');
  }

  Future<int> countMemorizationThisWeek({required String userId}) async {
    await ensureInitialized();
    final weekStart = DateTime.now().subtract(const Duration(days: 6));
    final sinceIso =
        DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String();
    final rows = await customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM memorization_progress
      WHERE user_id = ? AND datetime(updated_at) >= datetime(?)
      ''',
      variables: <Variable<Object>>[
        Variable<String>(userId),
        Variable<String>(sinceIso),
      ],
    ).getSingle();
    return rows.read<int>('count');
  }

  Future<int> countReviewsThisWeek() async {
    await ensureInitialized();
    final weekStart = DateTime.now().subtract(const Duration(days: 6));
    final sinceIso =
        DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String();
    final rows = await customSelect(
      '''
      SELECT COUNT(*) AS count
      FROM review_items
      WHERE reviewed = 1 AND datetime(updated_at) >= datetime(?)
      ''',
      variables: <Variable<Object>>[Variable<String>(sinceIso)],
    ).getSingle();
    return rows.read<int>('count');
  }

  Future<int> getMemorizedAyahCount({required String userId}) async {
    await ensureInitialized();
    final rows = await customSelect(
      '''
      SELECT COUNT(DISTINCT (CAST(surah_number AS TEXT) || ':' || CAST(ayah_number AS TEXT))) AS count
      FROM memorization_progress
      WHERE user_id = ?
      ''',
      variables: <Variable<Object>>[Variable<String>(userId)],
    ).getSingle();
    return rows.read<int>('count');
  }

  Future<int> countReviewedItems() async {
    await ensureInitialized();
    final rows = await customSelect(
      'SELECT COUNT(*) AS count FROM review_items WHERE reviewed = 1',
    ).getSingle();
    return rows.read<int>('count');
  }

  /// Memorization events per calendar day for the last [days] days (oldest first).
  Future<List<int>> memorizationCountsByDay({
    required String userId,
    int days = 7,
  }) async {
    await ensureInitialized();
    final counts = List<int>.filled(days, 0);
    final since = DateTime.now().subtract(Duration(days: days - 1));
    final sinceIso = DateTime(since.year, since.month, since.day).toIso8601String();
    final rows = await customSelect(
      '''
      SELECT date(updated_at) AS day, COUNT(*) AS count
      FROM memorization_progress
      WHERE user_id = ? AND datetime(updated_at) >= datetime(?)
      GROUP BY date(updated_at)
      ''',
      variables: <Variable<Object>>[
        Variable<String>(userId),
        Variable<String>(sinceIso),
      ],
    ).get();
    final start = DateTime(since.year, since.month, since.day);
    for (final row in rows) {
      final dayStr = row.read<String>('day');
      final parsed = DateTime.tryParse(dayStr);
      if (parsed == null) continue;
      final day = DateTime(parsed.year, parsed.month, parsed.day);
      final index = day.difference(start).inDays;
      if (index >= 0 && index < days) {
        counts[index] = row.read<int>('count');
      }
    }
    return counts;
  }

  Future<int> countActiveDaysThisWeek({required String userId}) async {
    await ensureInitialized();
    final weekStart = DateTime.now().subtract(const Duration(days: 6));
    final sinceIso =
        DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String();
    final memRows = await customSelect(
      '''
      SELECT COUNT(DISTINCT date(updated_at)) AS count
      FROM memorization_progress
      WHERE user_id = ? AND datetime(updated_at) >= datetime(?)
      ''',
      variables: <Variable<Object>>[
        Variable<String>(userId),
        Variable<String>(sinceIso),
      ],
    ).getSingle();
    final reviewRows = await customSelect(
      '''
      SELECT COUNT(DISTINCT date(updated_at)) AS count
      FROM review_items
      WHERE reviewed = 1 AND datetime(updated_at) >= datetime(?)
      ''',
      variables: <Variable<Object>>[Variable<String>(sinceIso)],
    ).getSingle();
    return memRows.read<int>('count') + reviewRows.read<int>('count');
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'werdi_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
