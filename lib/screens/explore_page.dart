import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/components/custom_app_bar.dart';
import '../core/components/explore_page/article_content_grid.dart';
import '../core/components/explore_page/filter_tag_group.dart';
import '../features/domain/entities/article.dart';
import '../features/presentation/providers/news_provider.dart';
import 'article_detail_screen.dart';
// ... other imports ...

class ExplorePage extends StatelessWidget {
  ExplorePage({super.key});
  final TextEditingController _searchController = TextEditingController();

  // Helper method to build the main content widget tree
  Widget _buildContent(BuildContext context, ExploreViewModel viewModel) {
    // ... (Your existing _buildContent logic remains the same)

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
    // 1. Initial Fetch Management using a Selector (The FIX)
    // The Selector runs whenever the VM changes, but its builder only runs if the
    // selected value (initialLoadAttempted) changes.
    // NOTE: This Selector returns an empty widget, its only job is the side effect.
    Selector<ExploreViewModel, bool>(
      selector: (_, vm) => vm.initialLoadAttempted,
      builder: (ctx, initialLoadAttempted, __) {
        // Run the fetch only when the flag is false (i.e., the first time).
        if (!initialLoadAttempted) {
          // Use Future.microtask to run the side effect *after* the current build finishes.
          Future.microtask(() {
            final vm = ctx.read<ExploreViewModel>();
            if (!vm.initialLoadAttempted) {
              // Double-check safety
              debugPrint(
                '✅ [Selector] Triggering initial data fetch (Guarded).',
              );
              vm.fetchNews(isRefresh: true);
            }
          });
        }
        return const SizedBox.shrink(); // Important: return a minimal, non-visible widget.
      },
    );

    // 2. Main UI Rendering using a Consumer
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Consumer<ExploreViewModel>(
          builder: (context, viewModel, child) {
            // The rest of the UI uses the viewModel provided by the Consumer.
            return Column(
              children: [
                // Custom App Bar (uses the viewModel methods via reference)
                CustomAppBar(
                  searchController: _searchController,
                  onSearchSubmit: (query) =>
                      viewModel.fetchNews(isRefresh: true),
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
