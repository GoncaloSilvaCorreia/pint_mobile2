import 'package:pint_mobile/models/area.dart';

class Category {
  final int id;
  final String description;
  final List<Area> areas;

  Category({
    required this.id,
    required this.description,
    required this.areas,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      description: json['description'],
      areas: (json['areas'] as List).map((area) => Area.fromJson(area)).toList(),
    );
  }
}