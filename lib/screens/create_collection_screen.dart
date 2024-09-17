import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/collection_bloc.dart';

class CreateCollectionScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  CreateCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Collection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<CollectionBloc, CollectionState>(
          listener: (context, state) {
            if (state is CollectionLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Collection created successfully')),
              );
              Navigator.pop(context); // العودة إلى الشاشة السابقة بعد النجاح
            } else if (state is CollectionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is CollectionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text;
                    final description = _descriptionController.text;
                    context.read<CollectionBloc>().add(CreateCollection(title, description));
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
