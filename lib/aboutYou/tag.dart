import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:internappflutter/bottomnavbar.dart';
import 'package:internappflutter/home/home_page.dart';
import 'package:internappflutter/models/usermodel.dart';

class TagPage extends StatefulWidget {
  final UploadResume uploadResume;
  final File? profileImage;
  final File? resumeFile;

  const TagPage({
    super.key,
    required this.uploadResume,
    this.profileImage,
    this.resumeFile,
  });

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isUploading = false;
  String _uploadProgress = "Preparing upload...";

  // Replace with your actual backend URL
  final String baseUrl = "http://172.31.223.157:3000/student";

  /// Upload file to Firebase Storage and return download URL
  Future<String?> _uploadFileToStorage(
    File file,
    String folder,
    String fileName,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // Create unique file path
      final String filePath = '$folder/${currentUser.uid}_$fileName';

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
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        setState(() {
          _uploadProgress =
              '${folder.toUpperCase()}: ${progress.toStringAsFixed(1)}%';
        });
      });

      // Wait for completion
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print("✅ File uploaded successfully: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("❌ Error uploading file to Firebase Storage: $e");
      _showErrorSnackbar("Failed to upload ${folder}: $e");
      return null;
    }
  }

  /// Get MIME type for file
  String _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  Future<bool> _submitCompleteUserData() async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = "Preparing upload...";
      });

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("❌ No authenticated user found");
        _showErrorSnackbar("Authentication required");
        return false;
      }

      // Step 1: Upload files to Firebase Storage
      String? profileImageUrl;
      String? resumeFileUrl;

      // Upload profile image if exists
      if (widget.profileImage != null && widget.profileImage!.existsSync()) {
        setState(() {
          _uploadProgress = "Uploading profile image...";
        });

        final fileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}.${widget.profileImage!.path.split('.').last}';
        profileImageUrl = await _uploadFileToStorage(
          widget.profileImage!,
          'profile_images',
          fileName,
        );

        if (profileImageUrl == null) {
          _showErrorSnackbar("Failed to upload profile image");
          return false;
        }
      }

      // Upload resume if exists
      if (widget.resumeFile != null && widget.resumeFile!.existsSync()) {
        setState(() {
          _uploadProgress = "Uploading resume...";
        });

        final fileName =
            'resume_${DateTime.now().millisecondsSinceEpoch}.${widget.resumeFile!.path.split('.').last}';
        resumeFileUrl = await _uploadFileToStorage(
          widget.resumeFile!,
          'resumes',
          fileName,
        );

        if (resumeFileUrl == null) {
          _showErrorSnackbar("Failed to upload resume");
          return false;
        }
      }

      // Step 2: Submit data to backend with file URLs
      setState(() {
        _uploadProgress = "Submitting user data...";
      });

      final idToken = await currentUser.getIdToken();

      final requestBody = {
        "studentId": currentUser.uid,
        "phone": widget.uploadResume.phone ?? "",
        "profile": {
          "FullName": widget.uploadResume.name,
          "profilePicture": profileImageUrl ?? "", // Firebase Storage URL
          "bio": widget.uploadResume.description ?? "",
        },
        "education": {
          "college": widget.uploadResume.collegeName ?? "",
          "universityType": _mapUniversityType(
            widget.uploadResume.university ?? "",
          ),
          "degree": widget.uploadResume.degree ?? "",
          "collegeEmail": widget.uploadResume.collegeEmailId ?? "",
          "yearOfPassing": _extractGraduationYear(
            widget.uploadResume.year ?? "",
          ),
        },
        "job_preference": widget.uploadResume.preferences.isNotEmpty
            ? widget.uploadResume.preferences
            : ["Software Development"],
        "experience": [
          if (widget.uploadResume.organisation.isNotEmpty)
            {
              "nameOfOrg": widget.uploadResume.organisation,
              "position": widget.uploadResume.position,
              "timeline": widget.uploadResume.date,
              "description": widget.uploadResume.description,
            },
        ],
        "projects": [
          if (widget.uploadResume.projectName.isNotEmpty)
            {
              "projectName": widget.uploadResume.projectName,
              "link": widget.uploadResume.projectLink,
              "description": widget.uploadResume.projectDescription,
            },
        ],
        "user_skills": _mapSkillsToBackendFormat(
          widget.uploadResume.userSkills,
        ),
        // Add file URLs to the request body
        "files": {
          "profileImageUrl": profileImageUrl,
          "resumeUrl": resumeFileUrl,
        },
      };

      print("📤 Calling: $baseUrl/signup");
      print("📄 Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(requestBody),
      );

      print("📡 Backend response status: ${response.statusCode}");
      print("📄 Backend response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ User data submitted successfully");
        setState(() {
          _uploadProgress = "Upload completed successfully!";
        });
        return true;
      } else {
        print("❌ Backend submission failed: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        _showErrorSnackbar(
          "Upload failed: ${errorData['message'] ?? 'Unknown error'}",
        );

        // Clean up uploaded files if backend fails
        await _cleanupUploadedFiles(profileImageUrl, resumeFileUrl);
        return false;
      }
    } catch (e) {
      print("❌ Error submitting user data: $e");
      _showErrorSnackbar("Network error: $e");
      return false;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// Clean up uploaded files if backend submission fails
  Future<void> _cleanupUploadedFiles(
    String? profileUrl,
    String? resumeUrl,
  ) async {
    try {
      if (profileUrl != null) {
        await _storage.refFromURL(profileUrl).delete();
        print("🗑️ Cleaned up profile image");
      }
      if (resumeUrl != null) {
        await _storage.refFromURL(resumeUrl).delete();
        print("🗑️ Cleaned up resume file");
      }
    } catch (e) {
      print("⚠️ Error cleaning up files: $e");
    }
  }

  String _mapUniversityType(String university) {
    // Map university names to backend enum values: ["deemed", "public", "private"]
    final lowerUniversity = university.toLowerCase();

    if (lowerUniversity.contains('deemed') ||
        lowerUniversity.contains('du') ||
        lowerUniversity.contains('university of')) {
      return 'deemed';
    } else if (lowerUniversity.contains('private') ||
        lowerUniversity.contains('international') ||
        lowerUniversity.contains('institute of technology')) {
      return 'private';
    } else {
      return 'public'; // Default
    }
  }

  int _extractGraduationYear(String yearString) {
    try {
      // Handle empty or null strings
      if (yearString.isEmpty) {
        return DateTime.now().year + 1; // Default to next year
      }

      // Extract year from various formats like "2024", "2023-2024", "4th year", etc.
      final RegExp yearRegex = RegExp(r'\d{4}');
      final matches = yearRegex.allMatches(yearString);

      if (matches.isNotEmpty) {
        // Get the latest year if multiple years are found
        final years = matches.map((m) => int.parse(m.group(0)!)).toList();
        return years.reduce((a, b) => a > b ? a : b);
      }

      // Try to parse the whole string as a number
      final parsedYear = int.tryParse(
        yearString.replaceAll(RegExp(r'[^\d]'), ''),
      );
      if (parsedYear != null && parsedYear >= 1900 && parsedYear <= 2050) {
        return parsedYear;
      }

      // If no valid year found, return default
      print("⚠️ Could not parse year from '$yearString', using default");
      return DateTime.now().year + 1; // Default to next year
    } catch (e) {
      print("❌ Error parsing year: $e");
      return DateTime.now().year + 1; // Default to next year
    }
  }

  Map<String, dynamic> _mapSkillsToBackendFormat(List<String> skills) {
    // Convert List<String> to Map<String, {level: String}>
    final Map<String, dynamic> skillsMap = {};

    for (String skill in skills) {
      skillsMap[skill] = {
        "level": "mid", // Default level, you can modify this logic
      };
    }

    return skillsMap;
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleNextButton() async {
    final success = await _submitCompleteUserData();

    if (success) {
      _showSuccessSnackbar("Profile uploaded successfully!");

      // Navigate to home page after successful upload
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                BottomnavbarAlternative(userData: widget.uploadResume),
          ),
        );
      }
    }
    // Error handling is done in _submitCompleteUserData
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildIdCard(context),
              const Spacer(),
              const Text(
                'Nice to get your details.\nLet\'s dive in deep',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _buildNextButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _handleNextButton,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isUploading ? Colors.grey : Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isUploading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _uploadProgress,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : const Text('Next', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildIdCard(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: 480,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
            // Fallback color if image doesn't load
            color: Colors.white,
          ),
          child: Stack(
            children: [
              // Background image (with error handling)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage('assets/idBackground.png'),
                    fit: BoxFit.cover,
                    onError: null, // Handle image loading errors gracefully
                  ),
                ),
              ),
              _buildCardDetails(),
            ],
          ),
        ),
        // Card clip at top
        Positioned(
          top: -60,
          child: Container(
            width: 45,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
        ),
        // Profile image
        Positioned(top: 80, child: _buildProfileImage()),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: widget.profileImage != null && widget.profileImage!.existsSync()
            ? Image.file(widget.profileImage!, fit: BoxFit.cover)
            : Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.grey.shade500,
                ),
              ),
      ),
    );
  }

  Widget _buildCardDetails() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 80), // space for profile image
          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              widget.uploadResume.name.isNotEmpty
                  ? widget.uploadResume.name
                  : 'Your Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          // Info rows
          _buildInfoRow('Role', widget.uploadResume.role),
          _buildInfoRow('Email', widget.uploadResume.email),
          _buildInfoRow('Phone', widget.uploadResume.phone),
          _buildInfoRow('College', widget.uploadResume.collegeName),
          _buildInfoRow('University', widget.uploadResume.university),

          // Resume file info
          if (widget.resumeFile != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Resume: ${widget.resumeFile!.path.split('/').last}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
