import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:internappflutter/aboutYou/tag.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: LinearProgressIndicator(
                value: 0.8,
                color: Colors.green,
                backgroundColor: Colors.grey[300],
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/bear.gif", height: 150, width: 164),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: SvgPicture.asset(
                    "assets/text.svg",
                    height: 60,
                    width: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 25),

            FileUploadWidget(
              onTap: _pickPhoto,
              file: pickedPhotoFile,
              text: 'Profile Picture',
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

            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return TagPage(
                        profileImage: pickedPhotoFile,
                        userModel: null,
                      );
                    },
                  ),
                );
              },
              child: Image.asset("assets/Button.png", width: 500, height: 50),
            ),
            const SizedBox(height: 20),
          ],
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
