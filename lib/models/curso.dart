class Course {
  final int id;
  final String title;
  final bool type; // false=Assíncrono, true= Síncrono
  final String description;
  final String instructor;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool status; // false=Inativo, true=Ativo
  final bool visible; // false=Invisivel, true=Visivel
  final int topicId;
  final String level; // Básico, Intermédio, Avançado
  final String? image;
  final DateTime startDate;
  final DateTime endDate;
  final int? hours;
  final int? vacancies;
  final bool enrollmentsOpen; // Novo campo: inscricoes

  Course({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.instructor,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.visible,
    required this.topicId,
    required this.level,
    this.image,
    required this.startDate,
    required this.endDate,
    this.hours,
    this.vacancies,
    required this.enrollmentsOpen,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      type: json['courseType'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      status: json['status'] as bool? ?? false,
      visible: json['visible'] as bool? ?? false,
      topicId: json['topic'] != null ? json['topic']['id'] as int : 0,
      level: json['level'] as String? ?? 'Básico',
      image: json['image'] as String?,
      startDate: DateTime.parse(json['startDate'] as String? ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] as String? ?? DateTime.now().toIso8601String()),
      hours: json['hours'] as int?,
      vacancies: json['vacancies'] as int?,
      enrollmentsOpen: json['inscricoes'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseType': type,
        'description': description,
        'instructor': instructor,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'status': status,
        'visible': visible,
        'topicId': topicId,
        'level': level,
        'image': image,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'hours': hours,
        'vacancies': vacancies,
        'enrollmentsOpen': enrollmentsOpen,
      };

  // Métodos auxiliares
  String get courseType => type ? 'Síncrono' : 'Assíncrono';
  String get statusName => status ? 'Ativo' : 'Inativo';
  String get visibleName => visible ? 'Visível' : 'Invisível';

  bool get hasVacancies => vacancies == null || vacancies! > 0;
  
  // Verifica se o curso pode ser exibido na pesquisa
  bool get shouldDisplayInSearch {
    if (!visible) return false;
    
    // Cursos síncronos: mostrar se estiverem ativos OU com inscrições abertas
    if (!type) {
      return status || enrollmentsOpen;
    }
    // Cursos assíncronos: mostrar apenas se estiverem ativos
    return status;
  }
}