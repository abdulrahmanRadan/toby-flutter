import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
    connectTimeout: const Duration(seconds: 10), // تحديد مهلة الاتصال بـ 10 ثوانٍ
    receiveTimeout: const Duration(seconds: 10), // تحديد مهلة الاستقبال بـ 10 ثوانٍ
  ));


  // Method for user login
  Future<dynamic> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      // Check if the response is successful
      if (response.statusCode == 200) {
        return response.data;
      } else {
        // Handle different error status codes
        throw Exception('Failed to login: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (dioError) {
      // Handle Dio errors (like network issues, 404, 500, etc.)
      if (dioError.response != null) {
        throw Exception('Dio error: ${dioError.response?.statusCode} - ${dioError.response?.data['message'] ?? dioError.message}');
      } else {
        // Handle non-response errors (like network timeout, DNS error)
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      // Handle any other unexpected errors
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

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        // Handle different error status codes
        throw Exception('Failed to register: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (dioError) {
      // Handle Dio errors (like network issues, 404, 500, etc.)
      if (dioError.response != null) {
        throw Exception('Dio error: ${dioError.response?.statusCode} - ${dioError.response?.data['message'] ?? dioError.message}');
      } else {
        // Handle non-response errors (like network timeout, DNS error)
        throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('Unexpected error: $e');
    }
  }


  // طريقة لجلب المجموعات
  Future<List<dynamic>> getCollections() async {
    try {
      final response = await _dio.get('/collections');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to fetch collections');
    }
  }

  // طريقة لإنشاء مجموعة جديدة
  Future<void> createCollection(String title, String? description) async {
    try {
      await _dio.post('/collections', data: {
        'title': title,
        'description': description,
      });
    } catch (e) {
      throw Exception('Failed to create collection');
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
