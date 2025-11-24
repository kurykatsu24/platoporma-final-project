// lib/widgets/recipe_preview_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipePreviewCard extends StatelessWidget {
  const RecipePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          //<------- Recipe name + Pills + Price ------->
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //placeholder for now
                    Text(
                      "Sample Recipe Name",
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

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _pill(
                          label: "Filipino",
                          bgColor: const Color(0xFFD6FFFF),
                          outlineColor: const Color(0xFF0B9999),
                          textColor: const Color(0xFF0B9999),
                        ),
                        _pill(
                          label: "Keto",
                          bgColor: const Color(0xFFFFFACD),
                          outlineColor: const Color(0xFFCD901F),
                          textColor: const Color(0xFFCD901F),
                        ),
                        _pill(
                          label: "Chicken",
                          bgColor: const Color(0xFFFFD0E5),
                          outlineColor: const Color(0xFFC73576),
                          textColor: const Color(0xFFC73576),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 13),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
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
                      "₱120.00",
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

          //In a row: subtext view full recipe and delete (trash icon)

          Row(
            children: [

              //empty space (for balance to the delete icon)
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
                    onTap: () {
                      // later delete logic
                    },
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
}