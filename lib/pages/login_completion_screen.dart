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
                  width: MediaQuery.of(context).size.width * 0.35
                ),
                const SizedBox(height: 5),

                    //<---Title container (include ang Welcome to PlatoPorma and fork and spoon icons with bg mint green) --->
                    Transform.translate(
                      offset: const Offset(0, 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2ebd2),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: const Offset(8, 0),
                                child: Image.asset(
                                  'assets/images/fork_icon.png',
                                  width: 75,
                                  height: 75,
                                ),
                              ),
                              Column(
                                children: [
                                  Transform.translate(
                                    offset: const Offset(0, 6),
                                    child: Text(
                                      'Welcome to',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF27453E),
                                        letterSpacing: -2.2,
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, -3),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'PlatoPorma',
                                            style: const TextStyle(
                                              fontFamily: 'NiceHoney',
                                              fontSize: 44,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF27453E),
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                              Transform.translate(
                                offset: const Offset(-8, 0),
                                child: Image.asset(
                                  'assets/images/spoon_icon.png',
                                  width: 75,
                                  height: 75,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                
                const SizedBox(height: 95),

                // --- Welcome Text ---
                _buildCompletionText(firstName),

                const SizedBox(height: 140),

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
                    backgroundColor: const Color(0xFFf06644),
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
                    style: GoogleFonts.dmSans(
                      fontSize: 15.3 * MediaQuery.of(context).textScaleFactor,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.4,
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
          style: TextStyle(
            fontFamily: 'NiceHoney',
            fontSize: 40 * MediaQuery.of(context).textScaleFactor,
            height: 0.9, // tighter line height
            fontWeight: FontWeight.w500,
            letterSpacing: -0.4,
            color: const Color(0xFF27453E),
          ),
        ),

        // First name
        Text(
          '${firstName ?? ''}!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'NiceHoney',
            fontSize: 48 * MediaQuery.of(context).textScaleFactor,
            height: 1.2, // consistent line height
            fontWeight: FontWeight.w700,
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
            fontWeight: FontWeight.w600,
            color: const Color(0xFF27453E),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}
