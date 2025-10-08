import 'package:flutter/material.dart';
import 'package:internappflutter/home/cardDetails.dart';

class JobCard extends StatefulWidget {
  final String id;
  final String jobTitle;
  final String companyName;
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
  final String details;
  final String noOfOpenings;
  final String mode;
  final String jobType;

  const JobCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
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
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late int colorIndex;
  bool isFavorite = false;

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
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 🔹 Remove the shadow card completely OR keep it invisible if needed
          // (removed the Positioned black card)

          // Main card (kept same border and layout)
          Card(
            elevation: 0,
            shadowColor: Colors.transparent,
            color: const Color.fromRGBO(230, 211, 252, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: const Border(
                  top: BorderSide(
                    color: Colors.black,
                    width: 2, // slightly thinner top
                  ),
                  left: BorderSide(
                    color: Colors.black,
                    width: 2, // slightly thinner left
                  ),
                  right: BorderSide(
                    color: Colors.black,
                    width: 5, // thicker right
                  ),
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 4, // thicker bottom
                  ),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPosterCard(),
                  const SizedBox(height: 12),
                  _buildJobTitleSection(),
                  const SizedBox(height: 12),
                  _buildInfoSection(),
                ],
              ),
            ),
          ),

          // Keep your tag on top if present
          if (widget.tagLabel != null) _buildTag(),
        ],
      ),
    );
  }

  Widget _buildTag() {
    // Determine which image to show based on tagLabel
    String imagePath;
    if (widget.tagLabel == 'On Campus') {
      print(widget.tagLabel!);
      imagePath = 'assets/campus.png';
    } else if (widget.tagLabel == 'In House') {
      print(widget.tagLabel!);
      imagePath = 'assets/inhouse.png';
    } else {
      print(widget.tagLabel!);
      imagePath = 'assets/outreach.png'; // for external or any other type
    }

    return Positioned(
      top: 12,
      right: 12,
      child: Image.asset(
        imagePath,
        height: 50,
        width: 150,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPosterCard() {
    return InkWell(
      onTap: () {
        print("---- Navigating to Carddetails ----");
        print("Job Title: ${widget.jobTitle}");
        print("Company Name: ${widget.companyName}");
        print("Location: ${widget.location}");
        print("Experience Level: ${widget.experienceLevel}");
        print("Requirements: ${widget.requirements}");
        print("Website URL: ${widget.websiteUrl}");
        print("Tag Label: ${widget.tagLabel}");
        print("Employment Type: ${widget.employmentType}");
        print("Roles & Responsibilities: ${widget.rolesAndResponsibilities}");
        print("Duration: ${widget.duration}");
        print("Stipend: ${widget.stipend}");
        print("Details: ${widget.details}");
        print("No. of Openings: ${widget.noOfOpenings}");
        print("Mode: ${widget.mode}");
        print("Skills: ${widget.skills}");
        print("id: ${widget.id}");
        print("JobType: ${widget.jobType}");
        print("-----------------------------------");

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Carddetails(
              jobTitle: widget.jobTitle,
              companyName: widget.companyName,
              location: widget.location,
              experienceLevel: widget.experienceLevel,
              requirements: widget.requirements,
              websiteUrl: widget.websiteUrl,
              tagLabel: widget.tagLabel,
              employmentType: widget.employmentType,
              rolesAndResponsibilities: widget.rolesAndResponsibilities,
              duration: widget.duration,
              stipend: widget.stipend as String,
              details: widget.details,
              noOfOpenings: widget.noOfOpenings as String,
              mode: widget.mode,
              skills: widget.skills,
              id: widget.id,
              jobType: widget.jobType,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4B20C2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHiringTag(),
            const SizedBox(height: 12),
            Text(
              widget.jobTitle,
              style: const TextStyle(
                color: Color(0xFFF9A825),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Scrollable requirements
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.requirements
                      .map((req) => _buildRequirementRow(req))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildWebsiteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHiringTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'WE ARE HIRING!',
        style: TextStyle(
          color: Color(0xFF4B20C2),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white, fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteButton() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          widget.websiteUrl,
          style: const TextStyle(
            color: Color(0xFF4B20C2),
            fontWeight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildJobTitleSection() {
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.companyName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Favorite button
          ],
        ),
        const SizedBox(height: 12),
        const Divider(
          color: Color.fromARGB(255, 19, 16, 16),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey, size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.location,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.people_alt, color: Colors.grey, size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.experienceLevel,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
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

// Custom clipper for the arrow-shaped tag
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
