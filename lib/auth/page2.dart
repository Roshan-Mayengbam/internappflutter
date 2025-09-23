import 'package:flutter/material.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(250, 226, 253, 223),
      body: Stack(
        children: [
          Positioned(
            right: 0,
            top: 44,
            child: Image.asset('assets/2image1.png'),
          ),
          Positioned(top: 79, left: 0, child: Image.asset('assets/girl.png')),
          Positioned(
            top: 100,
            right: 20,
            child: Image.asset('assets/2text2.png'),
          ),
          Positioned(top: 412, left: 16, child: Image.asset('assets/JUMP.png')),
          Positioned(top: 496, left: 73, child: Image.asset('assets/IN.png')),
          Positioned(top: 562, left: 16, child: Image.asset('assets/YOUR.png')),
          Positioned(
            top: 627,
            left: 16,
            child: Image.asset('assets/DREAMS.png'),
          ),
          Positioned(
            top: 490,
            left: 150,
            child: Image.asset('assets/Star2.png'),
          ),
          Positioned(top: 487, left: 236, child: Image.asset('assets/TO.png')),
          Positioned(
            top: 737,
            left: 16,
            child: Image.asset('assets/2text1.png'),
          ),
          Positioned(
            top: 795,
            left: 16,
            child: Image.asset('assets/Union1.png'),
          ),
          Positioned(top: 813, left: 135, child: Image.asset('assets/cwg.png')),
          Positioned(
            top: 813,
            left: 35,
            child: Image.asset('assets/google.png'),
          ),

          Positioned(
            top: 800,
            left: 340,
            child: IconButton(
              iconSize: 100,
              onPressed: () {
                print("Image pressed!");
              },
              icon: Image.asset("assets/arrow_outward.png"),
            ),
          ),
        ],
      ),
    );
  }
}
