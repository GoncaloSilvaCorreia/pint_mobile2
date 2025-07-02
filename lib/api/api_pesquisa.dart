import 'package:pint_mobile/models/area.dart';
import 'package:pint_mobile/models/categoria.dart';
import 'package:pint_mobile/models/areas_all.dart';
import 'package:pint_mobile/models/topico.dart';
import 'package:pint_mobile/api/api_categoria.dart';
import 'package:pint_mobile/api/api_area.dart';
import 'package:pint_mobile/api/api_topico.dart';

class SearchManager {
  final CategoryService _categoryService = CategoryService();
  final AreaService _areaService = AreaService();
  final TopicService _topicService = TopicService();

  List<Category> _categories = [];
  List<Area> _areas = []; 
  List<Topic> _topics = [];

  List<Category> get categories => _categories;
  
  List<Area> get areas => _areas;
  
  List<Topic> get topics => _topics;

  Future<void> initialize() async {
    _categories = await _categoryService.getCategories();
    _areas = await _areaService.getAreas();
    _topics = await _topicService.getTopics();
  }

  List<Area> getAreasForCategory(int categoryId) {
    return _areas.where((area) => area.categoryId == categoryId).toList();
  }

  List<Topic> getTopicsForArea(int areaId) {
    return _topics.where((topic) => topic.areaId == areaId).toList();
  }
}