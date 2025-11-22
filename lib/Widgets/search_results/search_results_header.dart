import 'package:flutter/material.dart';
import 'package:platoporma/pages/search_results_screen.dart'; 

class SearchResultsHeader extends StatelessWidget {
  final String query;
  final bool hasExactMatch;

  const SearchResultsHeader({
    super.key,
    required this.query,
    required this.hasExactMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 15,
        bottom: hasExactMatch ? 15 : 0,
      ),
      child: Text(
        'Results for "$query"',
        style: const TextStyle(
          fontFamily: 'NiceHoney',
          fontSize: 25,
          fontWeight: FontWeight.w100,
          color: primaryText,
          letterSpacing: -0.8,
        ),
      ),
    );
  }
}