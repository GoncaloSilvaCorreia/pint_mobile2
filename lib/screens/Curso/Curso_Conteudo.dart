import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/seccao.dart';
import 'package:pint_mobile/models/resource.dart';
import 'package:pint_mobile/api/api.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      endDrawer: const SideMenu(),  
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: FutureBuilder<Course>(
          future: _futureCourse,
          builder: (context, snapshot) {
            String title = '...';
            if (snapshot.hasData) {
              title = snapshot.data!.title;
            }
            return AppBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
              backgroundColor: Colors.grey[300],
              elevation: 1,
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
            );
          },
        ),
      ),
      body: FutureBuilder<Course>(
        future: _futureCourse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}', style: TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Curso não encontrado', style: TextStyle(color: Colors.black)));
          }

          final course = snapshot.data!;
          course.sections.sort((a, b) => a.order.compareTo(b.order));

          return Column(
            children: [
              // Cabeçalho do curso
              /*Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.description,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),*/
              // Lista de seções
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildSectionItem(Section section) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

  Widget _buildResourceItem(Resource resource) {
    switch (resource.typeId) {
      case 1: // PDF
        return Card(
          color: Colors.red[50],
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
            title: Text(resource.title ?? 'PDF sem título', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('PDF', style: TextStyle(color: Colors.red)),
            trailing: resource.file != null
                ? IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.red),
                    tooltip: 'Abrir PDF',
                    onPressed: () async {
                      final url = resource.file;
                      if (url != null && url.isNotEmpty) {
                        final uri = Uri.parse(url);
                        try {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            await launchUrl(uri, mode: LaunchMode.platformDefault);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Não foi possível abrir o PDF.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ficheiro do PDF não disponível.')),
                        );
                      }
                    },
                  )
                : null,
            onTap: () {
              final url = resource.file;
              if (url != null && url.isNotEmpty) {
                final uri = Uri.parse(url);
                launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ficheiro do PDF não disponível.')),
                );
              }
            },
          ),
        );
      case 2: // Vídeo
        return Card(
          color: Colors.blue[50],
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: ListTile(
            leading: Icon(Icons.videocam, color: Colors.blue, size: 32),
            title: Text(resource.title ?? 'Vídeo sem título', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Vídeo', style: TextStyle(color: Colors.blue)),
            trailing: resource.link != null
                ? IconButton(
                    icon: const Icon(Icons.play_circle, color: Colors.blue),
                    tooltip: 'Abrir vídeo',
                    onPressed: () async {
                      final url = resource.link;
                      if (url != null && url.isNotEmpty) {
                        final uri = Uri.parse(url);
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link do vídeo não disponível.')),
                        );
                      }
                    },
                  )
                : null,
            onTap: () {
              final url = resource.link;
              if (url != null && url.isNotEmpty) {
                final uri = Uri.parse(url);
                launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link do vídeo não disponível.')),
                );
              }
            },
          ),
        );
      case 3: // Link
        return Card(
          color: Colors.green[50],
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: ListTile(
            leading: Icon(Icons.link, color: Colors.green, size: 32),
            title: Text(resource.title ?? 'Link sem título', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Link', style: TextStyle(color: Colors.green)),
            trailing: resource.link != null
                ? IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.green),
                    tooltip: 'Abrir link',
                    onPressed: () async {
                      final url = resource.link;
                      if (url != null && url.isNotEmpty) {
                        final uri = Uri.parse(url);
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link não disponível.')),
                        );
                      }
                    },
                  )
                : null,
            onTap: () {
              final url = resource.link;
              if (url != null && url.isNotEmpty) {
                final uri = Uri.parse(url);
                launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link não disponível.')),
                );
              }
            },
          ),
        );
      case 4: // Texto
        return Card(
          color: Colors.purple[50],
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: ExpansionTile(
            leading: Icon(Icons.text_fields, color: Colors.purple, size: 32),
            title: Text(resource.title ?? 'Texto sem título', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Texto', style: TextStyle(color: Colors.purple)),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(resource.text ?? 'Sem conteúdo', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      default:
        return Card(
          color: Colors.grey[100],
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: ListTile(
            leading: Icon(Icons.insert_drive_file, color: Colors.grey, size: 32),
            title: Text(resource.title ?? 'Arquivo sem título', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Arquivo', style: TextStyle(color: Colors.grey)),
          ),
        );
    }
  }
}