import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tab_bloc.dart';
import '../models/collection_model.dart';
import '../repositories/tab_repository.dart'; // تأكد من استيراد TabRepository

class CollectionDetailsScreen extends StatelessWidget {
  final Collection collection;

  const CollectionDetailsScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collection.title),
      ),
      body: BlocProvider<TabBloc>(
        create: (context) {
          final tabRepository = RepositoryProvider.of<TabRepository>(context);
          final tabBloc = TabBloc(tabRepository); // توفير TabBloc باستخدام Repository
          tabBloc.add(LoadTabs(collection.id)); // إرسال الحدث لجلب البيانات
          return tabBloc;
        },
        child: BlocBuilder<TabBloc, TabState>(
          builder: (context, state) {
            if (state is TabLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TabLoaded) {
              return ListView.builder(
                itemCount: state.tabs.length,
                itemBuilder: (context, index) {
                  final tab = state.tabs[index];
                  return ListTile(
                    title: Text(tab.title),
                    subtitle: Text(tab.url),
                    onTap: () {
                      // Implement tab click action here
                    },
                  );
                },
              );
            } else if (state is TabError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No tabs available'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createTab', arguments: collection.id);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
