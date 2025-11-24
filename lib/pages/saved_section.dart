import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedSection extends StatefulWidget {
  const SavedSection({super.key});

  @override
  State<SavedSection> createState() => _SavedSectionState();
}

class _SavedSectionState extends State<SavedSection> {
  String selected = "recent"; // pill state

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
                        //<---- Title with icons ---->
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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

          //<---- Pills Row ---->
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              child: Row(
                children: [
                  _buildPill("recent"),
                  const SizedBox(width: 12),
                  _buildPill("all"),
                ],
              ),
            ),
          ),

          //<----------- Body Placeholder ------------->
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

  //<------- UI Helpers ------->

  //ui helper for a single pill (as pills for RECENT and ALL)
  Widget _buildPill(String label) {
    const activeColor = Color(0xFFF06644);
    const inactiveBG = Color(0xFFECECEC);
    bool isActive = selected == label;

    return Expanded(
      child: Material(
        color: Colors.transparent, // keep background from AnimatedContainer
        borderRadius: BorderRadius.circular(30),
        //animation logic for switching pills
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: activeColor.withOpacity(0.15),
          highlightColor: activeColor.withOpacity(0.1),
          onTap: () => setState(() => selected = label),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.2) : inactiveBG,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? activeColor : Colors.black.withOpacity(0.6),
                width: isActive ? 2.3 : 1.5,
              ),
            ),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -1,
                  color: isActive ? activeColor : Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
