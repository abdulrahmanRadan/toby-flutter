import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toby1/models/collection_model.dart';

// TODO: check all requests's body for any mistakes
// TODO: Create a API call for getById to all the other methods

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

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
              'Login response is missing, email or token: ${data['data']['email']} : $token');
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
              'Login response is missing, email or token: ${data['data']['email']} : $token');
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
  Future<void> saveUserData(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('token', token);
  }

  // Retrieve user ID dynamically
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Retrieve token dynamically
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> getCollections() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      // Proceed with the request if authenticated
      final response = await _dio.get(
        '/collections',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Check for success response
      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'];
      } else if (response.statusCode == 401) {
        // Handle unauthorized access (invalid or expired token)
        throw Exception(
            'Unauthorized: Invalid or expired token. Please log in again.');
      } else {
        // Handle other types of errors with status code and message
        throw Exception(
            'Failed to getCollections: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to fetch collections: $e');
    }
  }

  // طريقة لإنشاء مجموعة جديدة
  Future<void> createCollection(String title, String? description,
      {bool isFav = true, int? tagId}) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      final response = await _dio.post(
        '/collections',
        data: {
          'title': title,
          'description': description,
          'is_fav': isFav,
          'tagId': tagId
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

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

  // TODO: هل لازم نطرح هنا
  // tag_id?
  Future<void> updateCollection(
      int collectionId, String title, String? description, bool? isFav) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      final response = await _dio.put(
        '/collections/$collectionId',
        data: {
          'title': title,
          'description': description,
          'is_fav': isFav,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data;
      } else {
        throw Exception(
            'Failed to update collection: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception('Error Response: ${e.response!.data}');
      }
      throw Exception('Failed to update collection: $e');
    }
  }


  Future<Collection> fetchCollection(int collectionId) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      final response = await _dio.get(
        '/collections/$collectionId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Collection.fromJson(response.data); // تحويل الاستجابة إلى نموذج Collection
      } else {
        throw Exception(
            'Failed to fetch collection: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}'
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch collection API: ${e.toString()}');
    }
  }

  Future<void> deleteCollection(int collectionId) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      final response = await _dio.delete(
        '/collections/$collectionId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return; // Success, no need to return data on delete
      } else {
        throw Exception(
            'Failed to delete collection: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception('Error Response: ${e.response!.data}');
      }
      throw Exception('Failed to delete collection: $e');
    }
  }

  // طريقة لجلب العناصر (Tabs) لمجموعة معينة
  Future<List<dynamic>> getTabs(int collectionId) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      final response = await _dio.get('/tabs',
          queryParameters: {
            'collection_id': collectionId,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed 1 to fetch tabs');
    }
  }


  // طريقة لإنشاء عنصر جديد داخل مجموعة
  Future<void> createTab(String title, String url, int collectionId) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      await _dio.post('/tabs',
          data: {
            'title': title,
            'url': url,
            'collection_id': collectionId,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
    } catch (e) {
      throw Exception('Failed to create tab');
    }
  }

  Future<Response> updateTab(
      int id, String title, String url, int collectionId) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }
      final response = await _dio.put('/tabs/$id',
          data: {
            'title': title,
            'url': url,
            'collection_id': collectionId
          }, // إضافة collection_id
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
            'Failed to update tab: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to update tab API');
    }
  }

  // طريقة لحذف عنصر
  Future<void> deleteTab(int tabId) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      await _dio.delete('/tabs/$tabId',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
    } catch (e) {
      throw Exception('Failed to delete tab');
    }
  }

  // طريقة لجلب العلامات (Tags)
  Future<List<dynamic>> getTags() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }
      // print(token);
      final response = await _dio.get('/tags',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to fetch tags');
    }
  }
  Future<List<dynamic>> getConnectedTags(int collectionId) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      final response = await _dio.get('/collections/$collectionId/tags',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));

      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to fetch connected tags');
    }
  }

  // طريقة لإنشاء علامة جديدة
  Future<void> createTag(String title) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }
      await _dio.post('/tags',
          data: {
            'title': title,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
    } catch (e) {
      throw Exception('Failed to create tag');
    }
  }

  // طريقة لحذف علامة
  Future<void> deleteTag(int tagId) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }
      await _dio.delete('/tags/$tagId',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
    } catch (e) {
      throw Exception('Failed to delete tag');
    }
  }

  // Update a tag
  Future<void> updateTag(int tagId, String newTitle) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      await _dio.put(
        '/tags/$tagId',
        data: {
          'title': newTitle,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to update tag');
    }
  }

  // Add a tag to a collection
  Future<void> addTagToCollection(int collectionId, int tagId) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      await _dio.post(
        '/collections/$collectionId/tags',
        data: {'tag_id': tagId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to add tag to collection');
    }
  }

  // Remove a tag from a collection
  Future<void> removeTagFromCollection(int collectionId, int tagId) async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        throw Exception('User is not authenticated. Please log in.');
      }

      await _dio.delete(
        '/collections/$collectionId/tags/$tagId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to remove tag from collection');
    }
  }
}
