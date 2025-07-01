class Section {
  final int id;
  final int courseId;
  final String title;
  final int order;
  final bool status; // false=Inativo, true=Ativo

  Section({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
    required this.status,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      status: json['status'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'title': title,
        'order': order,
        'status': status,
      };

  String get statusName => status ? 'Ativo' : 'Inativo';
}