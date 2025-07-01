class Reaction {
  final int id;
  final String workerNumber;
  final int commentId;
  final bool type; // false=Dislike, true=Like

  Reaction({
    required this.id,
    required this.workerNumber,
    required this.commentId,
    required this.type,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'] as int? ?? 0,
      workerNumber: json['workerNumber'] as String? ?? '',
      commentId: json['commentId'] as int? ?? 0,
      type: json['type'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workerNumber': workerNumber,
        'commentId': commentId,
        'type': type,
      };
}