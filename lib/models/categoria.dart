class Category {
  final int id;
  final String description;

  Category({
    required this.id,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
      };
}