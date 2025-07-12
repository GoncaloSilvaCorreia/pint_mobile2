class ForumTopic {
  final int id;
  final int topicId;
  final String topicTitle;
  final String authorName;
  final String authorAvatar;
  final String? category;
  final String? area;
  final String title;
  final String description;
  final String date;
  final int commentsCount;
  final int likes;
  final int dislikes;
  final ForumComment firstComment;

  ForumTopic({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.authorName,
    required this.authorAvatar,
    this.category,
    this.area,
    required this.title,
    required this.description,
    required this.date,
    required this.commentsCount,
    required this.likes,
    required this.dislikes,
    required this.firstComment,
  });

  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    return ForumTopic(
      id: json['id'],
      topicId: json['topicId'],
      topicTitle: json['topicTitle'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'] ?? '',
      category: json['category'],
      area: json['area'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      commentsCount: json['commentsCount'],
      likes: json['likes'],
      dislikes: json['dislikes'],
      firstComment: ForumComment.fromJson(json['firstComment']),
    );
  }
}

class ForumComment {
  final int id;
  final String content;
  final String? ficheiro;
  final String authorName;
  final String authorAvatar;
  final String? date;
  final List<dynamic> reaction;
  final List<ForumComment> replies;

  ForumComment({
    required this.id,
    required this.content,
    this.ficheiro,
    required this.authorName,
    required this.authorAvatar,
    this.date,
    required this.reaction,
    required this.replies,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'],
      content: json['content'],
      ficheiro: json['ficheiro'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'] ?? '',
      date: json['date'],
      reaction: json['Reaction'] ?? [],
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((e) => ForumComment.fromJson(e)).toList(),
    );
  }
}
