import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:platoporma/Widgets/recipe_card.dart';

class HomePageSection extends StatefulWidget {
  const HomePageSection({super.key});

  @override
  State<HomePageSection> createState() => _HomePageSectionState();
}

class _HomePageSectionState extends State<HomePageSection> {
  String? firstName;

  @override
  void initState() {
    super.initState();
    _fetchFirstName();
  }

  Future<void> _fetchFirstName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('first_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          firstName = response['first_name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),

            // ------------------ Appbar ------------------
      body: CustomScrollView(
        slivers: [

          // ------------------ Appbar ------------------
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            backgroundColor: const Color(0xFFCCEDD8),
            elevation: 0,
            expandedHeight: 135,

            // Rounded bottom corners
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,

                //Custom appbar
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFCCEDD8),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),

                  //Appbar contents
                  child: Builder(
                    builder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenWidth * 0.05,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo
                            Image.asset(
                              'assets/images/platoporma_logo_whitebg2.png',
                              width: 80,
                            ),

                            SizedBox(width: screenWidth * 0.03),

                            //Text Column
                            ///THIS PART MAKES THE TEXT WRAP DOWN INSTEAD OF OVERFLOW(right)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Welcome,",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF27453E),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 30,
                                      letterSpacing: -0.5,
                                      height: 0.8,
                                    ),
                                  ),

                                  Text(
                                    "${firstName ?? ""}!",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF27453E),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 27,
                                      letterSpacing: -1,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),

                                  Text(
                                    "Let’s find something delicious and comforting today",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF27453E),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.9,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Sticky header (BLUE TEST BAR)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(),
          ),

          // ------------------ BODY ------------------
          SliverToBoxAdapter(
            child: FutureBuilder<List<RecipeCard>>(
              future: fetchRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Text('No recipes found'),
                    ),
                  );
                } else {
                  final recipes = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                    child: MasonryGridView.count(
                      padding: EdgeInsets.only(top: 0),
                      physics: const NeverScrollableScrollPhysics(), // important: disables internal scroll
                      shrinkWrap: true, // important: allows it to fit inside scroll view
                      crossAxisCount: 2,           // 2 columns
                      mainAxisSpacing: 5,         // vertical gap
                      crossAxisSpacing: 5,        // horizontal gap
                      itemCount: recipes.length,
                      itemBuilder: (context, index) => recipes[index],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),

        child: Container(
          width: double.infinity,
          height: maxExtent,
          color: const Color(0xFFFDFFEC).withOpacity(0.75),
        
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Title ----------
                Text(
                  "Explore Recipes",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 32,
                    color: const Color(0xFF27453E),
                    letterSpacing: -2.3,
                  ),
                ),

                const SizedBox(height: 10),

                // ---------- Horizontal Pills ----------
                SizedBox(
                  height: 33, // height of the pills container
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryPill("Budget-Friendly"),
                      _buildCategoryPill("Healthy"),
                      _buildCategoryPill("Limited Ingredients"),
                      _buildCategoryPill("Quick & Easy"),
                      _buildCategoryPill("Comfort Food"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Creates an inactive pill ----------
  Widget _buildCategoryPill(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E5D4), // light gray fill
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE6E6E6)), // gray outline
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF72736A),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 130; // Increased to fit title + pills

  @override
  double get minExtent => 130; // Same for non-collapsing sticky header

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}