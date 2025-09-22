import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internappflutter/screens/add_experience.dart';
import 'package:internappflutter/screens/add_project_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // controllers
  final TextEditingController fullNameCtrl = TextEditingController(
    text: 'Johnraj',
  );
  final TextEditingController phoneCtrl = TextEditingController(
    text: '+91 72645-05924',
  );
  final TextEditingController emailCtrl = TextEditingController(
    text: 'john@gmail.com',
  );
  final TextEditingController bio = TextEditingController(
    text: 'Write about your bio',
  );
  final TextEditingController about = TextEditingController(
    text: 'Write about yourself',
  );
  final TextEditingController collegeCtrl = TextEditingController(
    text: 'Sastra College',
  );
  final TextEditingController degreeCtrl = TextEditingController(
    text: 'Bachelor of Engineering',
  );
  final TextEditingController collegeEmailCtrl = TextEditingController(
    text: '127157023@sastra.ac.in',
  );
  final TextEditingController skillController = TextEditingController();
  final TextEditingController jobController = TextEditingController();

  List<String> skills = [];
  List<String> jobPreferences = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // top profile picture
          ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),

          // everything in ONE draggable sheet
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Jost',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // full name
                      _buildTextField('Full Name', fullNameCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Phone Number', phoneCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Email', emailCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Bio', bio),
                      const SizedBox(height: 15),
                      _buildTextField('About', about),
                      const SizedBox(height: 15),
                      _buildTextField('College Name', collegeCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Degree', degreeCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('College Email ID', collegeEmailCtrl),

                      const Divider(height: 40),

                      // Skills Section
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Jost',
                        ),
                      ),
                      const SizedBox(height: 10),

                      const SizedBox(height: 10),

                      // big input box for skill
                      // Skill input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                        ),
                        child: TextField(
                          controller: skillController,
                          decoration: InputDecoration(
                            hintText: 'Add Your Skills',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                skills.add(value.trim());
                                skillController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Show skill chips with red delete
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: skills
                            .map(
                              (skill) => _buildChip(
                                skill,
                                onDelete: () {
                                  setState(() {
                                    skills.remove(skill);
                                  });
                                },
                                deleteColor: Colors.red, // new property
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 30),

                      // Job Preference input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                        ),
                        child: TextField(
                          controller: jobController,
                          decoration: InputDecoration(
                            hintText: 'Select Your Job Preference',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                jobPreferences.add(value.trim());
                                jobController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Show job chips with red delete
                      Wrap(
                        spacing: 15,
                        runSpacing: 10,
                        children: jobPreferences
                            .map(
                              (job) => _buildChip(
                                job,
                                onDelete: () {
                                  setState(() {
                                    jobPreferences.remove(job);
                                  });
                                },
                                deleteColor: Colors.red, // new property
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Experience',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddExperienceScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFF5B967,
                              ), // light blue background
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                color: Colors.black, // text color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildExperienceCard(
                        organization: 'MaxWells Coperations',
                        position: 'AI Intern',
                        timeline: 'Jan 2025 - Feb 2025',
                        description:
                            'Manage the qualifications or preference used to hide jobs from your search…',
                        onEdit: () {
                          // edit logic here
                        },
                        onDelete: () {
                          // delete logic here
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildExperienceCard(
                        organization: 'MaxWells Coperations',
                        position: 'AI Intern',
                        timeline: 'Jan 2025 - Feb 2025',
                        description:
                            'Manage the qualifications or preference used to hide jobs from your search. '
                            'Manage the qualifications or preference used to hide jobs from your search. '
                            'Manage the qualifications or preference used to hide jobs from your search.',
                        onEdit: () {
                          // Edit logic
                        },
                        onDelete: () {
                          // Delete logic
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Projects',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Jost',
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddProjectScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFF5B967,
                              ), // light blue background
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                color: Colors.black, // text color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildProjectCard(
                        projectName: 'MaxWells Coperations',
                        link: 'https://amxa.com/pro1',
                        description:
                            'Manage the qualifications or preference used to hide jobs from your search. '
                            'Manage the qualifications or preference used to hide jobs from your search.',
                        onEdit: () {
                          // Edit logic here
                        },
                        onDelete: () {
                          // Delete logic here
                        },
                      ),
                      const SizedBox(height: 5),
                      _buildProjectCard(
                        projectName: 'MaxWells Coperations',
                        link: 'https://amxa.com/pro1',
                        description:
                            'Manage the qualifications or preference used to hide jobs from your search. '
                            'Manage the qualifications or preference used to hide jobs from your search. '
                            'Manage the qualifications or preference used to hide jobs from your search.',
                        onEdit: () {
                          // Your edit logic here, e.g., open a dialog to edit project
                        },
                        onDelete: () {
                          // Your delete logic here, e.g., remove project from list
                        },
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF090909),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ), // light border
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
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // save changes
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF090909,
                              ), // same as container
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor:
                                  Colors.transparent, // remove default shadow
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(
                                fontFamily: 'Jost',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            fontFamily: 'Jost',
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
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
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    String label, {
    required VoidCallback onDelete,
    Color deleteColor = Colors.black,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              fontFamily: GoogleFonts.jost().fontFamily,
              color: const Color(0xFF1FA7E3),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close_rounded,
              size: 25,
              color: deleteColor, // red delete button
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard({
    required String organization,
    required String position,
    required String timeline,
    required String description,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black, // subtle light border
          width: 1,
        ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Organization + buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Organization: $organization',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text('Position: $position', style: TextStyle(fontFamily: 'Jost')),
          Text('Timeline: $timeline', style: TextStyle(fontFamily: 'Jost')),
          const SizedBox(height: 8),
          Text(
            'Description: $description',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontFamily: 'Jost',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String projectName,
    required String link,
    required String description,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black, // subtle light border
          width: 1,
        ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Project Name + buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Project: $projectName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text('Link: $link', style: TextStyle(fontFamily: 'Jost')),
          const SizedBox(height: 8),
          Text(
            'Description: $description',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontFamily: 'Jost',
            ),
          ),
        ],
      ),
    );
  }
}
