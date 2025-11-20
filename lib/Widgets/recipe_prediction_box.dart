import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/models/recipe_prediction.dart';

typedef OnPredictionTap = void Function(RecipePrediction p);

class RecipePredictionBox extends StatelessWidget {
  final List<RecipePrediction> items;
  final String query;
  final OnPredictionTap onTap;
  final double width; // recommended width passed from parent
  final double topOffset; // y offset from top (for explicit positioning if desired)

  const RecipePredictionBox({
    super.key,
    required this.items,
    required this.query,
    required this.onTap,
    this.width = 360,
    this.topOffset = 0,
  });

  static const highlightColor = Color(0xFFF06644);
  static const splashColor = Color(0xFFF06644); // will use withOpacity

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

  Widget _buildRow(BuildContext context, RecipePrediction p) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(p),
        splashColor: splashColor.withOpacity(0.4),
        highlightColor: splashColor.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              // left icon bullet
              Image.asset(
                'assets/icon_images/search_inactive.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              // text (highlight)
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: _styledMatch(p.displayText, query),
                ),
              ),
              // optional meta for categories
              if (p.itemType == 'category' && p.categoryType != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    p.categoryType!.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: Colors.black54,
                    ),
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

    // box width determined by parent to match search box width
    return Container(
      width: width,
      // you can adjust top/bottom spacing to match your UI
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