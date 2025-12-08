import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:internappflutter/aboutYou/tag.dart';
import 'package:internappflutter/auth/courserange.dart';
import 'package:internappflutter/models/usermodel.dart';

class UploadScreen extends StatefulWidget {
  final UserProject? userProject;
  const UploadScreen({super.key, required this.userProject});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? pickedPhotoFile;
  File? pickedResumeFile;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Check Android version
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ - Request granular media permissions
        await [Permission.photos, Permission.videos].request();
      } else if (androidInfo.version.sdkInt >= 30) {
        // Android 11-12 - Request storage permission
        await Permission.storage.request();

        // If denied, request manage external storage
        if (await Permission.storage.isDenied) {
          await Permission.manageExternalStorage.request();
        }
      } else {
        // Android 10 and below
        await Permission.storage.request();
      }
    }
  }

  // Check if permissions are granted
  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+
        return await Permission.photos.isGranted;
      } else {
        // Android 12 and below
        return await Permission.storage.isGranted ||
            await Permission.manageExternalStorage.isGranted;
      }
    }
    return true; // iOS doesn't need these permissions for file_picker
  }

  Future<void> _pickPhoto() async {
    // Check permissions first
    bool hasPermission = await _checkPermissions();

    if (!hasPermission) {
      // Show permission dialog
      bool? shouldRequest = await _showPermissionDialog(
        'Photo Access',
        'This app needs permission to access your photos to upload a profile picture.',
      );

      if (shouldRequest == true) {
        await _requestPermissions();
        hasPermission = await _checkPermissions();
      }

      if (!hasPermission) {
        _showPermissionDeniedSnackBar('photo');
        return;
      }
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      final filePath = result.files.single.path;

      const maxFileSize = 5 * 1024 * 1024; // 5 MB

      if (fileBytes != null && fileBytes.length > maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size must be less than 5 MB'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (filePath != null) {
        setState(() {
          pickedPhotoFile = File(filePath);
        });
      }
    }
  }

  Future<void> _pickResume() async {
    // File picker doesn't need special permissions for documents on most Android versions
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      final filePath = result.files.single.path;

      const maxFileSize = 5 * 1024 * 1024; // 5 MB

      if (fileBytes != null && fileBytes.length > maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size must be less than 5 MB'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (filePath != null) {
        setState(() {
          pickedResumeFile = File(filePath);
        });
      }
    }
  }

  // Show permission dialog
  Future<bool?> _showPermissionDialog(String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  // Show permission denied snackbar
  void _showPermissionDeniedSnackBar(String fileType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permission denied. Cannot access $fileType.'),
        backgroundColor: Colors.redAccent,
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            openAppSettings(); // Opens app settings
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFE0E0E0),
                        color: const Color.fromARGB(255, 97, 251, 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    height: 150,
                    child: Image.asset('assets/bear.gif', fit: BoxFit.fill),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/text.png',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 25),
              FileUploadWidget(
                onTap: _pickPhoto,
                file: pickedPhotoFile,
                text: 'Profile ',
                text1: 'JPG',
                text2: 'PNG',
                text3: '<1mb',
              ),
              if (pickedPhotoFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Photo selected: ${pickedPhotoFile!.path.split('/').last}',
                  ),
                ),
              const SizedBox(height: 25),
              FileUploadWidget(
                onTap: _pickResume,
                file: pickedResumeFile,
                text: 'Resume',
                text1: 'PDF',
                text2: 'DOCX',
                text3: '<3mb',
              ),
              if (pickedResumeFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Resume selected: ${pickedResumeFile!.path.split('/').last}',
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (widget.userProject != null &&
                pickedPhotoFile != null &&
                pickedResumeFile != null) {
              final uploadResume = UploadResume(
                profilePic: pickedPhotoFile!.path,
                resumeFile: pickedResumeFile!.path,
                projectName: widget.userProject!.projectName,
                projectLink: widget.userProject!.projectLink,
                projectDescription: widget.userProject!.projectDescription,
                organisation: widget.userProject!.organisation,
                position: widget.userProject!.position,
                date: widget.userProject!.date,
                description: widget.userProject!.description,
                year: widget.userProject!.year,
                name: widget.userProject!.name,
                phone: widget.userProject?.phone,
                email: widget.userProject!.email,
                uid: widget.userProject!.uid,
                role: widget.userProject!.role,
                collegeName: widget.userProject!.collegeName,
                university: widget.userProject!.university,
                degree: widget.userProject!.degree,
                collegeEmailId: widget.userProject!.collegeEmailId,
                userSkills: widget.userProject!.userSkills,
                preferences: widget.userProject!.preferences,
              );

              print('--- UploadResume Details ---');
              print('Profile Pic: ${uploadResume.profilePic}');
              print('Resume File: ${uploadResume.resumeFile}');
              print('Project Name: ${uploadResume.projectName}');
              print('Project Link: ${uploadResume.projectLink}');
              print('Project Description: ${uploadResume.projectDescription}');
              print('Organisation: ${uploadResume.organisation}');
              print('Position: ${uploadResume.position}');
              print('Date: ${uploadResume.date}');
              print('Description: ${uploadResume.description}');
              print('Year: ${uploadResume.year}');
              print('Name: ${uploadResume.name}');
              print('Phone: ${uploadResume.phone}');
              print('Email: ${uploadResume.email}');
              print('UID: ${uploadResume.uid}');
              print('Role: ${uploadResume.role}');
              print('College Name: ${uploadResume.collegeName}');
              print('University: ${uploadResume.university}');
              print('Degree: ${uploadResume.degree}');
              print('College Email ID: ${uploadResume.collegeEmailId}');
              print('User Skills: ${uploadResume.userSkills}');
              print('Preferences: ${uploadResume.preferences}');
              print('---------------------------');

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return TagPage(
                      profileImage: pickedPhotoFile,
                      resumeFile: pickedResumeFile,
                      uploadResume: uploadResume,
                    );
                  },
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please pick both profile photo and resume'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB6A5FE),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class FileUploadWidget extends StatelessWidget {
  final File? file;
  final VoidCallback? onTap;
  final String? text;
  final String? text1;
  final String? text2;
  final String? text3;

  const FileUploadWidget({
    super.key,
    this.file,
    this.onTap,
    this.text,
    this.text1,
    this.text2,
    this.text3,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF6C25FF);
    const Color lightPurpleBg = Color(0xFFF2EAFF);
    const Color lightGreyText = Color(0xFF8A8A8A);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$text',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 32.0,
                horizontal: 24.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildUploadPrompt(
                primaryPurple,
                lightGreyText,
                lightPurpleBg,
                text1!,
                text2!,
                text3!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt(
    Color primaryPurple,
    Color lightGreyText,
    Color lightPurpleBg,
    String text1,
    String text2,
    String text3,
  ) {
    return Column(
      children: [
        Image.asset("assets/addItem.png"),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(
                text: 'Click to Upload',
                style: TextStyle(
                  color: primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' or drag and drop'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '(Max. File size: 5 MB)',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTag(text1, primaryPurple, lightPurpleBg),
            const SizedBox(width: 8),
            _buildTag(text2, primaryPurple, lightPurpleBg),
            const SizedBox(width: 8),
            _buildTag(text3, Colors.red, Colors.red.withOpacity(0.1)),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
