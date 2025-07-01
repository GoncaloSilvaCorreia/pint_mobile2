class Course {
  final int id;
  final String title;
  final bool courseType; // false=Síncrono, true=Assíncrono
  final String description;
  final String instructor;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int status; // 0=Inativo, 1=Ativo
  final int topicId;
  final String level; // Básico, Intermédio, Avançado
  final String? image;
  final DateTime startDate;
  final DateTime endDate;
  final int? hours;
  final int? vacancies;

  Course({
    required this.id,
    required this.title,
    required this.courseType,
    required this.description,
    required this.instructor,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.topicId,
    required this.level,
    this.image,
    required this.startDate,
    required this.endDate,
    this.hours,
    this.vacancies,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      courseType: json['courseType'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      status: json['status'] as int? ?? 1,
      topicId: json['topicId'] as int? ?? 0,
      level: json['level'] as String? ?? 'Básico',
      image: json['image'] as String?,
      startDate: DateTime.parse(json['startDate'] as String? ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] as String? ?? DateTime.now().toIso8601String()),
      hours: json['hours'] as int?,
      vacancies: json['vacancies'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseType': courseType,
        'description': description,
        'instructor': instructor,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'status': status,
        'topicId': topicId,
        'level': level,
        'image': image,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'hours': hours,
        'vacancies': vacancies,
      };

  // Métodos auxiliares
  String get courseTypeName => courseType ? 'Assíncrono' : 'Síncrono';
  String get statusName => status == 1 ? 'Ativo' : 'Inativo';
  bool get hasVacancies => vacancies == null || vacancies! > 0;
}