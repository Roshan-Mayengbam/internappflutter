import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class HackathonDetailsScreen extends StatelessWidget {
  const HackathonDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organizer + Logo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Google Developers Group ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.verified, color: Colors.blue, size: 18),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "CodeSprint 2024",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Coimbatore, Tamil Nadu, India • 3 weeks ago • Over 100 people clicked apply",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Tags
            Row(
              children: [
                _tag("On-site"),
                const SizedBox(width: 10),
                _tag("Full Time"),
                const Spacer(),
                const Icon(Icons.favorite_border, color: Colors.pink),
              ],
            ),
            const SizedBox(height: 12),

            // Apply Button
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
            const SizedBox(height: 20),

            // About the job
            _sectionTitle("About the job"),
            const SizedBox(height: 12),

            _infoGrid([
              _infoCard("Mode", "Online"),
              _infoCard("Start Date", "2024-02-15"),
              _infoCard("End Date", "2024-02-17"),
              _infoCard("Prize", "20k/month"),
            ]),
            const SizedBox(height: 20),

            _sectionTitle("Description:"),
            _description(),
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
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      style: TextStyle(fontSize: 13),
    ),
  );
}
