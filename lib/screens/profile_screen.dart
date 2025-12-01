import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/features/core/design_systems/app_typography.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';
import 'package:internappflutter/features/core/design_systems/app_shapes.dart';
import 'package:internappflutter/screens/edit_profile_screen.dart';
import 'package:internappflutter/screens/resume_edit_screen.dart';
import 'package:internappflutter/skillVerify/SkillVerification.dart';
import 'package:internappflutter/skillVerify/TestStart.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreenPage extends StatefulWidget {
  const ProfileScreenPage({super.key});

  @override
  State<ProfileScreenPage> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenPage> {
  Map<String, dynamic>? userData;
  final User? user = FirebaseAuth.instance.currentUser;
  final String baseUrl = "https://hyrup-730899264601.asia-south1.run.app";

  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // Sign out from Google and Firebase
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      // Navigate to SignUpScreen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Page2()),
        (route) => false, // remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign out failed: $e")));
    }
  }

  Future<void> fetchStudentDetails() async {
    setState(() {
      isLoading = true; // ← Change from false to true
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not logged in";
          isLoading = false;
        });
        // Navigate back or to login screen
        Navigator.of(context).pushReplacementNamed('/signup');
        return;
      }

      String uid = user.uid;
      String? idToken = await user.getIdToken();

      if (idToken == null) {
        setState(() {
          errorMessage = "Could not get authentication token";
          isLoading = false;
        });
        return;
      }

      print("🔄 Fetching user details...");

      final response = await http.post(
        Uri.parse('$baseUrl/student/StudentDetails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({'studentId': uid}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data['user'];
          isLoading = false;
        });
        print("✅ Fetched user details: $userData");
      } else {
        setState(() {
          errorMessage =
              'Failed to load Student details: ${response.statusCode}';
          isLoading = false;
        });
        print("❌ Failed to load Student details: ${response.statusCode}");
        // Show a snackbar instead
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load profile. Please try again.'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: fetchStudentDetails,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
      print("❌ Error fetching Student details: ${e.toString()}");
      // Show a snackbar for errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: fetchStudentDetails,
            ),
          ),
        );
      }
    }
  }

  // ONLY REPLACE THE BUILD METHOD AND RELATED PARTS

  @override
  Widget build(BuildContext context) {
    if (isLoading || userData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE9E4F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = userData!['profile'] ?? {};
    final fullName = profile['FullName'] ?? 'No Name';
    final profilePic = profile['profilePicture'] ?? '';
    final bio = profile['bio'] ?? '';
    final phone = userData!['phone'] ?? 'N/A';
    final email = user?.email ?? 'N/A';
    final education = userData!['education'] ?? {};
    final resume = profile['resume'] ?? '';
    final resumeName = profile['resumeName'] ?? '';
    final collegeEmail = education['collegeEmail'] ?? '';

    // ✅✅✅ CORRECT WAY TO HANDLE MAP
    final rawSkills = userData!['user_skills'];
    List<MapEntry<String, dynamic>> skillsList = [];

    if (rawSkills is Map<String, dynamic>) {
      // Backend sends Map: {"React.js": {"level": "intermediate"}}
      skillsList = rawSkills.entries.toList();
    } else if (rawSkills != null) {
      print("⚠️ user_skills is not a Map: ${rawSkills.runtimeType}");
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image section
          Container(
            height: 450,
            width: double.infinity,
            color: Colors.black,
            child: profilePic.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: profilePic,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: Colors.red, size: 100),
                  )
                : const Icon(Icons.person, size: 100, color: Colors.white),
          ),

          // Draggable sheet with all content
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF2EAFF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  border: Border(
                    top: BorderSide(color: AppColors.borderSoft, width: 1.5),
                    left: BorderSide(color: AppColors.borderSoft, width: 1.5),
                    right: BorderSide(color: AppColors.borderSoft, width: 1.5),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Name and Resume button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              fullName,
                              style: AppTypography.headingLg.copyWith(
                                fontSize: 28,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  ResumeEditPopupUtils.showResumeEditPopup(
                                    context,
                                    resumelink: resumeName,
                                    resume: resume,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentLime,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppShapes.card,
                                  ),
                                ),
                                child: Text(
                                  'Resume',
                                  style: AppTypography.chip.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Contact info
                      Text(
                        phone,
                        style: AppTypography.bodySm.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        email,
                        style: AppTypography.bodySm.copyWith(fontSize: 16),
                      ),

                      // Bio section
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Bio',
                        style: AppTypography.jobTitle.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        bio,
                        style: AppTypography.bodySm.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        'College Details',
                        style: AppTypography.jobTitle.copyWith(
                          fontSize: 30,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Education section
                      _buildInputField(
                        'College Name',
                        education['college'] ?? '',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildInputField(
                        'University',
                        education['universityType'] ?? '',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildInputField('Degree', education['degree'] ?? ''),
                      const SizedBox(height: AppSpacing.lg),
                      _buildInputField('College Email ID', collegeEmail),
                      const SizedBox(height: AppSpacing.lg),
                      _buildInputField(
                        'Year of Graduation',
                        education['yearOfPassing']?.toString() ?? '',
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Skills section
                      if (skillsList.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Skills',
                              style: AppTypography.jobTitle.copyWith(
                                fontSize: 26,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Map<String, dynamic> skillsMap =
                                    Map.fromEntries(skillsList);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SkillVerification(
                                      userSkills: skillsMap,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentLime,
                                foregroundColor: AppColors.textPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppShapes.pill,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Verify Skills",
                                style: AppTypography.chip.copyWith(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.lg,
                          runSpacing: AppSpacing.lg,
                          children: skillsList.map<Widget>((entry) {
                            String skillName = entry.key;
                            String level = 'unverified';

                            if (entry.value is Map) {
                              level = (entry.value['level'] ?? 'unverified')
                                  .toString()
                                  .toLowerCase();
                            } else if (entry.value is String) {
                              level = entry.value.toLowerCase();
                            }

                            return _buildSkillChip(skillName, level);
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // Job Preference section
                      _buildJobPreferenceSection(),
                      const SizedBox(height: AppSpacing.xl),

                      // Experience section
                      _buildExperienceSection(),
                      const SizedBox(height: AppSpacing.xl),

                      // Projects section
                      _buildProjectsSection(),
                      const SizedBox(height: AppSpacing.xl),

                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            _signOut(context);
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: Text(
                            'Logout',
                            style: AppTypography.chip.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppShapes.card,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Edit button
          Positioned(
            top: 40,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentLime,
                borderRadius: AppShapes.pill,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    fetchStudentDetails();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.chip.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.card,
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
            borderRadius: AppShapes.card,
            border: const Border(
              top: BorderSide(color: AppColors.borderStrong, width: 1),
              left: BorderSide(color: AppColors.borderStrong, width: 1),
              right: BorderSide(color: AppColors.borderStrong, width: 2),
              bottom: BorderSide(color: AppColors.borderStrong, width: 2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill, String level) {
    Color chipColor;
    switch (level.toLowerCase()) {
      case 'beginner':
        chipColor = const Color(0xFFFDD34F);
        break;
      case 'intermediate':
        chipColor = const Color(0xFF96E7E5);
        break;
      case 'advanced':
      case 'advance':
        chipColor = const Color(0xFF40FFB9);
        break;
      case 'unverified':
      default:
        chipColor = const Color.fromARGB(255, 255, 244, 244);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: chipColor,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSharp,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        borderRadius: AppShapes.card,
        border: const Border(
          top: BorderSide(color: AppColors.borderStrong, width: 1),
          left: BorderSide(color: AppColors.borderStrong, width: 1),
          right: BorderSide(color: AppColors.borderStrong, width: 2),
          bottom: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: AppTypography.chip.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (level.toLowerCase() != 'unverified')
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: AppShapes.pill,
              ),
              child: Text(
                level.toUpperCase()[0],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobPreferenceSection() {
    final jobPreferences = userData?['job_preference'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Preference',
          style: AppTypography.jobTitle.copyWith(fontSize: 26),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: jobPreferences
              .map<Widget>((job) => _buildJobChipWithShadow(job.toString()))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildJobChipWithShadow(String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
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
        borderRadius: AppShapes.pill,
        border: Border.all(color: AppColors.borderStrong, width: 1),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: AppTypography.chip.copyWith(
          fontSize: 15,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    final experiences = userData?['experience'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience',
          style: AppTypography.jobTitle.copyWith(fontSize: 26),
        ),
        const SizedBox(height: AppSpacing.md),
        ...experiences.map((exp) {
          final org = exp['nameOfOrg'] ?? '';
          final position = exp['position'] ?? '';
          final timeline = exp['timeline'] ?? '';
          final description = exp['description'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _buildExperienceCard(org, position, timeline, description),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProjectsSection() {
    final projects = userData?['projects'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Projects', style: AppTypography.jobTitle.copyWith(fontSize: 26)),
        const SizedBox(height: AppSpacing.md),
        ...projects.map((proj) {
          final name = proj['projectName'] ?? '';
          final description = proj['description'] ?? '';
          final link = proj['link'] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildProjectCard(
              name: name,
              description: description,
              link: link,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExperienceCard(
    String org,
    String position,
    String timeline,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name of Organization', org),
          _buildDetailRow('Position', position),
          _buildDetailRow('Timeline', timeline),
          _buildDetailRow('Description', description),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String name,
    required String description,
    String? link,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Name of Project: $name',
                  style: AppTypography.chip.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (link != null && link.isNotEmpty)
                ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(link);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      print('Could not launch $link');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.card,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.card),
                  ),
                  child: Text(
                    'LINK',
                    style: AppTypography.chip.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Description: $description',
            style: AppTypography.bodySm.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text.rich(
        TextSpan(
          text: '$label : ',
          style: AppTypography.chip.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          children: [
            TextSpan(
              text: value,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.normal,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeFileItem(String fileName, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: isSelected
                ? Icon(Icons.check, size: 20, color: Colors.blue[700])
                : null,
          ),
          const SizedBox(width: 12),

          // File name
          Text(fileName, style: const TextStyle(fontSize: 16)),

          const Spacer(),

          // More options icon
          Icon(Icons.more_vert, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Widget _buildAIResumeBuilderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Resume Builder',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  Widget _buildToolSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tool',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        _buildToolItem('Manage the qualifications | Manage the qualifications'),
        const SizedBox(height: 8),
        _buildToolItem('Manage the qualifications | Manage the qualifications'),
      ],
    );
  }

  Widget _buildToolItem(String text) {
    return Text(text, style: const TextStyle(fontSize: 16));
  }

  void _showResumeDialog(BuildContext context) {
    final profile = userData!['profile'] ?? {};
    final resumeName = profile['resumeName'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resume'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResumeFileItem(resumeName, true),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Click to Upload or drag and drop',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '(Max. File size: 1.2 MB)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PDF | DOCX | > 3 MB',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI Resume Builder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
