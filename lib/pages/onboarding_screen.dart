import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/pages/signup_screen.dart';
import 'package:platoporma/pages/login_screen.dart';

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
            left: 30,
            top: 280,
            child: Transform.scale( //wrapped in here para mascale
              scale: 1.2,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.1),
                  BlendMode.darken,
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationX(math.pi), //this will rotate the image (because it contains EXIF)
                  child: Image.asset(
                    'assets/images/adobong_manok.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            ),
          ),

          //<--Top logo (platoporma with white bg 1)-->
          Positioned(
            top: 55,
            child: ScaleTransition(
              scale: _scaleAnimation, //calling the scale animation as an entrance animation
              child: Image.asset(
                'assets/images/platoporma_logo_whitebg1.png',
                width: 95,
                height: 95,
              ),
            ),
          ),

          //<--- Container for title, subtexts and buttons for auth --->
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(width: MediaQuery.of(context).size.width, height: 412,
              decoration: const BoxDecoration(
                color: Color(0xFFFDFFEC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),topRight: Radius.circular(35),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    //<---Title container (include ang Welcome to PlatoPorma and fork and spoon icons with bg mint green) --->
                    Transform.translate(
                      offset: const Offset(0, 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
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
                                    offset: const Offset(0, 8),
                                    child: Text(
                                      'Welcome to',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 26,
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
                                              fontSize: 57,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF27453E),
                                              letterSpacing: 1.5,
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

                    const SizedBox(height: 52),

                    //<--- Description text 1---->
                    Text(
                      '“Discover delicious, budget-friendly, easy to make\n recipes with your one and only kitchen companion”',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16.3,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF27453E),
                        letterSpacing: -1.3,
                      ),
                    ),
                    const SizedBox(height: 32),

                    //<--- Description text 2 --->
                    Text(
                      '“Create an account now and start cooking!”',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16.8,                        
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF27453E),
                        letterSpacing: -1.3,
                      ),
                    ),
                    const SizedBox(height: 60),

                    //<---- Buttons for Login (elevated button) and Signup (outlined button) ----->
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
                            backgroundColor: const Color(0xFFF06644),
                            fixedSize: const Size(160, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.3,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 17),
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
                              color: Color(0xFFF06644),
                              width: 2.5,
                            ),
                            fixedSize: const Size(160, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: Text(
                            'Sign-up',
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFFF06644),
                              fontWeight: FontWeight.w600,
                              fontSize: 15.3,
                              letterSpacing: -0.4,
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
