import 'package:flutter/material.dart';
import 'package:internappflutter/core/components/custom_button.dart';
import 'package:internappflutter/core/components/custom_search_field.dart';

import '../core/components/custom_app_bar.dart';
import '../core/components/jobs_page/custom_carousel_section.dart';
import '../core/components/jobs_page/filter_tag.dart';
import '../core/components/jobs_page/job_carousel_card.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  final List<String> jobFilters = [
    'Featured',
    'Live',
    'Upcoming',
    'Always Open',
    'Full-Time',
    'Part-Time',
    'Internship',
  ];

  String selectedJobFilter = 'Featured';

  final List<Map<String, dynamic>> jobs = const [
    {
      'jobTitle': 'Senior Full-Stack Developer',
      'companyName': 'Innovate Solutions Inc.',
      'experienceLevel': '5+ years',
      'description':
          'Develop and maintain web applications using the MERN stack.',
      'isVerified': true,
      'location': 'San Francisco',
      'tags': ['REMOTE', 'FULL-TIME', 'TECH'],
    },
    {
      'jobTitle': 'Product Manager',
      'companyName': 'Apex Innovations',
      'experienceLevel': '3-5 years',
      'description': 'Lead product development from ideation to launch.',
      'isVerified': false,
      'location': 'New York',
      'tags': ['PRODUCT', 'AGILE', 'FINTECH'],
    },
    {
      'jobTitle': 'Data Scientist',
      'companyName': 'DataCraft Analytics',
      'experienceLevel': '2-4 years',
      'description': 'Analyze large datasets to provide actionable insights.',
      'isVerified': true,
      'location': 'Boston',
      'tags': ['DATA', 'AI/ML', 'HEALTHCARE'],
    },
    {
      'jobTitle': 'Marketing Specialist',
      'companyName': 'Growth Hub Agency',
      'experienceLevel': '1-3 years',
      'description': 'Develop and execute digital marketing campaigns.',
      'isVerified': true,
      'location': 'Remote',
      'tags': ['MARKETING', 'REMOTE', 'DIGITAL'],
    },
    {
      'jobTitle': 'DevOps Engineer',
      'companyName': 'CloudSphere Tech',
      'experienceLevel': '4-6 years',
      'description': 'Manage and optimize cloud infrastructure on AWS.',
      'isVerified': true,
      'location': 'Seattle',
      'tags': ['DEVOPS', 'CLOUD', 'AWS'],
    },
    {
      'jobTitle': 'UI/UX Designer',
      'companyName': 'Creative Minds Studio',
      'experienceLevel': '0-2 years',
      'description': 'Create intuitive and beautiful user interfaces.',
      'isVerified': false,
      'location': 'Austin',
      'tags': ['DESIGN', 'UX/UI', 'STARTUP'],
    },
    {
      'jobTitle': 'Mobile App Developer',
      'companyName': 'Appify Solutions',
      'experienceLevel': '2-3 years',
      'description': 'Build cross-platform mobile applications with Flutter.',
      'isVerified': true,
      'location': 'Toronto',
      'tags': ['MOBILE', 'FLUTTER', 'CROSS-PLATFORM'],
    },
    {
      'jobTitle': 'Cybersecurity Analyst',
      'companyName': 'SecureNet Systems',
      'experienceLevel': '3-5 years',
      'description': 'Protect company data and systems from threats.',
      'isVerified': true,
      'location': 'Washington D.C.',
      'tags': ['SECURITY', 'CYBER', 'GOVERNMENT'],
    },
    {
      'jobTitle': 'Game Developer',
      'companyName': 'Pixel Playground',
      'experienceLevel': '1-4 years',
      'description': 'Design and develop engaging video games.',
      'isVerified': false,
      'location': 'Los Angeles',
      'tags': ['GAMING', 'UNITY', 'CREATIVE'],
    },
    {
      'jobTitle': 'HR Generalist',
      'companyName': 'People First Corp.',
      'experienceLevel': '2-5 years',
      'description': 'Handle all aspects of human resources operations.',
      'isVerified': true,
      'location': 'Chicago',
      'tags': ['HR', 'CORPORATE', 'BUSINESS'],
    },
  ];

  final List<String> hackathonFilters = [
    'Featured',
    'Upcoming',
    'Live',
    'Remote',
    'In-Person',
  ];

  String selectedHackathonFilter = 'Upcoming';

  final List<Map<String, dynamic>> hackathons = const [
    {
      'jobTitle': 'AI for Good Challenge',
      'companyName': 'Tech for Humanity',
      'location': 'Online',
      'experienceLevel': 'Undergraduates',
      'date': 'October 25-27, 2025',
      'theme': 'Using AI to solve social and environmental problems.',
      'prizes': ['\$5,000 Cash', 'Mentorship', 'Job Interviews'],
      'tags': ['AI', 'SOCIAL GOOD', 'VIRTUAL'],
    },
    {
      'jobTitle': 'Fintech Frontier Hack',
      'companyName': 'Finnovate Labs',
      'location': 'London',
      'date': 'November 1-3, 2025',
      'experienceLevel': 'Undergraduates',
      'theme': 'Innovations in financial technology and digital payments.',
      'prizes': ['\$10,000 Seed Funding', 'Incubator Spot'],
      'tags': ['FINTECH', 'IN-PERSON', 'LONDON'],
    },
    {
      'jobTitle': 'Health-Tech Innovation Sprint',
      'companyName': 'Global Health Institute',
      'location': 'Boston',
      'date': 'November 8-10, 2025',
      'experienceLevel': 'Working Professionals',
      'theme': 'Developing solutions for modern healthcare challenges.',
      'prizes': ['\$7,500 Grant', 'Partnership with Hospitals'],
      'tags': ['HEALTHCARE', 'MEDTECH', 'BOSTON'],
    },
    {
      'jobTitle': 'Game Jam 2025',
      'companyName': 'Indie Game Collective',
      'location': 'Online',
      'experienceLevel': 'High School',
      'date': 'December 6-8, 2025',
      'theme': 'Create a game from scratch in 48 hours.',
      'prizes': ['Publishing Deal', 'Console Dev Kits'],
      'tags': ['GAMING', 'DEVELOPMENT', 'VIRTUAL'],
    },
    {
      'jobTitle': 'Cyber Defense Marathon',
      'companyName': 'Secure Future Foundation',
      'experienceLevel': 'Undergraduates',
      'location': 'Washington D.C.',
      'date': 'December 13-15, 2025',
      'theme': 'Build tools to combat cyber threats and protect data.',
      'prizes': ['\$6,000 Cash', 'Internships with Government Agencies'],
      'tags': ['CYBERSECURITY', 'SECURITY', 'IN-PERSON'],
    },
    {
      'jobTitle': 'Sustainable Techathon',
      'companyName': 'Green Earth Alliance',
      'experienceLevel': 'Undergraduates',
      'location': 'Remote',
      'date': 'January 10-12, 2026',
      'theme': 'Developing sustainable and eco-friendly technology.',
      'prizes': ['\$4,000 Cash', 'Featured on Tech Blog'],
      'tags': ['SUSTAINABILITY', 'ENVIRONMENT', 'REMOTE'],
    },
    {
      'jobTitle': 'Data Science & Machine Learning Challenge',
      'companyName': 'Data Guild',
      'location': 'Seattle',
      'experienceLevel': 'Undergraduates',
      'date': 'January 24-26, 2026',
      'theme': 'Solve complex real-world problems with data.',
      'prizes': ['Job Offer', 'Trip to Tech Conference'],
      'tags': ['DATA SCIENCE', 'ML', 'IN-PERSON'],
    },
    {
      'jobTitle': 'UX/UI Design Sprint',
      'companyName': 'Design Masters',
      'location': 'Online',
      'experienceLevel': 'Undergraduates',
      'date': 'February 7-9, 2026',
      'theme': 'Designing intuitive user experiences and interfaces.',
      'prizes': ['Portfolio Review', 'Design Tool Subscriptions'],
      'tags': ['DESIGN', 'UX/UI', 'VIRTUAL'],
    },
    {
      'jobTitle': 'Open Source Contribution Weekend',
      'companyName': 'Community Coders',
      'location': 'Online',
      'experienceLevel': 'Undergraduates',
      'date': 'February 21-23, 2026',
      'theme': 'Contribute to popular open-source projects.',
      'prizes': ['Special Mentions', 'Swag'],
      'tags': ['OPEN SOURCE', 'COMMUNITY', 'REMOTE'],
    },
    {
      'jobTitle': 'Robotics Rumble',
      'companyName': 'RoboTech Labs',
      'location': 'Silicon Valley',
      'experienceLevel': 'Tech Enthusiasts',
      'date': 'March 7-9, 2026',
      'theme': 'Build and program a robot to complete a challenge.',
      'prizes': ['\$8,000 Cash', 'Robotics Kit'],
      'tags': ['ROBOTICS', 'ENGINEERING', 'IN-PERSON'],
    },
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // We get the height of the screen to make the carousels responsive.
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            // Custom App Bar
            CustomAppBar(
              searchController: _searchController,
              onSearchSubmit: (query) {
                print("Search submitted: $query");
                // Your search logic
              },
              onChatPressed: () {
                print("Chat button pressed");
              },
              onNotificationPressed: () {
                print("Notification button pressed");
              },
            ),
            const SizedBox(height: 30),
            // Top Job Picks Section
            CustomCarouselSection(
              title: 'Top job picks for you',
              subtitle:
                  'Based on your profile, preference and activity like applies, searches and saves',
              filters: jobFilters,
              selectedFilter: selectedJobFilter,
              onFilterTap: (filter) {
                setState(() {
                  selectedJobFilter = filter;
                });
              },
              items: jobs,
            ),
            const SizedBox(height: 30),
            CustomCarouselSection(
              title: 'Hackathon',
              subtitle:
                  'Based on your profile, preference and activity like applies, searches and saves',
              filters: hackathonFilters,
              selectedFilter: selectedHackathonFilter,
              onFilterTap: (filter) {
                setState(() {
                  selectedHackathonFilter = filter;
                });
              },
              items: hackathons,
            ),
          ],
        ),
      ),
    );
  }
}
