import 'package:flutter/material.dart';
import 'package:internappflutter/common/components/custom_button.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/features/core/design_systems/app_typography.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';
import 'package:internappflutter/features/core/design_systems/app_shapes.dart';
import 'package:internappflutter/skillVerify/TestStart.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class SkillVerification extends StatefulWidget {
  final Map<String, dynamic> userSkills;
  const SkillVerification({super.key, required this.userSkills});

  @override
  State<SkillVerification> createState() => _SkillVerificationState();
}

class _SkillVerificationState extends State<SkillVerification> {
  // TODO: Remove this flag once the feature is complete and ready for production.
  final bool _isComingSoon = true; // New boolean flag, false by default
  String? selectedSkill;
  String? selectedSkillLevel;

  @override
  Widget build(BuildContext context) {
    // TODO : Remove this after feature is complete.
    if (_isComingSoon) {
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  left: AppSpacing.xl,
                ),
                child: CustomButton(
                  buttonIcon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/coming_soon/coming_soon_lottie.json',
                    repeat: false,
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Skill Verification Coming Soon!',
                    style: AppTypography.headingLg.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'We\'re working hard to bring this feature to you.',
                    style: AppTypography.bodySm.copyWith(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // --- Normal content starts here (when _isComingSoon is false) ---

    // Extract skills from the userSkills map with their levels
    Map<String, String> skillsWithLevels = {};

    if (widget.userSkills.containsKey('skills')) {
      // If skills is a map with skill names as keys
      if (widget.userSkills['skills'] is Map) {
        final skillsMap = widget.userSkills['skills'] as Map;
        skillsMap.forEach((key, value) {
          String level = 'unverified';
          if (value is Map && value.containsKey('level')) {
            level = value['level'].toString();
          }
          skillsWithLevels[key.toString()] = level;
        });
      }
    }
    // If skills are at the root level of userSkills map
    else {
      widget.userSkills.forEach((key, value) {
        String level = 'unverified';
        if (value is Map && value.containsKey('level')) {
          level = value['level'].toString();
        }
        skillsWithLevels[key.toString()] = level;
      });
    }

    List<String> skills = skillsWithLevels.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md * 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  CustomButton(
                    buttonIcon: Icons.arrow_back,
                    onPressed: Navigator.of(context).pop,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      'Flex your skills',
                      style: AppTypography.headingLg.copyWith(fontSize: 28),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Description
              Text(
                "'Short & snappy quiz. Nail it and unlock shiny badges recruiters can't ignore.",
                style: AppTypography.bodySm.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                'Pick your power skill 💡',
                style: AppTypography.jobTitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Instructions
              Text(
                '"Choose one of your skills to test first. You can always come back for more."',
                style: AppTypography.bodySm.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Skills Grid
              skills.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl,
                        ),
                        child: Text(
                          'No skills available',
                          style: AppTypography.bodySm,
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: AppSpacing.lg,
                          ),
                      itemCount: skills.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return SkillButton(
                          text: skills[index],
                          isSelected: selectedSkill == skills[index],
                          onTap: () {
                            setState(() {
                              selectedSkill = skills[index];
                              selectedSkillLevel =
                                  skillsWithLevels[skills[index]];
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestStart(
                                  selectedSkill: skills[index],
                                  UserSkillLevel:
                                      skillsWithLevels[skills[index]]!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
              const SizedBox(height: AppSpacing.xl),

              // Next Button
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderStrong, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowSharp,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                  ],
                  borderRadius: AppShapes.card,
                ),
                child: ElevatedButton(
                  onPressed: selectedSkill == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestStart(
                                selectedSkill: selectedSkill!,
                                UserSkillLevel: selectedSkillLevel!,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: AppColors.borderSoft,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppShapes.card),
                  ),
                  child: Text(
                    'Next',
                    style: AppTypography.chip.copyWith(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkillButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SkillButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLime : AppColors.primarySurface,
          borderRadius: AppShapes.card,
          border: Border.all(color: AppColors.borderStrong, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSharp,
              offset: Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.chip.copyWith(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
