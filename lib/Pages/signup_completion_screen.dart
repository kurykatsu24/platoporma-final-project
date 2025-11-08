import 'package:flutter/material.dart';

class SignUpCompletionScreen extends StatelessWidget {
  const SignUpCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFDFFEC),
      body: Center(
        child: Text(
          'Sign-Up Successful!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
