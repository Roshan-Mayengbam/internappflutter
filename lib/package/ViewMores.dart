import 'package:flutter/material.dart';
import 'package:internappflutter/core/components/jobs_page/job_carousel_card.dart';

class ViewMores extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool statusPage;
  const ViewMores({super.key, required this.items, required this.statusPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: (statusPage)
                  ? CarouselCard(
                      title: item["jobTitle"],
                      subtitle: item["companyName"],
                      tag1: statusPage ? "Applied" : "Not Applied",
                      statusCard: statusPage,
                    )
                  : CarouselCard(
                      title: item["jobTitle"],
                      subtitle: item["companyName"],
                      tag1: item["location"],
                      tag2: item['experienceLevel'],
                      statusCard: statusPage,
                    ),
            );
          },
        ),
      ),
    );
  }
}
