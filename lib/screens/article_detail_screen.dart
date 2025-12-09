import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/components/custom_button.dart';
import '../features/NewsFeed/domain/entities/article.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';
import 'package:internappflutter/features/core/design_systems/app_shapes.dart';
import 'package:internappflutter/features/core/design_systems/app_typography.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(article.webUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch ${article.webUrl}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Controller for the search bar (local to this screen)

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------------
              // Custom App Bar Implementation
              // ----------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 1. Back Button using CustomButton
                    CustomButton(
                      buttonIcon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      iconSize: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ----------------------------------------------------------------

              // --- Main Content Card (Image + Title) ---
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH,
                ),
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppShapes.card,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowSharp,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: article.thumbnailUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: article.thumbnailUrl,
                              fit: BoxFit.cover,
                              height: 250,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                height: 250,
                                color: AppColors.primarySurface,
                                child: const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 250,
                                width: double.infinity,
                                color: AppColors.card,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 250,
                              width: double.infinity,
                              color: AppColors.primarySurface,
                              child: const Center(
                                child: Text('No Image Available'),
                              ),
                            ),
                    ),

                    // Title and Subtitle Section
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.webTitle,
                            style: AppTypography.headingLg,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                article.sectionName,
                                style: AppTypography.companyName,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Description Section ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: AppTypography.jobTitle.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      article.bodyHtml,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- "Know More" Button ---
              Center(
                child: ElevatedButton(
                  onPressed: _launchUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.card,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.card),
                    elevation: 0,
                  ),
                  child: Text(
                    'Know More',
                    style: AppTypography.jobTitle.copyWith(
                      color: AppColors.card,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
