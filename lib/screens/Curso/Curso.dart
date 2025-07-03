import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/inscricoes.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  final Enrollment? enrollment;

  const CourseDetailScreen({super.key, required this.course, this.enrollment});

  Future<String> getTrainerName(String trainerId) async {
    final response = await http.get(
      Uri.parse('https://pint-13nr.onrender.com/api/users'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = (data as List).firstWhere(
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
    bool inscritoPendente = enrollment != null && enrollment!.status == "Pendente";
    bool inscritoAtivo = enrollment != null && enrollment!.status == "Ativo";
    bool cursoJaComecou = course.startDate.isBefore(DateTime.now());
    bool semVagas = course.vacancies != null && course.vacancies == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cursos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // ação do menu
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem
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

              // Título
              Text(
                course.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Formador com FutureBuilder
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

              // Descrição
              const Text("Descrição", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                course.description,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),

              // Data limite
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

              // Estado inscrição
              if (inscritoAtivo)
                const Text("Já estás inscrito neste curso.",
                    style: TextStyle(color: Colors.green)),
              if (inscritoPendente)
                const Text("Inscrição pendente. Aguarda aprovação.",
                    style: TextStyle(color: Colors.orange)),

              const SizedBox(height: 16),

              // Botão de inscrição
              if (!inscritoAtivo && !inscritoPendente)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (cursoJaComecou || semVagas) ? null : () {
                      // ação para inscrever
                    },
                    child: const Text("Inscrever"),
                  ),
                ),

              if (cursoJaComecou)
                const Text("Este curso já começou.",
                    style: TextStyle(color: Colors.red)),
              if (semVagas)
                const Text("Este curso não tem vagas disponíveis.",
                    style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Rodape(),
    );
  }
}
