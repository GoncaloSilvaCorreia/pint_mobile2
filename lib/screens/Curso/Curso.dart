import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/inscricoes.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  final Enrollment? enrollment; // null se não inscrito

  const CourseDetailScreen({super.key, required this.course, this.enrollment});

  @override
  Widget build(BuildContext context) {
    bool inscritoPendente = enrollment != null && enrollment!.status == "Pendente";
    bool inscritoAtivo = enrollment != null && enrollment!.status == "Ativo";
    bool cursoJaComecou = course.startDate.isBefore(DateTime.now());
    bool semVagas = course.vacancies != null && course.vacancies == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(course.description),
            const SizedBox(height: 8),
            Text('Tipo: ${course.type ? "Assíncrono" : "Síncrono"}'),
            const SizedBox(height: 8),
            Text('Data Início: ${DateFormat('dd/MM/yyyy').format(course.startDate)}'),
            Text('Data Fim: ${DateFormat('dd/MM/yyyy').format(course.endDate)}'),
            const SizedBox(height: 16),

            // Estado inscrição
            if (inscritoAtivo)
              const Text("Já estás inscrito neste curso.", style: TextStyle(color: Colors.green)),
            if (inscritoPendente)
              const Text("Inscrição pendente. Aguarda aprovação.", style: TextStyle(color: Colors.orange)),

            const Spacer(),

            // Botão de inscrição
            if (!inscritoAtivo && !inscritoPendente)
              ElevatedButton(
                onPressed: (cursoJaComecou || semVagas) ? null : () {
                  // ação para inscrever
                },
                child: const Text("Inscrever"),
              ),

            if (cursoJaComecou)
              const Text("Este curso já começou.", style: TextStyle(color: Colors.red)),
            if (semVagas)
              const Text("Este curso não tem vagas disponíveis.", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
