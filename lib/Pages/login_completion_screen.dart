import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/Pages/homepage_section.dart';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                const SizedBox(height: 15),

                // Reused Title Container from onboarding
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 23),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCEDD8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/fork_icon.png',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(width: 2),
                      Column(
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 10),
                            child: Text(
                              'Welcome to',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF27453E),
                                letterSpacing: -1.5,
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -6),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Plato',
                                    style: GoogleFonts.poppins(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF27453E),
                                      letterSpacing: -2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Porma',
                                    style: GoogleFonts.poppins(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF27453E),
                                      letterSpacing: -2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 2),
                      Image.asset(
                        'assets/images/spoon_icon.png',
                        width: 80,
                        height: 80,
                      ),
                    ],
                  ),
                ),


                
                const SizedBox(height: 140),

                // --- Welcome Text ---
                _buildCompletionText(firstName),

                const SizedBox(height: 215),

                // --- Proceed Button ---
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) => const HomePageSection(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0); // slide in from right to left
                              const end = Offset.zero;
                              final curve = Curves.easeInOut;
                               final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                               return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                  },
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
      ),
    );
  }

  // --- Welcome Text Widget ---
  Widget _buildCompletionText(String? firstName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Welcome back,"
        Text(
          'Welcome back,',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 48,
            height: 0.9, // tighter line height
            fontWeight: FontWeight.bold,
            letterSpacing: -2,
            color: const Color(0xFF27453E),
          ),
        ),

        // First name
        Text(
          '${firstName ?? ''}!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 55,
            height: 1.2, // consistent line height
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: const Color(0xFF27453E),
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
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
