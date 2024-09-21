import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toby1/blocs/auth_bloc.dart';
import 'package:toby1/blocs/collection_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  Future<Map<String, String?>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('name') ?? 'abod';
    final userEmail = prefs.getString('email') ?? 'abod@a.com';

    return {
      'name': userName,
      'email': userEmail,
    };
  }

  @override
  Widget build(BuildContext context) {
    // تأكد من جلب الـ collections عند بناء الصفحة
    context.read<CollectionBloc>().add(LoadCollections());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home '),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<Map<String, String?>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                  child: Text('لم يتم العثور على بيانات المستخدم'));
            }

            final userName = snapshot.data!['name'] ?? 'اسم المستخدم غير موجود';
            final userEmail = snapshot.data!['email'] ??
                'البريد الإلكتروني غير موجود';

            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(userName),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                      style: const TextStyle(fontSize: 40.0),
                    ),
                  ),
                ),
                // ListTile(
                //   leading: const Icon(Icons.person),
                //   title: const Text('الملف الشخصي'),
                //   onTap: () {
                //     Navigator.pushNamed(context, '/profile');
                //   },
                // ),
                // ListTile(
                //   leading: const Icon(Icons.settings),
                //   title: const Text('الإعدادات'),
                //   onTap: () {
                //     // Action for settings
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('تسجيل الخروج'),
                  onTap: () {
                    // تنفيذ تسجيل الخروج هنا
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<CollectionBloc, CollectionState>(
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CollectionLoaded) {
            return ListView.builder(
              itemCount: state.collections.length,
              itemBuilder: (context, index) {
                final collection = state.collections[index];
                return ListTile(
                  title: Text(collection.title),
                  subtitle: Text(collection.description ?? ''),
                  onTap: () {
                    Navigator.pushNamed(context, '/collectionDetails',
                        arguments: collection);
                  },
                );
              },
            );
          } else if (state is CollectionError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No collections available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createCollection');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/profile');
              break;
            case 2:
              // Navigate to settings
              break;
          }
        },
      ),
    );
  }
}
