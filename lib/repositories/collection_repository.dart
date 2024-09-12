import '../models/collection_model.dart';
import '../repositories/api_service.dart';

class CollectionRepository {
  final ApiService apiService;

  CollectionRepository(this.apiService);

  Future<List<Collection>> getCollections() async {
    try {
      final response = await apiService.getCollections();
      // تحويل البيانات إلى قائمة من الكائنات من نوع Collection
      return response.map<Collection>((json) => Collection.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch collections');
    }
  }

  Future<void> createCollection(String title, String? description) async {
    try {
      await apiService.createCollection(title, description);
    } catch (e) {
      throw Exception('Failed to create collection');
    }
  }
}
