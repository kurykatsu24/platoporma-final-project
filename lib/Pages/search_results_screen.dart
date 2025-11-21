import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/Pages/search_section.dart';

class SearchResultsPage extends StatelessWidget {
  final String? query;

  const SearchResultsPage({
    super.key,
    this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCEDD8),
        elevation: 0,
        automaticallyImplyLeading: false, // prevent default back button
        titleSpacing: 0, // so custom back button aligns nicely

        title: Row(
          children: [
            const SizedBox(width: 8),

            // 🔙 Custom Circular Shadow Back Button
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 12),
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
                iconSize: 22,
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SearchSection(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0);
                        const end = Offset.zero;
                        final curve = Curves.easeInOut;

                        final tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // 📄 Title
            Text(
              "Search Results",
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF27453E),
              ),
            ),
          ],
        ),
      ),

      // 📌 Body
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Placeholder Results for:\n"$query"',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF27453E),
            ),
          ),
        ),
      ),
    );
  }
}