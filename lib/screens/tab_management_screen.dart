import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tab_bloc.dart';

class TabManagementScreen extends StatelessWidget {
  final int collectionId;

  const TabManagementScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tabs'),
      ),
      body: BlocBuilder<TabBloc, TabState>(
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<TabBloc>().add(DeleteTab(tab.id));
                    },
                  ),
                );
              },
            );
          } else if (state is TabError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No tabs available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/createTab',
            arguments: collectionId,
          );

          if (result == true) {
            // عرض رسالة نجاح
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tab created successfully')),
            );

            // إعادة تحميل التبويبات لتحديث القائمة
            context.read<TabBloc>().add(LoadTabs(collectionId));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

