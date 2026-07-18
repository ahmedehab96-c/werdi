import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:werdi/core/database/app_database.dart';
import 'package:werdi/core/network/supabase_service.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/core/sync/sync_capabilities.dart';

/// Queues write operations while offline, then replays them when possible.
class OfflineSyncService {
  OfflineSyncService({
    AppPreferences? preferences,
    AppDatabase? database,
  })  : _preferences = preferences ?? const SharedPrefsService(),
        _database = database;

  final AppPreferences _preferences;
  final AppDatabase? _database;

  static const _queueKey = 'offline_sync_queue_v1';
  static const _maxQueueLength = 500;
  bool _migratedToDb = false;

  SupabaseClient? get _client => SupabaseService.clientOrNull;

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
    if (!canSyncWithSupabase) return;

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
      } on SocketException {
        remaining.add(item);
        final index = queue.indexOf(item);
        if (index + 1 < queue.length) {
          remaining.addAll(queue.sublist(index + 1));
        }
        break;
      } on PostgrestException catch (e) {
        if (_isConnectivityIssue(e)) {
          remaining.add(item);
          final index = queue.indexOf(item);
          if (index + 1 < queue.length) {
            remaining.addAll(queue.sublist(index + 1));
          }
          break;
        }
      } catch (_) {
        remaining.add(item);
      }
    }

    await _writeQueue(remaining);
  }

  Future<void> _execute({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final client = _client;
    final userId = supabaseUserId;
    if (client == null || userId == null) return;

    switch (type) {
      case 'bookmark.toggle_surah':
        final surahNumber = (payload['surah_number'] as num).toInt();
        final existing = await client
            .from('bookmarks')
            .select('id')
            .eq('user_id', userId)
            .eq('type', 'surah')
            .eq('surah_number', surahNumber)
            .maybeSingle();
        if (existing == null) {
          await client.from('bookmarks').insert({
            'user_id': userId,
            'type': 'surah',
            'surah_number': surahNumber,
          });
        } else {
          await client
              .from('bookmarks')
              .delete()
              .eq('user_id', userId)
              .eq('type', 'surah')
              .eq('surah_number', surahNumber);
        }
      case 'bookmark.toggle_ayah':
        final surahNumber = (payload['surah_number'] as num).toInt();
        final ayahNumber = (payload['ayah_number'] as num).toInt();
        final previewText = payload['preview_text'] as String? ?? '';
        final existing = await client
            .from('bookmarks')
            .select('id')
            .eq('user_id', userId)
            .eq('type', 'ayah')
            .eq('surah_number', surahNumber)
            .eq('ayah_number', ayahNumber)
            .maybeSingle();
        if (existing == null) {
          await client.from('bookmarks').insert({
            'user_id': userId,
            'type': 'ayah',
            'surah_number': surahNumber,
            'ayah_number': ayahNumber,
            'preview_text': previewText,
          });
        } else {
          await client
              .from('bookmarks')
              .delete()
              .eq('user_id', userId)
              .eq('type', 'ayah')
              .eq('surah_number', surahNumber)
              .eq('ayah_number', ayahNumber);
        }
      case 'progress.memorization':
        await client.from('user_progress').upsert({
          'user_id': userId,
          'memorized_ayah_count':
              (payload['memorized_ayah_count'] as num?)?.toInt() ?? 0,
          'reviewed_items_count':
              (payload['reviewed_items_count'] as num?)?.toInt() ?? 0,
          'streak_days': (payload['streak_days'] as num?)?.toInt() ?? 0,
          'last_surah_number': (payload['surah_number'] as num?)?.toInt(),
          'last_ayah_number': (payload['ayah_number'] as num?)?.toInt(),
          'last_progress': (payload['progress'] as num?)?.toDouble() ?? 0,
          'updated_at': DateTime.now().toIso8601String(),
        });
      case 'progress.review':
        await client.from('user_progress').upsert({
          'user_id': userId,
          'memorized_ayah_count':
              (payload['memorized_ayah_count'] as num?)?.toInt() ?? 0,
          'reviewed_items_count':
              (payload['reviewed_items_count'] as num?)?.toInt() ?? 0,
          'streak_days': (payload['streak_days'] as num?)?.toInt() ?? 0,
          'updated_at': DateTime.now().toIso8601String(),
        });
      case 'progress.activity':
        await client.from('user_progress').upsert({
          'user_id': userId,
          'memorized_ayah_count':
              (payload['memorized_ayah_count'] as num?)?.toInt() ?? 0,
          'reviewed_items_count':
              (payload['reviewed_items_count'] as num?)?.toInt() ?? 0,
          'streak_days': (payload['streak_days'] as num?)?.toInt() ?? 0,
          'updated_at': DateTime.now().toIso8601String(),
        });
      case 'review.upsert':
        await client.from('review_items').upsert(
          {
            'user_id': userId,
            'id': payload['id'],
            'title': payload['title'],
            'subtitle': payload['subtitle'],
            'priority': payload['priority'],
            'surah_number': payload['surah_number'],
            'ayah_start': payload['ayah_start'],
            'ayah_end': payload['ayah_end'],
            'reviewed': payload['reviewed'] ?? false,
            'difficult': payload['difficult'] ?? false,
            'updated_at': payload['updated_at'] ??
                DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id,id',
        );
      default:
        return;
    }
  }

  bool _isConnectivityIssue(PostgrestException e) {
    final message = e.message.toLowerCase();
    return message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('connection');
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
