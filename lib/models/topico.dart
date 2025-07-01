class Topic {
  final int id;
  final String description;
  final int areaId;

  Topic({
    required this.id,
    required this.description,
    required this.areaId,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      areaId: json['areaId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'areaId': areaId,
      };
}