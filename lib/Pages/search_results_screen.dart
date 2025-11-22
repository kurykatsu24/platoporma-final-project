// lib/Pages/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:platoporma/widgets/recipe_card.dart'; 

// Colors used in your app (kept consistent)
const Color bgColor = Color(0xFFFDFFEC);
const Color appbarColor = Color(0xFFC2EBD2);
const Color primaryText = Color(0xFF27453E);

// Flag colors (confirmed)
const Color flagComplete = Color(0xFF0ABFB6); // complete
const Color flagMissing = Color(0xFFFC4D4D); // missing

/// Data model representing a recipe result with ingredient-match metadata.
/// We fetch recipe fields and compute `matchedIngredientCount`.
class RecipeResult {
  final String id;
  final String name;
  final String? cuisineType;
  final String? dietType;
  final String? proteinType;
  final int estimatedPriceCentavos;
  final String imagePath;

  // Ingredient matching metadata (used only for ingredient searches)
  final int matchedIngredientCount; // how many of the selected ingredients are present in this recipe
  final int selectedIngredientCount; // how many ingredients were selected in the query

  RecipeResult({
    required this.id,
    required this.name,
    this.cuisineType,
    this.dietType,
    this.proteinType,
    required this.estimatedPriceCentavos,
    required this.imagePath,
    this.matchedIngredientCount = 0,
    this.selectedIngredientCount = 0,
  });

  bool get isCompleteIngredients =>
      selectedIngredientCount > 0 && matchedIngredientCount >= selectedIngredientCount;

  int get missingCount =>
      (selectedIngredientCount > matchedIngredientCount) ? (selectedIngredientCount - matchedIngredientCount) : 0;
}

class SearchResultsPage extends StatefulWidget {
  final String? textQuery;
  final List<String>? ingredientList;

  const SearchResultsPage({
    Key? key,
    this.textQuery,
    this.ingredientList,
  }) : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final supabase = Supabase.instance.client;
  

  bool _isLoading = true;
  String? _error;
  List<RecipeResult> _results = [];
  bool _isIngredientSearch = false;
  String _queryText = '';

  bool _hasExactMatch(String q) {
    if (_results.isEmpty) return false;
    return _results.any((r) => r.name.toLowerCase() == q.toLowerCase());
  }


  @override
  void initState() {
    super.initState();
    _queryText = widget.textQuery?.trim() ?? '';

    // If an explicit ingredientList was provided, run ingredient search immediately.
    if (widget.ingredientList != null) {
      _queryText = widget.ingredientList!.join(', ');
      _isIngredientSearch = true;
      _performIngredientSearch(widget.ingredientList!.map((s) => s.trim()).where((s) => s.isNotEmpty).toList());
    } else {
      // For typed queries, detect whether the query likely refers to ingredients
      // by checking the ingredients table. This handles single-ingredient queries
      // like "corned beef" which previously required a comma to be recognized.
      _detectIngredientSearchAndPerform(_queryText);
    }
  }

  // Asynchronously detect whether the provided query should be treated as an
  // ingredient-list search. Returns true if the query contains commas or if at
  // least one ingredient matches the query in the database.
  Future<bool> _looksLikeIngredientQuery(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return false;

    // Ingredient-mode only if query contains commas.
    return trimmed.contains(',');
  }


  Future<void> _detectIngredientSearchAndPerform(String q) async {
    final looksLikeIngredient = await _looksLikeIngredientQuery(q);
    setState(() {
      _isIngredientSearch = looksLikeIngredient;
    });

    if (_isIngredientSearch) {
      final ingList = q.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      // If user typed a single ingredient without commas, ingList will contain one entry which is fine.
      await _performIngredientSearch(ingList);
    } else {
      await _performSearch();
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });

