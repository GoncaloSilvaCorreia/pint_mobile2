import 'package:pint_mobile/models/area.dart';
import 'package:pint_mobile/models/categoria.dart';
import 'package:pint_mobile/models/inscricoes.dart';
//import 'package:pint_mobile/models/areas_all.dart';
import 'package:pint_mobile/models/topico.dart';
import 'package:pint_mobile/models/curso.dart';

import 'package:pint_mobile/api/api_categoria.dart';
import 'package:pint_mobile/api/api_area.dart';
import 'package:pint_mobile/api/api_topico.dart';
import 'package:pint_mobile/api/api_curso.dart';
import 'package:pint_mobile/api/api_inscricoes.dart';

class SearchManager {
  final CategoryService _categoryService = CategoryService();
  final AreaService _areaService = AreaService();
  final TopicService _topicService = TopicService();
  final CourseService _courseService = CourseService();

  List<Category> _categories = [];
  List<Area> _areas = []; 
  List<Topic> _topics = [];
  List<Course> _courses = [];


  List<Category> get categories => _categories;
  List<Area> get areas => _areas;
  List<Topic> get topics => _topics;

  Future<void> initialize() async {
    _categories = await _categoryService.getCategories();
    _areas = await _areaService.getAreas();
    _topics = await _topicService.getTopics();
  }

  Future<List<Course>> getCoursesByTopic(int topicId) async {
    _courses = await _courseService.getCoursesByTopic(topicId);
    return _courses;
  }

  List<Area> getAreasForCategory(int categoryId) {
    return _areas.where((area) => area.categoryId == categoryId).toList();
  }

  List<Topic> getTopicsForArea(int areaId) {
    return _topics.where((topic) => topic.areaId == areaId).toList();
  }

  List<Course> filterCoursesByType(bool? isAsync) {
    if (isAsync == null) return _courses; // Mostra todos
    return _courses.where((course) => course.type == isAsync).toList();
  }

  List<Course> filterCoursesByTopicAndType(int? topicId, bool? isAsync) {
    return _courses.where((course) {
      final matchesTopic = topicId == null || course.topicId == topicId;
      final matchesType = isAsync == null || course.type == isAsync;
      return matchesTopic && matchesType;
    }).toList();
  }

  Future<Enrollment?> getEnrollmentForCourseAndUser(int courseId, String workerNumber) async {
    List<Enrollment> allEnrollments = await EnrollmentService().getEnrollments();

    try {
      return allEnrollments.firstWhere((e) => e.courseId == courseId && e.workerNumber == workerNumber);
    } catch (_) {
      return null; // não inscrito
    }
  }
}