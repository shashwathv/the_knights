import 'package:flutter/material.dart';

class Resource {
  final String id;
  final String title;
  final String titleKannada;
  final String description;
  final String descriptionKannada;
  final String type;
  final String typeKannada;
  final String? url;
  final String? filePath;
  final List<String> tags;
  final String date;

  Resource({
    required this.id,
    required this.title,
    required this.titleKannada,
    required this.description,
    required this.descriptionKannada,
    required this.type,
    required this.typeKannada,
    this.url,
    this.filePath,
    required this.tags,
    required this.date,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      titleKannada: json['titleKannada'] as String,
      description: json['description'] as String,
      descriptionKannada: json['descriptionKannada'] as String,
      type: json['type'] as String,
      typeKannada: json['typeKannada'] as String,
      url: json['url'] as String?,
      filePath: json['filePath'] as String?,
      tags: List<String>.from(json['tags'] as List),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleKannada': titleKannada,
      'description': description,
      'descriptionKannada': descriptionKannada,
      'type': type,
      'typeKannada': typeKannada,
      'url': url,
      'filePath': filePath,
      'tags': tags,
      'date': date,
    };
  }

  IconData getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.video_library;
      case 'document':
        return Icons.description;
      case 'guide':
        return Icons.menu_book;
      case 'link':
        return Icons.link;
      default:
        return Icons.article;
    }
  }
} 