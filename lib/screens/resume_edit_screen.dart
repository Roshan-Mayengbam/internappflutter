import 'package:flutter/material.dart';

class ResumeEditPopupUtils {
  static void showResumeEditPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return const ResumeEditPopup();
      },
    );
  }
}

class ResumeEditPopup extends StatefulWidget {
  const ResumeEditPopup({super.key});

  @override
  State<ResumeEditPopup> createState() => _ResumeEditPopupState();
}

class _ResumeEditPopupState extends State<ResumeEditPopup> {
  bool _isResumeSelected = false;
  String? _selectedFileName;

  final List<String> _dummyFiles = [
    'Harish_Resume.pdf',
    'John_CV.docx',
    'My_Resume.pdf',
  ];

  void _showFileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select File',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._dummyFiles.map(
                (fileName) => ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(fileName),
                  onTap: () {
                    setState(() {
                      _selectedFileName = fileName;
                      _isResumeSelected = true;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFileName = 'uploaded_resume.pdf';
                      _isResumeSelected = true;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Upload New File'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name section
              const SizedBox(height: 8),

              // Resume title
              const Text(
                'Resume',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Resume file selection with checkbox
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Custom checkbox
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isResumeSelected = !_isResumeSelected;
                          if (!_isResumeSelected) {
                            _selectedFileName = null;
                          }
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isResumeSelected
                                ? Colors.blue
                                : Colors.grey,
                            width: 2,
                          ),
                          color: _isResumeSelected
                              ? Colors.blue
                              : Colors.transparent,
                        ),
                        child: _isResumeSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // File name
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showFileOptions(context),
                        child: Text(
                          _selectedFileName ?? 'Harish_Resume',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedFileName != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    // More options button
                    IconButton(
                      onPressed: () => _showFileOptions(context),
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Upload section
              GestureDetector(
                onTap: () => _showFileOptions(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Click to Upload or drag and drop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '(Max. File size: 1.2 MB)',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'PDF | DOCX | > 3 MB',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Resume Builder section
              const Text(
                'AI Resume Builder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resume Submitted!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tool section
              const SizedBox(height: 12),

              // Tool items
            ],
          ),
        ),
      ),
    );
  }
}
