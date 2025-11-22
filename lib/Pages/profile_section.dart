import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:platoporma/pages/onboarding_screen.dart'; 

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCEDD8),
        title: Text(
          "Here's the Profile Section",
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
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signOut(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEE795C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: Text(
            'Sign Out',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}