import 'package:dotted_border/dotted_border.dart'
    show DottedBorder, RoundedRectDottedBorderOptions;
import 'package:flutter/material.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(
          decoration: BoxDecoration(
            boxShadow: [
              // Bottom shadow
              const BoxShadow(
                color: Colors.black,
                offset: Offset(0, 6),
                blurRadius: 0,
                spreadRadius: -2,
              ),
              // Right shadow
              const BoxShadow(
                color: Colors.black,
                offset: Offset(6, 0),
                blurRadius: 0,
                spreadRadius: -2,
              ),
              // Bottom-right corner shadow
              const BoxShadow(
                color: Colors.black,
                offset: Offset(6, 6),
                blurRadius: 0,
                spreadRadius: -2,
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
              left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
              right: BorderSide(
                color: Color.fromARGB(255, 6, 7, 8),
                width: 2,
              ),
              bottom: BorderSide(
                color: Color.fromARGB(255, 6, 7, 8),
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context); // Goes back to previous screen
            },
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company & Tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Lumel Technologies ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'jost',
                  ),
                ),
                const Icon(Icons.verified, color: Colors.blue, size: 18),
                const Spacer(),
                Container(
                  child: Image.asset(
                    'assets/inhouse.png',
                    width: 170,
                    height: 50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "UI/UX Designer",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'jost',
              ),
            ),
            const Text(
              "Coimbatore, Tamil Nadu, India • 3 weeks ago • Over 100 people clicked apply",
              style: TextStyle(
                fontFamily: 'jost',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Tags
            Row(
              children: [
                _tag("On-site"),
                const SizedBox(width: 10),
                _tag("Full Time"),
                const Spacer(),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        // Bottom shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Right shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Bottom-right corner shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.pink,
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        // Bottom shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Right shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Bottom-right corner shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        top: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Apply Button
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      top: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 2,
                      ),
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 2,
                      ),
                    ),
                    boxShadow: const [
                      // Bottom shadow
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 6),
                        blurRadius: 0,
                        spreadRadius: -2,
                      ),
                      // Right shadow
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(6, 0),
                        blurRadius: 0,
                        spreadRadius: -2,
                      ),
                      // Bottom-right corner shadow
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF9F3C6),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0, // Remove default button shadow
                    ),
                    child: const Text("Apply Now"),
                  ),
                ),

                const SizedBox(width: 25),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: [
                      // Bottom shadow
                      const BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 6),
                        blurRadius: 0,
                        spreadRadius: -2,
                      ),
                      // Right shadow
                      const BoxShadow(
                        color: Colors.black,
                        offset: Offset(6, 0),
                        blurRadius: 0,
                        spreadRadius: -2,
                      ),
                      // Bottom-right corner shadow
                      const BoxShadow(
                        color: Colors.black,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                        spreadRadius: -2,
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      top: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 2,
                      ),
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 6, 7, 8),
                        width: 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    "No. of Openings\n20",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // About job
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // background color of the section
                border: Border.all(
                  color: Colors.black26, // border color (subtle)
                  width: 1, // border thickness
                ),
                borderRadius: BorderRadius.circular(10), // rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16), // inner padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("About the job"),
                  _infoGrid([
                    _infoCard("Job Type", "Full Time"),
                    _infoCard("Duration", "2month"),
                    _infoCard("Mode", "Online"),
                    _infoCard("Stipend", "20k/month"),
                  ]),
                  const SizedBox(height: 16),

                  // Skills
                  Text(
                    "Skills:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'jost',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 25,
                      children: [
                        _chip("ADOBE"),
                        _chip("FIGMA"),
                        _chip("CANVA"),
                        _chip("ADOBE"),
                        _chip("FIGMA"),
                        _chip("CANVA"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Roles
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // background color
                border: Border.all(
                  color: Colors.black26, // subtle border
                  width: 1, // border thickness
                ),
                borderRadius: BorderRadius.circular(10), // rounded corners
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(2, 2), // shadow position
                    blurRadius: 4, // shadow blur
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16), // inner spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Roles and Responsibility:"),
                  const SizedBox(height: 8),
                  _description(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Perks:"),
            Wrap(
              spacing: 40,
              runSpacing: 20,
              children: [
                _chip("Certificate"),
                _chip("Letter of recommendation"),
                _chip("Stipend"),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // background color
                border: Border.all(
                  color: Colors.black26, // subtle border
                  width: 1, // border thickness
                ),
                borderRadius: BorderRadius.circular(10), // rounded corners
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(2, 2), // shadow position
                    blurRadius: 4, // shadow blur
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16), // inner spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Details :"),
                  const SizedBox(height: 8),
                  _description(),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // background color
                border: Border.all(
                  color: Colors.black26, // subtle border
                  width: 1, // border thickness
                ),
                borderRadius: BorderRadius.circular(10), // rounded corners
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(2, 2), // shadow position
                    blurRadius: 4, // shadow blur
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16), // inner spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("About Lumel Technologies :"),
                  const SizedBox(height: 8),
                  _description(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  static Widget _tag(String text) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF9F3C6), // background color for the whole tag
      borderRadius: BorderRadius.circular(10), // match DottedBorder radius
    ),
    child: DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        strokeWidth: 1.5,
        color: Colors.black26,
        dashPattern: const <double>[4, 3],
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    ),
  );

  static Widget _infoCard(String title, String value) => Container(
    width: 150,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      boxShadow: [
        // Bottom shadow
        const BoxShadow(
          color: Colors.black,
          offset: Offset(0, 6),
          blurRadius: 0,
          spreadRadius: -2,
        ),
        // Right shadow
        const BoxShadow(
          color: Colors.black,
          offset: Offset(6, 0),
          blurRadius: 0,
          spreadRadius: -2,
        ),
        // Bottom-right corner shadow
        const BoxShadow(
          color: Colors.black,
          offset: Offset(6, 6),
          blurRadius: 0,
          spreadRadius: -2,
        ),
      ],
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: const Border(
        top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
        left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
        right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
      ),
    ),
    child: Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontFamily: 'jost')),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'jost',
          ),
        ),
      ],
    ),
  );

  static Widget _infoGrid(List<Widget> children) =>
      Wrap(spacing: 12, runSpacing: 12, children: children);

  static Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
    decoration: BoxDecoration(
      boxShadow: [
        // Bottom shadow
        const BoxShadow(
          color: Colors.black,
          offset: Offset(0, 6),
          blurRadius: 0,
          spreadRadius: -2,
        ),
        // Right shadow
        const BoxShadow(
          color: Colors.black,
          offset: Offset(6, 0),
          blurRadius: 0,
          spreadRadius: -2,
        ),
        // Bottom-right corner shadow
        const BoxShadow(
          color: Colors.black,
          offset: Offset(6, 6),
          blurRadius: 0,
          spreadRadius: -2,
        ),
      ],
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: const Border(
        top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
        left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
        right: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
        bottom: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 2),
      ),
    ),
    child: Text(text, style: TextStyle(color: Color(0xFF1FA7E3))),
  );

  static Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fontFamily: 'jost',
    ),
  );

  static Widget _description() => Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      "Durante seu estágio, você pode aprimorar seu conhecimento e ganhar experiência profissional trabalhando em projetos de clientes. Esta função oferece uma oportunidade excepcional para construir um portfólio atraente, adquirir novas habilidades, obter insights sobre diversos setores e abraçar novos desafios para sua futura carreira.",
      style: TextStyle(fontSize: 13, fontFamily: 'jost'),
    ),
  );
}
