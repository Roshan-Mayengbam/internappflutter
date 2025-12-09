import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/features/Search/presentation/search_page.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import for ConnectivityResult

import 'package:internappflutter/common/components/explore_page/article_content_grid.dart';
import 'package:internappflutter/common/components/custom_app_bar.dart';
import 'package:internappflutter/common/components/explore_page/filter_tag_group.dart';
import 'package:internappflutter/features/NewsFeed/domain/entities/article.dart';
import 'package:internappflutter/features/NewsFeed/presentation/provider/news_provider.dart';
import 'package:internappflutter/screens/article_detail_screen.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';
import 'package:internappflutter/features/core/network/network_service.dart'; // Import for NetworkService

import 'package:internappflutter/chat/chatpage.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  // Helper function for the main content when network is OK
  Widget _buildMainAppContent(
    BuildContext context,
    ExploreViewModel viewModel,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomAppBar(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          ),
          onChatPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          ),
          onNotificationPressed: () => debugPrint('Notification pressed'),
        ),

        const SizedBox(height: 16),

        // Filter Tag Group
        FilterTagGroup(
          selectedFilter: viewModel.selectedFilter,
          onFilterSelected: viewModel.setFilter,
        ),

        SizedBox(height: AppSpacing.lg),

        Expanded(child: _buildContent(context, viewModel)),

        // PAGINATION LOADING INDICATOR
        if (viewModel.isLoading && viewModel.articles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 20),
            child: SizedBox(
              height: 150,
              width: 200,
              child: Lottie.asset(
                'assets/animations/searching/searching_lottie.json',
                fit: BoxFit.cover,
                repeat: true,
                animate: true,
              ),
            ),
          ),
      ],
    );
  }

  // Helper function to build the full-screen network error state
  Widget _buildNetworkErrorScreen(
    BuildContext context,
    ExploreViewModel viewModel,
  ) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            CustomAppBar(
              onChatPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              ),
              onNotificationPressed: () {
                if (kDebugMode) print("Pressed Notifications button");
              },
            ),
            SizedBox(height: AppSpacing.xl * 2),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/error/error_lottie.json',
                      width: 250,
                      height: 250,
                      repeat: false,
                      animate: true,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No network connection detected. Please check your internet.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // The "Try Again" button manually triggers a fetch attempt
                    OutlinedButton(
                      onPressed: () {
                        viewModel.fetchNews(isRefresh: true);
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExploreViewModel viewModel) {
    // Handle generic API/Rate Limit errors (when network is OK, but API call failed)
    // Note: The network error screen is reused here, but the error message will reflect
    // the generic API failure set by the ViewModel's try/catch block.
    if (viewModel.errorMessage != null && viewModel.articles.isEmpty) {
      return _buildNetworkErrorScreen(context, viewModel);
    }

    // FULL-SCREEN INITIAL LOADING CHECK
    if (viewModel.isLoading && viewModel.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/searching/searching_lottie.json',
              width: 300,
              height: 300,
              repeat: true,
              animate: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Fetching the latest news just for you...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // EMPTY STATE CHECK
    if (viewModel.articles.isEmpty && !viewModel.isLoading) {
      return Center(
        child: Lottie.asset(
          'assets/animations/empty/empty_lottie.json',
          width: 200,
          height: 200,
          repeat: true,
        ),
      );
    }

    // MAIN CONTENT (Articles Grid)
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
    // Get the ViewModel, but DO NOT listen (listen: false)
    final viewModel = Provider.of<ExploreViewModel>(context, listen: false);
    final networkService = Provider.of<NetworkService>(context, listen: false);

    if (!viewModel.initialLoadAttempted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!viewModel.initialLoadAttempted) {
          debugPrint(
            '✅ [ExplorePage] Triggering initial data fetch (PostFrameCallback).',
          );
          viewModel.fetchNews(isRefresh: true);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: StreamBuilder<ConnectivityResult>(
          stream: networkService.onConnectivityChanged,
          initialData: ConnectivityResult.wifi, // Assumes connected initially
          builder: (context, snapshot) {
            // Check if the current network status is 'none'
            final isOffline = snapshot.data == ConnectivityResult.none;

            // Use the Consumer to listen to ViewModel state changes
            return Consumer<ExploreViewModel>(
              builder: (context, viewModel, child) {
                if (isOffline) {
                  return _buildNetworkErrorScreen(context, viewModel);
                }

                // If online, render the normal app structure
                return _buildMainAppContent(context, viewModel);
              },
            );
          },
        ),
      ),
    );
  }
}
