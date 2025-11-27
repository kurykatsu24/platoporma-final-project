import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromARGB(255, 115, 208, 150)
              : const Color.fromARGB(255, 247, 246, 246),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isActive
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.black.withOpacity(0.60),
            width: isActive ? 2.0 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
            color: isActive
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color(0xFF6E6E6E),
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}