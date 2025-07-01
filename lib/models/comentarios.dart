class Comment {
  final int id;
  final int topicId;
  final String workerNumber;
  final int? parentCommentId;
  final DateTime commentDate;
  final String content;
  final bool status;

  Comment({
    required this.id,
    required this.topicId,
    required this.workerNumber,
    this.parentCommentId,
    required this.commentDate,
    required this.content,
    required this.status,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int? ?? 0,
      topicId: json['topicId'] as int? ?? 0,
      workerNumber: json['workerNumber'] as String? ?? '',
      parentCommentId: json['parentCommentId'] as int?,
      commentDate: DateTime.parse(json['commentDate'] as String? ?? DateTime.now().toIso8601String()),
      content: json['content'] as String? ?? '',
      status: json['status'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'workerNumber': workerNumber,
        'parentCommentId': parentCommentId,
        'commentDate': commentDate.toIso8601String(),
        'content': content,
        'status': status,
      };
}
