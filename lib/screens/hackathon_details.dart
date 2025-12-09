import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppConstants {
  static const Color backgroundColor = Colors.white;
  static const Color borderColor = Colors.blue;
}

class HackathonDetailsScreen extends StatefulWidget {
  final String title;
  final String organizer;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String? prizePool;
  final String eligibility;
  final String? website;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HackathonDetailsScreen({
    super.key,
    required this.title,
    required this.organizer,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    this.prizePool,
    required this.eligibility,
    required this.website,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  State<HackathonDetailsScreen> createState() => _HackathonDetailsScreenState();
}

class _HackathonDetailsScreenState extends State<HackathonDetailsScreen> {
  IconData icon = Icons.arrow_back;
  String _errorMessage = '';
  bool _isApplied = false; // Add this
  bool _isLoading = false; // Add this
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Go back when pressed
          },
          child: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 5),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(5, 0),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: Color.fromARGB(255, 4, 4, 4),
                    thickness: 1,
                    height: 30,
                  ),
                  // Company Name with Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.organizer,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Job Title
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Location and Time
                  Text(
                    'Location:${widget.location}',
                    style: TextStyle(fontSize: 20, color: Colors.grey[900]),
                  ),
                  const SizedBox(height: 16),

                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.yellow[700]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.yellow[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'On site',
                              style: TextStyle(
                                color: Colors.yellow[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.yellow[700]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.yellow[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Full Time',
                              style: TextStyle(
                                color: Colors.yellow[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 6),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(6, 0),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(6, 6),
                                blurRadius: 0,
                                spreadRadius: -2,
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: const Border(
                              top: BorderSide(
                                color: Color.fromARGB(255, 6, 7, 8),
                                width: 1,
                              ),
                              left: BorderSide(
                                color: Color.fromARGB(255, 6, 7, 8),
                                width: 1,
                              ),
                              right: BorderSide(
                                color: Color.fromARGB(255, 6, 7, 8),
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: Color.fromARGB(255, 6, 7, 8),
                                width: 2,
                              ),
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (kDebugMode) {
                                      print("Website URL: ${widget.website}");
                                    }

                                    if (widget.website != null &&
                                        widget.website!.isNotEmpty &&
                                        widget.website != 'Apply via app' &&
                                        widget.website != 'N/A') {
                                      try {
                                        String url = widget.website ?? '';

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
                                            mode:
                                                LaunchMode.externalApplication,
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
                                              'Invalid URL: ${widget.website}',
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
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen[300],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Apply Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // About the job Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About the job',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Job Details Grid
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Job Type',
                                widget.eligibility,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Duration',
                                '${widget.endDate.difference(widget.startDate).inDays} days',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildInfoCard('Mode', 'Online')),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Stipend',
                                widget.prizePool ?? 'N/A',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Skills Section
                        // Replace the Skills Section in your Carddetails widget with this:

                        // Skills Section
                      ],
                    ),
                  ),

                  // Details
                  const Text(
                    'Details :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
          bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
          bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        ),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: Colors.blue[400],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPerkButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 0),
            blurRadius: 0,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
            blurRadius: 0,
            spreadRadius: -2,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
          right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
          bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue[400],
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
