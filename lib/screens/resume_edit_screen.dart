import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ResumeEditPopupUtils {
  static void showResumeEditPopup(
    BuildContext context, {
    required resumelink,
    required resume,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return ResumeEditPopup(resumelink: resumelink, resume: resume);
      },
    );
  }
}

class ResumeEditPopup extends StatefulWidget {
  final String resumelink;
  final String resume;
  const ResumeEditPopup({
    super.key,
    required this.resumelink,
    required this.resume,
  });

  @override
  State<ResumeEditPopup> createState() => _ResumeEditPopupState();
}

class _ResumeEditPopupState extends State<ResumeEditPopup> {
  bool _isResumeSelected = false;
  String? _selectedFileName;
  File? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final String baseUrl2 = "https://hyrup-730899264601.asia-south1.run.app";
  bool isLoading = false;
  String errorMessage = '';

  final List<String> _dummyFiles = [
    'Harish_Resume.pdf',
    'John_CV.docx',
    'My_Resume.pdf',
  ];

  // Open resume in browser
  Future<void> _openResumeInBrowser(BuildContext context) async {
    final resumeUrl = widget.resume;
    if (resumeUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(resumeUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening resume: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No resume uploaded yet'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Pick file from device
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        // Check file size (1.2 MB = 1.2 * 1024 * 1024 bytes)
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 1.2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size exceeds 1.2 MB limit'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFile = file;
          _selectedFileName = result.files.single.name;
          _isResumeSelected = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Upload file to Firebase Storage
  Future<String?> _uploadToFirebase(File file, String fileName) async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Create a reference to Firebase Storage
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String path = 'resumes/${timestamp}_$fileName';

      Reference storageRef = FirebaseStorage.instance.ref().child(path);

      // Upload file with progress tracking
      UploadTask uploadTask = storageRef.putFile(file);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // Send resume data to backend
  Future<void> _updateResumeOnBackend(
    String resumeUrl,
    String resumeName,
  ) async {
    try {
      final String apiUrl = '$baseUrl2/student/update-resume';
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not logged in";
          isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed('/signup');
        return;
      }

      String uid = user.uid;
      String? idToken = await user.getIdToken();

      if (idToken == null) {
        setState(() {
          errorMessage = "Could not get authentication token";
          isLoading = false;
        });
        return;
      }

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'resume': resumeUrl, 'resumeName': resumeName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resume updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          throw Exception(data['message'] ?? 'Update failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend update failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Handle submit button
  Future<void> _handleSubmit() async {
    if (_selectedFile != null && _selectedFileName != null) {
      // Upload new file to Firebase
      String? firebaseUrl = await _uploadToFirebase(
        _selectedFile!,
        _selectedFileName!,
      );

      if (firebaseUrl != null) {
        // Update backend with new resume URL
        await _updateResumeOnBackend(firebaseUrl, _selectedFileName!);
      }
    } else if (_isResumeSelected && _selectedFileName != null) {
      // Using existing file from dummy list
      await _updateResumeOnBackend(widget.resumelink, _selectedFileName!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a resume'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

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
                      _selectedFile = null;
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
                    Navigator.pop(context);
                    _pickFile();
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
                            _selectedFile = null;
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
                        onTap: () => _openResumeInBrowser(context),
                        child: Text(
                          _selectedFileName ?? widget.resumelink,
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Upload section
              GestureDetector(
                onTap: _isUploading ? null : _pickFile,
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
                  child: _isUploading
                      ? Column(
                          children: [
                            CircularProgressIndicator(value: _uploadProgress),
                            const SizedBox(height: 8),
                            Text(
                              'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        )
                      : const Column(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 40,
                              color: Colors.grey,
                            ),
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'PDF | DOCX | < 1.2 MB',
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
                  onPressed: _isUploading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
