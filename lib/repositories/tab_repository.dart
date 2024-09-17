import '../models/tab_model.dart';
import '../repositories/api_service.dart';

class TabRepository {
  final ApiService apiService;

  TabRepository(this.apiService);

  // إرجاع قائمة من الكائنات Tab
  Future<List<AppTab>> getTabs(int collectionId) async {
    try {
      final response = await apiService.getTabs(collectionId);
      // تحويل البيانات إلى قائمة من AppTab
      if (response.isEmpty) {

        // Throw an exception or handle empty data scenario
        throw Exception('No tabs available for the specified collection.');
      }
      return response.map<AppTab>((json) => AppTab.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tabs sdsd');
    }
  }

  // إنشاء عنصر Tab جديد
  Future<void> createTab(String title, String url, int collectionId) async {
    try {
      await apiService.createTab(title, url, collectionId);
    } catch (e) {
      throw Exception('Failed to create tab');
    }
  }

  // حذف عنصر Tab
  Future<void> deleteTab(int tabId) async {
    try {
      await apiService.deleteTab(tabId);
    } catch (e) {
      throw Exception('Failed to delete tab');
    }
  }
}
