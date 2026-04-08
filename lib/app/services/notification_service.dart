import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/model/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationService {
  NotificationService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _api.dio.get<dynamic>('/api/notifications');
      if (response.statusCode != 200) {
        throw Exception('Bildirimler alınamadı');
      }

      final items = _extractItems(response.data);
      return items.map(_mapNotification).toList();
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
      if (response.statusCode != 200 && response.statusCode != 204) {
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

  NotificationModel _mapNotification(Map<String, dynamic> json) {
    final createdAt = _parseDateTime(
      json['createdAt'] ?? json['date'] ?? json['timestamp'] ?? json['time'],
    );

    return NotificationModel(
      id: (json['id'] ?? json['_id'] ?? json['notificationId'] ?? '')
          .toString(),
      title: _pickFirstNonEmpty([
        json['title']?.toString(),
        json['subject']?.toString(),
        json['name']?.toString(),
        'Bildirim',
      ]),
      subtitle: _emptyToNull(
        _pickFirstNonEmpty([
          json['subtitle']?.toString(),
          json['summary']?.toString(),
          json['description']?.toString(),
        ]),
      ),
      content: _pickFirstNonEmpty([
        json['content']?.toString(),
        json['message']?.toString(),
        json['body']?.toString(),
        '',
      ]),
      time: createdAt == null ? '' : _formatRelativeTime(createdAt),
      isUnread: json['isUnread'] == true ||
          json['unread'] == true ||
          json['read'] == false ||
          json['isRead'] == false,
    );
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
