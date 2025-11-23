import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:platoporma/pages/recipe_main_screen.dart';
import 'package:platoporma/widgets/recipes/recipe_card.dart';

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

            //< -------------- The Appbar ------------------ >
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            backgroundColor: const Color(0xFFC2EBD2),
            elevation: 0,
            expandedHeight: 135,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
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
                            //Logo displayed sa right
                            Image.asset(
                              'assets/images/platoporma_logo_whitebg2.png',
                              width: 80,
                            ),

                            SizedBox(width: screenWidth * 0.03),

                            //<---------- Text Column ---------->
                            ///used for texts especially "first name" retrieval to handle long first names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Welcome,",
                                    style: TextStyle(
                                      fontFamily: 'NiceHoney',
                                      color: const Color(0xFF27453E),
                                      fontWeight: FontWeight.w100,
                                      fontSize: 33,
                                      letterSpacing: -0.2,
                                      height: 0.7,
                                    ),
                                  ),

                                  Text(
                                    "${firstName ?? ""}!",
                                    style: TextStyle(
                                      fontFamily: 'NiceHoney',
                                      color: const Color(0xFF27453E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      letterSpacing: -0.3,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),

                                  Text(
                                    "Take a scroll at a wide range of recipes",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF27453E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.5,
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

          //Sticky header for explore recipes with horizontal carousel
          SliverPersistentHeader(pinned: true, delegate: _StickyHeaderDelegate(),
          ),

          // <------------- Main Body w/ recipe cards --------------->
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
                    padding: const EdgeInsets.only(left: 7, right: 7, bottom: 6),
                    child: MasonryGridView.count(
                      padding: EdgeInsets.only(top: 0),
                      physics: const NeverScrollableScrollPhysics(), // important: disables internal scroll
                      shrinkWrap: true, // important: allows it to fit inside scroll view
                      crossAxisCount: 2,           // 2 columns
                      mainAxisSpacing: 2,         // vertical gap
                      crossAxisSpacing: 2,        // horizontal gap
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return RecipeCard(
                          recipeName: recipe.recipeName,
                          imagePath: recipe.imagePath,
                          estimatedPriceCentavos: recipe.estimatedPriceCentavos,
                          cuisineType: recipe.cuisineType,
                          dietType: recipe.dietType,
                          proteinType: recipe.proteinType,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeMainScreen(
                                  recipeName: recipe.recipeName,
                                  isIngredientSearch: false,
                                  isComplete: false,
                                  missingCount: 0,
                                  matchedCount: 0,
                                  selectedCount: 0,
                                ),
                              ),
                            );
                          },
                        );
                      }
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

//created separate class for the stickyheader: Explore Recipes
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
          color: const Color(0xFFFDFFEC).withOpacity(0.85),
        
          child: Padding(
            padding: const EdgeInsets.only(left: 18, right: 25, top: 25, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // <---- Title ------>
                Text(
                  "Explore Recipes",
                  style: const TextStyle(
                  fontFamily: 'NiceHoney',
                  fontSize: 28,
                  fontWeight: FontWeight.w100, 
                  color: const Color(0xff27453E),
                  letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                // <--------- Horizontal Pills Carousel ------>
                SizedBox(
                  height: 33,
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

  // <------ Creates an inactive pill ------->
  Widget _buildCategoryPill(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC), 
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.black.withOpacity(0.60), width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6E6E6E),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 130; //increased to fit title + pills

  @override
  double get minExtent => 130; //same for non-collapsing sticky header

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}