    try {
      if (_isIngredientSearch) {
        await _performIngredientSearch(_queryText.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList());
      } else {
        await _performRecipeSearch(_queryText);
      }
    } catch (e, st) {
      debugPrint('Search error: $e\n$st');
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ----------------- Recipe Search (name & category) -----------------
  Future<void> _performRecipeSearch(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    // 1) Search by name (case-insensitive, partial match)
    // Use select() and cast to a list (safer than maybeSingle and avoids an unused variable).
    final nameList = await supabase
        .from('recipes')
        .select('id, name, cuisine_type, diet_type, protein_type, estimated_price_centavos, images')
        .ilike('name', '%$query%') as List<dynamic>?;

    final cuisineList = await supabase
        .from('recipes')
        .select('id, name, cuisine_type, diet_type, protein_type, estimated_price_centavos, images')
        .eq('cuisine_type', query)
        .then((v) => v as List<dynamic>?)
        .catchError((_) => []);

    final dietList = await supabase
        .from('recipes')
        .select('id, name, cuisine_type, diet_type, protein_type, estimated_price_centavos, images')
        .eq('diet_type', query)
        .then((v) => v as List<dynamic>?)
        .catchError((_) => []);

    final proteinList = await supabase
        .from('recipes')
        .select('id, name, cuisine_type, diet_type, protein_type, estimated_price_centavos, images')
        .eq('protein_type', query)
        .then((v) => v as List<dynamic>?)
        .catchError((_) => []);

    // Aggregate unique recipe rows
    final combined = <Map<String, dynamic>>[];
    void addAllIfNotPresent(List<dynamic>? list) {
      if (list == null) return;
      for (final item in list) {
        final m = Map<String, dynamic>.from(item as Map);
        if (!combined.any((c) => c['id'] == m['id'])) {
          combined.add(m);
        }
      }
    }

    addAllIfNotPresent(nameList);
    addAllIfNotPresent(cuisineList);
    addAllIfNotPresent(dietList);
    addAllIfNotPresent(proteinList);

    // Build results
    final res = combined.map((json) {
      return RecipeResult(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        cuisineType: json['cuisine_type'],
        dietType: json['diet_type'],
        proteinType: json['protein_type'],
        estimatedPriceCentavos: json['estimated_price_centavos'] ?? 0,
        imagePath: (json['images'] ?? '') as String,
      );
    }).toList();

    // Did you mean: if there are results but none exactly match the query by name,
    // show a suggestion later in the UI. We simply store results here.
    setState(() {
      _results = res;
    });
  }

  // ----------------- Ingredient Search (ALL match logic) -----------------
  Future<void> _performIngredientSearch(List<String> selectedNames) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (selectedNames.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    try {
      // 1️⃣ Fetch ingredient IDs for selected names
      final Map<String, String> nameToId = {};

      for (final name in selectedNames) {
        final rows = await supabase
            .from('ingredients')
            .select('id, name')
            .ilike('name', '%$name%')
            .limit(1) as List<dynamic>;

        if (rows.isNotEmpty) {
          nameToId[name] = rows.first['id'].toString();
        }
      }

      final ingIds = nameToId.values.toList();

      // If NO ingredient matches at all → no results
      if (ingIds.isEmpty) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        return;
      }

      // 2️⃣ Get recipes that contain ANY of these ingredients
      final matchedRows = await supabase
          .from('recipe_ingredients')
          .select('recipe_id, ingredient_id')
          .inFilter('ingredient_id', ingIds) as List<dynamic>;

      if (matchedRows.isEmpty) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        return;
      }

      // recipeId -> matched ingredient IDs
      final Map<String, Set<String>> matchedMap = {};
      for (final row in matchedRows) {
        final recipeId = row['recipe_id'].toString();
        final ingredientId = row['ingredient_id'].toString();

        matchedMap.putIfAbsent(recipeId, () => <String>{});
        matchedMap[recipeId]!.add(ingredientId);
      }

      final recipeIds = matchedMap.keys.toList();

      // 3️⃣ Fetch ALL recipe ingredients to compute missing ingredients
      final allIngRows = await supabase
          .from('recipe_ingredients')
          .select('recipe_id, ingredient_id')
          .inFilter('recipe_id', recipeIds) as List<dynamic>;

      final Map<String, Set<String>> fullIngMap = {};
      for (final row in allIngRows) {
        final recipeId = row['recipe_id'].toString();
        final ingredientId = row['ingredient_id'].toString();

        fullIngMap.putIfAbsent(recipeId, () => <String>{});
        fullIngMap[recipeId]!.add(ingredientId);
      }

      // 4️⃣ Fetch recipe info
      final recipeRows = await supabase
          .from('recipes')
          .select('id, name, cuisine_type, diet_type, protein_type, estimated_price_centavos, images')
          .inFilter('id', recipeIds) as List<dynamic>;

      final List<RecipeResult> results = [];

      for (final r in recipeRows) {
        final recipeId = r['id'].toString();
        final matchedCount = matchedMap[recipeId]?.length ?? 0;
        final totalIngredients = fullIngMap[recipeId]?.length ?? 0;

        results.add(
          RecipeResult(
            id: recipeId,
            name: r['name'] ?? '',
            cuisineType: r['cuisine_type'],
            dietType: r['diet_type'],
            proteinType: r['protein_type'],
            estimatedPriceCentavos: r['estimated_price_centavos'] ?? 0,
            imagePath: r['images'] ?? '',
            matchedIngredientCount: matchedCount,
            selectedIngredientCount: totalIngredients, // IMPORTANT
          ),
        );
      }

      // Sort: fewest missing first
      results.sort((a, b) => a.missingCount.compareTo(b.missingCount));

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ---------- UI helpers ----------
  Widget _buildAppBar(double screenW) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // --- Left: Back button (kept from your UI) ---
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
                    iconSize: 22,
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(width: 8),

                // --- Appbar Title ---
                Expanded(
                  child: Text(
                    'Search Result',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'NiceHoney',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                      height: 1,
                    ),
                  ),
                ),

