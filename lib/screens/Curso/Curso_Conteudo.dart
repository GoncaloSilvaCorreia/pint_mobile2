import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/seccao.dart';
import 'package:pint_mobile/models/resource.dart';
import 'package:pint_mobile/api/api.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CursoConteudo extends StatefulWidget {
  final int courseId;

  const CursoConteudo({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CursoConteudo> createState() => _CursoConteudo();
}

class _CursoConteudo extends State<CursoConteudo> {
  late Future<Course> _futureCourse;
  final ApiClient _apiClient = ApiClient();
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _futureCourse = _fetchCourse();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    setState(() {
      _userId = userId;
    });
  }

  Future<Course> _fetchCourse() async {
    final response = await _apiClient.get('/cursos/${widget.courseId}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Course.fromJson(data['course']);
    } else {
      throw Exception('Falha ao carregar o curso');
    }
  }

  Widget _buildResourceItem(Resource resource) {
    IconData icon;
    Color color;
    String type;

    switch (resource.typeId) {
      case 1: // PDF
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        type = "PDF";
        break;
      case 2: // Vídeo
        icon = Icons.videocam;
        color = Colors.blue;
        type = "Vídeo";
        break;
      case 3: // Link
        icon = Icons.link;
        color = Colors.green;
        type = "Link";
        break;
      case 4: // Texto
        icon = Icons.text_fields;
        color = Colors.purple;
        type = "Texto";
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
        type = "Arquivo";
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(resource.title ?? 'Recurso sem título'),
      subtitle: Text(type),
      onTap: () {
        // Implementar ação ao clicar no recurso
        if (resource.typeId == 1 && resource.file != null) {
          // Abrir PDF
        } else if (resource.typeId == 2 && resource.link != null) {
          // Abrir vídeo
        } else if (resource.typeId == 3 && resource.link != null) {
          // Abrir link
        } else if (resource.typeId == 4 && resource.text != null) {
          // Mostrar texto
        }
      },
    );
  }

  Widget _buildSectionItem(Section section) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          if (section.resources.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Nenhum recurso disponível nesta seção'),
            )
          else
            ...section.resources.map(_buildResourceItem).toList()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conteúdo do Curso'),
      ),
      body: FutureBuilder<Course>(
        future: _futureCourse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Curso não encontrado'));
          }

          final course = snapshot.data!;
          
          // Ordenar seções por ordem
          course.sections.sort((a, b) => a.order.compareTo(b.order));

          return Column(
            children: [
              // Cabeçalho do curso
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(course.description),
                  ],
                ),
              ),
              
              // Lista de seções
              Expanded(
                child: ListView.builder(
                  itemCount: course.sections.length,
                  itemBuilder: (context, index) {
                    return _buildSectionItem(course.sections[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Rodape(workerNumber: _userId.toString()),
    );
  }
}