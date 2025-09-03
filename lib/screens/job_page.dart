import 'package:flutter/material.dart';

import 'package:internappflutter/core/components/jobs_page/job_carousel_card.dart';

import '../core/components/jobs_page/filter_tag.dart';

class JobPage extends StatefulWidget {
  const JobPage({Key? key}) : super(key: key);

  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: JobCarouselCard(
              jobTitle: 'UI/UX Designer',
              companyName: 'Laravel Company',
              location: 'Bangalore',
              experienceLevel: 'Junior Dev',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilterTag(label: 'Featured', isSelected: true, onTap: () {}),
              FilterTag(label: 'Live', isSelected: false, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
