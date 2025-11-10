import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/Pages/onboarding_screen.dart';
import 'package:platoporma/Pages/login_screen.dart';
import 'package:platoporma/Pages/signup_completion_screen.dart';
import 'package:platoporma/Auth/validators.dart';
import 'package:platoporma/Auth/auth_service.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Create an instance of your AuthService
  final AuthService _authService = AuthService();

  // CONTROLLERS FOR VALIDATION
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // BUTTON ENABLE STATE
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    // ✅ ADD LISTENERS TO UPDATE BUTTON STATE
    _firstNameController.addListener(_updateButtonState);
    _lastNameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  // ✅ Enable button when all fields filled
  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = Validators.areAllFieldsFilled([
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      ]);
    });
  }

  // ✅ LOCAL VALIDATION CHECKS
  Future<void> _validateAndSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (!Validators.isValidEmail(email)) {
      _showError('Please enter a valid email address.');
      return;
    }

    if (!Validators.isValidPassword(password)) {
      _showError(
          'Password must be at least 8 characters and contain at least one letter and one number.');
      return;
    }

    if (!Validators.doPasswordsMatch(password, confirmPassword)) {
      _showError('Passwords do not match.');
      return;
    }

    try {
      // 👇 Call Supabase signup via AuthService
      final error = await _authService.signUp(email, password);

      if (!mounted) return;

      if (error == null) {
        // Success
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) => const SignUpCompletionScreen(),
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
      } else {
        // ❌ Failure (e.g. duplicate email or network issue)
        _showError(error);
      }
    } catch (e) {
      // 👇 Handle Supabase or network errors
      _showError(e.toString());
    }
  }

  // Snackbar Layout for error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans(fontSize: 16)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }


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
                                    'Sign-Up',
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
                            _buildTextField('First Name', _firstNameController),
                            _buildTextField('Last Name', _lastNameController),
                            _buildTextField('Email Address', _emailController),
                            _buildPasswordField('Password', true, _passwordController),
                            _buildPasswordField('Confirm Password', false, _confirmPasswordController),
                            const SizedBox(height: 20),

                            // Already have account text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
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
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login',
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

                            // Complete registration button
                            // Complete registration button
                            SizedBox(                      
                              child: Opacity( // ✅ opacity for disabled state
                                opacity: _isButtonEnabled ? 1.0 : 0.65,
                                child: ElevatedButton(
                                  onPressed: _isButtonEnabled ? _validateAndSubmit : null, // ✅ button disabled until all filled
                                  style: ElevatedButton.styleFrom(
                                    overlayColor: const Color.fromARGB(255, 201, 52, 14).withOpacity(0.50),
                                    fixedSize: const Size(300, 60),
                                    backgroundColor: const Color(0xFFEE795C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Text(
                                    'Complete Registration',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
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
                  top: 110,
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
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
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
  Widget _buildPasswordField(String label, bool isPasswordField, TextEditingController controller) {
    final isMainPassword = isPasswordField;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isMainPassword ? _obscurePassword : _obscureConfirmPassword,
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
              (isMainPassword ? _obscurePassword : _obscureConfirmPassword)
                  ? Icons.visibility_outlined
                  : Icons.visibility,
              color: Colors.black.withOpacity(0.4),
            ),
            onPressed: () {
              setState(() {
                if (isMainPassword) {
                  _obscurePassword = !_obscurePassword;
                } else {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                }
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
