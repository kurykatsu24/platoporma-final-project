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
    final double screenW = MediaQuery.of(context).size.width;
    const Color appbarColor = Color(0xFFCCEDD8);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),

      // 🔹 NEW APPBAR — Styled like Search Section
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(135),
        child: Container(
          decoration: const BoxDecoration(
            color: appbarColor,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenW * 0.04,
                vertical: screenW * 0.05,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // 🔙 Custom Back Button
                  Container(
                    width: 42,
                    height: 42,
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
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const SearchSection(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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

                  const Spacer(),

                  // 📝 Title
                  Text(
                    "Search Result",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'NiceHoney',
                      color: Color(0xFF27453E),
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                      height: 1,
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),

      // 🔸 Body (keep query for debugging)
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