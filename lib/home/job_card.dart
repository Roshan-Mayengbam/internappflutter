import 'package:flutter/material.dart';
import 'package:internappflutter/home/cardDetails.dart';

class JobCard extends StatefulWidget {
  final String jobTitle;
  final String companyName;
  final String location;
  final String experienceLevel;
  final List<String> requirements;
  final String websiteUrl;
  final int initialColorIndex;
  final String? tagLabel;
  final Color? tagColor;

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
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  static const List<Color> cardColors = [
    Color.fromRGBO(230, 211, 252, 1),
    Color.fromRGBO(229, 223, 156, 1),
    Color.fromRGBO(184, 209, 230, 1),
  ];

  late int colorIndex;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    colorIndex = widget.initialColorIndex % cardColors.length;
  }

  void swapColours() {
    setState(() {
      colorIndex = (colorIndex + 1) % cardColors.length;
    });
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
      child: InkWell(
        onTap: swapColours,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Shadow card
            Positioned(
              top: 16,
              left: 16,
              right: -4,
              bottom: -4,
              child: Card(
                elevation: 0,
                color: Colors.black.withOpacity(1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
              ),
            ),
            // Main card
            Card(
              elevation: 12,
              shadowColor: Colors.black.withOpacity(1),
              color: cardColors[colorIndex],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
            // Tag positioned on top of the card
            if (widget.tagLabel != null) _buildTag(),
          ],
        ),
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
        width: 140,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPosterCard() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Carddetails(
              jobTitle: widget.jobTitle,
              companyName: widget.companyName,
              location: widget.location,
              experienceLevel: widget.experienceLevel,
              requirements: widget.requirements,
              websiteUrl: widget.websiteUrl,
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
              constraints: const BoxConstraints(maxHeight: 100),
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
            InkWell(
              onTap: toggleFavourite,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 5),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                  ],
                  color: Colors.pink[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: const Icon(Icons.favorite, color: Colors.pink, size: 24),
              ),
            ),
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
