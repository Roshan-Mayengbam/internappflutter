import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internappflutter/chat/chatscreen.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/features/core/design_systems/app_typography.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';
import 'package:internappflutter/features/core/design_systems/app_shapes.dart';
import 'package:url_launcher/url_launcher.dart';

class Carddetails extends StatefulWidget {
  final String jobTitle;
  final String companyName;
  final String about;
  final String location;
  final String experienceLevel;
  final List<String> requirements;
  final String websiteUrl;
  final String? tagLabel;
  final String employmentType;
  final String rolesAndResponsibilities;
  final String duration;
  final String stipend;
  final String details;
  final String description;
  final String noOfOpenings;
  final List<String> perks;
  final String mode;
  final List skills;
  final String id;
  final String jobType;
  final Map<String, dynamic>? recruiter;
  final String salaryRange;

  const Carddetails({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.about,
    required this.location,
    required this.experienceLevel,
    required this.requirements,
    required this.websiteUrl,
    required this.tagLabel,
    required this.employmentType,
    required this.rolesAndResponsibilities,
    required this.duration,
    required this.stipend,
    required this.details,
    required this.noOfOpenings,
    required this.mode,
    required this.skills,
    required this.id,
    required this.jobType,
    this.recruiter,
    required this.salaryRange,
    required this.perks,
    required this.description,
  });

  @override
  State<Carddetails> createState() => _CarddetailsState();
}

class _CarddetailsState extends State<Carddetails> {
  IconData icon = Icons.arrow_back;
  String _errorMessage = '';
  bool _isApplied = false;
  bool _isLoading = false;
  static const String baseUrl =
      'https://hyrup-730899264601.asia-south1.run.app';
  String get recruiterFirebaseId => widget.recruiter?['firebaseId'] ?? '';
  String get recruiterName => widget.recruiter?['name'] ?? 'Unknown Recruiter';

  String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String get _formattedStipendK {
    final sr = widget.salaryRange;
    if (sr.trim().isEmpty) return sr;

    // Find numeric values (allow commas and decimals)
    final matches = RegExp(r'[\d,]+(?:\.\d+)?').allMatches(sr);
    if (matches.isEmpty) return sr;

    List<String> parts = matches.map((m) => m.group(0)!).toList();
    List<String> formatted = [];

    for (var p in parts.take(2)) {
      final clean = p.replaceAll(',', '');
      final double? amount = double.tryParse(clean);
      if (amount == null) {
        formatted.add(p);
        continue;
      }
      final double k = amount / 1000.0;
      final String kStr = k % 1 == 0
          ? k.toStringAsFixed(0)
          : k.toStringAsFixed(1);
      formatted.add('₹${kStr}k');
    }

    return formatted.length == 1 ? formatted.first : formatted.join(' - ');
  }

