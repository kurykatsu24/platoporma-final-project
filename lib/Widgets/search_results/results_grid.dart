import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:platoporma/pages/search_results_screen.dart'; 
import 'package:platoporma/pages/search_results_screen.dart' show RecipeResult;
import 'ingredient_flag.dart';
import 'package:platoporma/widgets/recipes/recipe_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultsGrid extends StatelessWidget {
  final bool loading;
  final String? error;
  final bool isIngredientMode;
  final List<RecipeResult> results;
  final String queryText;

  const ResultsGrid({
    super.key,
    required this.loading,
    required this.error,
    required this.isIngredientMode,
    required this.results,
    required this.queryText,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Text(
          'Error: $error',
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.red),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'Sorry, but\nno results found for "$queryText"',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];

        return Stack(
          clipBehavior: Clip.none,
          children: [
            RecipeCard(
              name: item.name,
              cuisineType: item.cuisineType,
              dietType: item.dietType,
              proteinType: item.proteinType,
              estimatedPriceCentavos: item.estimatedPriceCentavos,
              imagePath: item.imagePath,
            ),
            if (isIngredientMode)
              Positioned(
                top: 6,
                right: 8,
                child: IngredientFlag(recipe: item),
              ),
          ],
        );
      },
    );
  }
}