import 'package:toby1/blocs/collection_bloc.dart';
import 'package:toby1/models/tab_model.dart';
import '../../models/collection_model.dart';  // تأكد من استيراد الـ Collection
import '../../models/tag_model.dart';  // استيراد الوسوم

class SingleCollectionLoaded extends CollectionState {
  final Collection collection;
  final List<AppTab> tabs;
  final List<Tag> tags;

  const SingleCollectionLoaded({
    required this.collection,
    required this.tabs,
    required this.tags,
  });

  @override
  List<Object?> get props => [collection, tabs, tags];
}