import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ingredient_prediction.dart';

typedef OnIngredientTap = void Function(IngredientPrediction p);

class IngredientPredictionBox extends StatelessWidget {
  final List<IngredientPrediction> items;
  final String query;
  final OnIngredientTap onTap;
  final double width;
  final double topOffset;

  const IngredientPredictionBox({
    super.key,
    required this.items,
    required this.query,
    required this.onTap,
    this.width = 360,
    this.topOffset = 0,
  });

  static const highlightColor = Color(0xFFF06644);

  String _iconForCategory(String? cat) {
    if (cat == null || cat.isEmpty) {
      return 'assets/icon_images/miscellaneous.png';
    }
    // assumes file names equal category values
    return 'assets/icon_images/${cat.toLowerCase()}.png';
  }

  TextSpan _styledMatch(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);

    if (start == -1 || query.isEmpty) {
      return TextSpan(
        text: text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
          color: Colors.black,
        ),
      );
    }

    final end = start + query.length;
    return TextSpan(
      children: [
        TextSpan(
          text: text.substring(0, start),
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: text.substring(start, end),
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: highlightColor,
          ),
        ),
        TextSpan(
          text: text.substring(end),
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, IngredientPrediction p) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(p),
        splashColor: highlightColor.withOpacity(0.4),
        highlightColor: highlightColor.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              // category icon as bullet
              Image.asset(
                _iconForCategory(p.category),
                width: 18,
                height: 18,
                fit: BoxFit.contain,
                color: highlightColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: _styledMatch(p.name, query),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: width,
      margin: EdgeInsets.only(top: 8 + topOffset),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (context, i) => const Divider(height: 1, indent: 12, endIndent: 12),
          itemBuilder: (context, i) => _buildRow(context, items[i]),
        ),
      ),
    );
  }
}