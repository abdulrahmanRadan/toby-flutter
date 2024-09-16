import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final String? userId; // اجعل معرف المستخدم قابلاً لأن يكون null

  ApiService(this.userId);

  // Method for user login
  Future<dynamic> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['data']['access_token']?.toString();
        final email =
            data['data']['email']?.toString(); // Use email instead of id

        if (token != null && email != null) {
          await saveUserData(email, token);
        } else {
          throw Exception(
              'Login response is missing userId or token: ${data['data']['email']} : $token');
        }
        return data;
      } else {
        throw Exception(
            'Failed to login: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        throw Exception(
            'Dio error: ${dioError.response?.statusCode} - ${dioError.response?.data['message'] ?? dioError.message}');
      } else {
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Method for user registration
  Future<dynamic> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.ok) {
        final data = response.data;
        final token =
            data['data']['access_token']?.toString(); // Add null check here
        final email = data['data']['email']?.toString();

        if (token != null && email != null) {
          await saveUserData(email, token);
        } else {
          throw Exception(
              'Login response is missing userId or token: ${data['data']['email']} : $token');
        }
        return data;
      } else {
        throw Exception(
            'Failed to register: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        throw Exception(
            'Dio error: ${dioError.response?.statusCode} - ${dioError.response?.data['message'] ?? dioError.message}');
      } else {
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Save user data to SharedPreferences
  Future<void> saveUserData(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('token', token);
  }

  // Retrieve user ID dynamically
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Retrieve token dynamically
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> getCollections() async {
    try {
      // final userId = await getUserId();
      final response = await _dio.get('/collections', data: {'id': userId});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return data['data'];
      } else {
        throw Exception(
            'Failed to getCollections: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to fetch collections');
    }
  }

  // طريقة لإنشاء مجموعة جديدة
  Future<void> createCollection(String title, String? description,
      {bool isFav = true, int? tagId}) async {
    try {
      final response = await _dio.post('/collections', data: {
        'title': title,
        'description': description,
        'is_fav': isFav,
        'tagId': tagId,
        'user_id': userId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return data;
      } else {
        throw Exception(
            'Failed to register: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception('Error Response: ${e.response!.data}');
      }
      throw Exception('Failed to create collection $e');
    }
  }

  // طريقة لجلب العناصر (Tabs) لمجموعة معينة
  Future<List<dynamic>> getTabs(int collectionId) async {
    try {
      final response = await _dio.get('/tabs', queryParameters: {
        'collection_id': collectionId,
      });
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to fetch tabs');
    }
  }

  // طريقة لإنشاء عنصر جديد داخل مجموعة
  Future<void> createTab(String title, String url, int collectionId) async {
    try {
      await _dio.post('/tabs', data: {
        'title': title,
        'url': url,
        'collection_id': collectionId,
      });
    } catch (e) {
      throw Exception('Failed to create tab');
    }
  }

  // طريقة لحذف عنصر
  Future<void> deleteTab(int tabId) async {
    try {
      await _dio.delete('/tabs/$tabId');
    } catch (e) {
      throw Exception('Failed to delete tab');
    }
  }

  // طريقة لجلب العلامات (Tags)
  Future<List<dynamic>> getTags() async {
    try {
      final response = await _dio.get('/tags');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to fetch tags');
    }
  }

  // طريقة لإنشاء علامة جديدة
  Future<void> createTag(String title) async {
    try {
      await _dio.post('/tags', data: {
        'title': title,
      });
    } catch (e) {
      throw Exception('Failed to create tag');
    }
  }

  // طريقة لحذف علامة
  Future<void> deleteTag(int tagId) async {
    try {
      await _dio.delete('/tags/$tagId');
    } catch (e) {
      throw Exception('Failed to delete tag');
    }
  }
}
