// lib/pages/recipe_card_design_preview.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/widgets/recipes/saved_recipe_card.dart';

class RecipeCardDesignPreview extends StatelessWidget {
  const RecipeCardDesignPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFFEC),
        elevation: 0,
        title: Text(
          "Card Design Preview",
          style: GoogleFonts.dmSans(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [

            SizedBox(height: 12),

            // Only placeholder cards for now
            RecipePreviewCard(),

            SizedBox(height: 24),

            RecipePreviewCard(),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}