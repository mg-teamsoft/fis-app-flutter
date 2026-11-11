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
    this.category,
    this.version,
    this.endDate,
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
      category: json['category']?.toString(),
      version: json['version']?.toString(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
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
  final String? category;
  final String? version;
  final DateTime? endDate;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? content,
    String? time,
    bool? isUnread,
    String? actionType,
    String? screen,
    String? category,
    String? version,
    DateTime? endDate,
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
      category: category ?? this.category,
      version: version ?? this.version,
      endDate: endDate ?? this.endDate,
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
      'category': category,
      'version': version,
      'endDate': endDate?.toIso8601String(),
    };
  }
}
