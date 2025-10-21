import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:internappflutter/features/AvailableHackathons/presentation/provider/hackathon_provider.dart';
import 'package:internappflutter/home/cardDetails.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../common/components/search_page/data_tile.dart';
import '../../../common/components/search_page/search_filter_group.dart';
import '../../../common/components/search_page/search_page_app_bar.dart';
import 'package:internappflutter/common/constants/search_page/search_page_constants.dart';
import '../../AvailableHackathons/domain/entities/hackathon.dart';
import '../../AvailableJobs/domain/entities/job.dart';
import '../../AvailableJobs/presentation/provider/job_provider.dart';

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
    final hackathonProvider = context.read<HackathonProvider>();
    final filterSlug = _selectedSearchCategory.searchFilter;
    final query = isInitialLoad ? null : _currentSearchQuery;

    print('--- Executing Search ---');
    print('Scope: $filterSlug');
    print('Query: "$query"');

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
        return const Center(child: CircularProgressIndicator());

      case JobState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Error fetching jobs: ${jobProvider.errorMessage}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        );

      case JobState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              currentQuery != null && currentQuery.isNotEmpty
                  ? 'No results found for "$currentQuery".'
                  : 'No jobs are currently available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
        );

      case JobState.loaded:
      case JobState.loadingMore:
        // Success: Display list of jobs
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text(
                currentQuery != null && currentQuery.isNotEmpty
                    ? '$totalJobs results for "$currentQuery"'
                    : 'Showing $totalJobs jobs',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                        padding: EdgeInsets.all(16.0),
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

  Widget _buildHackathonResults(HackathonProvider hackathonProvider) {
    final state = hackathonProvider.state;
    final hackathons = hackathonProvider.hackathons;
    final totalHackathons = hackathons.length;
    final currentQuery = hackathonProvider.currentQuery;

    switch (state) {
      case HackathonState.loading:
      case HackathonState.initial:
        // 1. Loading State: Display a circular indicator
        return const Center(child: CircularProgressIndicator());

      case HackathonState.error:
        // 2. Error State: Display the error message
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Error fetching hackathons: ${hackathonProvider.errorMessage}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        );

      case HackathonState.empty:
        // 3. Empty State: Display a "No results" message based on the query
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              currentQuery != null && currentQuery.isNotEmpty
                  ? 'No results found for "$currentQuery". 🧐'
                  : 'No hackathons are currently scheduled.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
        );

      case HackathonState.loaded:
        // 4. Loaded State: Display the filtered list
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Show the result count and query
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text(
                currentQuery != null && currentQuery.isNotEmpty
                    ? '$totalHackathons results for "$currentQuery"'
                    : 'Showing $totalHackathons hackathons',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            // List View: Display the hackathon tiles
            Expanded(
              child: ListView.builder(
                // Assuming no 'load more' functionality yet, use list length directly
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SearchPageAppBar (Header)
            SearchPageAppBar(
              controller: _searchController,
              onSubmitted: _handleSearchSubmission,
            ),

            // 2. Filter Group
            SearchFilterGroup(
              selectedFilter: _selectedSearchCategory,
              onFilterSelected: _handleCategorySelection,
            ),

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
                    child: Consumer<HackathonProvider>(
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Carddetails(
          jobTitle: job.title,
          companyName: job.recruiter.company.name,
          location: job.preferences.location ?? job.mode,
          experienceLevel: job.preferences.minExperience?.toString() ?? 'N/A',
          requirements: job.preferences.skills,
          websiteUrl: job.applicationLink ?? "",
          tagLabel: job.perks,
          employmentType: job.employmentType,
          rolesAndResponsibilities: job.rolesAndResponsibilities ?? "N/A",
          duration: job.duration ?? "N/A",
          stipend: job.stipend?.toString() ?? 'N/A',
          details: job.description ?? "",
          noOfOpenings: job.noOfOpenings.toString(),
          mode: job.mode,
          skills: job.preferences.skills,
          id: job.id,
          jobType: job.jobType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: DataTile(
        title: job.title,
        description: _buildDescriptionSummary(),
        imageUrl: job.recruiter.company.logo,
        onTap: () => _handleTap(context),
      ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tapped on Hackathon: ${hackathon.title} - Organized by: ${hackathon.organizer}',
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
