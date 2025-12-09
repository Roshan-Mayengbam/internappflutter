import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumeUploadHelper {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Pick a PDF or DOCX file
  static Future<File?> pickResumeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        // Check file size (max 3 MB = 3 * 1024 * 1024 bytes)
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 3) {
          throw Exception('File size exceeds 3 MB limit');
        }

        return file;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error picking file: $e');
      rethrow;
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String filePath) {
    if (filePath.toLowerCase().endsWith('.pdf')) {
      return 'application/pdf';
    } else if (filePath.toLowerCase().endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    return 'application/octet-stream';
  }

  /// Upload resume to Firebase Storage with progress tracking
  static Future<Map<String, String>?> uploadResumeToFirebase(
    File file,
    Function(String) onProgress,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Extract original filename
      final String originalFileName = file.path.split('/').last;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Create unique file path: resumes/userId_timestamp_filename
      final String filePath =
          'resumes/${currentUser.uid}_${timestamp}_$originalFileName';

      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child(filePath);

      // Upload file with metadata
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(file.path),
          customMetadata: {
            'userId': currentUser.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalFileName': originalFileName,
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        onProgress('Uploading: ${progress.toStringAsFixed(1)}%');
      });

      // Wait for completion
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      if (kDebugMode) print("✅ Resume uploaded successfully: $downloadUrl");

      return {'url': downloadUrl, 'name': originalFileName};
    } catch (e) {
      if (kDebugMode) print("❌ Error uploading resume to Firebase Storage: $e");
      rethrow;
    }
  }

  /// Update resume in backend
  static Future<bool> updateResumeInBackend({
    required String baseUrl,
    required String resumeUrl,
    required String resumeName,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? idToken = await user.getIdToken();
      if (idToken == null) throw Exception('Could not get auth token');

      if (kDebugMode) print('🔄 Updating resume in backend...');
      if (kDebugMode) print('URL: $baseUrl/student/update-resume');
      if (kDebugMode) {
        print(
          'Body: ${json.encode({'resume': resumeUrl, 'resumeName': resumeName})}',
        );
      }

      final response = await http.put(
        Uri.parse('$baseUrl/student/update-resume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({'resume': resumeUrl, 'resumeName': resumeName}),
      );

      if (kDebugMode) print('Response status: ${response.statusCode}');
      if (kDebugMode) print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (kDebugMode) print('✅ Resume updated in backend');
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Failed to update backend: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error updating backend: $e');
      return false;
    }
  }

  /// Complete resume upload flow with progress dialog
  static Future<bool> uploadResume({
    required BuildContext context,
    required String baseUrl,
    required VoidCallback onSuccess,
  }) async {
    String progressMessage = 'Preparing upload...';

    try {
      // Step 1: Pick file first (before showing dialog)
      File? file = await pickResumeFile();
      if (file == null) {
        return false; // User cancelled
      }

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        progressMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      // Step 2: Upload to Firebase with progress updates
      Map<String, String>? uploadResult = await uploadResumeToFirebase(file, (
        progress,
      ) {
        progressMessage = progress;
        // Update dialog is handled by stream
      });

      if (uploadResult == null) {
        throw Exception('Failed to upload to Firebase Storage');
      }

      // Step 3: Update backend
      progressMessage = 'Updating profile...';
      bool backendUpdated = await updateResumeInBackend(
        baseUrl: baseUrl,
        resumeUrl: uploadResult['url']!,
        resumeName: uploadResult['name']!,
      );

      // Close dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!backendUpdated) {
        throw Exception('Failed to update backend');
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        onSuccess();
      }

      return true;
    } catch (e) {
      // Close dialog if open
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return false;
    }
  }

  /// View resume (open in browser or external viewer)
  static Future<void> viewResume(String resumeUrl) async {
    try {
      final uri = Uri.parse(resumeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch resume URL');
      }
    } catch (e) {
      if (kDebugMode) print('Error viewing resume: $e');
      rethrow;
    }
  }
}
