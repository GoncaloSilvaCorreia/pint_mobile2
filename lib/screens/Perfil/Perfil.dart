import 'package:flutter/material.dart';
import 'package:pint_mobile/api/api_utilizador.dart';
import 'package:pint_mobile/models/utilizador.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Perfil extends StatefulWidget {
  final String workerNumber;

  const Perfil({Key? key, required this.workerNumber}) : super(key: key);

  @override
  State<Perfil> createState() => PerfilScreenState();
}

class PerfilScreenState extends State<Perfil> {
  final ApiUtilizador api = ApiUtilizador();
  late Future<Utilizador> _futureUtilizador;
  String _workerNumber = '';
  late Future<List<Map<String, dynamic>>> _futureCursos;

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
    _futureUtilizador = api.getUtilizadorByWorkerNumber(widget.workerNumber);
    _futureCursos = api.getCursosByWorkerNumber(widget.workerNumber);
  }

  Future<void> _loadWorkerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final workerNumber = prefs.getString('workerNumber') ?? '';
    setState(() {
      _workerNumber = workerNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: AppBar(title: const Text('Meu perfil')),
      endDrawer: const SideMenu(),
      body: FutureBuilder<Utilizador>(
        future: _futureUtilizador,
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData) {
            final utilizador = userSnapshot.data!;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureCursos,
              builder: (context, cursosSnapshot) {
                List<Map<String, dynamic>> cursos = [];
                if (cursosSnapshot.hasData) {
                  cursos = cursosSnapshot.data!;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com informações do usuário
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                  utilizador.pfp ?? 'https://via.placeholder.com/150',
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                utilizador.nome,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow("Função:", utilizador.primaryRole ?? "N/A"),
                            _buildInfoRow("ID:", utilizador.workerNumber),
                            _buildInfoRow("E-mail:", utilizador.email),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Seção de Preferências
                      const Text(
                        "As minhas preferências",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPreferencesTable(utilizador.interests),
                      
                      const SizedBox(height: 20),
                      
                      // Seção de Cursos Concluídos
                      const Text(
                        "Cursos concluídos",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCoursesTable(cursos),
                    ],
                  ),
                );
              },
            );
          } else if (userSnapshot.hasError) {
            return Center(child: Text('Erro: ${userSnapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: Rodape(workerNumber: _workerNumber),
    );
  }

  // Widget para construir linha de informação
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir a tabela de preferências
  Widget _buildPreferencesTable(List<Map<String, dynamic>> interests) {
    if (interests.isEmpty) {
      return const Center(
        child: Text("Nenhum interesse encontrado"),
      );
    }

    // Dividir interesses em grupos de 2 para formar as linhas
    List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < interests.length; i += 2) {
      if (i + 1 < interests.length) {
        rows.add([interests[i], interests[i + 1]]);
      } else {
        rows.add([interests[i]]);
      }
    }

    return Table(
      border: TableBorder.all(
        color: Colors.grey[300]!,
        width: 1.0,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(0.3),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(0.3),
      },
      children: [
        for (var row in rows)
          TableRow(
            decoration: BoxDecoration(
              color: rows.indexOf(row) % 2 == 0
                  ? Colors.white
                  : Colors.grey[50],
            ),
            children: [
              // Primeiro interesse
              _buildPreferenceCell(row[0]["description"]),
              _buildRemoveButton(),
              // Segundo interesse (se existir)
              row.length > 1
                  ? _buildPreferenceCell(row[1]["description"])
                  : Container(),
              row.length > 1
                  ? _buildRemoveButton()
                  : Container(),
            ],
          ),
      ],
    );
  }

  // Widget para célula de preferência
  Widget _buildPreferenceCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // Widget para botão de remoção (X)
  Widget _buildRemoveButton() {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.close, size: 20),
        color: Colors.red,
        onPressed: () {
          // Lógica para remover preferência
        },
      ),
    );
  }

  // Widget para construir a tabela de cursos (CORRIGIDO)
  Widget _buildCoursesTable(List<Map<String, dynamic>> cursos) {
    if (cursos.isEmpty) {
      return const Center(
        child: Text("Nenhum curso encontrado"),
      );
    }

    return Table(
      border: TableBorder.all(
        color: Colors.grey[300]!,
        width: 1.0,
      ),
      columnWidths: const {
        0: FlexColumnWidth(0.5),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(0.5),
      },
      children: [
        // Cabeçalho da tabela
        TableRow(
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  "ID",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  "Nome",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  "Certificado",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Linhas de cursos (CORREÇÃO APLICADA AQUI)
        for (var curso in cursos)
          TableRow(
            decoration: BoxDecoration(
              color: cursos.indexOf(curso) % 2 == 0
                  ? Colors.white
                  : Colors.grey[50],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Center(child: Text(curso["id"].toString())),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(curso["title"]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Center(
                  child: curso.containsKey("certificado") && curso["certificado"]
                      ? const Icon(Icons.verified, color: Colors.green)
                      : const Text("💤", style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}