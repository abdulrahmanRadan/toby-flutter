import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tag_bloc.dart';

class TagManagementScreen extends StatelessWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
      ),
      body: BlocBuilder<TagBloc, TagState>(
        builder: (context, state) {
          if (state is TagLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TagLoaded) {
            return ListView.builder(
              itemCount: state.tags.length,
              itemBuilder: (context, index) {
                final tag = state.tags[index];
                return ListTile(
                  title: Text(tag.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<TagBloc>().add(DeleteTag(tag.id));
                    },
                  ),
                );
              },
            );
          } else if (state is TagError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No tags available'));
        },
      ),
    );
  }
}
