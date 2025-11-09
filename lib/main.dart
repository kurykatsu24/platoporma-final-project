import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:platoporma/Pages/signup_completion_screen.dart';

Future<void> main() async {
  // Ensures Flutter widgets are ready before running any async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qyhvkifjstjwlbbswdoc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aHZraWZqc3Rqd2xiYnN3ZG9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyMjY4MDYsImV4cCI6MjA3NzgwMjgwNn0.yVxdM0vD0jKe34XlxvGpvY9vaxCC665JRfzNBlMdlTE',
  );

  // Run your app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Platoporma',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set SplashScreen as the home
      home: SignUpCompletionScreen(),
    );
  }
}