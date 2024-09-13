import 'package:dio/dio.dart';

import '../models/collection_model.dart';
import '../repositories/api_service.dart';

class CollectionRepository {
  final ApiService apiService;

  CollectionRepository(this.apiService);

  Future<List<Collection>> getCollections() async {
    try {
      final response = await apiService.getCollections();
      return response.map<Collection>((json) => Collection.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException ) {
        throw Exception('No internet connection');
      } else {
        throw Exception('Failed to fetch collections');
      }
    }
  }


  Future<void> createCollection(String title, String? description, {bool isFav = true, int? tagId}) async {
    try {
      await apiService.createCollection(title, description, isFav: isFav, tagId: tagId);
    } catch (e) {
      throw Exception('failed to create collection $e');
    }
  }
}
