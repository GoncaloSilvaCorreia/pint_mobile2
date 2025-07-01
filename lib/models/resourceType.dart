class ResourceType {
  final int id;
  final int type;
  final String? icon;

  ResourceType({
    required this.id,
    required this.type,
    this.icon,
  });

  factory ResourceType.fromJson(Map<String, dynamic> json) {
    return ResourceType(
      id: json['id'] as int? ?? 0,
      type: json['type'] as int? ?? 0,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'icon': icon,
      };
}