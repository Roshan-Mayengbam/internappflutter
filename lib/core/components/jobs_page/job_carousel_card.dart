import 'package:flutter/material.dart';

class JobCarouselCard extends StatelessWidget {
  const JobCarouselCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 65,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
