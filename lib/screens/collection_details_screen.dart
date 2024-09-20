// تعديل الكود في ملف collection_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toby1/blocs/tab_bloc.dart';
import 'package:toby1/models/collection_model.dart';

class CollectionDetailsScreen extends StatelessWidget {
  final Collection collection;

  const CollectionDetailsScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    context.read<TabBloc>().add(LoadTabs(collection.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(collection.title),
      ),
      body: BlocListener<TabBloc, TabState>(
        listener: (context, state) {
          if (state is TabError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TabLoaded) {
            // Display a message if a tab was successfully updated
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tabs loaded successfully')),
            );
          }
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
                  return Dismissible(
                    key: Key(tab.id.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      context.read<TabBloc>().add(DeleteTab(tab.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${tab.title} deleted')),
                      );
                      // context.read<TabBloc>().add(LoadTabs(collection.id));
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(tab.title),
                      subtitle: Text(tab.url),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/editTab',
                            arguments: tab,
                          );

                          if (result == true) {
                            // إعادة تحميل البيانات أو عرض رسالة إذا كانت العملية ناجحة
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tab updated successfully')),
                            );
                            // context.read<TabBloc>().add(LoadTabs(collection.id));
                          }
                        },
                      ),
                      onTap: () {},
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/createTab',
            arguments: collection.id,
          );

          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tab created successfully')),
            );
            // context.read<TabBloc>().add(LoadTabs(collection.id));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
