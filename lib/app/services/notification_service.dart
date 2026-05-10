import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/model/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class NotificationService {
  factory NotificationService({ApiClient? apiClient}) {
    if (apiClient != null) {
      _instance._api = apiClient;
    }
    return _instance;
  }

  NotificationService._internal() : _api = ApiClient();

  static final NotificationService _instance = NotificationService._internal();

  ApiClient _api;
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Future<List<NotificationModel>> fetchNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _api.dio.get<dynamic>(
        '/api/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode != 200) {
        throw Exception('Bildirimler alınamadı');
      }

      final items = _extractItems(response.data);
      final mappedItems = items.map(_mapNotification).toList();

      var count = 0;
      for (final item in mappedItems) {
        if (item.isUnread) count++;
      }
      unreadCount.value = count;

      return mappedItems;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Bildirimler alınamadı');
    }
  }

  Future<void> markAsRead(List<String> notificationIds) async {
    final ids = notificationIds
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (ids.isEmpty) {
      return;
    }

    try {
      final response = await _api.dio.post<dynamic>(
        '/api/notifications/read',
        data: {'notificationIds': ids},
      );
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception('Bildirim okundu olarak işaretlenemedi');
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Bildirim okundu olarak işaretlenemedi');
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      const candidateKeys = ['data', 'items', 'notifications', 'results'];
      for (final key in candidateKeys) {
        final value = data[key];
        if (value is List) {
          return value
              .whereType<Map<String, dynamic>>()
              .map(Map<String, dynamic>.from)
              .toList();
        }
      }
    }

    return const [];
  }

  void decrementUnreadCount({int by = 1}) {
    if (unreadCount.value >= by) {
      unreadCount.value -= by;
    } else {
      unreadCount.value = 0;
    }
  }

  void incrementUnreadCount({int by = 1}) {
    unreadCount.value += by;
  }

  NotificationModel _mapNotification(Map<String, dynamic> json) {
    final createdAt = _parseDateTime(
      json['createdAt'] ?? json['date'] ?? json['timestamp'],
    );

    return NotificationModel(
      id: (json['id'] ?? json['_id'] ?? json['notificationId'] ?? '')
          .toString(),
      title: _pickFirstNonEmpty([
        json['title']?.toString(),
        json['subject']?.toString(),
        'Bildirim',
      ]),
      subtitle: _emptyToNull(
        _pickFirstNonEmpty([
          json['subtitle']?.toString(),
          json['summary']?.toString(),
        ]),
      ),
      content: _pickFirstNonEmpty([
        json['content']?.toString(),
        json['message']?.toString(),
        '',
      ]),
      // Eğer backend'den 'time' zaten "2 dk önce" şeklinde geliyorsa doğrudan kullan,
      // yoksa createdAt üzerinden formatla.
      time: json['time']?.toString() ??
          (createdAt == null ? '' : _formatRelativeTime(createdAt)),
      isUnread: _parseIsUnread(json),

      // BURASI KRİTİK: Yeni alanları ekliyoruz
      actionType: json['actionType']?.toString(),
      screen: json['screen']?.toString(),
    );
  }

  bool _parseIsUnread(Map<String, dynamic> json) {
    bool? getBool(String key) {
      if (!json.containsKey(key)) return null;
      final val = json[key];
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true';
      if (val is num) return val > 0;
      return null;
    }

    final unread = getBool('isUnread') ?? getBool('unread');
    if (unread != null) return unread;

    final read = getBool('isRead') ?? getBool('read');
    if (read != null) return !read;

    return false;
  }

  DateTime? _parseDateTime(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }

  String _formatRelativeTime(DateTime value) {
    final now = DateTime.now();
    final local = value.toLocal();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) {
      return 'Az önce';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} dk önce';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} saat önce';
    }
    if (diff.inDays == 1) {
      return 'Dün';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    }
    return DateFormat('d MMM yyyy', 'tr_TR').format(local);
  }

  String _pickFirstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return '';
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;
}
