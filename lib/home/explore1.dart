import 'package:flutter/material.dart';

class Explore1 extends StatefulWidget {
  final String title;
  const Explore1({super.key, required this.title});
  @override
  State<Explore1> createState() => _Explore1State();
}

class _Explore1State extends State<Explore1> {
  @override
  Widget build(BuildContext context) {
    String title;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30),
          Row(
            children: [
              SizedBox(width: 5),
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
                  onPressed: () {},
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              SizedBox(width: 10),
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
                        child: Icon(Icons.search, size: 20),
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
            ],
          ),
          SizedBox(height: 30),
          Container(
            height: 661,
            width: 408,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),

            child: Image.asset(widget.title, fit: BoxFit.contain),
          ),
          SizedBox(height: 10),
          Container(
            height: 72,
            width: 408,
            child: Row(
              children: [
                SizedBox(width: 20),
                Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'UI/UX Designer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Lumel Technologies',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(width: 150),
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(252, 247, 141, 247),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 0,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      size: 30,
                      color: Colors.purpleAccent,
                    ),
                    onPressed: () {
                      // Handle favorite icon tap
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
