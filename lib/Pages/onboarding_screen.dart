import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background image with vignette
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.1),
                BlendMode.darken,
              ),
              child: Image.asset(
                'assets/images/adobong_manok.png',
                fit: BoxFit.fitHeight,
              ),
            ),
          ),

          // Top logo
          Positioned(
            top: 55,
            child: Image.asset(
              'assets/images/platoporma_logo_whitebg1.png',
              width: 120,
              height: 120,
            ),
          ),

          // Bottom container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 500,
              height: 412,
              decoration: const BoxDecoration(
                color: Color(0xFFFDFFEC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    // Title container
                    Transform.translate(
                      offset: const Offset(0, 0), // move upward by 25 pixels (adjust value as needed)
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCEDD8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/fork_icon.png', width: 80, height: 80),
                            const SizedBox(width: 1),
                            Column(
                              children: [
                              Transform.translate(
                                offset: const Offset(0, 10),
                                child: Text(
                                  'Welcome to',
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF27453E),
                                    letterSpacing: -1.5,                              
                                  ),
                                ),
                              ),                           
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Plato',
                                        style: GoogleFonts.poppins(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF27453E),
                                          letterSpacing: -2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Porma',
                                        style: GoogleFonts.poppins(
                                          fontSize: 42,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF27453E),
                                          letterSpacing: -2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 1),
                            Image.asset('assets/images/spoon_icon.png', width: 80, height: 80),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),

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
                      '“What are we cooking today?”',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 19,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF27453E),
                        letterSpacing: -1,        
                      ),
                    ),
                    const SizedBox(height: 55),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEE795C),
                            fixedSize: const Size(130, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFEE795C),
                              width: 2,
                            ),
                            fixedSize: const Size(130, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Sign-up',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFEE795C),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
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
