import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/widgets/recipes/saved_recipe_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedSection extends StatefulWidget {
  const SavedSection({super.key});

  @override
  State<SavedSection> createState() => _SavedSectionState();
}

class _SavedSectionState extends State<SavedSection> {
  String selected = "recent"; //pill state
  List<Map<String, dynamic>> savedRecipes = [];
  bool loading = true;
  bool offline = false;

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('saved_recipes')
          .select('id, recipe_id, initial_recipe_json, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          savedRecipes = response;
          loading = false;
          offline = false; // success
        });
      }
    } catch (e) {
      // socket exception / dns / supabase unreachable → offline UI
      if (mounted) {
        setState(() {
          loading = false;
          offline = true;
        });
      }
    }
  }

  Future<void> _deleteSavedRecipe(String id) async {
    await Supabase.instance.client
        .from('saved_recipes')
        .delete()
        .eq('id', id);

    _loadSavedRecipes();
  }

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
            floating: false,
            pinned: false,
            elevation: 0,
            backgroundColor: const Color(0xFFC2EBD2),
            expandedHeight: 135,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //<---- Title with icons ---->
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/fork_icon.png',
                              width: screenW * 0.18, height: screenW * 0.18),
                          const SizedBox(width: 1),
                          const Text("Saved Recipes",
                              style: TextStyle(
                                fontFamily: 'NiceHoney',
                                color: Color(0xFF27453E),
                                fontSize: 36,
                              )),
                          const SizedBox(width: 1),
                          Image.asset('assets/images/spoon_icon.png',
                              width: screenW * 0.18, height: screenW * 0.18),
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

          // ---------- PILLS ----------
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

          //<---------- Contents---------->
          SliverToBoxAdapter(
            child: loading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : offline
                    ? _buildOfflineSticker()
                    : _buildSavedList(),
          ),
        ],
      ),
    );
  }

  // ---------- LIST BUILDER ----------
  Widget _buildSavedList() {
    if (savedRecipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Text(
            "No saved recipes yet!",
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    List<Map<String, dynamic>> displayList =
        selected == "recent" ? savedRecipes.take(5).toList() : savedRecipes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var item in displayList) ...[
            SavedRecipeCard(
              saveId: item["id"],
              recipeId: item["recipe_id"],
              recipeJson: item["initial_recipe_json"],
              onDelete: () => _deleteSavedRecipe(item["id"]),
            ),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------- PILL ----------
  Widget _buildPill(String label) {
    const activeColor = Color(0xFFF06644);
    const inactiveBG = Color(0xFFECECEC);
    bool isActive = selected == label;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => selected = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                  fontSize: 13,
                  color: isActive ? activeColor : Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
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
              "You're offline!\nSaved recipes need internet to sync",
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
                  loading = true;
                });
                _loadSavedRecipes();
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