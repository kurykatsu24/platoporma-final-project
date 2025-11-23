import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedSection extends StatelessWidget {
  const SavedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),

      body: CustomScrollView(
        slivers: [
          //<---- AppBar --->
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            elevation: 0,
            backgroundColor: const Color(0xFFC2EBD2),
            expandedHeight: 135,

            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFC2EBD2),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left icon
                            Image.asset(
                              'assets/images/fork_icon.png',
                              width: screenW * 0.18,
                              height: screenW * 0.18,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(width: 1),

                            Text(
                              "Saved Recipes",
                              style: const TextStyle(
                                fontFamily: 'NiceHoney',
                                color: Color(0xFF27453E),
                                fontWeight: FontWeight.w100,
                                fontSize: 36,
                                letterSpacing: -0.4,
                              ),
                            ),

                            const SizedBox(width: 1),

                            // Right icon
                            Image.asset(
                              'assets/images/spoon_icon.png',
                              width: screenW * 0.18,
                              height: screenW * 0.18,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),

                        const SizedBox(height: 1),

                        //<--- subtext below the title----->
                        Transform.translate(
                          offset: const Offset(0, -15),
                          child: Text(
                            "Your favorite meals all in one place",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF27453E),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ------------- Body Placeholder -------------
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                "No saved recipes yet",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6E6E6E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
