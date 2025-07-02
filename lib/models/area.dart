class Area {
  final int id;
  final String description;
  final int? categoryId;

  Area({
    required this.id,
    required this.description,
    this.categoryId,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as int,
      description: json['description'] as String,
      categoryId: json['categoryId'] as int? ?? json['category']?['id'] as int?,
    );
  }
}