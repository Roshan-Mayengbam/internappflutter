import 'package:flutter/material.dart';
import 'package:internappflutter/home/notification.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
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
                onTap: () {}, //nagivate to search page
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
                child: IconButton(
                  icon: Icon(Icons.notifications_none_outlined, size: 30),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => NotificationScreen(),
                    //   ),
                    // );
                  },
                ),
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
                        onPressed: () {},
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
          //           Expanded(
          //             child: MasonryGridView.count(
          //   crossAxisCount: 2, // 2 columns
          //   mainAxisSpacing: 4,
          //   crossAxisSpacing: 4,
          //   itemCount: 50, //photos.length,
          //   i//temBuilder: (context, index) {
          //     return ClipRRect(
          //       borderRadius: BorderRadius.circular(12),
          //       child: Image.network(
          //        photos[index],//conecting to the backend
          //         fit: BoxFit.cover, // keep aspect ratio
          //       ),
          //     );
          //  },
          //  )

          //            ),
          //
        ],
      ),
      // Floating bar at bottom center
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 56,
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.black,
          ), // Half of height for pill shape
        ),
        child: Row(
          children: [
            SizedBox(width: 25),
            InkWell(
              onTap: () {
                // Handle home image tap
              },
              child: Image.asset(
                'assets/home.png', // Replace with your image path
                height: 32,
                width: 32,
              ),
            ),
            SizedBox(width: 25),
            InkWell(
              onTap: () {
                // Handle search image tap
              },
              child: Image.asset(
                'assets/search.png', // Replace with your image path
                height: 32,
                width: 32,
              ),
            ),
            SizedBox(width: 25),
            InkWell(
              onTap: () {
                // Handle favorite image tap
              },
              child: Image.asset(
                'assets/box.png', // Replace with your image path
                height: 32,
                width: 32,
              ),
            ),
            SizedBox(width: 25),
            InkWell(
              onTap: () {
                // Handle person image tap
              },
              child: Image.asset(
                'assets/person.png', // Replace with your image path
                height: 32,
                width: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
