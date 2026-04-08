class NotificationModel {
  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String time;
  final bool isUnread;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.content = '',
    required this.time,
    this.isUnread = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      isUnread: json['isUnread'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'time': time,
      'isUnread': isUnread,
    };
  }
}
