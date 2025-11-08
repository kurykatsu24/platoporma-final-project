import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:platoporma/Pages/onboarding_screen.dart';

class SignUpCompletionScreen extends StatelessWidget {
  const SignUpCompletionScreen({super.key});

  Future<void> signOut(BuildContext context) async {
    // 👇 Signs out and clears the persisted session
    await Supabase.instance.client.auth.signOut();

    // ✅ Navigate back to OnboardingScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      (route) => false, // remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign-Up Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () => signOut(context),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent.shade200,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}