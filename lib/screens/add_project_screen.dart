import 'package:flutter/material.dart';

class AddProjectScreen extends StatefulWidget {
  final Map<String, dynamic>? project;

  const AddProjectScreen({super.key, this.project});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // Check if we're editing an existing project
    if (widget.project != null && widget.project!.isNotEmpty) {
      _isEditing = true;
      _projectNameController.text = widget.project!['projectName'] ?? '';
      _linkController.text = widget.project!['link'] ?? '';
      _descriptionController.text = widget.project!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProject() {
    final projectName = _projectNameController.text.trim();
    final link = _linkController.text.trim();
    final description = _descriptionController.text.trim();

    if (projectName.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill Project Name and Description')),
      );
      return;
    }

    final projectData = {
      'projectName': projectName,
      'link': link,
      'description': description,
    };

    // Return the project data to the previous screen
    Navigator.pop(context, projectData);
  }

  void _markAsDone() {
    _saveProject();
  }

  @override
  Widget build(BuildContext context) {
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
          _isEditing ? 'Edit Project' : 'Add Projects',
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
              'Projects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '“Flex your side hustles, hackathons, or college builds. Drop links & let recruiters see your work 🚀.”',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _inputField(
              'Project Name',
              'Write the name of the Project',
              _projectNameController,
            ),
            _inputField(
              'Link',
              'Paste the link of your project',
              _linkController,
            ),
            _inputField(
              'Description',
              'Describe the project',
              _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            _button(
              _isEditing ? 'Update' : 'Add',
              Color(0xFFF5B967),
              Colors.white,
              onPressed: _saveProject,
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
