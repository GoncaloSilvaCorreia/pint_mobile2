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
      id: json['id'],
      description: json['description'],
      areaId: json['area']?['id'] ?? json['areaId'],
    );
  }
}