import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/Pages/onboarding_screen.dart';
import 'package:platoporma/Pages/signup_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC), // Background color
      body: SafeArea(
        child: SingleChildScrollView(  // make the entire stack scrollable
          reverse: true,               // scroll up when keyboard opens
          child: SizedBox(
            height: MediaQuery.of(context).size.height, // fill the screen
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back button
                Positioned(
                  width: 60,
                  height: 60,
                  top: 50,
                  left: 30,
                  child: Container(
                    decoration: BoxDecoration(                
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(       
                      iconSize: 35,         
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 500),
                            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0); // slide in from left to right
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
                    ),
                  ),
                ),

                const SizedBox(height: 150),

                // White box container with drop shadow
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Align(
                    alignment: Alignment.center,            
                    child: Container(              
                      width: 420,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Title with background
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCCEDD8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                      letterSpacing: -2,
                                      color: const Color(0xFF27453E),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Input fields
                            _buildTextField('Email Address'),
                            _buildPasswordField('Password'),
                            const SizedBox(height: 1),
                            
                            // Forgot Password text
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to Forgot Password screen
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Don't have account text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    color: Colors.black.withOpacity(0.6),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
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
                                  child: Text(
                                    'Sign-Up',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFEE795C),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 35),

                            // Login button
                            SizedBox(                      
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Login logic
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(300, 60),
                                  backgroundColor: const Color(0xFFEE795C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Logo stacked on top of the white box
                Positioned(
                  top: 200,
                  child: Image.asset(
                    'assets/images/platoporma_logo_whitebg1.png',
                    width: 120,
                    height: 120,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom reusable textfield
  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        style: GoogleFonts.dmSans(
          fontSize: 18,
          color: Colors.black.withOpacity(0.6),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 18,
            color: Colors.black.withOpacity(0.6),
            letterSpacing: -0.2,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEE795C)),
          ),
        ),
      ),
    );
  }

  // Password field with toggle
  Widget _buildPasswordField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        obscureText: _obscurePassword,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          color: Colors.black.withOpacity(0.6),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 16,
            color: Colors.black.withOpacity(0.6),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility,
              color: Colors.black.withOpacity(0.4),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEE795C)),
          ),
        ),
      ),
    );
  }
}