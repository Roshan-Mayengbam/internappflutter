import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/features/AvailableHackathons/presentation/provider/hackathon_provider.dart';
import 'package:internappflutter/home/cardDetails.dart';
import 'package:internappflutter/screens/hackathon_details.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../common/components/search_page/data_tile.dart';
import '../../../common/components/search_page/search_filter_group.dart';
import '../../../common/components/search_page/search_page_app_bar.dart';
import 'package:internappflutter/common/constants/search_page/search_page_constants.dart';
import '../../AvailableHackathons/domain/entities/hackathon.dart';
import '../../AvailableJobs/domain/entities/job.dart';
import '../../AvailableJobs/presentation/provider/job_provider.dart';
import '../../core/design_systems/app_typography.dart';
import '../../core/design_systems/app_colors.dart';
import '../../core/design_systems/app_spacing.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _searchController;
  late SearchCategory _selectedSearchCategory;
  String _currentSearchQuery = '';

  Timer? _debounce;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedSearchCategory = kSearchFilters.first;

    _searchController.addListener(_onSearchQueryChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedSearchCategory.searchFilter == 'jobs') {
        setState(() {
          _performSearch(isInitialLoad: true);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchQueryChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- SEARCH AND FILTER HANDLERS ---

  void _onSearchQueryChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(_debounceDuration, _handleLiveSearch);
  }

  void _handleLiveSearch() {
    final newQuery = _searchController.text.trim();

    if (newQuery != _currentSearchQuery) {
      setState(() {
        _currentSearchQuery = newQuery;
      });
      _performSearch();
    }
  }

  void _handleCategorySelection(SearchCategory category) {
    setState(() {
      _selectedSearchCategory = category;
      _currentSearchQuery = _searchController.text.trim();
    });
    _performSearch();
  }

  void _handleSearchSubmission(String query) {
    _searchController.text = query.trim();
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );

    setState(() {
      _currentSearchQuery = query.trim();
      FocusScope.of(context).unfocus();
    });
    _performSearch();
  }

  void _performSearch({bool isInitialLoad = false}) {
    final jobProvider = context.read<JProvider>();
    final hackathonProvider = context.read<HProvider>();
    final filterSlug = _selectedSearchCategory.searchFilter;
    final query = isInitialLoad ? null : _currentSearchQuery;

    if (kDebugMode) print('--- Executing Search ---');
    if (kDebugMode) print('Scope: $filterSlug');
    if (kDebugMode) print('Query: "$query"');

    if (filterSlug == 'jobs') {
      jobProvider.fetchJobs(searchString: query);
    } else if (filterSlug == 'hackathons') {
      hackathonProvider.fetchHackathons(searchString: query);
    }
  }

  Widget _buildJobResults(JProvider jobProvider) {
    final state = jobProvider.state;
    final jobs = jobProvider.jobs;
    final totalJobs = jobProvider.totalJobs;
    final currentQuery = jobProvider.currentQuery;

    switch (state) {
      case JobState.loading:
      case JobState.initial:
        return Center(
          child: Lottie.asset(
            'assets/animations/searching/searching_lottie.json',
            width: 250,
            height: 250,
            repeat: true,
            animate: true,
          ),
        );
      case JobState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
                  'Error fetching jobs: ${jobProvider.errorMessage}',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      case JobState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/empty/empty_lottie.lottie',
                  width: 200,
                  height: 200,
                  repeat: true,
                  animate: true,
                ),
                const SizedBox(height: 20),
                Text(
                  currentQuery != null && currentQuery.isNotEmpty
                      ? 'No results found for "$currentQuery".'
                      : 'No jobs are currently available.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );

      case JobState.loaded:
      case JobState.loadingMore:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(
                currentQuery != null && currentQuery.isNotEmpty
                    ? '$totalJobs results for "$currentQuery"'
                    : 'Showing $totalJobs jobs',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: jobs.length + (jobProvider.hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < jobs.length) {
                    final job = jobs[index];
                    return _JobListItem(job: job);
                  } else {
                    jobProvider.fetchJobs(isLoadMore: true);
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
    }
  }

  Widget _buildHackathonResults(HProvider hackathonProvider) {
    final state = hackathonProvider.state;
    final hackathons = hackathonProvider.hackathons;
    final totalHackathons = hackathons.length;
    final currentQuery = hackathonProvider.currentQuery;

    switch (state) {
      case HackathonState.loading:
      case HackathonState.initial:
        return Center(
          child: Lottie.asset(
            'assets/animations/searching/searching_lottie.json',
            width: 250,
            height: 250,
            repeat: true,
            animate: true,
          ),
        );

      case HackathonState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
                  'Error fetching jobs: ${hackathonProvider.errorMessage}',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );

      case HackathonState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/empty/empty_lottie.json',
                  width: 200,
                  height: 200,
                  repeat: false,
                  animate: true,
                ),
                const SizedBox(height: 20),
                Text(
                  currentQuery != null && currentQuery.isNotEmpty
                      ? 'No results found for "$currentQuery".'
                      : 'No jobs are currently available.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );

      case HackathonState.loaded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(
                currentQuery != null && currentQuery.isNotEmpty
                    ? '$totalHackathons results for "$currentQuery"'
                    : 'Showing $totalHackathons hackathons',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: hackathons.length,
                itemBuilder: (context, index) {
                  final hackathon = hackathons[index];
                  return _HackathonListItem(hackathon: hackathon);
                },
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterSlug = _selectedSearchCategory.searchFilter;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SearchPageAppBar (Header)
            SearchPageAppBar(
              controller: _searchController,
              onSubmitted: _handleSearchSubmission,
            ),
            SizedBox(height: AppSpacing.md),
            // 2. Filter Group
            SearchFilterGroup(
              selectedFilter: _selectedSearchCategory,
              onFilterSelected: _handleCategorySelection,
            ),
            SizedBox(height: AppSpacing.sm),
            // 3. Search Results Section (Content)
            (filterSlug == 'jobs')
                ? Expanded(
                    child: Consumer<JProvider>(
                      builder: (context, jobProvider, child) {
                        return _buildJobResults(jobProvider);
                      },
                    ),
                  )
                : (filterSlug == 'hackathons')
                ? Expanded(
                    child: Consumer<HProvider>(
                      builder: (context, hackathonProvider, child) {
                        return _buildHackathonResults(hackathonProvider);
                      },
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: Text(
                        'Showing results for "${_selectedSearchCategory.label}" scope.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _JobListItem extends StatelessWidget {
  final Job job;
  const _JobListItem({required this.job});

  String _buildDescriptionSummary() {
    final location = job.mode;
    final type = '${job.jobType} (${job.employmentType})';
    final companyName = job.recruiter.company.name;
    return '$companyName • $location • $type';
  }

  void _handleTap(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Tapped on Job: ${job.title} - Mode: ${job.mode}'),
    //   ),
    // );

    final String tagLabel = (job.jobType == 'on-campus')
        ? 'On Campus'
        : job.jobType == 'external'
        ? 'External'
        : 'In House';

    if (kDebugMode) print(job.perks);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Carddetails(
          jobTitle: job.title,
          companyName: job.recruiter.company.name,
          location: job.preferences.location ?? job.mode,
          experienceLevel: ((job.preferences.minExperience ?? 0) > 0)
              ? '${job.preferences.minExperience}+ years'
              : 'Entry level',
          requirements: job.preferences.skills.isNotEmpty
              ? job.preferences.skills
              : ['Skills not specified'],
          websiteUrl: job.applicationLink ?? 'Apply via app',
          tagLabel: tagLabel,
          employmentType: job.employmentType,
          rolesAndResponsibilities:
              job.rolesAndResponsibilities ?? 'Not specified',
          duration: job.duration ?? 'Not specified',
          stipend: (job.stipend != null) ? "${job.stipend}" : "Not Specified",
          details: job.description,
          noOfOpenings: job.noOfOpenings.toString(),
          mode: job.mode.isNotEmpty ? job.mode : 'Not specified',
          skills: job.preferences.skills,
          id: job.id,
          jobType: job.jobType,
          about: job.recruiter.company.description ?? "Description Not found",
          salaryRange: "${job.salaryRange.max} - ${job.salaryRange.min}",
          perks: job.perks?.isNotEmpty == true
              ? job.perks!
                    .split(RegExp(r'[.,]')) // Split using regex for . or ,
                    .map((s) => s.trim()) // Remove leading/trailing whitespace
                    .where((s) => s.isNotEmpty)
                    .toList()
              : ['Not specified'],
          description:
              job.description, // Return a List of strings or ['Not specified']
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DataTile(
      title: job.title,
      description: _buildDescriptionSummary(),
      imageUrl: job.recruiter.company.logo,
      onTap: () => _handleTap(context),
    );
  }
}

class _HackathonListItem extends StatelessWidget {
  final Hackathon hackathon;
  const _HackathonListItem({required this.hackathon});

  // 1. Build a descriptive summary for the hackathon tile
  String _buildDescriptionSummary() {
    final organizer = hackathon.organizer;
    final location = hackathon.mode;
    return '$organizer • $location';
  }

  // 2. Handle the tap action
  void _handleTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HackathonDetailsScreen(
          title: hackathon.title,
          organizer: hackathon.organizer,
          description: hackathon.description,
          location: hackathon.location,
          startDate: hackathon.startDate,
          endDate: hackathon.endDate,
          registrationDeadline: hackathon.registrationDeadline,
          eligibility: hackathon.eligibility ?? "N/A",
          website: hackathon.website,
          createdAt: hackathon.startDate,
          updatedAt: hackathon.endDate,
        ),
      ),
    );
  }

  // 3. Build the actual widget using DataTile
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: DataTile(
        // Use the hackathon title
        title: hackathon.title,
        description: _buildDescriptionSummary(),
        imageUrl: null,
        onTap: () => _handleTap(context),
      ),
    );
  }
}
