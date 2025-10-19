// lib/presentation/widgets/molecules/article_tile.dart (UPDATED)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:internappflutter/features/NewsFeed/domain/entities/article.dart';

class ArticleTile extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const ArticleTile({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.thumbnailUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Card styling
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(6, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Image (The dominant part)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildFallbackContent(),
                    )
                  : _buildFallbackContent(),
            ),

            // 2. Title (Minimal text below the image)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Text(
                article.webTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  // --- CHANGE MADE HERE ---
                  fontSize: 12,
                  // ------------------------
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fallback for missing or failed image (unchanged)
  Widget _buildFallbackContent() {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Text(
        '${article.webTitle}\n(${article.sectionName})',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54, fontSize: 13),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
