class NotificationModel {
  NotificationModel({
    required this.id,
    required this.title,
    required this.time,
    this.subtitle,
    this.content = '',
    this.isUnread = false,
    this.actionType,
    this.screen,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      content: json['content']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      isUnread: json['isUnread'] as bool? ?? false,
      actionType: json['actionType']?.toString(),
      screen: json['screen']?.toString(),
    );
  }

  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String time;
  final bool isUnread;
  // Yönlendirme için gereken alanlar
  final String? actionType;
  final String? screen;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? content,
    String? time,
    bool? isUnread,
    String? actionType,
    String? screen,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      time: time ?? this.time,
      isUnread: isUnread ?? this.isUnread,
      actionType: actionType ?? this.actionType,
      screen: screen ?? this.screen,
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
      'actionType': actionType,
      'screen': screen,
    };
  }
}
