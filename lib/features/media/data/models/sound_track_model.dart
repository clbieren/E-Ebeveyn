import 'package:flutter/material.dart';

class SoundTrackModel {
  const SoundTrackModel({
    required this.id,
    required this.title,
    required this.category,
    required this.audioUrl,
    required this.durationSeconds,
    this.thumbnailUrl,
    this.description,
  });

  final String id;
  final String title;
  final String category;
  final String audioUrl;
  final int durationSeconds;
  final String? thumbnailUrl;
  final String? description;

  Duration get duration => Duration(seconds: durationSeconds);

  /// Kategori sütunu olmadığı için ikonları doğrudan 'title' (başlık) üzerinden atıyoruz.
  IconData get iconData {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('ninni') || lowerTitle.contains('lull')) {
      return Icons.nightlight_round;
    } else if (lowerTitle.contains('beyaz') ||
        lowerTitle.contains('fön') ||
        lowerTitle.contains('gürültü')) {
      return Icons.graphic_eq_rounded;
    } else if (lowerTitle.contains('orman') || lowerTitle.contains('doğa')) {
      return Icons.forest_rounded;
    } else if (lowerTitle.contains('kalp') || lowerTitle.contains('anne')) {
      return Icons.favorite_rounded;
    } else if (lowerTitle.contains('müzik') || lowerTitle.contains('uyku')) {
      return Icons.music_note_rounded;
    } else if (lowerTitle.contains('yağmur')) {
      return Icons.grain_rounded;
    }
    return Icons.bedtime_rounded; // Varsayılan ikon
  }

  factory SoundTrackModel.fromJson(Map<String, dynamic> json) {
    return SoundTrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      // Veritabanında category yok, çökmeyi engellemek için varsayılan değer atıyoruz:
      category: json['category'] as String? ?? 'Uyku Sesleri',
      // DİKKAT: Veritabanındaki 'content_url' sütunu buraya bağlandı!
      audioUrl: json['content_url'] as String,
      // duration_seconds veritabanında yok, çökmeyi engellemek için 0 atıyoruz:
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      description: json['description'] as String?,
    );
  }
}
