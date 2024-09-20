import 'package:toby1/models/tab_model.dart';
import 'package:toby1/repositories/api_service.dart';

class TabRepository {
  final ApiService apiService;

  TabRepository(this.apiService);

  Future<List<AppTab>> getTabs(int collectionId) async {
    try {
      final response = await apiService.getTabs(collectionId);
      if (response.isEmpty) {
        throw Exception('No tabs available for the specified collection.');
      }
      return response.map<AppTab>((json) => AppTab.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tabs');
    }
  }

  Future<void> createTab(String title, String url, int collectionId) async {
    try {
      await apiService.createTab(title, url, collectionId);
    } catch (e) {
      throw Exception('Failed to create tab');
    }
  }

  Future<void> updateTab(int id, String title, String url, int collectionId) async {
    try {
      await apiService.updateTab(id, title, url, collectionId);
    } catch (e) {
      throw Exception('Failed to update tab repository');
    }
  }

  Future<void> deleteTab(int tabId) async {
    try {
      await apiService.deleteTab(tabId);
    } catch (e) {
      throw Exception('Failed to delete tab');
    }
  }
}
