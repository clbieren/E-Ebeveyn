import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase'den gelen akademi rehberi modeli.
final class AcademyGuide {
  const AcademyGuide({
    required this.id,
    required this.title,
    this.author,
    required this.pdfUrl,
    this.thumbnailUrl,
    this.description,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? author;
  final String pdfUrl;
  final String? thumbnailUrl;
  final String? description;
  final DateTime createdAt;

  factory AcademyGuide.fromJson(Map<String, dynamic> json) {
    return AcademyGuide(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      pdfUrl: json['pdf_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

final academyProvider = FutureProvider<List<AcademyGuide>>((ref) async {
  final response = await Supabase.instance.client
      .from('academy_content')
      .select()
      .order('created_at', ascending: false);

  if (response.isEmpty) return [];

  return response.map((json) => AcademyGuide.fromJson(json)).toList();
});
