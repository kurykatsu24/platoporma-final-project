import 'package:flutter/material.dart';
import 'package:platoporma/pages/search_results_screen.dart'; 

class SearchAppBar extends StatelessWidget {
  final double screenW;
  final VoidCallback onBack;

  const SearchAppBar({
    super.key,
    required this.screenW,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(135),
      child: Container(
        decoration: const BoxDecoration(
          color: appbarColor,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenW * 0.04,
              vertical: screenW * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: onBack,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Search Result',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NiceHoney',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 55),
              ],
            ),
          ),
        ),
      ),
    );
  }
}