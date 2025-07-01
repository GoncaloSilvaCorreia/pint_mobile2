class Interest {
  final int id;
  final String workerNumber;
  final int? categoryId;
  final int? areaId;
  final int? topicId;

  Interest({
    required this.id,
    required this.workerNumber,
    this.categoryId,
    this.areaId,
    this.topicId,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'] as int? ?? 0,
      workerNumber: json['workerNumber'] as String? ?? '',
      categoryId: json['categoryId'] as int?,
      areaId: json['areaId'] as int?,
      topicId: json['topicId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workerNumber': workerNumber,
        'categoryId': categoryId,
        'areaId': areaId,
        'topicId': topicId,
      };
}