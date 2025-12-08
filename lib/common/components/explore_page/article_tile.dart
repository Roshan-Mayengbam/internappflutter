// lib/presentation/widgets/molecules/article_tile.dart (UPDATED)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:internappflutter/features/NewsFeed/domain/entities/article.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/features/core/design_systems/app_shapes.dart';
import 'package:internappflutter/features/core/design_systems/app_typography.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';

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
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppShapes.card,
          border: Border.all(color: AppColors.borderSoft, width: 1),
          boxShadow: [
            BoxShadow(color: AppColors.shadowSharp, offset: const Offset(4, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 150,
                        color: AppColors.primarySurface,
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

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Text(
                article.webTitle,
                style: AppTypography.companyName.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
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
