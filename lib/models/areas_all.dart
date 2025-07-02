class FullArea {
  final int id;
  final String description;
  final int categoryId;
  
  FullArea({
    required this.id,
    required this.description,
    required this.categoryId
  });
  
  factory FullArea.fromJson(Map<String, dynamic> json) {
    return FullArea(
      id: json['id'] as int,
      description: json['description'] as String,
      categoryId: json['categoryId'] as int,
    );
  }
}