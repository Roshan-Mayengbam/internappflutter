import 'package:flutter/material.dart';

class AddExperienceScreen extends StatefulWidget {
  final Map<String, dynamic>? experience;

  const AddExperienceScreen({super.key, this.experience});

  @override
  State<AddExperienceScreen> createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // Check if we're editing an existing experience
    if (widget.experience != null && widget.experience!.isNotEmpty) {
      _isEditing = true;
      print('Editing experience: ${widget.experience}');
      _organizationController.text = widget.experience!['nameOfOrg'] ?? '';
      _positionController.text = widget.experience!['position'] ?? '';
      _timelineController.text = widget.experience!['timeline'] ?? '';
      _descriptionController.text = widget.experience!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _organizationController.dispose();
    _positionController.dispose();
    _timelineController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveExperience() {
    final organization = _organizationController.text.trim();
    final position = _positionController.text.trim();
    final timeline = _timelineController.text.trim();
    final description = _descriptionController.text.trim();

    if (organization.isEmpty ||
        position.isEmpty ||
        timeline.isEmpty ||
        description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final experienceData = {
      'nameOfOrg': organization,
      'position': position,
      'timeline': timeline,
      'description': description,
    };

    // Return the experience data to the previous screen
    Navigator.pop(context, experienceData);
  }

  void _markAsDone() {
    _saveExperience();
  }

  @override
  Widget build(BuildContext context) {
    print('Editing: $_isEditing');
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Experience' : 'Add Experience',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Experience',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '“Internships, part-time jobs, freelance gigs — every hustle counts.”',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _inputField(
              'Name of organization',
              'Write the name of the organisation',
              _organizationController,
            ),
            _inputField(
              'Position',
              'Which position did you work on',
              _positionController,
            ),
            _inputField('Timeline', 'Date', _timelineController),
            _inputField(
              'Description',
              'Write about the experience you had',
              _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            _button(
              _isEditing ? 'Update' : 'Add',
              Color(0xFFF5B967),
              Colors.white,
              onPressed: _saveExperience,
            ),
            const SizedBox(height: 12),
            _button(
              'Done',
              Color(0xFFB6A5FE),
              Colors.white,
              onPressed: _markAsDone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1),
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
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(
    String text,
    Color bg,
    Color txtColor, {
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
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
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shadowColor: Colors.transparent,
          ),
          child: Text(
            text,
            style: TextStyle(color: txtColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
