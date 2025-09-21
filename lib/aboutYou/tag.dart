import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:internappflutter/auth/courserange.dart';
import 'package:internappflutter/auth/google_signin.dart';
import 'package:internappflutter/bottomnavbar.dart';

class TagPage extends StatefulWidget {
  final FinalUserModel? userModel;
  final File? profileImage;

  const TagPage({super.key, this.profileImage, required this.userModel});

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  final GoogleAuthService _authService = GoogleAuthService();
  bool _isSubmitting = false;

  Future<void> _submitUserData() async {
    if (widget.userModel == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // ✅ Debug print all collected data
      print("=== FINAL USER DATA SUMMARY ===");
      print("Name: ${widget.userModel!.name}");
      print("Email: ${widget.userModel!.email}");
      print("Phone: ${widget.userModel!.phone}");
      print("UID: ${widget.userModel!.uid}");
      print("Role: ${widget.userModel!.role}");
      print("College: ${widget.userModel!.collegeName}");
      print("University: ${widget.userModel!.university}");
      print("Degree: ${widget.userModel!.degree}");
      print("Course Range: ${widget.userModel!.courseRange}");
      print("Profile Image: ${widget.profileImage?.path ?? 'None'}");
      print("===============================");

      // ✅ Submit complete user data to backend
      final success = await _authService.submitCompleteUserData(
        widget.userModel!,
        widget.profileImage,
      );

      if (success) {
        print("✅ User data submitted successfully!");

        // Navigate to main app
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomnavbarAlternative(userData: null),
            ),
          );
        }
      } else {
        print("❌ Failed to submit user data");

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save your data. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error during submission: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userModel == null) {
      return const Scaffold(
        body: Center(child: Text("No user data available")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildEnhancedIdCard(context, widget.userModel!),
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
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting ? Colors.grey : Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...', style: TextStyle(fontSize: 18)),
                          ],
                        )
                      : Text('Next', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedIdCard(BuildContext context, FinalUserModel user) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 520,
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
            image: const DecorationImage(
              image: AssetImage('assets/idBackground.png'),
              fit: BoxFit.contain,
            ),
          ),
          child: Stack(children: [_buildEnhancedCardDetails(user)]),
        ),
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
        Positioned(top: 80, child: _buildProfileImage(user)),
      ],
    );
  }

  Widget _buildProfileImage(FinalUserModel user) {
    return Container(
      width: 140,
      height: 140,
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
        child: widget.profileImage != null
            ? Image.file(widget.profileImage!, fit: BoxFit.cover)
            : (user.profileImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user.profileImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )),
      ),
    );
  }

  Widget _buildEnhancedCardDetails(FinalUserModel user) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildDetailColumn('Role', user.role)),
                const SizedBox(width: 10),
                Expanded(child: _buildDetailColumn('Email', user.email)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildDetailColumn('College', user.collegeName),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailColumn('University', user.university),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildDetailColumn('Degree', user.degree)),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailColumn('Course Range', user.courseRange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
