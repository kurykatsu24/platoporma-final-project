import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/pages/mainpage_section.dart';
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
                  width: MediaQuery.of(context).size.width * 0.38
                ),
                const SizedBox(height: 5),

                // Reused Title Container from onboarding
                Transform.translate(
                      offset: const Offset(0, 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCEDD8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: const Offset(13, 0),
                                child: Image.asset(
                                  'assets/images/fork_icon.png',
                                  width: 65,
                                  height: 65,
                                ),
                              ),
                              Column(
                                children: [
                                  Transform.translate(
                                    offset: const Offset(0, 12),
                                    child: Text(
                                      'Welcome to',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF27453E),
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, -5),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Plato',
                                            style: GoogleFonts.poppins(
                                              fontSize: 38,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF27453E),
                                              letterSpacing: -2,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Porma',
                                            style: GoogleFonts.poppins(
                                              fontSize: 38,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
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
                              Transform.translate(
                                offset: const Offset(-13, 0),
                                child: Image.asset(
                                  'assets/images/spoon_icon.png',
                                  width: 65,
                                  height: 65,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                
                const SizedBox(height: 100),

                // --- Welcome Text ---
                _buildCompletionText(firstName),

                const SizedBox(height: 150),

                // --- Proceed Button ---
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) => const MainPageSection(),
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
                    fixedSize: const Size(280, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Proceed to Homepage',
                    style: GoogleFonts.poppins(
                      fontSize: 14 * MediaQuery.of(context).textScaleFactor,
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
            fontSize: 42 * MediaQuery.of(context).textScaleFactor,
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
            fontSize: 50 * MediaQuery.of(context).textScaleFactor,
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
            fontSize: 16 * MediaQuery.of(context).textScaleFactor,
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
