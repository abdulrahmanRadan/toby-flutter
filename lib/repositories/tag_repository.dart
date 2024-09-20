import '../models/tag_model.dart';
import '../repositories/api_service.dart';

class TagRepository {
  final ApiService apiService;

  TagRepository(this.apiService);

  // Fetch all tags
  Future<List<Tag>> getTags() async {
    try {
      // print('tag pesponsitory');
      final response = await apiService.getTags();
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

  // Delete a tag
  Future<void> deleteTag(int tagId) async {
    try {
      await apiService.deleteTag(tagId);
    } catch (e) {
      throw Exception('Failed to delete tag');
    }
  }

  Future<List<Tag>> getConnectedTags(int collectionId) async {
    final response = await apiService.getConnectedTags(collectionId);
    return response.map<Tag>((tagData) => Tag.fromJson(tagData)).toList();
  }

  // Update a tag
  Future<void> updateTag(int tagId, String newTitle) async {
    try {
      await apiService.updateTag(tagId, newTitle);
    } catch (e) {
      throw Exception('Failed to update tag');
    }
  }

  // Add a tag to a collection
  Future<void> addTagToCollection(int collectionId, int tagId) async {
    try {
      await apiService.addTagToCollection(collectionId, tagId);
    } catch (e) {
      throw Exception('Failed to add tag to collection');
    }
  }

  // Remove a tag from a collection
  Future<void> removeTagFromCollection(int collectionId, int tagId) async {
    try {
      await apiService.removeTagFromCollection(collectionId, tagId);
    } catch (e) {
      throw Exception('Failed to remove tag from collection');
    }
  }
}
