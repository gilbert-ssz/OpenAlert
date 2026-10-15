import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Lists the source and license of every bundled photograph
/// (required for Creative Commons attribution).
class ImageCreditsScreen extends StatelessWidget {
  const ImageCreditsScreen({super.key});

  Future<List<Map<String, dynamic>>> _load() async {
    final raw = await rootBundle.loadString('assets/data/image_credits.json');
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Credits')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: StateMessage(
                icon: Icons.error_outline_rounded,
                title: 'Could not load credits',
                message: 'assets/data/image_credits.json is missing.',
              ),
            );
          }
          final items = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == 0) {
                return const Text(
                  'Photographs from Wikimedia Commons, used under the licenses '
                  'shown. Images may be cropped for display.',
                  style: TextStyle(color: AppColors.muted),
                );
              }
              final c = items[i - 1];
              return AppCard(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/${c['file']}',
                          width: 72, height: 72, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (c['title'] as String).replaceFirst('File:', ''),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text('By ${c['author']} • ${c['license']}',
                              style: const TextStyle(fontSize: 12.5)),
                          const SizedBox(height: 2),
                          SelectableText(c['source'] as String,
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.teal)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
