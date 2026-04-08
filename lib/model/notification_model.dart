class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    this.content = '',
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

  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String time;
  final bool isUnread;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? content,
    String? time,
    bool? isUnread,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      time: time ?? this.time,
      isUnread: isUnread ?? this.isUnread,
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
