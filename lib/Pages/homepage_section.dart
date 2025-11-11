import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePageSection extends StatelessWidget {
  const HomePageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCEDD8),
        title: Text(
          "Here's the Home Section",
          style: GoogleFonts.poppins(
            color: const Color(0xFF27453E),
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Home Section Placeholder'),
      ),
    );
  }
}
