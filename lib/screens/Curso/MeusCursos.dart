import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:pint_mobile/api/api_inscricoes.dart';
//import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/inscricoes.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeusCursos extends StatefulWidget {
  const MeusCursos({Key? key}) : super(key: key);

  @override
  _MeusCursosState createState() => _MeusCursosState();
}

class _MeusCursosState extends State<MeusCursos> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  late Future<List<Enrollment>> _futureInscricoes;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _futureInscricoes = _loadEnrollments();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    setState(() {
      _userId = userId;
    });
  }

  Future<List<Enrollment>> _loadEnrollments() async {
    final allEnrollments = await _enrollmentService.getEnrollments();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? '';
    
    return allEnrollments
        .where((e) => e.userId == _userId)
        .toList();
  }

  String _determinarEstado(Enrollment enrollment) {
    final now = DateTime.now();
    final startDate = enrollment.course.startDate;
    final endDate = enrollment.course.endDate;

    if (enrollment.status == "Pendente") {
      return "Pendente";
    } else if (enrollment.status == "Ativo") {
      if (now.isBefore(startDate)) {
        return "Em Breve";
      } else if (now.isAfter(startDate) && now.isBefore(endDate)) {
        return "Em curso";
      } else {
        return "Concluído";
      }
    }
    return enrollment.status;
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case "Em Breve":
        return Colors.blue;
      case "Pendente":
        return Colors.orange;
      case "Em curso":
        return Colors.green;
      case "Concluído":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Cursos')),
      endDrawer: const SideMenu(),
      body: FutureBuilder<List<Enrollment>>(
        future: _futureInscricoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum curso encontrado'));
          }

          final inscricoes = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inscricoes.length,
            itemBuilder: (context, index) {
              final enrollment = inscricoes[index];
              final estado = _determinarEstado(enrollment);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Imagem do curso
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                  enrollment.course.image ?? 'https://via.placeholder.com/150',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Título e estado
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enrollment.course.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getEstadoColor(estado),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    estado,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Barra de progresso simulada
                      if (estado == "Em curso")
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: 0.4,
                              backgroundColor: Colors.grey[300],
                              color: Colors.green,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '40% concluído',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      // Botões de ação
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botão Continuar
                          if (estado == "Em curso")
                            ElevatedButton(
                              onPressed: () {
                                // Lógica para continuar o curso
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Continuar'),
                            ),
                          
                          // Botão Detalhes
                          TextButton(
                            onPressed: () {
                              // Lógica para ver detalhes do curso
                            },
                            child: const Text('Ver detalhes'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Rodape(workerNumber: _userId.toString()),
    );
  }
}