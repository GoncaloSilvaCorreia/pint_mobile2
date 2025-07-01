class Notification {
  final int id;
  final String type;
  final String message;
  final DateTime sendDate;
  final String workerNumber;
  final bool seen;

  Notification({
    required this.id,
    required this.type,
    required this.message,
    required this.sendDate,
    required this.workerNumber,
    required this.seen,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      sendDate: DateTime.parse(json['sendDate'] as String? ?? DateTime.now().toIso8601String()),
      workerNumber: json['workerNumber'] as String? ?? '',
      seen: json['seen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'message': message,
        'sendDate': sendDate.toIso8601String(),
        'workerNumber': workerNumber,
        'seen': seen,
      };
}