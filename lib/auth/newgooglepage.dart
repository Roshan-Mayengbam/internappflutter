import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HyrupOnboardingScreen extends StatefulWidget {
  const HyrupOnboardingScreen({super.key});

  @override
  State<HyrupOnboardingScreen> createState() => _HyrupOnboardingScreenState();
}

class _HyrupOnboardingScreenState extends State<HyrupOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final size = MediaQuery.of(context).size;

    // Calculate responsive padding and scaling factors
    final horizontalPadding = size.width * 0.1; // 10% of width
    final characterScaleFactor = size.height < 600
        ? 0.7
        : size.height < 800
        ? 0.9
        : 1.0; // Scale character based on screen height

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar (Kept fixed for standard UI)
            _buildStatusBar(size),
            // Main Content
            Expanded(
              child: Stack(
                children: [
                  // Background decorative elements (Positioned relatively)
                  _buildDecorativeElements(size),
                  // Main content
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ), // A bit of horizontal breathing room
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.05,
                        ), // Responsive spacing
                        // Character illustration with speech bubble
                        _buildCharacterSection(characterScaleFactor),
                        SizedBox(
                          height: size.height * 0.06,
                        ), // Responsive spacing
                        // Main text
                        _buildMainText(size),
                        SizedBox(
                          height: size.height * 0.03,
                        ), // Responsive spacing
                        // Subtitle
                        _buildSubtitle(),
                        const Spacer(), // Pushes the button to the bottom
                        // Continue button
                        _buildContinueButton(horizontalPadding),
                        SizedBox(
                          height: size.height * 0.04,
                        ), // Responsive spacing
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the status bar
  Widget _buildStatusBar(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: 10,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, size: 18, color: Colors.black),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 18, color: Colors.black),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 18, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  // REVISED: Decorative Elements use relative positioning based on screen size
  Widget _buildDecorativeElements(Size size) {
    return Stack(
      children: [
        // Crosses
        Positioned(
          top: size.height * 0.08, // 8% from top
          left: size.width * 0.12, // 12% from left
          child: const RotationTransition(
            turns: AlwaysStoppedAnimation(15 / 360),
            child: Text(
              '×',
              style: TextStyle(fontSize: 24, color: Colors.black26),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.2, // 20% from top
          right: size.width * 0.1, // 10% from right
          child: const RotationTransition(
            turns: AlwaysStoppedAnimation(-20 / 360),
            child: Text(
              '×',
              style: TextStyle(fontSize: 24, color: Colors.black26),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.3, // 30% from bottom
          left: size.width * 0.08, // 8% from left
          child: const RotationTransition(
            turns: AlwaysStoppedAnimation(45 / 360),
            child: Text(
              '×',
              style: TextStyle(fontSize: 24, color: Colors.black26),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.2, // 20% from bottom
          right: size.width * 0.15, // 15% from right
          child: const RotationTransition(
            turns: AlwaysStoppedAnimation(-30 / 360),
            child: Text(
              '×',
              style: TextStyle(fontSize: 24, color: Colors.black26),
            ),
          ),
        ),
        // Dots
        Positioned(
          top: size.height * 0.15, // 15% from top
          left: size.width * 0.05, // 5% from left
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.3, // 30% from top
          right: size.width * 0.05, // 5% from right
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Stars
        Positioned(
          bottom: size.height * 0.25, // 25% from bottom
          left: size.width * 0.12, // 12% from left
          child: const Text(
            '✦',
            style: TextStyle(fontSize: 16, color: Colors.orange),
          ),
        ),
        Positioned(
          top: size.height * 0.18, // 18% from top
          left: size.width * 0.2, // 20% from left
          child: const Text(
            '✦',
            style: TextStyle(fontSize: 16, color: Colors.orange),
          ),
        ),
      ],
    );
  }

  // REVISED: Character section scales and uses relative positioning for the bubble
  Widget _buildCharacterSection(double factor) {
    return SizedBox(
      height: 280 * factor, // Scaled height
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Character
          _buildCharacter(factor),
          // Speech bubble - positioned relative to the character section size
          Positioned(
            top: 20 * factor,
            right: 20 * factor,
            child: _buildSpeechBubble(factor),
          ),
        ],
      ),
    );
  }

  // All character components are scaled by the factor
  Widget _buildCharacter(double factor) {
    final width = 200 * factor;
    final height = 250 * factor;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arms (behind body)
          Positioned(
            top: 100 * factor,
            left: 10 * factor,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 60 * factor,
                height: 60 * factor,
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100 * factor,
            right: 10 * factor,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 60 * factor,
                height: 60 * factor,
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Body
          Positioned(
            top: 80 * factor,
            child: Container(
              width: 80 * factor,
              height: 120 * factor,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40 * factor),
                  topRight: Radius.circular(40 * factor),
                ),
              ),
            ),
          ),
          // Legs
          Positioned(
            bottom: 20 * factor,
            child: Container(
              width: 100 * factor,
              height: 80 * factor,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40 * factor),
                  bottomRight: Radius.circular(40 * factor),
                ),
              ),
            ),
          ),
          // Head
          Positioned(
            top: 40 * factor,
            child: Container(
              width: 60 * factor,
              height: 60 * factor,
              decoration: const BoxDecoration(
                color: Color(0xFF8B4513),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Glasses
          Positioned(
            top: 55 * factor,
            child: Container(
              width: 50 * factor,
              height: 20 * factor,
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.3),
                border: Border.all(
                  color: Colors.black,
                  width: 3 * factor.clamp(0.5, 3.0),
                ),
                borderRadius: BorderRadius.circular(20 * factor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Speech bubble scales with the factor
  Widget _buildSpeechBubble(double factor) {
    return Transform.rotate(
      angle: -0.1,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * factor,
          vertical: 8 * factor,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90E2),
          borderRadius: BorderRadius.circular(20 * factor),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 10 * factor,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'SWIPE\nMATCH\nGROW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12 * factor.clamp(0.8, 1.0),
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Main text uses font size relative to screen height
  Widget _buildMainText(Size size) {
    final baseFontSize = size.height * 0.055;
    final starFontSize = baseFontSize * 0.8;

    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: baseFontSize.clamp(36, 55),
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 0.9,
              letterSpacing: -2,
            ),
            children: [
              TextSpan(
                text: 'SWIPE\n',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFFE74C3C), Color(0xFFF39C12)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              const TextSpan(text: 'INTO '),
              TextSpan(
                text: '✦',
                style: TextStyle(
                  color: const Color(0xFFF39C12),
                  fontSize: starFontSize.clamp(30, 45),
                ),
              ),
              const TextSpan(text: ' TO\nYOUR\nDREAMS'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: const Text(
        '"Dream Job? Just Swipe. Hyrup."',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Button uses responsive horizontal margin
  Widget _buildContinueButton(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle continue action
          HapticFeedback.lightImpact();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