                const SizedBox(width: 55), // Spacer to balance layout visually
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsFor(String query) {
    final bool exact = _hasExactMatch(query);
    final double bottomPad = exact ? 15 : 0;

    return Padding(
      padding: EdgeInsets.only(left: 18, right: 18, top: 15, bottom: bottomPad),
      child: Text(
        'Results for "$query"',
        textAlign: TextAlign.left,
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

  Widget _buildDidYouMeanSuggestion(String originalQuery) {
    if (_results.isEmpty) return const SizedBox.shrink();

    final bool exactMatch = _hasExactMatch(originalQuery);
    if (exactMatch) return const SizedBox.shrink();

    final suggestion = _results.first.name;

    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 15),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'NiceHoney',
            fontSize: 18,
            fontWeight: FontWeight.w100,
            letterSpacing: -1,
            color: primaryText, // default for "Did you mean" + "?"
          ),
          children: [
            const TextSpan(text: 'Did you mean '),
            TextSpan(
              text: suggestion, // no quotes
              style: const TextStyle(
                color: Color(0xFFF06644),
                fontStyle: FontStyle.italic,
              ),
            ),
            const TextSpan(text: ' ?'),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag(RecipeResult r) {
    if (!_isIngredientSearch) return const SizedBox.shrink();

    final bool complete = r.isCompleteIngredients;
    final Color bg = complete ? flagComplete : flagMissing;
    final String text = complete
        ? 'Complete\nIngredients'
        : 'Missing\nIngredients\n(${r.missingCount})';

    return Transform.translate(
      offset: const Offset(0, 0), // shift flag slightly to the left
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            text,
            textAlign: TextAlign.center, // <-- center the multiline text
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildResultsGrid(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            'Error: $_error',
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.red),
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Sorry, but\nno results found for "${_queryText}"',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primaryText,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
      child: MasonryGridView.count(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(), // outer scroll handles scroll
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final item = _results[index];

          // Wrap existing RecipeCard in a Stack to overlay flag at top-right
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // underlying card
              RecipeCard(
                name: item.name,
                cuisineType: item.cuisineType,
                dietType: item.dietType,
                proteinType: item.proteinType,
                estimatedPriceCentavos: item.estimatedPriceCentavos,
                imagePath: item.imagePath,
              ),

              // positioned flag
              if (_isIngredientSearch)
                Positioned(
                  right: 8,
                  top: 6,
                  child: _buildFlag(item),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverToBoxAdapter(child: _buildAppBar(screenW)),

          // Spacer
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Results For <query> title
          SliverToBoxAdapter(child: _buildResultsFor(_queryText)),

          // Optional Did-you-mean suggestion (only for recipe searches)
          if (!_isIngredientSearch) SliverToBoxAdapter(child: _buildDidYouMeanSuggestion(_queryText)),

          // Results grid
          SliverToBoxAdapter(child: _buildResultsGrid(context)),
        ],
      ),
    );
  }
}