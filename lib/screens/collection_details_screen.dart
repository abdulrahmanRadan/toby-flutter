import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toby1/blocs/tag_bloc.dart';
import 'package:toby1/blocs/tab_bloc.dart';
import 'package:toby1/models/collection_model.dart';
import 'package:toby1/models/tag_model.dart';

class CollectionDetailsScreen extends StatefulWidget {
  final Collection collection;

  const CollectionDetailsScreen({super.key, required this.collection});

  @override
  _CollectionDetailsScreenState createState() => _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  List<Tag> _connectedTags = []; // قائمة لتخزين الـ Tags المتصلة

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<TagBloc>().add(GetConnectedTags(widget.collection.id));
    context.read<TagBloc>().add(LoadTags());
    context.read<TabBloc>().add(LoadTabs(widget.collection.id));


    // _loadConnectedTags();
  }
  // void _loadConnectedTags() {
  //
  //
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < (context.read<TagBloc>().state as TagLoaded).tags.length ~/ 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  void _toggleTag(Tag tag) {
    setState(() {
      if (_connectedTags.contains(tag)) {
        _connectedTags.remove(tag);
        context.read<TagBloc>().add(RemoveTagFromCollection(widget.collection.id, tag.id));
      } else {
        _connectedTags.add(tag);
        context.read<TagBloc>().add(AddTagToCollection(widget.collection.id, tag.id));
      }
    });
    context.read<TagBloc>().add(LoadTags());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.collection.title} Collection"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عرض Tags المتصلة بالـ Collection
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: _connectedTags.map((tag) {
                return Chip(
                  label: Text(tag.title),
                  backgroundColor: Colors.blueAccent, // لون خلفية مختلف
                  onDeleted: () {
                    _toggleTag(tag);
                  },
                );
              }).toList(),
            ),
          ),

          // Tags PageView
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<TagBloc, TagState>(
              builder: (context, state) {
                if (state is TagLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TagLoaded) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 80.0,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: (state.tags.length / 2).ceil(),
                          itemBuilder: (context, pageIndex) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: state.tags.skip(pageIndex * 10).take(10).map((tag) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: GestureDetector(
                                      onTap: () => _toggleTag(tag), // إضافة الدالة عند النقر
                                      child: Chip(
                                        label: Text(tag.title),
                                        backgroundColor: _connectedTags.contains(tag) ? Colors.blueAccent : null,
                                      ),

                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _previousPage,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _nextPage,
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (state is TagError) {
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: Text('No tags available'));
                }
              },
            ),
          ),

          // Expanded widget for tabs ListView
          Expanded(
            child: BlocListener<TabBloc, TabState>(
              listener: (context, state) {

                if (state is TabError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is TabLoaded) {
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
                            context.read<TabBloc>().add(LoadTabs(widget.collection.id));
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
                                  context.read<TabBloc>().add(LoadTabs(widget.collection.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tab updated successfully')),
                                  );
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
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/createTab',
            arguments: widget.collection.id,
          );

          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tab created successfully')),

            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
