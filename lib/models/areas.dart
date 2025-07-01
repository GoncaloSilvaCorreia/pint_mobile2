class Area {
  final int id;
  final String description;
  final int categoryId;

  Area({
    required this.id,
    required this.description,
    required this.categoryId,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'categoryId': categoryId,
      };
}