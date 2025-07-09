import 'resource.dart';

class Section {
  final int id;
  final int courseId;
  final String title;
  final int order;
  final bool status;
  final List<Resource> resources;

  Section({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
    required this.status,
    required this.resources,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      status: json['status'] as bool? ?? false,
      resources: (json['resources'] as List<dynamic>?)
              ?.map((resource) => Resource.fromJson(resource))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'order': order,
        'status': status,
        'resources': resources.map((resource) => resource.toJson()).toList(),
      };
}