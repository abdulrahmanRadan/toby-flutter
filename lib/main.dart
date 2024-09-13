import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toby1/blocs/collection_bloc.dart';
import 'package:toby1/blocs/registration_bloc.dart';
import 'package:toby1/repositories/api_service.dart';
import 'package:toby1/repositories/collection_repository.dart';
import 'package:toby1/repositories/tab_repository.dart';
import 'package:toby1/screens/collection_details_screen.dart';
import 'package:toby1/screens/create_collection_screen.dart';
import 'package:toby1/screens/home_screen.dart';
import 'package:toby1/screens/login_screen.dart';
import 'package:toby1/screens/registration_screen.dart';
import 'package:toby1/screens/tab_management_screen.dart';
import 'package:toby1/screens/tag_management_screen.dart';
import 'package:toby1/screens/user_profile_screen.dart';
import 'package:toby1/blocs/auth_bloc.dart';
import 'package:toby1/models/collection_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      // Handle the case where userId is null, e.g., navigate to login or return a default value
      return null;
    }
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while the user ID is being retrieved
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          // Handle error scenario
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error loading user data')),
            ),
          );
        }

        final userId = snapshot.data;

        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider(create: (context) => ApiService(userId)),
            RepositoryProvider(create: (context) => CollectionRepository(context.read<ApiService>())),
            RepositoryProvider(create: (context) => TabRepository(context.read<ApiService>())),
            BlocProvider(create: (context) => AuthBloc(context.read<ApiService>())),
            BlocProvider(create: (context) => RegistrationBloc(context.read<ApiService>())),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => CollectionBloc(context.read<CollectionRepository>())),
            ],
            child: MaterialApp(
              title: 'Toby App',
              initialRoute: userId == null ? '/' : '/home',
              routes: {
                '/': (context) => LoginScreen(),
                '/home': (context) => const HomeScreen(),
                '/createCollection': (context) => CreateCollectionScreen(),
                '/collectionDetails': (context) {
                  final collection = ModalRoute.of(context)?.settings.arguments as Collection?;
                  if (collection == null) {
                    return const Scaffold(body: Center(child: Text('No collection provided')));
                  }
                  return CollectionDetailsScreen(collection: collection);
                },
                '/createTab': (context) {
                  final collectionId = ModalRoute.of(context)?.settings.arguments as int?;
                  if (collectionId == null) {
                    return const Scaffold(body: Center(child: Text('No collection ID provided')));
                  }
                  return TabManagementScreen(collectionId: collectionId);
                },
                '/manageTags': (context) => const TagManagementScreen(),
                '/profile': (context) => UserProfileScreen(),
                '/register': (context) => RegistrationScreen(),
              },
            ),
          ),
        );
      },
    );
  }
}
