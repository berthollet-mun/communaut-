class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool is_read;
  final int? related_id;
  final String? related_type;
  final DateTime created_at;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.is_read,
    this.related_id,
    this.related_type,
    required this.created_at,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      is_read: json['is_read'] == true || json['is_read'] == 1,
      related_id: json['related_id'],
      related_type: json['related_type']?.toString(),
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  /// Créer une notification locale (sans API)
  factory NotificationModel.local({
    required String type,
    required String title,
    required String message,
    int? relatedId,
    String? relatedType,
  }) {
    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      type: type,
      title: title,
      message: message,
      is_read: false,
      related_id: relatedId,
      related_type: relatedType,
      created_at: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'is_read': is_read,
      'related_id': related_id,
      'related_type': related_type,
      'created_at': created_at.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    String? type,
    String? title,
    String? message,
    bool? is_read,
    int? related_id,
    String? related_type,
    DateTime? created_at,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      is_read: is_read ?? this.is_read,
      related_id: related_id ?? this.related_id,
      related_type: related_type ?? this.related_type,
      created_at: created_at ?? this.created_at,
    );
  }

  // Helpers
  bool get isUnread => !is_read;

  String get icon {
    switch (type) {
      case 'task_created':
        return '📝';
      case 'task_assigned':
        return '📋';
      case 'task_completed':
        return '✅';
      case 'task_updated':
        return '✏️';
      case 'comment_added':
        return '💬';
      case 'member_joined':
        return '👤';
      case 'member_left':
        return '👋';
      case 'project_created':
        return '📁';
      case 'project_updated':
        return '📂';
      case 'community_created':
        return '🏠';
      case 'invitation':
        return '📨';
      case 'login':
        return '🔐';
      case 'success':
        return '✅';
      case 'error':
        return '❌';
      case 'warning':
        return '⚠️';
      case 'info':
        return 'ℹ️';
      default:
        return '🔔';
    }
  }
}
