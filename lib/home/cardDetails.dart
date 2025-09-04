import 'package:flutter/material.dart';

class AppConstants {
  static const Color backgroundColor = Colors.white;
  static const Color borderColor = Colors.blue;
}

class Carddetails extends StatefulWidget {
  final String jobTitle;
  final String companyName;
  final String location;
  final String experienceLevel;
  final List<String> requirements;
  final String websiteUrl;

  const Carddetails({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.experienceLevel,
    required this.requirements,
    required this.websiteUrl,
  });

  @override
  State<Carddetails> createState() => _CarddetailsState();
}

class _CarddetailsState extends State<Carddetails> {
  IconData icon = Icons.arrow_back; // Example icon

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            boxShadow: [
              // Bottom shadow
              const BoxShadow(
                color: Colors.black,
                offset: Offset(0, 5),
                blurRadius: 0,
                spreadRadius: -2,
              ),
              // Right shadow
              const BoxShadow(
                color: Colors.black,
                offset: Offset(5, 0),
                blurRadius: 0,
                spreadRadius: -2,
              ),
              // Bottom-right corner shadow (to make it symmetric)
              const BoxShadow(
                color: Colors.black,
                offset: Offset(5, 5),
                blurRadius: 0,
                spreadRadius: -2,
              ),
            ],
            color: AppConstants.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromARGB(255, 6, 7, 8),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: const Color.fromARGB(255, 7, 8, 9)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                color: Color.fromARGB(255, 4, 4, 4),
                thickness: 1,
                height: 30,
              ),

              // ✅ Linux + check + love at rightmost
              Row(
                children: [
                  Text(
                    widget.companyName,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle, color: Colors.blue, size: 18),

                  const Spacer(), // 🔹 Pushes the love icon to the right

                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.pink[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.pink,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                widget.jobTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              const Text(
                "Coimbatore, Tamil Nadu, India . 3 weeks ago .Over 100 people clicked apply",
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildTag("✓ On-site"),
                  const SizedBox(width: 8),
                  _buildTag("✓ Full-time"),

                  const Spacer(), // 🔹 Pushes the love icon to the right
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        // Bottom shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 5),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Right shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(5, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Bottom-right corner shadow (to make it symmetric)
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(5, 5),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ), // thin
                        left: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ), // thin
                        right: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ), // thick
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ), // thick
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.comment,
                      color: const Color.fromARGB(255, 7, 8, 9),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Text(
                "How your profile and resume fit this job",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 14),
              Text(
                "About this job",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 14),
              _buildIdCard(context),
              SizedBox(height: 15),
              _details(context),
              SizedBox(height: 15),
              const Divider(
                color: Color.fromARGB(255, 4, 4, 4),
                thickness: 1,
                height: 30,
              ),
              SizedBox(
                width: double.infinity, // full width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      240,
                      234,
                      182,
                    ), // yellow background
                    foregroundColor: Colors.black, // text color black
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ), // black border
                    ),
                  ),
                  onPressed: () {
                    // Handle action here
                  },
                  child: const Text(
                    "Apply Now",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200, // light grey background
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Job ID
            RichText(
              text: TextSpan(
                text: 'Job ID : ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: ' ER 1201',
                    style: TextStyle(
                      color: Color.fromARGB(255, 104, 100, 100),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ✅ Job Type
            RichText(
              text: const TextSpan(
                text: 'Job Type : ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: ' Full Time',
                    style: TextStyle(
                      color: Color.fromARGB(255, 104, 100, 100),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ✅ Qualification
            RichText(
              text: TextSpan(
                text: 'Qualification Skills : ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: widget.requirements.toString(),
                    style: TextStyle(
                      color: Color.fromARGB(255, 104, 100, 100),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.black, thickness: 1, height: 30),

            Row(
              children: [
                Icon(Icons.location_on, color: Colors.black54),
                SizedBox(width: 5),
                Text(widget.location),
                Spacer(), // pushes next widget to rightmost
                Icon(Icons.person, color: Colors.black54),
                SizedBox(width: 5),
                Text(widget.experienceLevel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }

  Widget _details(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 172, 206, 228),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Company Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We are a leading technology solutions provider with expertise in "
              "software development, UI/UX design, and digital transformation. "
              "Our mission is to deliver high-quality products that empower "
              "businesses to achieve their goals and create value for customers.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Responsibilities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "• Collaborate with the design and development team to create user-friendly applications.\n"
              "• Assist in wireframing, prototyping, and UI/UX improvements.\n"
              "• Conduct research to identify user needs and industry trends.\n"
              "• Prepare documentation, reports, and presentations as required.\n"
              "• Support in testing and troubleshooting issues during development.\n"
              "• Contribute creative ideas to improve overall product quality.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
