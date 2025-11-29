import 'package:flutter/material.dart';
import 'package:internappflutter/home/cardDetails.dart';

class JobCard extends StatefulWidget {
  final String id;
  final String jobTitle;
  final String companyName;
  final String about; // ✅ Add this parameter
  final String location;
  final String experienceLevel;
  final List<String> requirements;
  final String websiteUrl;
  final int initialColorIndex;
  final String? tagLabel;
  final Color? tagColor;
  final List<String> skills;
  final String employmentType;
  final String rolesAndResponsibilities;
  final String duration;
  final String stipend;
  final String salaryRange;
  final List<String> perks;
  final String details;
  final String noOfOpenings;
  final String mode;
  final String jobType;
  final Map<String, dynamic>? recruiter;

  const JobCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.about, // ✅ Add this
    required this.location,
    required this.experienceLevel,
    required this.requirements,
    required this.websiteUrl,
    required this.initialColorIndex,
    this.tagLabel,
    this.tagColor,
    required this.skills,
    required this.employmentType,
    required this.rolesAndResponsibilities,
    required this.duration,
    required this.stipend,
    required this.details,
    required this.noOfOpenings,
    required this.mode,
    required this.id,
    required this.jobType,
    this.recruiter,
    required this.salaryRange,
    required this.perks,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late int colorIndex;
  bool isFavorite = false;
  bool _showAllRequirements = false;

  @override
  void initState() {
    super.initState();
  }

  void swapColours() {
    setState(() {});
  }

  void toggleFavourite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = screenWidth * 0.03;
    final borderRadius = screenWidth * 0.05;

    return RepaintBoundary(
      // Wrap entire card
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Card(
              elevation: 0,
              shadowColor: Colors.transparent,
              color: const Color.fromRGBO(230, 211, 252, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border(
                    top: BorderSide(
                      color: Colors.black,
                      width: screenWidth * 0.005,
                    ),
                    left: BorderSide(
                      color: Colors.black,
                      width: screenWidth * 0.005,
                    ),
                    right: BorderSide(
                      color: Colors.black,
                      width: screenWidth * 0.012,
                    ),
                    bottom: BorderSide(
                      color: Colors.black,
                      width: screenWidth * 0.01,
                    ),
                  ),
                ),
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPosterCard(screenWidth, screenHeight),
                    SizedBox(height: screenHeight * 0.015),
                    _buildJobTitleSection(screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    _buildInfoSection(screenWidth),
                  ],
                ),
              ),
            ),
            if (widget.tagLabel != null) _buildTag(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(double screenWidth) {
    String imagePath;
    if (widget.tagLabel == 'On Campus') {
      imagePath = 'assets/campus.png';
    } else if (widget.tagLabel == 'In House') {
      imagePath = 'assets/inhouse.png';
    } else {
      imagePath = 'assets/outreach.png';
    }

    return Positioned(
      top: screenWidth * 0.03,
      right: screenWidth * 0.03,
      child: Image.asset(
        imagePath,
        height: screenWidth * 0.12,
        width: screenWidth * 0.35,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPosterCard(double screenWidth, double screenHeight) {
    return RepaintBoundary(
      // Isolate repaints
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Carddetails(
                jobTitle: widget.jobTitle,
                companyName: widget.companyName,
                about: widget.about,
                location: widget.location,
                experienceLevel: widget.experienceLevel,
                requirements: widget.requirements,
                websiteUrl: widget.websiteUrl,
                tagLabel: widget.tagLabel,
                employmentType: widget.employmentType,
                rolesAndResponsibilities: widget.rolesAndResponsibilities,
                duration: widget.duration,
                stipend: widget.stipend,
                details: widget.details,
                noOfOpenings: widget.noOfOpenings,
                mode: widget.mode,
                skills: widget.skills,
                id: widget.id,
                jobType: widget.jobType,
                recruiter: widget.recruiter,
                salaryRange: widget.salaryRange,
                perks: [...widget.perks],
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: const Color(0xFF4B20C2),
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHiringTag(screenWidth),
              SizedBox(height: screenHeight * 0.015),
              Text(
                widget.jobTitle,
                style: TextStyle(
                  color: const Color(0xFFF9A825),
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.015),
              // Use Column instead of ConstrainedBox + SingleChildScrollView
              // for better performance when showing only 3 items
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.requirements
                      .take(3)
                      .map((req) => _buildRequirementRow(req, screenWidth)),

                  if (widget.requirements.length > 3)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Carddetails(
                              jobTitle: widget.jobTitle,
                              companyName: widget.companyName,
                              about: widget.about,
                              location: widget.location,
                              experienceLevel: widget.experienceLevel,
                              requirements: widget.requirements,
                              websiteUrl: widget.websiteUrl,
                              tagLabel: widget.tagLabel,
                              employmentType: widget.employmentType,
                              rolesAndResponsibilities:
                                  widget.rolesAndResponsibilities,
                              duration: widget.duration,
                              stipend: widget.stipend,
                              details: widget.details,
                              noOfOpenings: widget.noOfOpenings,
                              mode: widget.mode,
                              skills: widget.skills,
                              id: widget.id,
                              jobType: widget.jobType,
                              recruiter: widget.recruiter,
                              salaryRange: widget.salaryRange,
                              perks: [...widget.perks],
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 0.0),
                        child: Text(
                          'Show more...',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildWebsiteButton(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHiringTag(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Text(
        'WE ARE HIRING!',
        style: TextStyle(
          color: const Color(0xFF4B20C2),
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.025,
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.035,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteButton(double screenWidth) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.075),
        ),
        child: Text(
          widget.websiteUrl,
          style: TextStyle(
            color: const Color(0xFF4B20C2),
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.032,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildJobTitleSection(double screenWidth) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jobTitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.companyName,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: screenWidth * 0.045,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.03),
        const Divider(
          color: Color.fromARGB(255, 19, 16, 16),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildInfoSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.grey,
              size: screenWidth * 0.05,
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Text(
                widget.location,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: screenWidth * 0.035,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Icon(
              Icons.people_alt,
              color: Colors.grey,
              size: screenWidth * 0.05,
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Text(
                widget.experienceLevel,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: screenWidth * 0.035,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const arrowHeight = 10.0;
    const arrowWidth = 15.0;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(arrowWidth, size.height);
    path.lineTo(0, size.height - arrowHeight);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
