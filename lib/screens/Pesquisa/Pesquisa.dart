import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pint_mobile/api/api_pesquisa.dart';
import 'package:pint_mobile/models/categoria.dart';
import 'package:pint_mobile/models/area.dart';
import 'package:pint_mobile/models/topico.dart';
import 'package:pint_mobile/models/inscricoes.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
import 'package:pint_mobile/screens/Curso/Curso.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({super.key});

  @override
  _PesquisaState createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  final SearchManager _searchManager = SearchManager();
  String _currentStep = 'categories';
  String _workerNumber = '';
  Category? _selectedCategory;
  Area? _selectedArea;
  bool? _selectedCourseType; // false = síncrono, true = assíncrono
  Topic? _selectedTopic;
  bool _isLoadingCourses = false;

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
    _searchManager.initialize().then((_) {
      setState(() {});
    });
  }

  void _goBack() {
    setState(() {
      if (_currentStep == 'courses') {
        _currentStep = 'types';
      } else if (_currentStep == 'types') {
        _currentStep = 'topics';
        _selectedTopic = null;
      } else if (_currentStep == 'topics') {
        _currentStep = 'areas';
        _selectedArea = null;
      } else if (_currentStep == 'areas') {
        _currentStep = 'categories';
        _selectedCategory = null;
      }
    });
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
      backgroundColor: Colors.grey[300],
      endDrawer: const SideMenu(),
      bottomNavigationBar: Rodape(workerNumber: _workerNumber),
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Pesquisa'),
        leading: _currentStep != 'categories'
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              )
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 'categories':
        return _buildCategoryList();
      case 'areas':
        return _buildAreaList();
      case 'topics':
        return _buildTopicList();
      case 'types':
        return _buildTypeList();
      case 'courses':
        return _buildCourseList();
      default:
        return const Center(child: Text('Selecione uma opção'));
    }
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      itemCount: _searchManager.categories.length,
      itemBuilder: (context, index) {
        final category = _searchManager.categories[index];
        return ListTile(
          title: Text(category.description),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            setState(() {
              _selectedCategory = category;
              _currentStep = 'areas';
            });
          },
        );
      },
    );
  }

  Widget _buildAreaList() {
    if (_selectedCategory == null) return Container();

    final areas = _searchManager.getAreasForCategory(_selectedCategory!.id);
    
    return ListView.builder(
      itemCount: areas.length,
      itemBuilder: (context, index) {
        final area = areas[index];
        return ListTile(
          title: Text(area.description),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            setState(() {
              _selectedArea = area;
              _currentStep = 'topics';
            });
          },
        );
      },
    );
  }

  Widget _buildTopicList() {
    if (_selectedArea == null) {
      return const Center(child: Text('Selecione uma área primeiro'));
    }

    final topics = _searchManager.getTopicsForArea(_selectedArea!.id);
    
    if (topics.isEmpty) {
      return const Center(child: Text('Nenhum tópico disponível para esta área'));
    }

    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return ListTile(
          title: Text(topic.description),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            setState(() {
              _selectedTopic = topic;
              _currentStep = 'types';
            });
          },
        );
      },
    );
  }

  Widget _buildTypeList() {
    final tipos = [
      {'label': 'Síncrono', 'value': false},
      {'label': 'Assíncrono', 'value': true},
      {'label': 'Todos os Tipos', 'value': null},
    ];

    return ListView.builder(
      itemCount: tipos.length,
      itemBuilder: (context, index) {
        final tipo = tipos[index];
        return ListTile(
          title: Text(tipo['label'] as String),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            setState(() {
              _selectedCourseType = tipo['value'] as bool?;
              _currentStep = 'courses';
            });
          },
        );
      },
    );
  }
  
  Widget _buildCourseList() {
    final courses = _searchManager.filterCoursesByTopicAndType(
      _selectedTopic?.id,
      _selectedCourseType,
    );
    
    if (courses.isEmpty) {
      return const Center(child: Text('Nenhum curso disponível'));
    }

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(course.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo: ${course.courseType}'),
                Text('Nível: ${course.level}'),
                Text('Data: ${DateFormat('dd/MM/yyyy').format(course.startDate)} - ${DateFormat('dd/MM/yyyy').format(course.endDate)}'),
              ],
            ),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? userWorkerNumber = prefs.getString('workerNumber');

              if (userWorkerNumber == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro: Utilizador não encontrado.')),
                );
                return;
              }

              Enrollment? enrollment = await _searchManager.getEnrollmentForCourseAndUser(
                course.id,
                userWorkerNumber,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(
                    course: course,
                    enrollment: enrollment,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}