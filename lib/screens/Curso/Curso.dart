import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/inscricoes.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  final Enrollment? enrollment;

  const CourseDetailScreen({super.key, required this.course, this.enrollment});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  String _workerNumber = '';

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
  }

  Future<void> _loadWorkerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final workerNumber = prefs.getString('workerNumber') ?? '';
    setState(() {
      _workerNumber = workerNumber;
    });
  }

  Future<String> getTrainerName(String trainerId) async {
    final response = await http.get(
      Uri.parse('https://pint-13nr.onrender.com/api/users'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final users = data['users'] as List;
      final user = users.firstWhere(
        (u) => u['workerNumber'] == trainerId,
        orElse: () => null,
      );
      if (user != null) {
        return user['name'] ?? 'Desconhecido';
      } else {
        return 'Desconhecido';
      }
    } else {
      throw Exception('Erro ao carregar formador');
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final enrollment = widget.enrollment;

    bool inscritoPendente = enrollment != null && enrollment.status == "Pendente";
    bool inscritoAtivo = enrollment != null && enrollment.status == "Ativo";
    bool semVagas = course.vacancies != null && course.vacancies == 0;
    bool podeInscrever = course.enrollmentsOpen && !semVagas && !inscritoPendente && !inscritoAtivo;

    return Scaffold(
      endDrawer: const SideMenu(),
      appBar: AppBar(
        title: const Text("Cursos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    course.image ?? 'https://via.placeholder.com/150',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                course.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              FutureBuilder<String>(
                future: getTrainerName(course.instructor),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("Erro ao carregar formador");
                  } else {
                    return Row(
                      children: [
                        const Text("Formador: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          snapshot.data ?? "Desconhecido",
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              const Text("Descrição", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                course.description,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(course.endDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (inscritoAtivo)
                const Text("Já estás inscrito neste curso.",
                    style: TextStyle(color: Colors.green)),
              if (inscritoPendente)
                const Text("Inscrição pendente. Aguarda aprovação.",
                    style: TextStyle(color: Colors.orange)),

              const SizedBox(height: 16),

              if (!inscritoAtivo && !inscritoPendente)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: podeInscrever ? () {
                      // ação para inscrever
                    } : null,
                    child: const Text("Inscrever"),
                  ),
                ),

              if (!course.enrollmentsOpen)
                const Text("Inscrições encerradas para este curso.",
                    style: TextStyle(color: Colors.red)),
                    
              if (semVagas)
                const Text("Este curso não tem vagas disponíveis.",
                    style: TextStyle(color: Colors.red)),
                    
              if (!course.status && !course.type)
                const Text("Este curso já terminou.",
                    style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Rodape(workerNumber: _workerNumber),
    );
  }
}