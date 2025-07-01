class Resource {
  final int id;
  final int sectionId;
  final int typeId;
  final String? title;
  final String? text;
  final String? file;
  final String? link;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.sectionId,
    required this.typeId,
    this.title,
    this.text,
    this.file,
    this.link,
    required this.createdAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as int? ?? 0,
      sectionId: json['sectionId'] as int? ?? 0,
      typeId: json['typeId'] as int? ?? 0,
      title: json['title'] as String?,
      text: json['text'] as String?,
      file: json['file'] as String?,
      link: json['link'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionId': sectionId,
        'typeId': typeId,
        'title': title,
        'text': text,
        'file': file,
        'link': link,
        'createdAt': createdAt.toIso8601String(),
      };
}