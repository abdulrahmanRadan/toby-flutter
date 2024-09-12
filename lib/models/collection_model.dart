class Collection {
  final int id;
  final String title;
  final String? description;

  Collection({required this.id, required this.title, this.description});

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
