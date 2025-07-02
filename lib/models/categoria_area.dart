class CategoriaArea {
  final int id;
  final String description;
  
  CategoriaArea({required this.id, required this.description});
  
  factory CategoriaArea.fromJson(Map<String, dynamic> json) {
    return CategoriaArea(
      id: json['id'],
      description: json['description'],
    );
  }
}