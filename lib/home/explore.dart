import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> allJobs = [
    'Software Engineer Intern',
    'Data Science Intern',
    'Frontend Developer',
    'Backend Developer',
    'Mobile App Developer',
    'UI/UX Designer',
    'Product Manager Intern',
    'Marketing Intern',
    'Business Analyst',
    'DevOps Engineer',
  ];
  List<String> filteredJobs = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredJobs = allJobs;
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredJobs = allJobs;
        isSearching = false;
      } else {
        isSearching = true;
        filteredJobs = allJobs
            .where((job) => job.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _navigateToSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(
          onSearch: _performSearch,
          searchController: _searchController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30),
          Row(
            children: [
              SizedBox(width: 5),
              InkWell(
                onTap: _navigateToSearchPage,
                child: Stack(
                  children: [
                    Container(
                      height: 44,
                      width: 289,
                      decoration: BoxDecoration(
                        color: Color(0xFFD7C3FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 0,
                            spreadRadius: 1,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        height: 25,
                        width: 25,
                        child: Icon(Icons.search, size: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 0,
                              spreadRadius: 0,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 50,
                      top: 12,
                      child: Text(
                        'Search jobs',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Jost',
                          color: const Color.fromARGB(255, 8, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 0,
                      spreadRadius: 1,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.messenger_outline, size: 30),
                  onPressed: () {
                    // Handle messenger icon tap
                  },
                ),
              ),
              SizedBox(width: 10),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 0,
                      spreadRadius: 1,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                // child: IconButton(
                //   icon: Icon(Icons.notifications_none_outlined, size: 30),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => NotificationScreen(),
                //       ),
                //     );
                //   },
                // ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Container(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final buttonLabels = [
                  'Tech',
                  'Non Tech',
                  'Latest',
                  'Internship',
                  'Job',
                  'Hackathon',
                  'Links',
                ];
                return Row(
                  children: [
                    Container(
                      height: 44,
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // Filter by category
                          _performSearch(buttonLabels[index]);
                        },
                        child: Text(
                          buttonLabels[index],
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Jost',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 30),
          // Search Results Display
          if (isSearching)
            Expanded(
              child: ListView.builder(
                itemCount: filteredJobs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 0,
                          spreadRadius: 1,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        filteredJobs[index],
                        style: TextStyle(
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to job details
                      },
                    ),
                  );
                },
              ),
            ),
          // Original content when not searching
          if (!isSearching)
            Expanded(
              child: Center(
                child: Text(
                  'Tap the search bar to find jobs',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Jost',
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Dedicated Search Page
class SearchPage extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController searchController;

  const SearchPage({
    super.key,
    required this.onSearch,
    required this.searchController,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Jobs'),
        backgroundColor: Color(0xFFD7C3FF),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    spreadRadius: 1,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search for jobs, internships...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  widget.onSearch(value);
                },
                onSubmitted: (value) {
                  widget.onSearch(value);
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jost',
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        'Software Engineer',
                        'Data Science',
                        'UI/UX Design',
                        'Marketing',
                        'Product Manager',
                      ]
                      .map(
                        (tag) => GestureDetector(
                          onTap: () {
                            widget.searchController.text = tag;
                            widget.onSearch(tag);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFD7C3FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
///modified code 
// class ExplorePage extends StatefulWidget {
//   const ExplorePage({super.key});

//   @override
//   State<ExplorePage> createState() => _ExplorePageState();
// }

// class _ExplorePageState extends State<ExplorePage> {
//   final photos = [
//     'assets/Union.png',
//     'assets/Logo.png',
//     'assets/Group 1686552468.png',
//     'assets/person.png',
//     'assets/box.png',
//     'assets/search.png',
//     'assets/home.png',
//     'assets/text1.png',
//     'assets/text2.png',
//     'assets/celebrate.png',
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           SizedBox(height: 30),
//           Row(
//             children: [
//               SizedBox(width: 5),
//               InkWell(
//                 onTap: () {}, //nagivate to search page
//                 child: Stack(
//                   children: [
//                     Container(
//                       height: 44,
//                       width: 289,
//                       decoration: BoxDecoration(
//                         color: Color(0xFFD7C3FF),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.black),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black,
//                             blurRadius: 0,
//                             spreadRadius: 1,
//                             offset: Offset(2, 2),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Positioned(
//                       left: 10,
//                       top: 10,
//                       child: Container(
//                         height: 25,
//                         width: 25,
//                         child: Icon(Icons.search, size: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(color: Colors.black),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black,
//                               blurRadius: 0,
//                               spreadRadius: 0,
//                               offset: Offset(2, 2),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       left: 50,
//                       top: 12,
//                       child: Text(
//                         'Search jobs',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontFamily: 'Jost',
//                           color: const Color.fromARGB(255, 8, 0, 0),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 10),
//               Container(
//                 height: 44,
//                 width: 44,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.black),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black,
//                       blurRadius: 0,
//                       spreadRadius: 1,
//                       offset: Offset(2, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   icon: Icon(Icons.messenger_outline, size: 30),
//                   onPressed: () {
//                     // Handle messenger icon tap
//                   },
//                 ),
//               ),
//               SizedBox(width: 10),
//               Container(
//                 height: 44,
//                 width: 44,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.black),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black,
//                       blurRadius: 0,
//                       spreadRadius: 1,
//                       offset: Offset(2, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   icon: Icon(Icons.notifications_none_outlined, size: 30),
//                   onPressed: () {
//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => NotificationScreen(),
//                     //   ),
//                     // );
//                   },
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 30),
//           Container(
//             height: 44,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: 7,
//               itemBuilder: (context, index) {
//                 final buttonLabels = [
//                   'Tech',
//                   'Non Tech',
//                   'Latest',
//                   'Internship',
//                   'Job',
//                   'Hackathon',
//                   'Links',
//                 ];
//                 return Row(
//                   children: [
//                     Container(
//                       height: 44,
//                       width: 90,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(5),
//                         border: Border.all(color: Colors.black),
//                       ),
//                       child: TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           buttonLabels[index],
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.w600,
//                             fontFamily: 'Jost',
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                   ],
//                 );
//               },
//             ),
//           ),
//           SizedBox(height: 30),
//           Expanded(
//             child: MasonryGridView.count(
//               crossAxisCount: 2, // 2 columns
//               mainAxisSpacing: 4,
//               crossAxisSpacing: 4,
//               itemCount: photos.length,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Explore1(title: photos[index]),
//                       ),
//                     );
//                   },
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.asset(
//                       photos[index], //connecting to the backend
//                       fit: BoxFit.cover, // keep aspect ratio
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       // Floating bar at bottom center
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: Container(
//         height: 56,
//         width: 260,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(28),
//           border: Border.all(
//             color: Colors.black,
//           ), // Half of height for pill shape
//         ),
//         child: Row(
//           children: [
//             SizedBox(width: 25),
//             InkWell(
//               onTap: () {
//                 // Handle home image tap
//               },
//               child: Image.asset(
//                 'assets/home.png', // Replace with your image path
//                 height: 32,
//                 width: 32,
//               ),
//             ),
//             SizedBox(width: 25),
//             InkWell(
//               onTap: () {
//                 // Handle search image tap
//               },
//               child: Image.asset(
//                 'assets/search.png', // Replace with your image path
//                 height: 32,
//                 width: 32,
//               ),
//             ),
//             SizedBox(width: 25),
//             InkWell(
//               onTap: () {
//                 // Handle favorite image tap
//               },
//               child: Image.asset(
//                 'assets/box.png', // Replace with your image path
//                 height: 32,
//                 width: 32,
//               ),
//             ),
//             SizedBox(width: 25),
//             InkWell(
//               onTap: () {
//                 // Handle person image tap
//               },
//               child: Image.asset(
//                 'assets/person.png', // Replace with your image path
//                 height: 32,
//                 width: 32,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
