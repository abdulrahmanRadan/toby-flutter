class Tag {
  final int id;
  final String title;

  Tag({required this.id, required this.title});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      title: json['title'],
    );
  }
}
