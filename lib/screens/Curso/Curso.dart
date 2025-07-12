import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';

import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/inscricoes.dart';

import 'package:pint_mobile/api/api_inscricoes.dart';

class Curso extends StatefulWidget {
  final Course course;
  final Enrollment? enrollment;

  const Curso({super.key, required this.course, this.enrollment});

  @override
  State<Curso> createState() => _CursoState();
}

class _CursoState extends State<Curso> {
  int _userId = 0;
  bool _isLoading = false;
  final EnrollmentService _enrollmentService = EnrollmentService();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    setState(() {
      _userId = userId;
    });
  }

  Future<String> getTrainerName(String trainerWorkerNumber) async {
    final response = await http.get(
      Uri.parse('https://pint2.onrender.com/api/users/id/$trainerWorkerNumber'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['user'] != null) {
        return data['user']['name'] ?? 'Desconhecido';
      } else {
        return 'Desconhecido';
      }
    } else {
      throw Exception('Erro ao carregar formador');
    }
  }

  Future<void> _realizarInscricao() async {
    setState(() => _isLoading = true);
    
    try {
      await _enrollmentService.createEnrollment(
        widget.course.id, 
        _userId
      );
      
      _mostrarConfirmacao();
    } catch (e) {
      String errorMessage = 'Erro ao proceder á inscrição no curso ${widget.course.title}';
      
      _mostrarErro(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarConfirmacao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Inscrição Realizada'),
        content: const Text('Sua inscrição foi realizada com sucesso e está pendente de aprovação.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Erro na Inscrição'),
        content: SingleChildScrollView(
          child: Text(mensagem),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
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
      backgroundColor: Colors.grey[300],
      endDrawer: const SideMenu(),
      appBar: AppBar(
        title: const Text("Detalhes do Curso", 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey[300], 
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          course.image ?? 'https://via.placeholder.com/150',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, size: 50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Color(0xFF1976D2), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FutureBuilder<String>(
                              future: getTrainerName(course.instructor),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Formador",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      snapshot.data ?? "Desconhecido",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Descrição",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            course.description,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cast_connected, size: 22, color: Color(0xFF1976D2)),
                              const SizedBox(width: 8),
                              Builder(
                                builder: (context) {
                                  String tipoCurso;
                                  final dynamic tipo = course.courseType;
                                  if (tipo is bool) {
                                    tipoCurso = tipo ? 'Assíncrono' : 'Síncrono';
                                  } else if (tipo is String) {
                                    tipoCurso = (tipo.toLowerCase() == 'true' || tipo.toLowerCase() == 'assíncrono' || tipo.toLowerCase() == 'assincrono')
                                        ? 'Assíncrono'
                                        : 'Síncrono';
                                  } else {
                                    tipoCurso = 'Síncrono';
                                  }
                                  return Text(
                                    tipoCurso,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.calendar_today,
                            "Data de Início",
                            DateFormat('dd/MM/yyyy').format(course.startDate),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.calendar_month,
                            "Data de Fim",
                            DateFormat('dd/MM/yyyy').format(course.endDate),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.people,
                            "Vagas Disponíveis",
                            course.vacancies?.toString() ?? "Indefinido",
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.lock_clock,
                            "Estado das Inscrições",
                            course.enrollmentsOpen ? "Abertas" : "Fechadas",
                            statusColor: course.enrollmentsOpen ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (inscritoAtivo) ...[
                      _buildStatusIndicator(
                        "Já estás inscrito neste curso",
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (inscritoPendente) ...[
                      _buildStatusIndicator(
                        "Inscrição pendente. Aguarda aprovação",
                        Icons.access_time,
                        Colors.orange,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (!course.enrollmentsOpen) ...[
                      _buildStatusIndicator(
                        "Inscrições encerradas para este curso",
                        Icons.lock,
                        Colors.red,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (semVagas) ...[
                      _buildStatusIndicator(
                        "Este curso não tem vagas disponíveis",
                        Icons.warning,
                        Colors.red,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (!course.status && !course.type) ...[
                      _buildStatusIndicator(
                        "Este curso já terminou",
                        Icons.event_busy,
                        Colors.red,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (!inscritoAtivo && !inscritoPendente)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: podeInscrever ? _realizarInscricao : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Inscrever-se",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Rodape(workerNumber: _userId.toString()),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {Color? statusColor}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1976D2), size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: statusColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}