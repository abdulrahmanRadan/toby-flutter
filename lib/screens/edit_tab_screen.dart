import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toby1/blocs/events/tab_event.dart';
import 'package:toby1/models/tab_model.dart';

import '../blocs/tab_bloc.dart';
import '../models/tab_model.dart';

class EditTabScreen extends StatefulWidget {
  final AppTab tab;

  const EditTabScreen({super.key, required this.tab});

  @override
  _EditTabScreenState createState() => _EditTabScreenState();
}

class _EditTabScreenState extends State<EditTabScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.tab.title;
    _urlController.text = widget.tab.url;
  }

  void _updateTab() {
    final title = _titleController.text;
    final url = _urlController.text;
    final collectionId = widget.tab.collectionId; // إضافة collectionId

    if (title.isNotEmpty && url.isNotEmpty) {
      BlocProvider.of<TabBloc>(context).add(
        UpdateTab(
          widget.tab.id,
          title,
          url,
          collectionId, // تمرير collectionId
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tab'),
      ),
      body: BlocListener<TabBloc, TabState>(
        listener: (context, state) {
          if (state is TabError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TabUpdatedSuccess) {
            // إذا كانت الحالة ناجحة
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tab updated successfully')),
            );
            Navigator.pop(context, true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTab,
                child: const Text('Update Tab'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
