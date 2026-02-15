class Article {
  final int id;
  final String title;
  final String content;
  final String? category;
  final String? imageUrl;
  final DateTime publishedDate;
  final String? author;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.imageUrl,
    required this.publishedDate,
    this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'],
      imageUrl: json['imageUrl'],
      publishedDate: DateTime.parse(json['publishedDate'] ?? DateTime.now().toIso8601String()),
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'author': author,
    };
  }
}
