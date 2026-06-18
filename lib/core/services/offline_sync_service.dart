import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/network/laravel_api_client.dart';
import 'package:werdi/core/services/app_preferences.dart';

/// Queues write operations while offline, then replays them when possible.
class OfflineSyncService {
  OfflineSyncService({
    required LaravelApiClient client,
    AppPreferences? preferences,
    AppDatabase? database,
  })  : _client = client,
        _preferences = preferences ?? const SharedPrefsService(),
        _database = database;

  final LaravelApiClient _client;
  final AppPreferences _preferences;
  final AppDatabase? _database;

  static const _queueKey = 'offline_sync_queue_v1';
  static const _maxQueueLength = 500;
  bool _migratedToDb = false;

  Future<void> enqueue({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    if (_database != null) {
      await _migrateLegacyQueueIfNeeded();
      await _database.enqueueSyncOperation(type: type, payload: payload);
      return;
    }
    final queue = await _readQueueFromPrefs();
    queue.add({'type': type, 'payload': payload});
    if (queue.length > _maxQueueLength) {
      queue.removeRange(0, queue.length - _maxQueueLength);
    }
    await _writeQueueToPrefs(queue);
  }

  Future<void> flushPending() async {
    final queue = await _readQueue();
    if (queue.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final item in queue) {
      final type = item['type'] as String?;
      final payload = item['payload'] as Map<String, dynamic>?;
      if (type == null || payload == null) {
        continue;
      }

      try {
        await _execute(type: type, payload: payload);
      } on DioException catch (e) {
        if (_isConnectivityIssue(e)) {
          remaining.add(item);
          final index = queue.indexOf(item);
          if (index + 1 < queue.length) {
            remaining.addAll(queue.sublist(index + 1));
          }
          break;
        }
        // Drop non-connectivity failing operation (validation/server conflict)
        // and continue replaying other operations.
      } catch (_) {
        // Keep unknown failures for another try.
        remaining.add(item);
      }
    }

    await _writeQueue(remaining);
  }

  Future<void> _execute({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    switch (type) {
      case 'bookmark.toggle_surah':
        await _client.dio.post<Map<String, dynamic>>(
          '/bookmarks/surah',
          data: {'surah_number': payload['surah_number']},
        );
      case 'bookmark.toggle_ayah':
        await _client.dio.post<Map<String, dynamic>>(
          '/bookmarks/ayah',
          data: {
            'surah_number': payload['surah_number'],
            'ayah_number': payload['ayah_number'],
            'preview_text': payload['preview_text'],
          },
        );
      case 'progress.memorization':
        await _client.dio.post<Map<String, dynamic>>(
          '/progress/memorization',
          data: {
            'user_id': payload['user_id'],
            'surah_number': payload['surah_number'],
            'ayah_number': payload['ayah_number'],
            'progress': payload['progress'],
          },
        );
      case 'progress.review':
        await _client.dio.post<Map<String, dynamic>>(
          '/progress/review',
          data: {
            'user_id': payload['user_id'],
            'review_id': payload['review_id'],
            'reviewed': payload['reviewed'],
            'difficult': payload['difficult'],
          },
        );
      default:
        // Unknown operation type should be ignored.
        return;
    }
  }

  bool _isConnectivityIssue(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }

  Future<List<Map<String, dynamic>>> _readQueue() async {
    if (_database != null) {
      await _migrateLegacyQueueIfNeeded();
      final rows = await _database.getSyncQueueItems();
      return rows
          .map(
            (row) => <String, dynamic>{
              'type': row.type,
              'payload': row.payload,
            },
          )
          .toList();
    }
    return _readQueueFromPrefs();
  }

  Future<List<Map<String, dynamic>>> _readQueueFromPrefs() async {
    final raw = await _preferences.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((e) {
        return e.map(
          (key, value) => MapEntry('$key', value),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeQueue(List<Map<String, dynamic>> queue) async {
    if (_database != null) {
      await _database.replaceSyncQueueItems(
        queue
            .where((item) => item['type'] is String && item['payload'] is Map)
            .map(
              (item) => (
                type: item['type'] as String,
                payload: Map<String, dynamic>.from(item['payload'] as Map),
              ),
            )
            .toList(),
      );
      return;
    }
    await _writeQueueToPrefs(queue);
  }

  Future<void> _writeQueueToPrefs(List<Map<String, dynamic>> queue) async {
    await _preferences.setString(_queueKey, jsonEncode(queue));
  }

  Future<void> _migrateLegacyQueueIfNeeded() async {
    if (_database == null || _migratedToDb) return;
    _migratedToDb = true;
    final legacy = await _readQueueFromPrefs();
    if (legacy.isEmpty) return;
    await _database.replaceSyncQueueItems(
      legacy
          .where((item) => item['type'] is String && item['payload'] is Map)
          .map(
            (item) => (
              type: item['type'] as String,
              payload: Map<String, dynamic>.from(item['payload'] as Map),
            ),
          )
          .toList(),
    );
    await _preferences.setString(_queueKey, '[]');
  }
}
