import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pint_mobile/api/api_forum.dart';
import 'package:pint_mobile/models/forum_topic.dart';
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

  @override
  void initState() {
    super.initState();
    _loadWorkerNumber();
    _topicsFuture = ApiForum().fetchTopics(); // Novo método para buscar tópicos
    _searchManager.initialize().then((_) {
      setState(() {});
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
          List<ForumTopic> topics = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar ...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    icon: const Icon(Icons.add_comment),
                    label: const Text('Adicionar comentário'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ForumCommentDialog(topics: topics);
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.15 ,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
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
                              Text(
                                topic.description,
                                style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
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
  final List<ForumTopic> topics;
  const ForumCommentDialog({Key? key, required this.topics}) : super(key: key);

  @override
  State<ForumCommentDialog> createState() => _ForumCommentDialogState();
}

class _ForumCommentDialogState extends State<ForumCommentDialog> {
  ForumTopic? dropdownValue;
  TextEditingController commentController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.topics.isNotEmpty ? widget.topics[0] : null;
  }

  Future<void> _sendComment() async {
    if (dropdownValue == null || commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um tópico e escreva o comentário.')),
      );
      return;
    }
    setState(() { isLoading = true; });
    final url = Uri.parse('https://pint2.onrender.com/api/forum/comments');
    final body = {
      'topicId': dropdownValue!.id.toString(),
      'content': commentController.text.trim(),
      'userId': '1', // Troque para o id do user logado se necessário
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<ForumTopic>(
            isExpanded: true,
            value: dropdownValue,
            items: widget.topics.map((ForumTopic topic) {
              return DropdownMenuItem<ForumTopic>(
                value: topic,
                child: Text(topic.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (ForumTopic? newValue) {
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