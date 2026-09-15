class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.read = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime date;
  bool read;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'date': date.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        date: DateTime.parse(json['date'] as String),
        read: json['read'] as bool? ?? false,
      );
}
