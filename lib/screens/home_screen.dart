import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toby1/blocs/auth_bloc.dart';
import 'package:toby1/blocs/collection_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text('اسم المستخدم'),
              accountEmail: Text('البريد الإلكتروني'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'A',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('الملف الشخصي'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('الإعدادات'),
              onTap: () {
                // Action for settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل الخروج'),
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
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
