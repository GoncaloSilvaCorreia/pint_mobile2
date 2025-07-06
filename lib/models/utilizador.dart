class Utilizador {
  final int id;
  final String nome;
  final String email;
  final List<String> roles;
  final String? primaryRole;
  final String workerNumber;
  final String token;
  final String? pfp;
  final List<Map<String, dynamic>> interests;

  Utilizador({
    required this.id,
    required this.nome,
    required this.email,
    required this.roles,
    this.primaryRole,
    required this.workerNumber,
    required this.token,
    this.pfp,
    required this.interests,
  });

  factory Utilizador.fromJson(Map<String, dynamic> json) {
    try {
      final token = json['token'] as String? ?? '';

      final userData = json['user'] as Map<String, dynamic>? ?? json;

      return Utilizador(
        id: (userData['id'] as int?) ?? 0,
        nome: (userData['name'] as String?) ?? '',
        email: (userData['email'] as String?) ?? '',
        roles: (userData['roles'] != null)
            ? List<String>.from(userData['roles'])
            : [],
        primaryRole: userData['primaryRole'] as String?,
        workerNumber: (userData['workerNumber'] as String?) ?? '',
        token: token,
        pfp: userData['pfp'],
        interests: (userData['interests'] as List?)
            ?.map((e) => {
                  'id': e['id'],
                  'description': e['topic']['description'] ?? 'Sem descrição',
                })
            .toList() ?? [],
      );
    } catch (e) {
      print('Erro ao criar Utilizador: $e');
      throw FormatException('Formato inválido dos dados do utilizador');
    }
  }
}
