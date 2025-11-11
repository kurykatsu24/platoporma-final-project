import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/Pages/signup_screen.dart';
import 'package:platoporma/Pages/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    //Spring Pop Animation for the logo upon entering the screen (like a pop/bounce effect)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    //to be called later
    _scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    //initial start animation after a slight delay (to sync with splash fade)
    Future.delayed(const Duration(milliseconds: 500), () {
      _logoController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          //background adobong manok(has a darken filter black)
          Positioned( //adjusting position that matches our prototype
            left: 40,
            top: -30,
            child: Transform.scale( //wrapped in here para mascale
              scale: 1.2,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.1),
                  BlendMode.darken,
                ),
                child: Image.asset(
                  'assets/images/adobong_manok.png',
                  fit: BoxFit.cover, //set to keep proportions better when scaling
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          ),

          //Top logo (platoporma with white bg 1)
          Positioned(
            top: 55,
            child: ScaleTransition(
              scale: _scaleAnimation, //calling the scale animation as an entrance animation
              child: Image.asset(
                'assets/images/platoporma_logo_whitebg1.png',
                width: 110,
                height: 110,
              ),
            ),
          ),

          //Container for title, subtexts and buttons for auth
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(width: 500, height: 412,
              decoration: const BoxDecoration(
                color: Color(0xFFFDFFEC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(95, 0, 0, 0),
                    blurRadius: 15, 
                    spreadRadius: 7, 
                    offset: Offset(0, 6), 
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    //Title container (include ang Welcome to PlatoPorma and fork and spoon icons with bg mint green)
                    Transform.translate(offset: const Offset(0, 8), //to move the eleents freely
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCEDD8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/fork_icon.png',
                                width: 80, height: 80),
                            const SizedBox(width: 1),
                            Column(
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, 12),
                                  child: Text(
                                    'Welcome to',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF27453E),
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(0, -5),
                                  child: RichText(
                                    text: TextSpan( //hiwalay ang specifications of Plato and Porma, just to apply italic style to Porma
                                      children: [
                                        TextSpan(
                                          text: 'Plato',
                                          style: GoogleFonts.poppins(
                                            fontSize: 44,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF27453E),
                                            letterSpacing: -2,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Porma',
                                          style: GoogleFonts.poppins(
                                            fontSize: 44,
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
                            const SizedBox(width: 1),
                            Image.asset('assets/images/spoon_icon.png',
                                width: 80, height: 80),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Description text
                    Text(
                      '“Discover delicious, budget-friendly, easy to make\n recipes with your one and only kitchen companion”',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 19,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF27453E),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description text
                    Text(
                      '“Create an account now and start cooking!”',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 19,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF27453E),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 45),

                    //Buttons for Login (elevated button) and Signup (outlined button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(  //slide transition navigation
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0); //slide in from right to left
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
                            overlayColor: const Color.fromARGB(255, 201, 52, 14).withOpacity(0.50), //styling for touchdown trigger purposes
                            backgroundColor: const Color(0xFFEE795C),
                            fixedSize: const Size(180, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
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
                          style: OutlinedButton.styleFrom(
                            overlayColor: const Color.fromARGB(255, 218, 101, 71).withOpacity(0.15),
                            side: const BorderSide(
                              color: Color(0xFFEE795C),
                              width: 2.5,
                            ),
                            fixedSize: const Size(180, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: Text(
                            'Sign-up',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFEE795C),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
