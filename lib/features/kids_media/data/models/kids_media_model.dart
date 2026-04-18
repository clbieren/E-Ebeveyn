class KidsMediaModel {
  final String id;
  final String title;
  final String contentUrl;
  final String category;
  final String? thumbnailUrl;
  final String? description;

  KidsMediaModel({
    required this.id,
    required this.title,
    required this.contentUrl,
    required this.category,
    this.thumbnailUrl,
    this.description,
  });

  factory KidsMediaModel.fromJson(Map<String, dynamic> json) {
    return KidsMediaModel(
      id: json['id'],
      title: json['title'],
      contentUrl: json['content_url'],
      category: json['category'],
      thumbnailUrl: json['thumbnail_url'],
      description: json['description'],
    );
  }
}
