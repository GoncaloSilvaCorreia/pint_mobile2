import 'package:flutter/material.dart';
import 'package:pint_mobile/models/forum_topic.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Dialog para responder comentário
class ReplyDialog extends StatefulWidget {
  final int topicId;
  final int parentCommentId;
  const ReplyDialog({Key? key, required this.topicId, required this.parentCommentId}) : super(key: key);

  @override
  State<ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  TextEditingController replyController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendReply() async {
    if (replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite sua resposta.')),
      );
      return;
    }
    setState(() { isLoading = true; });
    final prefs = await SharedPreferences.getInstance();
    dynamic userIdValue = prefs.get('userId');
    final userId = userIdValue != null ? userIdValue.toString() : '1';
    final url = Uri.parse('https://pint2.onrender.com/api/forum/comments');
    final body = {
      'topicId': widget.topicId.toString(),
      'content': replyController.text.trim(),
      'userId': userId,
      'parentCommentId': widget.parentCommentId.toString(),
    };
    try {
      final response = await http.post(url, body: json.encode(body), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 201) {
        // Adiciona a resposta localmente na tela anterior
        Navigator.of(context).pop(replyController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resposta enviada!')),
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
      title: const Text('Responder comentário'),
      content: TextField(
        controller: replyController,
        decoration: const InputDecoration(
          labelText: 'Resposta',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _sendReply,
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enviar'),
        ),
      ],
    );
  }
}

class ForumDetailScreen extends StatelessWidget {
  Widget buildReplies(List<ForumComment> replies, int indent, ForumTopic topic, BuildContext context) {
    return Column(
      children: replies.map((reply) => Padding(
        padding: EdgeInsets.only(left: 16.0 * indent, bottom: 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(reply.authorAvatar),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reply.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(reply.content),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.reply, size: 18, color: Color(0xFF1976D2)),
                          label: const Text('Responder', style: TextStyle(color: Color(0xFF1976D2))),
                          onPressed: () async {
                            final replyText = await showDialog<String>(
                              context: context,
                              builder: (context) => ReplyDialog(
                                topicId: topic.topicId,
                                parentCommentId: reply.id,
                              ),
                            );
                            if (replyText != null && replyText.isNotEmpty) {
                              final prefs = await SharedPreferences.getInstance();
                              final authorName = prefs.getString('userName') ?? 'Você';
                              final authorAvatar = prefs.getString('userAvatar') ?? '';
                              reply.replies.add(
                                ForumComment(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  content: replyText,
                                  ficheiro: null,
                                  authorName: authorName,
                                  authorAvatar: authorAvatar,
                                  date: DateTime.now().toIso8601String(),
                                  reaction: [],
                                  replies: [],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reply.replies.isNotEmpty)
              buildReplies(reply.replies, indent + 1, topic, context),
          ],
        ),
      )).toList(),
    );
  }
  final ForumTopic topic;

  const ForumDetailScreen({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Fórum', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(topic.authorAvatar),
                ),
                const SizedBox(width: 10),
                Text(topic.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Text(topic.date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              topic.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              topic.description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Divider(),
            // Exibe o primeiro comentário (pergunta principal)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(topic.firstComment.authorAvatar),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic.firstComment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(topic.firstComment.content),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.reply, size: 18, color: Color(0xFF1976D2)),
                          label: const Text('Responder', style: TextStyle(color: Color(0xFF1976D2))),
                          onPressed: () async {
                            final replyText = await showDialog<String>(
                              context: context,
                              builder: (context) => ReplyDialog(
                                topicId: topic.topicId,
                                parentCommentId: topic.firstComment.id,
                              ),
                            );
                            if (replyText != null && replyText.isNotEmpty) {
                              final prefs = await SharedPreferences.getInstance();
                              final authorName = prefs.getString('userName') ?? 'Você';
                              final authorAvatar = prefs.getString('userAvatar') ?? '';
                              topic.firstComment.replies.add(
                                ForumComment(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  content: replyText,
                                  ficheiro: null,
                                  authorName: authorName,
                                  authorAvatar: authorAvatar,
                                  date: DateTime.now().toIso8601String(),
                                  reaction: [],
                                  replies: [],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildReplies(topic.firstComment.replies, 1, topic, context)
          ],
        ),
      ),
    );
  }
}
