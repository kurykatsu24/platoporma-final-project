import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/Pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCompletionScreen extends StatefulWidget {
  const LoginCompletionScreen({super.key});

  @override
  State<LoginCompletionScreen> createState() => _LoginCompletionScreenState();
}

class _LoginCompletionScreenState extends State<LoginCompletionScreen> {
  String? firstName;

  @override
  void initState() {
    super.initState();
    _fetchFirstName();
  }

  Future<void> _fetchFirstName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('first_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          firstName = response['first_name'];
        });
      }
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 80),

              // Logo
              Image.asset(
                'assets/images/platoporma_logo_whitebg1.png',
                width: 185,
                height: 185,
              ),

              const SizedBox(height: 60),

              // --- Welcome Text ---
              _buildCompletionText(),

              const SizedBox(height: 100),

              // --- Proceed Button ---
              ElevatedButton(
                onPressed: _goToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE795C),
                  overlayColor: const Color.fromARGB(
                    255,
                    218,
                    101,
                    71,
                  ).withOpacity(0.15),
                  fixedSize: const Size(300, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Proceed to Homepage',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Welcome Text Widget ---
  Widget _buildCompletionText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome back, ${firstName ?? ''}!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: -2,
            color: const Color(0xFF27453E),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Glad to see you again. Let's explore more recipes!",
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 19,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF27453E),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}
