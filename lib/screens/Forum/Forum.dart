import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pint_mobile/api/api_forum.dart';
import 'package:pint_mobile/models/forum_topic.dart';
import 'package:pint_mobile/api/api_topico.dart';
import 'package:pint_mobile/models/topico.dart';
import 'package:pint_mobile/api/api_pesquisa.dart';
import 'package:pint_mobile/models/comentarios.dart';
import 'package:pint_mobile/screens/Forum/ForumDetail.dart';
import 'package:pint_mobile/utils/Rodape.dart';
import 'package:pint_mobile/utils/SideMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Forum extends StatefulWidget {
  @override
  _ForumState createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  final SearchManager _searchManager = SearchManager();
  String _workerNumber = '';
  late Future<List<ForumTopic>> _topicsFuture;
  List<ForumTopic> _allTopics = [];
  List<ForumTopic> _filteredTopics = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
    _topicsFuture = ApiForum().fetchTopics();
    _searchManager.initialize().then((_) {
      setState(() {});
    });
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadWorkerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final workerNumber = prefs.getString('workerNumber') ?? '';
    setState(() {
      _workerNumber = workerNumber;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTopics = List.from(_allTopics);
      } else {
        _filteredTopics = _allTopics.where((topic) => topic.title.toLowerCase().contains(query)).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      endDrawer: const SideMenu(),
      bottomNavigationBar: Rodape(workerNumber: _workerNumber),
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Fórum', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0))),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ForumTopic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum tópico disponível.'));
          }
          // Inicializa os tópicos e filtrados na primeira renderização
          if (_allTopics.isEmpty) {
            _allTopics = snapshot.data!;
            _filteredTopics = List.from(_allTopics);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_comment, size: 24, color: Color(0xFF1976D2)),
                    label: const Text('Sugerir Comentário', style: TextStyle(fontSize: 16, color: Color(0xFF1976D2))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ForumCommentDialog();
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.10,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredTopics.length,
                  itemBuilder: (context, index) {
                    final topic = _filteredTopics[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForumDetailScreen(topic: topic),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(
                                      topic.authorAvatar.isNotEmpty ? topic.authorAvatar : 'https://via.placeholder.com/150'),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(topic.authorName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text(topic.category ?? '', style: TextStyle(color: Colors.grey[700], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                topic.title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              
                              // Adiciona o conteúdo do primeiro comentário abaixo da descrição
                              if (topic.firstComment.content.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  topic.firstComment.content,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              Divider(),
                              Row(
                                children: [
                                  Text(
                                    topic.date,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${topic.commentsCount} respostas',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ForumCommentDialog extends StatefulWidget {
  const ForumCommentDialog({Key? key}) : super(key: key);

  @override
  State<ForumCommentDialog> createState() => _ForumCommentDialogState();
}

class _ForumCommentDialogState extends State<ForumCommentDialog> {
  Topic? dropdownValue;
  List<Topic> topics = [];
  TextEditingController commentController = TextEditingController();
  bool isLoading = false;
  bool isTopicsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final fetchedTopics = await TopicService().getTopics();
      setState(() {
        topics = fetchedTopics;
        dropdownValue = topics.isNotEmpty ? topics[0] : null;
        isTopicsLoading = false;
      });
    } catch (e) {
      setState(() { isTopicsLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar tópicos: $e')),
      );
    }
  }

  Future<void> _sendComment() async {
    if (dropdownValue == null || commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um tópico e escreva o comentário.')),
      );
      return;
    }
    setState(() { isLoading = true; });
    final prefs = await SharedPreferences.getInstance();
    dynamic userIdValue = prefs.get('userId');
    final userId = userIdValue != null ? userIdValue.toString() : '1';
    final url = Uri.parse('https://pint2.onrender.com/api/forum/comments');
    final body = {
      'topicId': dropdownValue!.id.toString(),
      'content': commentController.text.trim(),
      'userId': userId,
    };
    try {
      final response = await http.post(url, body: json.encode(body), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 201) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentário enviado!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede: $e')),
      );
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar comentário'),
      content: isTopicsLoading
          ? const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<Topic>(
                  isExpanded: true,
                  value: dropdownValue,
                  items: topics.map((Topic topic) {
                    return DropdownMenuItem<Topic>(
                      value: topic,
                      child: Text(topic.description, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (Topic? newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comentário',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _sendComment,
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enviar'),
        ),
      ],
    );
  }
}