import 'package:flutter/material.dart';
import 'package:platoporma/pages/search_results_screen.dart'; 

class SuggestionText extends StatelessWidget {
  final bool show;
  final String suggestion;

  const SuggestionText({
    super.key,
    required this.show,
    required this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'NiceHoney',
            fontSize: 18,
            fontWeight: FontWeight.w100,
            letterSpacing: -1,
            color: primaryText,
          ),
          children: [
            const TextSpan(text: 'Did you mean '),
            TextSpan(
              text: suggestion,
              style: const TextStyle(
                color: Color(0xFFF06644),
                fontStyle: FontStyle.italic,
              ),
            ),
            const TextSpan(text: ' ?'),
          ],
        ),
      ),
    );
  }
}