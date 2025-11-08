import 'package:flutter/material.dart';

class LoginCompletionScreen extends StatelessWidget {
  const LoginCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFDFFEC),
      body: Center(
        child: Text(
          'Login Successful!',
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