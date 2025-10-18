// lib/presentation/screens/explore/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:internappflutter/core/components/custom_search_field.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/components/custom_button.dart';
import '../features/domain/entities/article.dart';

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
    const String customFont = 'Jost';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------------
              // Custom App Bar Implementation
              // ----------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black, offset: const Offset(2, 2)),
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
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 250,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 250,
                              width: double.infinity,
                              color: Colors.blueGrey[100],
                              child: const Center(
                                child: Text('No Image Available'),
                              ),
                            ),
                    ),

                    // Title and Subtitle Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.webTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: customFont,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                article.sectionName,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.grey[700],
                                      fontFamily: customFont,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.blue,
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: customFont,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.bodyHtml,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                        fontFamily: customFont,
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
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Know More',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: customFont,
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
