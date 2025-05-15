class Post {
  final String id;
  final String title;
  final String titleKannada;
  final String content;
  final String contentKannada;
  final String author;
  final String date;
  final String category;
  final int likes;
  final int comments;
  final List<String> tags;

  Post({
    required this.id,
    required this.title,
    required this.titleKannada,
    required this.content,
    required this.contentKannada,
    required this.author,
    required this.date,
    required this.category,
    required this.likes,
    required this.comments,
    required this.tags,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      titleKannada: json['titleKannada'] as String,
      content: json['content'] as String,
      contentKannada: json['contentKannada'] as String,
      author: json['author'] as String,
      date: json['date'] as String,
      category: json['category'] as String,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleKannada': titleKannada,
      'content': content,
      'contentKannada': contentKannada,
      'author': author,
      'date': date,
      'category': category,
      'likes': likes,
      'comments': comments,
      'tags': tags,
    };
  }
} 