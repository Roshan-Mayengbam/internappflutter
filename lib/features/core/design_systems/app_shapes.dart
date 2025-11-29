// app_shapes.dart
import 'package:flutter/material.dart';

class AppShapes {
  static const radiusPill = Radius.circular(12);
  static const radiusLg = Radius.circular(20);

  static BorderRadius get pill => const BorderRadius.all(radiusPill);
  static BorderRadius get card => const BorderRadius.all(radiusLg);
}
