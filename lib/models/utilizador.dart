class Utilizador {
  final int id;
  final String nome;
  final String email;
  final List<String> roles;
  final String token;

  Utilizador({
    required this.id,
    required this.nome,
    required this.email,
    required this.roles,
    required this.token,
  });

  factory Utilizador.fromJson(Map<String, dynamic> json) {
    try {
      final userData = json['user'] as Map<String, dynamic>? ?? {};
      final token = json['token'] as String? ?? '';

      return Utilizador(
        id: (userData['id'] as int?) ?? 0, 
        nome: (userData['name'] as String?) ?? '', 
        email: (userData['email'] as String?) ?? '',
        roles: List<String>.from(userData['roles'] ?? []),
        token: token,
      );
    } catch (e) {
      print('Erro ao criar Utilizador: $e');
      throw FormatException('Formato inválido dos dados do utilizador');
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': nome,
        'email': email,
        'roles': roles,
        'token': token,
      };
}