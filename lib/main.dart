import 'package:flutter/material.dart';
import 'package:platoporma/pages/signup_screen.dart';
import 'package:platoporma/pages/recipe_main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  //this ensures Flutter widgets are ready before running any async code
  WidgetsFlutterBinding.ensureInitialized();  

  //initializing Supabase as our database (ONLINE)
  await Supabase.initialize(
    url: 'https://qyhvkifjstjwlbbswdoc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aHZraWZqc3Rqd2xiYnN3ZG9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyMjY4MDYsImV4cCI6MjA3NzgwMjgwNn0.yVxdM0vD0jKe34XlxvGpvY9vaxCC665JRfzNBlMdlTE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Platoporma',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignUpScreen(), //this is where the app starts

      //register routes
      routes: {
        // other static routes if you have them, e.g. "/login": (_) => LoginPage(),
        '/saved-recipe': (context) {
          // Extract passed args safely
          final rawArgs = ModalRoute.of(context)!.settings.arguments;
          final Map<String, dynamic> args =
              (rawArgs is Map<String, dynamic>) ? rawArgs : <String, dynamic>{};

          return RecipeMainScreen(
            recipeName: args['recipeName']?.toString() ?? '',
            recipeId: args['recipeId']?.toString() ?? '',
            recipeJson: args['recipeJson'] ?? {},
            isIngredientSearch: false,
            isComplete: true,
            missingCount: 0,
            matchedCount: 0,
            selectedCount: 0,
            fromSaved: true,
            saveId: args['saveId']?.toString(),   // <--- FIXED
          );
        },
      },
    );
  }
}
