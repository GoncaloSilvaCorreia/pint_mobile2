import 'package:flutter/material.dart';
import 'package:pint_mobile/api/api_pesquisa.dart';
import 'package:pint_mobile/models/categoria.dart';
import 'package:pint_mobile/models/area.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
//import 'package:pint_mobile/models/topico.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({super.key});

  @override
  _PesquisaState createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  final SearchManager _searchManager = SearchManager();
  String _currentStep = 'categories';
  Category? _selectedCategory;
  Area? _selectedArea;

  @override
  void initState() {
    super.initState();
    _searchManager.initialize().then((_) {
      setState(() {});
    });
  }

  void _goBack() {
    setState(() {
      if (_currentStep == 'topics') {
        _currentStep = 'areas';
        _selectedArea = null;
      } else if (_currentStep == 'areas') {
        _currentStep = 'categories';
        _selectedCategory = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      endDrawer: const SideMenu(),
      bottomNavigationBar: const Rodape(),
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
          // Campo de pesquisa
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
          
          // Conteúdo principal
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
    if (_selectedArea == null) return Container();

    final topics = _searchManager.getTopicsForArea(_selectedArea!.id);
    
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return ListTile(
          title: Text(topic.description),
          onTap: () {
            // Navegar para tela de cursos com este tópico
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (context) => CoursesScreen(topicId: topic.id),
            // ));
          },
        );
      },
    );
  }
}