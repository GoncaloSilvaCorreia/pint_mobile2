import 'package:pint_mobile/models/area.dart';
import 'package:pint_mobile/models/categoria.dart';
import 'package:pint_mobile/models/inscricoes.dart';
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
  List<Course> _allCourses = []; 

  List<Category> get categories => _categories;
  List<Area> get areas => _areas;
  List<Topic> get topics => _topics;
  List<Course> get allCourses => _allCourses;

  Future<void> initialize() async {
    _categories = await _categoryService.getCategories();
    _areas = await _areaService.getAreas();
    _topics = await _topicService.getTopics();
    
    _allCourses = await _courseService.getAllVisibleCourses();
  }

  Future<List<Course>> getCoursesByTopic(int topicId) async {
    return _allCourses.where((course) => course.topicId == topicId).toList();
  }

  List<Area> getAreasForCategory(int categoryId) {
    return _areas.where((area) => area.categoryId == categoryId).toList();
  }

  List<Topic> getTopicsForArea(int areaId) {
    return _topics.where((topic) => topic.areaId == areaId).toList();
  }

  List<Course> filterCoursesByType(bool? isAsync) {
    if (isAsync == null) return _allCourses; 
    return _allCourses.where((course) => course.type == isAsync).toList();
  }

  List<Course> filterCoursesByTopicAndType(int? topicId, bool? isAsync) {
    return _allCourses.where((course) {
      final matchesTopic = topicId == null || course.topicId == topicId;
      final matchesType = isAsync == null || course.type == isAsync;
      return matchesTopic && matchesType && course.shouldDisplayInSearch;
    }).toList();
  }

  Future<Enrollment?> getEnrollmentForCourseAndUser(int courseId, int userId) async {
    List<Enrollment> allEnrollments = await EnrollmentService().getEnrollments();

    try {
      return allEnrollments.firstWhere(
        (e) => e.courseId == courseId && e.userId == userId
      );
    } catch (_) {
      return null; // não inscrito
    }
  }
}