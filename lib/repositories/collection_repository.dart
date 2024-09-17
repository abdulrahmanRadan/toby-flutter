import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

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
      print("\n\n response: $e \n\n");

      if (e is DioException) {
        throw Exception('No internet connection');
      } else {
        if (e.toString().contains('401')) {
          // Handle unauthorized (invalid/expired token)
        } else if (e.toString().contains('500')) {
          // Handle server errors
          print('Server error. Please try again later.');
        } else {
          // Handle other errors
          print('Error: $e');
        }
        throw Exception('Failed to fetch collections');
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
}
