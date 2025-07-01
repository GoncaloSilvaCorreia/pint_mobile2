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
      id: json['id'],
      description: json['description'],
      categoryId: json['categoryId'] ?? json['category']?['id'],
    );
  }
}