import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ingredient_pill.dart';

typedef OnPillDoubleTap = void Function(IngredientPill pill);

class IngredientPillWidget extends StatelessWidget {
  final IngredientPill pill;
  final OnPillDoubleTap onDoubleTap;

  const IngredientPillWidget({
    super.key,
    required this.pill,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    // pill shadow & border per spec
    return GestureDetector(
      onDoubleTap: () => onDoubleTap(pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFF06644).withOpacity(0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF06644).withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pill.name,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.9,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}