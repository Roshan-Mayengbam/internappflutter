// lib/presentation/widgets/organisms/article_content_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:internappflutter/features/NewsFeed/domain/entities/article.dart';
import 'article_tile.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';

/// Organism responsible for displaying articles in a Masonry (Pinterest) layout.
class ArticleContentGrid extends StatelessWidget {
  /// The list of Article entities fetched from the GetNewsUseCase.
  final List<Article> articles;

  /// Callback function when a tile is tapped, usually for navigation.
  final Function(Article) onTileTap;

  const ArticleContentGrid({
    super.key,
    required this.articles,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          "No tech news found at the moment.",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    // Use MasonryGridView for the Pinterest-style staggered layout
    return MasonryGridView.count(
      // The overall padding for the entire grid
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH, vertical: AppSpacing.md),

      // Two columns for the classic Pinterest look
      crossAxisCount: 2,

      // Spacing between tiles
      mainAxisSpacing: AppSpacing.xl, // Vertical spacing
      crossAxisSpacing: AppSpacing.lg, // Horizontal spacing

      itemCount: articles.length,

      itemBuilder: (context, index) {
        final article = articles[index];

        // Render the ArticleTile, which handles image loading and styling
        return ArticleTile(article: article, onTap: () => onTileTap(article));
      },
    );
  }
}
