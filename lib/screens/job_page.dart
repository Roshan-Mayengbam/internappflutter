import 'package:flutter/material.dart';

import 'package:internappflutter/core/components/jobs_page/job_carousel_card.dart';

class JobPage extends StatefulWidget {
  const JobPage({Key? key}) : super(key: key);

  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  @override
  Widget build(BuildContext context) {
    return JobCarouselCard();
  }
}
