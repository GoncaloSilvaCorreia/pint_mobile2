import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pint_mobile/models/comentarios.dart';
import 'package:pint_mobile/models/forum_topic.dart';

class ApiForum {
  Future<List<ForumTopic>> fetchTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> topicsJson = data['topics'] ?? [];
      return topicsJson.map((json) => ForumTopic.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load forum topics');
    }
  }
  final String baseUrl = 'https://pint2.onrender.com/api/forum';

  Future<List<Comment>> fetchComments() async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> topics = data['topics'] ?? [];

      List<Comment> commentsList = [];
      
      for (var topic in topics) {
        var firstCommentJson = topic['firstComment'] ?? {};
        Comment firstComment = Comment.fromJson(firstCommentJson);

        commentsList.add(firstComment);
      }

      return commentsList;
    } else {
      throw Exception('Failed to load forum topics');
    }
  }
}