import 'package:toby1/models/tag_model.dart';
import 'package:toby1/models/tab_model.dart';

class Collection {
  final int id;
  final String title;
  final String? description;
  final List<AppTab> tabs;
  final List<Tag> tags;

  Collection({
    required this.id,
    required this.title,
    this.description,
    required this.tabs,
    required this.tags,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      tabs: List<AppTab>.from(json['tabs'].map((tab) => AppTab.fromJson(tab))),
      tags: List<Tag>.from(json['tags'].map((tag) => Tag.fromJson(tag))),
    );
  }
}
