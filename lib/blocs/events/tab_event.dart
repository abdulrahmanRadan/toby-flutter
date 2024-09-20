import 'package:toby1/blocs/tab_bloc.dart';

class UpdateTab extends TabEvent {
  final int id;
  final String title;
  final String url;
  final int collectionId;

  const UpdateTab(this.id, this.title, this.url, this.collectionId);

  @override
  List<Object?> get props => [id, title, url, collectionId];
}
