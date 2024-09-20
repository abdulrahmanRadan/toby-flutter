import 'package:dio/dio.dart';

import '../models/collection_model.dart';
import '../repositories/api_service.dart';

class CollectionRepository {
  final ApiService apiService;

  CollectionRepository(this.apiService);

  Future<List<Collection>> getCollections() async {
    try {
      final response = await apiService.getCollections();
      return response
          .map<Collection>((json) => Collection.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception('No internet connection');
      } else {
        if (e.toString().contains('401')) {
          // TODO: go to login page
          throw Exception('Invalid credentials. Please try again.');
        } else if (e.toString().contains('500')) {
          throw Exception('Server error. Please try again later.');
        } else {
          throw Exception('Error: $e');
        }
      }
    }
  }

  Future<void> createCollection(String title, String? description,
      {bool isFav = true, int? tagId}) async {
    try {
      final response = await apiService.createCollection(title, description,
          isFav: isFav, tagId: tagId);
      return response;
    } catch (e) {
      throw Exception('failed to create collection $e');
    }
  }
  // دالة لجلب collection باستخدام id
  Future<Collection> fetchCollection(int collectionId) async {
    try {
      final collection = await apiService.fetchCollection(collectionId);
      return collection; // إرجاع نموذج Collection
    } catch (e) {
      throw Exception('Failed to fetch collection: ${e.toString()}');
    }
  }

  Future<void> updateCollection(
      int collectionId, String title, String? description, bool? isFav) async {
    try {
      final response = await apiService.updateCollection(
          collectionId, title, description, isFav);
      return response;
    } catch (e) {
      throw Exception('failed to create collection $e');
    }
  }

  Future<void> deleteCollection(int collectionId) async {
    try {
      final response = await apiService.deleteCollection(collectionId);
      return response;
    } catch (e) {
      throw Exception('failed to delete collection $e');
    }
  }
}
