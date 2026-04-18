import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/kids_media_model.dart';
import '../providers/kids_media_providers.dart';

class KidsMediaScreen extends ConsumerWidget {
  const KidsMediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        appBar: AppBar(
          title: const Text('Dinle & Oku'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.music_note),
                text: 'Ninniler',
              ),
              Tab(
                icon: Icon(Icons.menu_book),
                text: 'Hikayeler',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NinnilerList(),
            _HikayelerList(),
          ],
        ),
      ),
    );
  }
}

class _NinnilerList extends ConsumerWidget {
  const _NinnilerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ninnilerAsync = ref.watch(ninnilerListProvider);

    return ninnilerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('Henüz içerik eklenmemiş'));
        }
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              color: const Color(0xFF3A3A3A),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: () {
                  // Şimdilik boş
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _HikayelerList extends ConsumerWidget {
  const _HikayelerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hikayelerAsync = ref.watch(hikayelerListProvider);

    return hikayelerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('Henüz içerik eklenmemiş'));
        }
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              color: const Color(0xFF3A3A3A),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: const Icon(Icons.auto_stories, color: Colors.white),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: () {
                  // Şimdilik boş
                },
              ),
            );
          },
        );
      },
    );
  }
}
