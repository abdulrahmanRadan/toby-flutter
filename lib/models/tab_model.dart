class AppTab {
  final int id;
  final String title;
  final String url;
  final int collectionId;

  AppTab({required this.id, required this.title, required this.url, required this.collectionId});

  factory AppTab.fromJson(Map<String, dynamic> json) {
    return AppTab(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      collectionId: json['collection_id'],
    );
  }
}
