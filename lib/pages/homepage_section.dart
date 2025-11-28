import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:platoporma/pages/recipe_main_screen.dart';
import 'package:platoporma/widgets/recipes/recipe_card.dart';

// NEW: import sticky header widget
import 'package:platoporma/widgets/homepage_sticky_header.dart';

class HomePageSection extends StatefulWidget {
  const HomePageSection({super.key});

  @override
  State<HomePageSection> createState() => _HomePageSectionState();
}

class _HomePageSectionState extends State<HomePageSection> {
  String? firstName;
  String? selectedCategory; // null = no filter
  late Future<List<RecipeCard>> recipeFuture;

  @override
  void initState() {
    super.initState();
    _fetchFirstName();
    recipeFuture = fetchRecipes();
  }

  Future<void> _fetchFirstName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('user_profiles')
            .select('first_name')
            .eq('id', user.id)
            .maybeSingle();

        if (response != null && mounted) {
          setState(() {
            firstName = response['first_name'];
          });
        } else if (mounted) {
          setState(() {
            firstName = "User"; // fallback name
          });
        }
      } catch (e) {
        // Fallback in case of network error
        if (mounted) {
          setState(() {
            firstName = "User"; // fallback name
          });
        }
        debugPrint("Failed to fetch first name: $e");
      }
    } else if (mounted) {
      setState(() {
        firstName = "Chef";
      });
    }
  }

  Future<Map<String, dynamic>> fetchRecipeJson(String id) async {
    final res = await Supabase.instance.client
        .from('recipes')
        .select()
        .eq('id', id)
        .single();

    return res;
  }

  Future<List<RecipeCard>> fetchRecipes() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.from('recipes').select("""
      id,
      name,
      cuisine_type,
      diet_type,
      protein_type,
      estimated_price_centavos,
      images
    """);

    final list = (response as List).cast<Map<String, dynamic>>();

    return list.map((json) {
      return RecipeCard(
        recipeId: json['id'],
        recipeJson: json,
        recipeName: json['name'] ?? '',
        cuisineType: json['cuisine_type'],
        dietType: json['diet_type'],
        proteinType: json['protein_type'],
        estimatedPriceCentavos: json['estimated_price_centavos'],
        imagePath: json['images'],
      );
    }).toList();
  }

  Future<List<RecipeCard>> fetchRecipesFiltered() async {
    final supabase = Supabase.instance.client;

    PostgrestFilterBuilder query = supabase.from('recipes').select("""
      id,
      name,
      cuisine_type,
      diet_type,
      protein_type,
      estimated_price_centavos,
      images
    """);

    // Apply category filters
    switch (selectedCategory) {
      case "Budget-Friendly":
        query = query.lte('estimated_price_centavos', 15000);
        break;
      case "Healthy":
        query = query.lte('total_calories', 450);
        break;
      case "Quick & Easy":
        query = query.lte('prep_time', 15);
        break;
      case "Creative Twists":
        query = query.eq('is_twist', true);
        break;
      case "International":
        query = query.eq('is_international', true);
        break;
    }

    final response = await query;
    final list = (response as List).cast<Map<String, dynamic>>();

    return list.map((json) {
      return RecipeCard(
        recipeId: json['id'],
        recipeJson: json,
        recipeName: json['name'] ?? '',
        cuisineType: json['cuisine_type'],
        dietType: json['diet_type'],
        proteinType: json['protein_type'],
        estimatedPriceCentavos: json['estimated_price_centavos'],
        imagePath: json['images'],
      );
    }).toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (selectedCategory == category) {
        selectedCategory = null; // toggle off
        recipeFuture = fetchRecipes();
      } else {
        selectedCategory = category; // turn on
        recipeFuture = fetchRecipesFiltered();
      }
    });
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
                child: _buildWelcomeHeader(context),
              ),
            ),
          ),

          //<------ Sticky Header widget ------>
          SliverPersistentHeader(
            pinned: true,
            delegate: HomepageStickyHeaderDelegate(
              onCategoryTap: _onCategorySelected,
              selectedCategory: selectedCategory,
            ),
          ),

          //<------------- Main Body w/ recipe cards --------------->
          SliverToBoxAdapter(
            child: FutureBuilder<List<RecipeCard>>(
              future: recipeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  // <-- FALLBACK UI -->
                  return _buildOfflineSticker();
                } else {
                  return _buildRecipeGrid(snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFC2EBD2),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.05,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/platoporma_logo_whitebg2.png',
              width: 80,
            ),
            SizedBox(width: screenWidth * 0.03),

            // Text column
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
                  ),
                  Text(
                    "Take a scroll at a wide range of recipes",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF27453E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(List<RecipeCard> recipes) {
    return Padding(
      padding: const EdgeInsets.only(left: 7, right: 7, bottom: 6),
      child: MasonryGridView.count(
        padding: EdgeInsets.only(top: 0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return RecipeCard(
            recipeId: recipe.recipeId,
            recipeJson: recipe.recipeJson,
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
                    recipeId: recipe.recipeId,
                    recipeJson: recipe.recipeJson,
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
        },
      ),
    );
  }

  //<---helper to catch error when supabase is not retriving due to internet issues or no internet ---->
  Widget _buildOfflineSticker() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orangeAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 60, color: Colors.orangeAccent),
            const SizedBox(height: 15),
            Text(
              "Oops! No internet connection.\nConnect to see the latest recipes",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orangeAccent.shade700,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  recipeFuture = fetchRecipes();
                });
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Retry",
                style: TextStyle(
                color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf06644),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}