  Future<void> applyJob(String jobId, String jobType) async {
    if (kDebugMode) print("🔄 Starting job application...");
    if (kDebugMode) print("📋 Job ID: $jobId");
    if (kDebugMode) print("🏢 Job Type: $jobType");

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "User not logged in";
        });
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        setState(() {
          _errorMessage = "Could not get authentication token";
        });
        return;
      }

      final url = '$baseUrl/student/jobs/$jobId/$jobType/apply';
      if (kDebugMode) print("🌐 API URL: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({}),
      );

      if (kDebugMode) print("📡 Response Status: ${response.statusCode}");
      if (kDebugMode) print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) print("✅ Application submitted successfully");
        setState(() {
          _errorMessage = '';
          _isApplied = true;
        });
      } else {
        if (kDebugMode) {
          print("❌ Application failed with status: ${response.statusCode}");
        }
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage =
              errorData['message'] ?? "Failed to apply: ${response.statusCode}";
        });
      }
    } catch (e) {
      if (kDebugMode) print("⚠️ Exception occurred: $e");
      setState(() {
        _errorMessage = "Error applying to job: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.card,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowSharp,
                  offset: Offset(0, 5),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: AppColors.shadowSharp,
                  offset: Offset(5, 0),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: AppColors.shadowSharp,
                  offset: Offset(5, 5),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
              ],
              color: AppColors.card,
              borderRadius: AppShapes.pill,
              border: Border.all(color: AppColors.borderStrong, width: 2),
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: AppColors.textPrimary,
                    thickness: 1,
                    height: AppSpacing.xl,
                  ),
                  // Company Name with Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.companyName.isNotEmpty
                              ? widget.companyName
                              : 'Company',
                          style: AppTypography.headingLg,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      _buildTag(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(widget.jobTitle, style: AppTypography.jobTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(widget.location, style: AppTypography.bodySm),
                  const SizedBox(height: AppSpacing.lg),

                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentLime.withOpacity(0.2),
                          borderRadius: AppShapes.pill,
                          border: Border.all(color: AppColors.accentLime),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.accentLime,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'On site',
                              style: AppTypography.chip.copyWith(
                                color: AppColors.accentLime,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentLime.withOpacity(0.2),
                          borderRadius: AppShapes.pill,
                          border: Border.all(color: AppColors.accentLime),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.accentLime,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Full Time',
                              style: AppTypography.chip.copyWith(
                                color: AppColors.accentLime,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      widget.tagLabel == 'In House'
                          ? Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowSharp,
                                    offset: Offset(0, 5),
                                    blurRadius: 0,
                                    spreadRadius: -2,
                                  ),
                                  BoxShadow(
                                    color: AppColors.shadowSharp,
                                    offset: Offset(5, 0),
                                    blurRadius: 0,
                                    spreadRadius: -2,
                                  ),
                                  BoxShadow(
                                    color: AppColors.shadowSharp,
                                    offset: Offset(5, 5),
                                    blurRadius: 0,
                                    spreadRadius: -2,
                                  ),
                                ],
                                color: AppColors.card,
                                borderRadius: AppShapes.pill,
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.borderStrong,
                                    width: 1,
                                  ),
                                  left: BorderSide(
                                    color: AppColors.borderStrong,
                                    width: 1,
                                  ),
                                  right: BorderSide(
                                    color: AppColors.borderStrong,
                                    width: 2,
                                  ),
                                  bottom: BorderSide(
                                    color: AppColors.borderStrong,
                                    width: 2,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: InkWell(
                                onTap: () {
                                  if (kDebugMode) {
                                    print('🔍 Current User ID: $currentUserId');
                                  }
                                  if (kDebugMode) {
                                    print(
                                      'Recruiter Firebase ID: $recruiterFirebaseId',
                                    );
                                  }
                                  if (kDebugMode) {
                                    print('🔍 Recruiter Name: $recruiterName');
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        currentUserId: currentUserId,
                                        otherUserId: recruiterFirebaseId,
                                        otherUserName: widget.companyName,
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.comment,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowSharp,
                                offset: Offset(0, 6),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: AppColors.shadowSharp,
                                offset: Offset(6, 0),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: AppColors.shadowSharp,
                                offset: Offset(6, 6),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                            ],
                            color: AppColors.card,
                            borderRadius: AppShapes.pill,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.borderStrong,
                                width: 1,
                              ),
                              left: BorderSide(
                                color: AppColors.borderStrong,
                                width: 1,
                              ),
                              right: BorderSide(
                                color: AppColors.borderStrong,
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: AppColors.borderStrong,
                                width: 2,
                              ),
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _isApplied || _isLoading
                                ? null
                                : () async {
                                    if (kDebugMode) {
                                      print("Tag Label: ${widget.tagLabel}");
                                    }
                                    if (kDebugMode) {
                                      print("Job Type: ${widget.jobType}");
                                    }
                                    if (kDebugMode) {
                                      print(
                                        "Website URL: ${widget.websiteUrl}",
                                      );
                                    }

                                    // Check if it's on-campus or external - open in browser
                                    if (widget.jobType == 'on-campus' ||
                                        widget.jobType == 'external') {
                                      if (widget.websiteUrl.isNotEmpty &&
                                          widget.websiteUrl !=
                                              'Apply via app' &&
                                          widget.websiteUrl != 'N/A') {
                                        try {
                                          String url = widget.websiteUrl;

                                          // Add https:// if not present
                                          if (!url.startsWith('http://') &&
                                              !url.startsWith('https://')) {
                                            url = 'https://$url';
                                          }

                                          if (kDebugMode) {
                                            print("Final URL: $url");
                                          }

                                          final Uri uri = Uri.parse(url);

                                          // Try to launch the URL
                                          bool launched = await launchUrl(
                                            uri,
                                            mode: LaunchMode.inAppWebView,
                                          );

                                          if (!launched) {
                                            // If in-app doesn't work, try external browser
                                            launched = await launchUrl(
                                              uri,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }

                                          if (!launched) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Could not open: $url',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (kDebugMode) {
                                            print("Error launching URL: $e");
                                          }
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Invalid URL: ${widget.websiteUrl}',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No application link available for this job',
                                            ),
                                            backgroundColor: Colors.orange,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                    // In House jobs - use API
                                    else if (widget.tagLabel?.trim() ==
                                        'In House') {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      await applyJob(widget.id, 'company');

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (_errorMessage.isEmpty && _isApplied) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: AppShapes.card,
                                              side: const BorderSide(
                                                color: AppColors.borderStrong,
                                                width: 2,
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: AppColors.accentLime,
                                                  size: 30,
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.md,
                                                ),
                                                const Text('Success!'),
                                              ],
                                            ),
                                            content: const Text(
                                              'Your application has been submitted successfully!',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            actions: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.accentLime,
                                                  borderRadius: AppShapes.pill,
                                                  border: Border.all(
                                                    color:
                                                        AppColors.borderStrong,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'OK',
                                                    style: AppTypography.chip
                                                        .copyWith(
                                                          color: AppColors
                                                              .textPrimary,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (_errorMessage.isNotEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: AppShapes.card,
                                              side: const BorderSide(
                                                color: AppColors.borderStrong,
                                                width: 2,
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                const Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                  size: 30,
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.md,
                                                ),
                                                const Text('Error'),
                                              ],
                                            ),
                                            content: Text(
                                              _errorMessage,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            actions: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red[300],
                                                  borderRadius: AppShapes.pill,
                                                  border: Border.all(
                                                    color:
                                                        AppColors.borderStrong,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'OK',
                                                    style: AppTypography.chip
                                                        .copyWith(
                                                          color: AppColors
                                                              .textPrimary,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isApplied
                                  ? AppColors.borderSoft
                                  : AppColors.accentLime,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppShapes.pill,
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _isApplied ? 'Applied' : 'Apply Now',
                                    style: AppTypography.chip.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildOpeningsCard(),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // About the job Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About the job', style: AppTypography.jobTitle),
                  const SizedBox(height: AppSpacing.lg),

                  // Job Details Grid
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: AppShapes.card,
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Job Type',
                                widget.employmentType,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildInfoCard(
                                'Duration',
                                '${widget.duration} months',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard('Mode', widget.mode),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildInfoCard(
                                'Stipend',
                                _formattedStipendK,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Skills Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderSoft),
                            borderRadius: AppShapes.card,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Skills:', style: AppTypography.jobTitle),
                              const SizedBox(height: AppSpacing.md),
                              widget.skills.isNotEmpty
                                  ? Wrap(
                                      spacing: AppSpacing.sm,
                                      runSpacing: AppSpacing.sm,
                                      children: widget.skills
                                          .map(
                                            (skill) => _buildSkillChip(
                                              skill.toString(),
                                            ),
                                          )
                                          .toList(),
                                    )
                                  : Text(
                                      'No skills specified',
                                      style: AppTypography.bodySm,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Roles and Responsibility
                  Text(
                    'Roles and Responsibility:',
                    style: AppTypography.jobTitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDescriptionCard(widget.rolesAndResponsibilities),

                  const SizedBox(height: AppSpacing.xl),

                  // Perks
                  Text('Perks:', style: AppTypography.jobTitle),

                  const SizedBox(height: AppSpacing.md),
                  for (var perk in widget.perks) ...[
                    _buildPerkButton(perk),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Details
                  Text('Details :', style: AppTypography.jobTitle),
                  const SizedBox(height: AppSpacing.md),
                  _buildDescriptionCard(widget.description),

                  const SizedBox(height: AppSpacing.xl),

                  // About Company
                  // Text('About:', style: AppTypography.jobTitle),
                  // const SizedBox(height: AppSpacing.md),
                  // _buildDescriptionCard(widget.about),

                  // const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: AppColors.card,
        borderRadius: AppShapes.pill,
        border: const Border(
          top: BorderSide(color: AppColors.borderStrong, width: 1),
          left: BorderSide(color: AppColors.borderStrong, width: 1),
          right: BorderSide(color: AppColors.borderStrong, width: 2),
          bottom: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('No. of', style: AppTypography.bodySm),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.noOfOpenings, style: AppTypography.jobTitle),
          const SizedBox(height: AppSpacing.xs),
          Text('Openings', style: AppTypography.bodySm),
        ],
      ),
    );
  }

  Widget _buildTag() {
    String imagePath;
    if (widget.tagLabel == 'On Campus') {
      imagePath = 'assets/campus.png';
    } else if (widget.tagLabel == 'In House') {
      imagePath = 'assets/inhouse.png';
    } else {
      imagePath = 'assets/outreach.png';
    }

    return Image.asset(imagePath, height: 50, width: 150, fit: BoxFit.contain);
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: AppColors.card,
        borderRadius: AppShapes.pill,
        border: const Border(
          top: BorderSide(color: AppColors.borderStrong, width: 1),
          left: BorderSide(color: AppColors.borderStrong, width: 1),
          right: BorderSide(color: AppColors.borderStrong, width: 2),
          bottom: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.chip,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.jobTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: AppColors.card,
        borderRadius: AppShapes.pill,
        border: const Border(
          top: BorderSide(color: AppColors.borderStrong, width: 1),
          left: BorderSide(color: AppColors.borderStrong, width: 1),
          right: BorderSide(color: AppColors.borderStrong, width: 2),
          bottom: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
      ),
      child: Text(
        skill,
        style: AppTypography.chip.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildPerkButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: AppColors.card,
        borderRadius: AppShapes.pill,
        border: const Border(
          top: BorderSide(color: AppColors.borderStrong, width: 1),
          left: BorderSide(color: AppColors.borderStrong, width: 1),
          right: BorderSide(color: AppColors.borderStrong, width: 2),
          bottom: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
      ),
      child: Text(
        text,
        style: AppTypography.chip.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: AppColors.card,
        borderRadius: AppShapes.card,
        border: const Border(
          top: BorderSide(color: AppColors.borderStrong, width: 1),
          left: BorderSide(color: AppColors.borderStrong, width: 1),
          right: BorderSide(color: AppColors.borderStrong, width: 2),
          bottom: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
      ),
      child: Text(
        description,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}
