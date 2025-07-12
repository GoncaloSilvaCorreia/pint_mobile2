import 'package:flutter/material.dart';
import 'package:pint_mobile/api/api_utilizador.dart';
import 'package:pint_mobile/models/utilizador.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pint_mobile/models/certificados.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Future<List<Certificate>> _futureCertificados; 

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
    _futureUtilizador = api.getUtilizadorByWorkerNumber(widget.workerNumber);
    _futureCursos = api.getCursosByWorkerNumber(widget.workerNumber);
    _futureCertificados = api.getCertificadosByWorkerNumber(widget.workerNumber);
  }

  Future<void> _loadWorkerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final workerNumber = prefs.getString('workerNumber') ?? '';
    print('WorkerNumber nas SharedPreferences: $workerNumber');
    setState(() {
      _workerNumber = workerNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      endDrawer: const SideMenu(),
      appBar: AppBar(
        title: const Text('Meu Perfil', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
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

                return FutureBuilder<List<Certificate>>(
                  future: _futureCertificados,
                  builder: (context, certificadosSnapshot) {
                    Map<int, Certificate> certMap = {};
                    if (certificadosSnapshot.hasData) {
                      for (var cert in certificadosSnapshot.data!) {
                        certMap[cert.courseId] = cert;
                      }
                    }

                    List<Map<String, dynamic>> cursosAtualizados = cursos.map((curso) {
                      int? courseId = curso['id'] as int?;
                      if (courseId != null && certMap.containsKey(courseId)) {
                        final cert = certMap[courseId]!;
                        return {
                          ...curso,
                          'nota': cert.grade,
                          'certificado': true,
                          'pdfUrl': cert.pdfUrl,
                        };
                      } else {
                        return {
                          ...curso,
                          'certificado': curso['certificado'] ?? false,
                        };
                      }
                    }).toList();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage: NetworkImage(
                                        utilizador.pfp ?? 'https://via.placeholder.com/150',
                                      ),
                                      backgroundColor: Colors.grey[200],
                                      child: utilizador.pfp == null
                                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                          : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  utilizador.nome,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  utilizador.primaryRole ?? "Função não definida",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildInfoCard(Icons.badge, "ID", utilizador.workerNumber),
                                const SizedBox(height: 12),
                                _buildInfoCard(Icons.email, "E-mail", utilizador.email),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 12),
                            child: Text(
                              "Cursos Inscritos/Concluídos",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _buildCoursesSection(cursosAtualizados), 
                        ],
                      ),
                    );
                  },
                );
              },
            );
          } else if (userSnapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar perfil: ${userSnapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: Rodape(workerNumber: _workerNumber),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(List<Map<String, dynamic>> cursos) {
    if (cursos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Center(
          child: Text(
            "Nenhum curso concluído",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "Curso",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Nº Horas",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Nota",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "Cert.",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < cursos.length; i++)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: i < cursos.length - 1
                      ? BorderSide(color: Colors.grey[300]!)
                      : BorderSide.none,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        cursos[i]["title"],
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        cursos[i]["horas"].toString(),
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        cursos[i]["nota"]?.toString() ?? "--",
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: cursos[i].containsKey("certificado") && cursos[i]["certificado"]
                            ? GestureDetector(
                                onTap: () async {
                                  final url = cursos[i]["pdfUrl"];
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
                                        SnackBar(content: Text('Não foi possível abrir o certificado.')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Certificado não disponível.')),
                                    );
                                  }
                                },
                                child: const Icon(Icons.verified, color: Colors.green, size: 24),
                              )
                            : const Icon(Icons.schedule, color: Colors.orange, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}