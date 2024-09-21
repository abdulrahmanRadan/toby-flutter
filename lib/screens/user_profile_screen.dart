import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<Map<String, String?>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('name') ?? 'اسم المستخدم غير موجود';
    final userEmail = prefs.getString('email') ?? 'البريد الإلكتروني غير موجود';

    return {
      'name': userName,
      'email': userEmail,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف المستخدم'),
      ),
      body: FutureBuilder<Map<String, String?>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('لم يتم العثور على بيانات المستخدم'));
          }

          final userName = snapshot.data!['name'] ?? 'اسم المستخدم غير موجود';
          final userEmail = snapshot.data!['email'] ?? 'البريد الإلكتروني غير موجود';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الاسم:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(userName),
                const SizedBox(height: 16.0),
                const Text(
                  'البريد الإلكتروني:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(userEmail),
              ],
            ),
          );
        },
      ),
    );
  }
}
