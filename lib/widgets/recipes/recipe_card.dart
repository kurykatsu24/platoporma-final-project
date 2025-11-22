import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<RecipeCard>> fetchRecipes() async {
  final supabase = Supabase.instance.client;

  final response = await supabase.from('recipes').select("""
    id,
    name,
    cuisine_type,
    diet_type,
    protein_type,
    estimated_price_centavos,
    images
  """);

  final list = (response as List<dynamic>).cast<Map<String, dynamic>>();

  return list.map((json) {
    return RecipeCard(
      recipeName: json['name'] ?? '',
      cuisineType: json['cuisine_type'],
      dietType: json['diet_type'],
      proteinType: json['protein_type'],
      estimatedPriceCentavos: json['estimated_price_centavos'] ?? 0,
      imagePath: json['images'] ?? '',
    );
  }).toList();
}

class RecipeCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String recipeName;
  final String? cuisineType;
  final String? dietType;
  final String? proteinType;
  final int? estimatedPriceCentavos;
  final String imagePath;
  
  const RecipeCard({
    super.key,
    required this.recipeName,
    this.cuisineType,
    this.dietType,
    this.proteinType,
    required this.estimatedPriceCentavos,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10, left: 10), // <-- small gap around image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // image rounded corners
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),


            const SizedBox(height: 10),

            // PILLS (Wrap)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (cuisineType != null && cuisineType!.isNotEmpty)
                    _buildPill(
                      cuisineType!,
                      bg: const Color(0xFFD6FFFF),
                      outline: const Color(0xFF0B9999),
                    ),
                  if (dietType != null && dietType!.isNotEmpty)
                    _buildPill(
                      dietType!,
                      bg: const Color(0xFFFFFACD),
                      outline: const Color(0xFFCD901F),
                    ),
                  if (proteinType != null && proteinType!.isNotEmpty)
                    _buildPill(
                      proteinType!,
                      bg: const Color(0xFFFFD0E5),
                      outline: const Color(0xFFC73576),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // NAME + PRICE ROW
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME (expands left, respects padding on right)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10), // space for price box
                      child: Text(
                        recipeName,
                        maxLines: null,
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // PRICE BOX (fixed width)
                  _buildPriceBox(),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // FOOTER
            Center(
              child: Text(
                "<<View Full Recipe>>",
                style: GoogleFonts.dmSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.50),
                  letterSpacing: -0.4,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }


  // ---------- UI HELPERS ---------- //

  Widget _buildPill(String text, {required Color bg, required Color outline}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: outline,
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: outline,
          fontWeight: FontWeight.bold,
          fontSize: 8.5,
        ),
      ),
    );
  }

  Widget _buildPriceBox() {
    final price = estimatedPriceCentavos != null
        ? "₱${(estimatedPriceCentavos! / 100).toStringAsFixed(2)}"
        : "-";

    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2FCEC),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            "Estimated Price",
            style: GoogleFonts.dmSans(
              fontSize: 7.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}