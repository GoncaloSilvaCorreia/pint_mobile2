class Comment {
  final int id;
  final int topicId;
  final String authorName;
  final String authorAvatar;
  final DateTime commentDate;
  final String content;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.topicId,
    required this.authorName,
    required this.authorAvatar,
    required this.commentDate,
    required this.content,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    var repliesFromJson = json['replies'] as List? ?? [];
    List<Comment> repliesList = repliesFromJson
        .map((replyJson) => Comment.fromJson(replyJson))
        .toList();

    return Comment(
      id: json['id'] as int? ?? 0,
      topicId: json['topicId'] as int? ?? 0,
      authorName: json['authorName'] as String? ?? '',
      authorAvatar: json['authorAvatar'] as String? ?? '',
      commentDate: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
      content: json['content'] as String? ?? '',
      replies: repliesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'date': commentDate.toIso8601String(),
        'content': content,
        'replies': replies.map((reply) => reply.toJson()).toList(),
      };
}