import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:internappflutter/aboutYou/tag.dart';
import 'package:internappflutter/auth/courserange.dart';

class UploadScreen extends StatefulWidget {
  final FinalUserModel userModel; // ✅ Add proper field declaration
  const UploadScreen({super.key, required this.userModel});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? pickedPhotoFile;
  File? pickedResumeFile;

  Future<void> _pickPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result != null) {
      setState(() {
        pickedPhotoFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result != null) {
      setState(() {
        pickedResumeFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                        backgroundColor: Colors.grey[300],
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
                        alignment:
                            Alignment.center, // centers children in the stack
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

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return TagPage(
                            profileImage: pickedPhotoFile,
                            userModel: widget.userModel,
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

TagPage({File? profileImage, required userModel}) {}

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
          '(Max. File size: 1.2 MB)',
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
