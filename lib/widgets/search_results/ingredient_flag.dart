import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/pages/search_results_screen.dart'; 
import 'package:platoporma/pages/search_results_screen.dart' show RecipeResult;

class IngredientFlag extends StatelessWidget {
  final RecipeResult recipe;

  const IngredientFlag({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final bool complete = recipe.isCompleteIngredients;
    final Color bg = complete ? flagComplete : flagMissing;

    final String text = complete
        ? 'Complete\nIngredients'
        : 'Missing\nIngredients\n(${recipe.missingCount})';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }
}