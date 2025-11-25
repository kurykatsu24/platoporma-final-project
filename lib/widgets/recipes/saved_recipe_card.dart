import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedRecipeCard extends StatelessWidget {
  final String saveId;
  final String recipeId;
  final Map<String, dynamic> recipeJson;
  final VoidCallback onDelete;

  const SavedRecipeCard({
    super.key,
    required this.saveId,
    required this.recipeId,
    required this.recipeJson,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = recipeJson["name"] ?? "Untitled Recipe";
    final price = recipeJson["estimated_price"] ?? 0;
    final cuisine = recipeJson["cuisine_type"];
    final diet = recipeJson["diet_type"];
    final protein = recipeJson["protein_type"];

    return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      Navigator.pushNamed(
        context,
        '/saved-recipe',
        arguments: {
          'recipeId': recipeId,
          'recipeName': name,
          'saveId': saveId,
          'recipeJson': recipeJson,
        },
      );
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //<------ Recipe name + Pills + Price ------->  
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //<----- On the leftside: Name + Pills ----->  
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //The Recipe Name  
                    Text(
                      name,
                      style: GoogleFonts.dmSans(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -2,
                        color: Colors.black,
                        height: 1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Pills  
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (cuisine != null && cuisine.toString().isNotEmpty)
                          _pillCuisine(cuisine),

                        if (diet != null && diet.toString().isNotEmpty)
                          _pillDiet(diet),

                        if (protein != null && protein.toString().isNotEmpty)
                          _pillProtein(protein),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 13),

              //<------- Estimated Price Box ------->  
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2FCEC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Estimated Price",
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "₱${price.toStringAsFixed(2)}",
                      style: GoogleFonts.dmSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          //<------ View Recipe + Delete Row ------>  
          Row(
            children: [
              const Expanded(child: SizedBox()),

              Text(
                "<<View Full Recipe>>",
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.50),
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),

              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Image.asset(
                      'assets/icon_images/delete.png',
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
  }
  //<---- Pill Widget Helper ------>
  static Widget _pill({
    required String label,
    required Color bgColor,
    required Color outlineColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineColor, width: 2),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  //Color themes assigned:
  //Cuisine pill theme
  static Widget _pillCuisine(String label) {
    return _pill(
      label: label,
      bgColor: const Color(0xFFD6FFFF),
      outlineColor: const Color(0xFF0B9999),
      textColor: const Color(0xFF0B9999),
    );
  }
  // Diet pill theme
  static Widget _pillDiet(String label) {
    return _pill(
      label: label,
      bgColor: const Color(0xFFFFFACD),
      outlineColor: const Color(0xFFCD901F),
      textColor: const Color(0xFFCD901F),
    );
  }
  // Protein pill theme
  static Widget _pillProtein(String label) {
    return _pill(
      label: label,
      bgColor: const Color(0xFFFFD0E5),
      outlineColor: const Color(0xFFC73576),
      textColor: const Color(0xFFC73576),
    );
  }
}
