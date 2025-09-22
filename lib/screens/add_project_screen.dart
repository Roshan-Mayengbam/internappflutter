import 'package:flutter/material.dart';

class AddProjectScreen extends StatelessWidget {
  const AddProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Projects',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Projects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '“Flex your side hustles, hackathons, or college builds. Drop links & let recruiters see your work 🚀.”',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _inputField('Project Name', 'Write the name of the Project'),
            _inputField('Link', 'Paste the link of your project'),
            _inputField('Description', 'Describe the project', maxLines: 4),
            const SizedBox(height: 20),
            _button('Add', Color(0xFFF5B967), Colors.white),
            const SizedBox(height: 12),
            _button('Done', Color(0xFFB6A5FE), Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 6),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(6, 0),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: TextFormField(
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(String text, Color bg, Color txtColor) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0, 6),
              blurRadius: 0,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black,
              offset: Offset(6, 0),
              blurRadius: 0,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black,
              offset: Offset(6, 6),
              blurRadius: 0,
              spreadRadius: -2,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shadowColor: Colors.transparent,
          ),
          child: Text(
            text,
            style: TextStyle(color: txtColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
