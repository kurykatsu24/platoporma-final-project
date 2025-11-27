import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:platoporma/pages/onboarding_screen.dart';
import 'package:platoporma/pages/login_screen.dart';
import 'package:platoporma/pages/signup_completion_screen.dart';
import 'package:platoporma/auth/validators.dart';
import 'package:platoporma/auth/auth_service.dart';

final supabase = Supabase.instance.client;


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  //Instance for AuthService
  final AuthService _authService = AuthService();

  //Controllers for validation
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //enable button state
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    //listeners to update button state (the fields will be checked)
    _firstNameController.addListener(_updateButtonState);
    _lastNameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  //enable button when all fields filled
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

  //<--- Local Validation Checks --->
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
      //Call Supabase signup via AuthService
      final error = await _authService.signUp(email, password);

      if (!mounted) return;

      if (error == null) {
        //after signup is successful, get the current user
        final user = supabase.auth.currentUser;

        if (user != null) {
          //insert a matching row in user_profiles
          await supabase.from('user_profiles').insert({
            'id': user.id,
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'created_at': DateTime.now().toIso8601String(),
          });
        }

        //Navigate to the completion screen (with slide transition)
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SignUpCompletionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              final curve = Curves.easeInOut;
              final tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      } else {
        _showError(error);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  //Custom Snackbar Layout for error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.4)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      body: SafeArea(
        child: SingleChildScrollView(  
          reverse: true,               
          child: SizedBox(
            height: MediaQuery.of(context).size.height, 
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back button
                Positioned(
                  width: 48,
                  height: 48,
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
                      iconSize: 25,         
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

                const SizedBox(height: 180),

                //<----- White box container with contents --->
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Align(
                    alignment: Alignment.center,            
                    child: Container(              
                      width: screenWidth * 0.9,
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
                            //< ---Title--->
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC2EBD2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign-Up',
                                    style: TextStyle(
                                      fontFamily: 'NiceHoney',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 38,
                                      letterSpacing: -1,
                                      color: const Color(0xFF27453E),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            //<--- theInput fields --->
                            _buildTextField('First Name', _firstNameController),
                            _buildTextField('Last Name', _lastNameController),
                            _buildTextField('Email Address', _emailController),
                            _buildPasswordField('Password', true, _passwordController),
                            _buildPasswordField('Confirm Password', false, _confirmPasswordController),
                            const SizedBox(height: 20),

                            //<---Already have account text-->
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFf06644),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 35),

                            //<--- Complete registration button --->
                            SizedBox(                      
                              child: Opacity( 
                                opacity: _isButtonEnabled ? 1.0 : 0.80,
                                child: ElevatedButton(
                                  onPressed: _isButtonEnabled ? _validateAndSubmit : null,
                                  style: ElevatedButton.styleFrom(
                                    overlayColor: const Color.fromARGB(255, 201, 52, 14).withOpacity(0.50),
                                    fixedSize: const Size(210, 48),
                                    backgroundColor: const Color(0xFFEE795C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Text(
                                    'Complete Registration',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15.3,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.4,
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

                //<-- Logo stacked on top of the white box--->
                Positioned(
                  top: 65,
                  child: Image.asset(
                    'assets/images/platoporma_logo_whitebg1.png',
                    width: 95,
                    height: 95,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //<--- Custom textfield --->
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: Colors.black.withOpacity(0.6),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 15,
            color: Colors.black.withOpacity(0.6),
            letterSpacing: -0.2,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFf06644)),
          ),
        ),
      ),
    );
  }

  //<--- Password field with toggle --->
  Widget _buildPasswordField(String label, bool isPasswordField, TextEditingController controller) {
    final isMainPassword = isPasswordField;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isMainPassword ? _obscurePassword : _obscureConfirmPassword,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: Colors.black.withOpacity(0.6),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 15,
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
