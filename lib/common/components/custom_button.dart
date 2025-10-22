import 'package:flutter/material.dart';

import 'package:internappflutter/common/constants/button_constants.dart';

// Use expanded if you want to occupy max space horizontally
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.foregroundColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.iconSize = 32,
    required this.buttonIcon,
    required this.onPressed,
  });

  final double iconSize;
  final VoidCallback onPressed;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData buttonIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: ButtonConstants.size,
        height: ButtonConstants.size,
        decoration: BoxDecoration(
          color: foregroundColor,
          borderRadius: BorderRadius.circular(ButtonConstants.borderRadius),
          border: Border.all(
            color: Colors.black,
            width: ButtonConstants.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: backgroundColor,
              offset: ButtonConstants.shadowOffset,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            buttonIcon,
            color: backgroundColor,
            size: iconSize, // Adjust icon size as needed
          ),
        ),
      ),
    );
  }
}
