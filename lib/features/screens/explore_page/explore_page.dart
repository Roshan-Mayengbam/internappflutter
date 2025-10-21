import 'package:flutter/material.dart';
import 'package:internappflutter/features/screens/search_page/search_page.dart';
import 'package:provider/provider.dart';

import '../../../common/components/explore_page/article_content_grid.dart';
import '../../../common/components/custom_app_bar.dart';
import '../../../common/components/explore_page/filter_tag_group.dart';
import '../../NewsFeed/domain/entities/article.dart';
import '../../NewsFeed/presentation/provider/news_provider.dart';
import '../../../screens/article_detail_screen.dart';

// Assuming ExploreViewModel is an alias for NewsProvider,
// as is common practice when using NewsProvider for the Explore UI logic.
// If not, replace ExploreViewModel with NewsProvider throughout the file.

class ExplorePage extends StatelessWidget {
  ExplorePage({super.key});
  final TextEditingController _searchController = TextEditingController();

  // Helper method to build the main content widget tree
  Widget _buildContent(BuildContext context, ExploreViewModel viewModel) {
    // Show full screen spinner only if NO articles have been loaded yet
    if (viewModel.isLoading && viewModel.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Show error message if fetch failed and no articles are present
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

    // --- INFINITE SCROLLING IMPLEMENTATION ---
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
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Consumer<ExploreViewModel>(
          builder: (context, viewModel, child) {
            // 1. Initial Fetch Management using addPostFrameCallback (THE FIX)
            // This runs the side effect *after* the current frame has been rendered,
            // which prevents the "setState during build" error and loads the default filter data.
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
                  onChatPressed: () => debugPrint('Chat pressed'),
                  onNotificationPressed: () =>
                      debugPrint('Notification pressed'),
                ),

                const SizedBox(height: 16),

                // Filter Tag Group
                FilterTagGroup(
                  selectedFilter: viewModel.selectedFilter,
                  onFilterSelected: viewModel.setFilter,
                ),

                const SizedBox(height: 16),

                // Content Area (Grid + Loading/Error)
                Expanded(child: _buildContent(context, viewModel)),

                // Optional: Loading indicator
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
