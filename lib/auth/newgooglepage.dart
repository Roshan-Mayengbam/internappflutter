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
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            _buildStatusBar(),
            // Main Content
            Expanded(
              child: Stack(
                children: [
                  // Background decorative elements
                  _buildDecorativeElements(),
                  // Main content
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      // Character illustration with speech bubble
                      _buildCharacterSection(),
                      const SizedBox(height: 60),
                      // Main text
                      _buildMainText(),
                      const SizedBox(height: 30),
                      // Subtitle
                      _buildSubtitle(),
                      const Spacer(),
                      // Continue button
                      _buildContinueButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
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
              const SizedBox(width: 4),
              Icon(Icons.wifi, size: 18, color: Colors.black),
              const SizedBox(width: 4),
              Icon(Icons.battery_full, size: 18, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return Stack(
      children: [
        // Crosses
        const Positioned(
          top: 80,
          left: 50,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(15 / 360),
            child: Text(
              '×',
              style: TextStyle(fontSize: 24, color: Colors.black26),
            ),
          ),
        ),
        const Positioned(
          top: 180,
          right: 40,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(-20 / 360),
            child: Text(
              '×',
              style: TextStyle(fontSize: 24, color: Colors.black26),
            ),
          ),
        ),
        const Positioned(
          bottom: 250,
          left: 30,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(45 / 360),
            child: Text(
              '×',
              style: TextStyle(fontSize: 24, color: Colors.black26),
            ),
          ),
        ),
        const Positioned(
          bottom: 150,
          right: 60,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(-30 / 360),
            child: Text(
              '×',
              style: TextStyle(fontSize: 24, color: Colors.black26),
            ),
          ),
        ),
        // Dots
        Positioned(
          top: 120,
          left: 20,
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
          top: 250,
          right: 20,
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
        const Positioned(
          bottom: 200,
          left: 50,
          child: Text(
            '✦',
            style: TextStyle(fontSize: 16, color: Colors.orange),
          ),
        ),
        const Positioned(
          top: 150,
          left: 80,
          child: Text(
            '✦',
            style: TextStyle(fontSize: 16, color: Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterSection() {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Character
          _buildCharacter(),
          // Speech bubble
          Positioned(top: 20, right: 20, child: _buildSpeechBubble()),
        ],
      ),
    );
  }

  Widget _buildCharacter() {
    return SizedBox(
      width: 200,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arms (behind body)
          Positioned(
            top: 100,
            left: 10,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 10,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Body
          Positioned(
            top: 80,
            child: Container(
              width: 80,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          // Legs
          Positioned(
            bottom: 20,
            child: Container(
              width: 100,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF9B59B6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          // Head
          Positioned(
            top: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF8B4513),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Glasses
          Positioned(
            top: 55,
            child: Container(
              width: 50,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.3),
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Transform.rotate(
      angle: -0.1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90E2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'SWIPE\nMATCH\nGROW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMainText() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 48,
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
              const TextSpan(
                text: '✦',
                style: TextStyle(color: Color(0xFFF39C12), fontSize: 40),
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

  Widget _buildContinueButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
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
