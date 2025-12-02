import 'package:flutter/material.dart';
import 'package:internappflutter/features/Search/presentation/search_page.dart';
import 'package:provider/provider.dart';

import 'package:internappflutter/common/components/explore_page/article_content_grid.dart';
import 'package:internappflutter/common/components/custom_app_bar.dart';
import 'package:internappflutter/common/components/explore_page/filter_tag_group.dart';
import 'package:internappflutter/features/NewsFeed/domain/entities/article.dart';
import 'package:internappflutter/features/NewsFeed/presentation/provider/news_provider.dart';
import 'package:internappflutter/screens/article_detail_screen.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';

import 'package:internappflutter/chat/chatpage.dart';

class ExplorePage extends StatelessWidget {
  ExplorePage({super.key});
  final TextEditingController _searchController = TextEditingController();

  Widget _buildContent(BuildContext context, ExploreViewModel viewModel) {
    // Show full screen spinner only if NO articles have been loaded yet
    if (viewModel.isLoading && viewModel.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (viewModel.errorMessage != null && viewModel.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            viewModel.errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.95 &&
            scrollInfo.metrics.pixels > 0 &&
            !viewModel.isLoading) {
          viewModel.loadMore();
          return true;
        }
        return false;
      },
      child: ArticleContentGrid(
        articles: viewModel.articles,
        onTileTap: (article) => _onArticleTap(context, article),
      ),
    );
  }

  void _onArticleTap(BuildContext context, Article article) {
    debugPrint('Navigating to detail for: ${article.webTitle}');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Main UI Rendering using a Consumer
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Consumer<ExploreViewModel>(
          builder: (context, viewModel, child) {
            if (!viewModel.initialLoadAttempted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Double-check safety
                if (!viewModel.initialLoadAttempted) {
                  debugPrint(
                    '✅ [Consumer] Triggering initial data fetch (PostFrameCallback).',
                  );
                  // This loads the initial data, typically for the first filter tag.
                  viewModel.fetchNews(isRefresh: true);
                }
              });
            }

            return Column(
              children: [
                CustomAppBar(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  ),
                  onChatPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatPage()),
                  ),
                  onNotificationPressed: () =>
                      debugPrint('Notification pressed'),
                ),

                const SizedBox(height: 16),

                // Filter Tag Group
                FilterTagGroup(
                  selectedFilter: viewModel.selectedFilter,
                  onFilterSelected: viewModel.setFilter,
                ),

                SizedBox(height: AppSpacing.lg),

                Expanded(child: _buildContent(context, viewModel)),

                if (viewModel.isLoading && viewModel.articles.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: CircularProgressIndicator.adaptive(strokeWidth: 3),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
