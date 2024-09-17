import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tab_bloc.dart';

class CreateTabScreen extends StatefulWidget {
  final int collectionId;

  const CreateTabScreen({super.key, required this.collectionId});

  @override
  _CreateTabScreenState createState() => _CreateTabScreenState();
}

class _CreateTabScreenState extends State<CreateTabScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Tab'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL (Optional)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final url = _urlController.text;

                if (title.isNotEmpty) {
                  // استخدام Bloc لإضافة تبويب جديد
                  context.read<TabBloc>().add(CreateTab(title, url, widget.collectionId));

                  // العودة مع تمرير قيمة تدل على نجاح العملية
                  Navigator.pop(context, true); // true تشير إلى أن العملية تمت بنجاح
                } else {
                  // عرض رسالة إذا كان العنوان فارغًا
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty')),
                  );
                }
              },
              child: const Text('Create Tab'),
            ),

          ],
        ),
      ),
    );
  }
}
