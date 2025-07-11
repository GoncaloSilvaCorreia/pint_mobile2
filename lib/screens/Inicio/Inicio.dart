import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';

import 'package:pint_mobile/api/api_curso.dart';
import 'package:pint_mobile/api/api_inscricoes.dart';

import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/inscricoes.dart';

import 'package:pint_mobile/screens/Curso/Curso.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  String _workerNumber = '';
  final CourseService _courseService = CourseService();
  late Future<List<Course>> _coursesFuture;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
    _coursesFuture = _courseService.getAllVisibleCourses();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  Future<void> _loadWorkerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final workerNumber = prefs.getString('workerNumber') ?? '';
    setState(() {
      _workerNumber = workerNumber;
    });
  }

  Widget _buildCourseCard(Course course) {
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
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? userId = prefs.getInt('userId');

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: Utilizador não encontrado.')),
          );
          return;
        }

        EnrollmentService enrollmentService = EnrollmentService();
        Enrollment? enrollment = await enrollmentService.getEnrollmentForCourseAndUser(
          course.id,
          userId,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Curso(
              course: course,
              enrollment: enrollment,
            ),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                course.image ?? 'https://via.placeholder.com/500x250?text=Sem+Imagem',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tipo do curso
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      Text(
                        tipoCurso,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 2, thickness: 1, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    course.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        '${course.hours ?? 'N/A'} horas',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        course.level,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPageIndicator(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return Container(
          width: 10, // Indicador maior
          height: 10, // Indicador maior
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Color(0xFF3F51B5) : Colors.grey[300],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      endDrawer: const SideMenu(),

      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: Row(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'SOF', style: TextStyle(color: Color(0xFF3F51B5))),
                  TextSpan(text: 'T', style: TextStyle(color: Colors.cyan)),
                  TextSpan(text: 'INSA', style: TextStyle(color: Color(0xFF3F51B5))),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications, color: Color(0xFF3F51B5), size: 28), // Ícone maior
              onPressed: () {
                // Ação do ícone de notificações
              },
            ),
          ],
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 20.0),
            child: Text(
              'Cursos Disponíveis',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3F51B5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Course>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final courses = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            return _buildCourseCard(courses[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPageIndicator(courses.length),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Nenhum curso disponível no momento',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),


      bottomNavigationBar: Rodape(workerNumber: _workerNumber),
    );
  }
}