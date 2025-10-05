import 'package:flutter/material.dart';
import 'package:internappflutter/core/components/filter_tag.dart';

class DescriptionScreen extends StatelessWidget {
  const DescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilterTag(label: "On-site", onTap: null, isDashed: true),
    );
  }
}
