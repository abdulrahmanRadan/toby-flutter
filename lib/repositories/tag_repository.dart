import '../models/tag_model.dart';
import '../repositories/api_service.dart';

class TagRepository {
  final ApiService apiService;

  TagRepository(this.apiService);

  // يجب أن ترجع قائمة من الكائنات Tag
  Future<List<Tag>> getTags() async {
    try {
      final response = await apiService.getTags();
      // تحويل البيانات إلى قائمة من الكائنات Tag
      return response.map<Tag>((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tags');
    }
  }

  Future<void> createTag(String title) async {
    try {
      await apiService.createTag(title);
    } catch (e) {
      throw Exception('Failed to create tag');
    }
  }

  Future<void> deleteTag(int tagId) async {
    try {
      await apiService.deleteTag(tagId);
    } catch (e) {
      throw Exception('Failed to delete tag');
    }
  }
}
