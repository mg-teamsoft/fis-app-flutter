part of '../widget/appbar/appbar.dart';

class _ModelNotification {
  _ModelNotification({
    required this.enumNotification,
    required this.isRead,
    required this.title,
    required this.summary,
    required this.date,
    required this.description,
    this.id,
  });

  // ignore: unused_element
  factory _ModelNotification.fromJson(Map<String, dynamic> json) {
    return _ModelNotification(
      id: json['id']?.toString(),
      // JSON'dan gelen String'i Enum'a çeviriyoruz
      enumNotification:
          _EnumNotification.fromName(json['enumNotification'] as String?),
      isRead: (json['isRead'] as bool?) ?? false,
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      description: json['description']?.toString() ?? '',
    );
  }
  final String? id;
  final _EnumNotification enumNotification;
  final bool isRead;
  final String title;
  final String summary;
  final DateTime date;
  final String description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enumNotification': enumNotification.name,
      'isRead': isRead,
      'title': title,
      'summary': summary,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
