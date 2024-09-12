import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toby1/blocs/auth_bloc.dart';
import 'package:toby1/blocs/collection_bloc.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
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
                    Navigator.pushNamed(context, '/collectionDetails', arguments: collection);
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
    );
  }
}
