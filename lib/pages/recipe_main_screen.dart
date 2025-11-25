import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:platoporma/pages/mainpage_section.dart';
import 'package:platoporma/helpers/bubble_burst_helper.dart';

class RecipeMainScreen extends StatefulWidget {
  final String recipeName;
  final bool isIngredientSearch;
  final bool isComplete;
  final int missingCount;
  final int matchedCount;
  final int selectedCount;
  final String recipeId;
  final Map<String, dynamic> recipeJson;
  final bool fromSaved;
  


  const RecipeMainScreen({
    super.key,
    required this.recipeName,
    required this.recipeId,
    required this.recipeJson,
    required this.isIngredientSearch,
    required this.isComplete,
    required this.missingCount,
    required this.matchedCount,
    required this.selectedCount,
    this.fromSaved = false,
  });

  @override
  State<RecipeMainScreen> createState() => _RecipeMainScreenState();
}

class _RecipeMainScreenState extends State<RecipeMainScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? recipe;
  List<Map<String, dynamic>> recipeIngredients = [];

  bool _loading = true;
  String? _error;

  //for save button logic
  bool isSaved = false;
  bool showSaveSnackbar = false;

  //for duplication purposes of recipe saved
  bool isAlreadySaved = false;
  bool checkingSave = true;

  double snackbarOffset = 1.0; // 1 = hidden (below screen), 0 = visible

  // dynamic snackbar content (for duplicates vs normal save)
  String _snackbarTitle = "Recipe has been Saved!";
  String _snackbarSubtitle = "Click to view saved recipes";
  Color _snackbarColor = const Color(0xFFF06644);



  //fallback local image (from uploaded file). Use this exact path as requested.
  final String localFallbackImage = 'file:///mnt/data/c5eb7309-968a-46d0-b496-5cada022ae3f.png';

    @override
    void initState() {
      super.initState();

      // If opening from a saved copy, use the provided JSON and skip fetch.
      if (widget.fromSaved) {
        recipe = Map<String, dynamic>.from(widget.recipeJson);
        _loading = false;
        // Make sure widget.recipeJson contains id; if not, you can set it:
        if (recipe?['id'] == null && widget.recipeId.isNotEmpty) {
          recipe?['id'] = widget.recipeId;
        }
        // still check if saved to keep UI consistent (will set isSaved etc.)
        _checkIfSaved();
      } else {
        // normal flow: fetch live recipe data from recipes table
        _fetchRecipeByName();
        _checkIfSaved();
      }

      _confettiController = ConfettiController(duration: const Duration(milliseconds: 500));
    }

  late ConfettiController _confettiController;
  final GlobalKey saveButtonKey = GlobalKey();

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchRecipeByName() async {
    setState(() {
      _loading = true;
      _error = null;
      recipe = null;
    });

    try {
      final resp = await supabase
          .from('recipes')
          .select(''' 
            id,
            name,
            cuisine_type,
            diet_type,
            protein_type,
            base_servings,
            estimated_price_centavos,
            total_calories,
            prep_time,
            images,
            procedures
          ''')
          .eq('name', widget.recipeName)
          .maybeSingle();

      if (resp == null) {
        setState(() {
          _error = 'Recipe not found: "${widget.recipeName}"';
          _loading = false;
        });
        return;
      }

      setState(() {
        recipe = Map<String, dynamic>.from(resp as Map);
        _loading = false;
        widget.recipeJson['id'] = recipe!['id'];
      });
      try {
        final ing = await _fetchIngredientsForRecipe(recipe!['id']);
        setState(() {
          recipeIngredients = ing;
          _loading = false;
        });
      } catch (e) {
        debugPrint("Ingredient fetch error: $e");
        setState(() => _loading = false);
      }

    } catch (e, st) {
      debugPrint('Fetch recipe error: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchIngredientsForRecipe(String recipeId) async {
    final result = await supabase
        .from('recipe_ingredients')
        .select('''
          id,
          quantity_q,
          prepared_type,
          ingredients ( name ),
          ingredient_units ( unit_name, conversion )
        ''')
        .eq('recipe_id', recipeId);

    return List<Map<String, dynamic>>.from(result);
  }

  List<String> _normalizeImages(dynamic raw) {
    if (raw == null) return [];
    if (raw is String && raw.trim().isNotEmpty) return [raw];
    if (raw is List) return raw.cast<String>();
    return [];
  }

  String _formatPeso(dynamic centavos) {
    if (centavos == null) return "-";
    // centavos should be numeric (int)
    try {
      final centsAsNum = centavos is int ? centavos : int.parse(centavos.toString());
      final pesos = centsAsNum / 100;
      return "₱${pesos.toStringAsFixed(2)}";
    } catch (_) {
      return "-";
    }
  }

  String _prepTimeText(dynamic prepTime) {
    if (prepTime == null) return "-";
    final p = int.tryParse(prepTime.toString()) ?? 0;
    return "$p ${p == 1 ? 'min' : 'mins'}";
  }

  String _servingsText(dynamic servings) {
    if (servings == null) return "-";
    final s = int.tryParse(servings.toString()) ?? 0;
    return "$s ${s == 1 ? 'serving' : 'servings'}";
  }

  String _caloriesText(dynamic kcal) {
    if (kcal == null) return "-";
    final c = int.tryParse(kcal.toString()) ?? 0;
    return "$c kcal";
  }

  Future<void> _checkIfSaved() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('saved_recipes')
        .select('id')
        .eq('user_id', user.id)
        .eq('recipe_id', recipe?['id'] ?? widget.recipeId)
        .maybeSingle();

    if (mounted) {
      setState(() {
        isAlreadySaved = response != null;
        isSaved = response != null; //this ensures UI button stays saved
        checkingSave = false;
      });
    }
  }

  Future<void> _saveRecipe() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() {
      isAlreadySaved = true;
      isSaved = true;    // <-- this triggers the UI scale animation
    });

    // Insert
    await Supabase.instance.client.from('saved_recipes').insert({
      "user_id": user.id,
      "recipe_id": recipe?['id'] ?? widget.recipeId,
      "initial_recipe_json": widget.recipeJson,
    });

    setState(() => isAlreadySaved = true);

  }


  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFDFFEC);
    final images = _normalizeImages(recipe?['images']);

    return Scaffold(  
      backgroundColor: bgColor,

      //<----- Wrap entire SafeArea + Scroll in a Stack so we can overlay the floating flag ------>
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: GoogleFonts.dmSans(color: Colors.red),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                    

                            //<----- Recipe Image ----->
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.20),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: const Border(
                                    bottom: BorderSide(width: 8, color: Colors.white),
                                  ),
                                ),
                                child: ClipRRect(
                                  child: AspectRatio(
                                    aspectRatio: 1.0,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        if (images.isNotEmpty)
                                          PageView.builder(
                                            itemCount: images.length,
                                            itemBuilder: (context, index) {
                                              final url = images[index];

                                              return Image.asset(
                                                url,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) {
                                                  return _fallbackImageWidget();
                                                },
                                              );
                                            },
                                          )
                                        else
                                          _fallbackImageWidget(),

                                        //top-left back button
                                        Positioned(
                                          top: 18,
                                          left: 15,
                                          child: _circleIconButton(
                                            child: IconButton(
                                              iconSize: 22,
                                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ),
                                        ),

                                        //top-right save button (with animation logic)
                                        //also hidden when opened from Saved Recipes
                                        if (!widget.fromSaved)
                                          Positioned(
                                            top: 17,
                                            right: 14,
                                            child: _circleIconButton(
                                              child: SizedBox(
                                                key: saveButtonKey,
                                                width: 44,
                                                height: 44,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  iconSize: 22,
                                                  onPressed: () async {
                                                    //<--- the Bubble burst animation should fire immediately ---->
                                                    showBubbleBurst(
                                                      context: context,
                                                      key: saveButtonKey,
                                                      offset: const Offset(-4, -3),
                                                    );

                                                    //<--- Duplicate checking before firing animations ----->
                                                    if (isAlreadySaved) {
                                                      setState(() {
                                                        isSaved = true;
                                                        showSaveSnackbar = true;
                                                        snackbarOffset = 0.0;

                                                        // duplicate snackbar
                                                        _snackbarTitle = "Already saved this recipe";
                                                        _snackbarSubtitle = "Click to view saved recipes";
                                                        _snackbarColor = const Color(0xFFFC4D4D);
                                                      });

                                                      Future.delayed(const Duration(seconds: 5), () {
                                                        if (!mounted) return;
                                                        setState(() => snackbarOffset = 1.0);

                                                        Future.delayed(const Duration(milliseconds: 300), () {
                                                          if (mounted) setState(() => showSaveSnackbar = false);
                                                        });
                                                      });

                                                      return;
                                                    }

                                                    //<--- Normal Save logic---->
                                                    setState(() {
                                                      isSaved = true;
                                                      showSaveSnackbar = true;
                                                      snackbarOffset = 0.0;
                                                      _snackbarTitle = "Recipe has been Saved!";
                                                      _snackbarSubtitle = "Click to view saved recipes";
                                                      _snackbarColor = const Color(0xFFF06644);
                                                    });

                                                    Future.delayed(const Duration(seconds: 5), () {
                                                      if (!mounted) return;
                                                      setState(() => snackbarOffset = 1.0);

                                                      Future.delayed(const Duration(milliseconds: 300), () {
                                                        if (mounted) setState(() => showSaveSnackbar = false);
                                                      });
                                                    });

                                                    await _saveRecipe();
                                                  },
                                                  icon: TweenAnimationBuilder(
                                                    duration: const Duration(milliseconds: 500),
                                                    tween: Tween<double>(begin: 1.0, end: isSaved ? 1.20 : 1.0),
                                                    curve: Curves.easeOutBack,
                                                    builder: (context, scale, child) {
                                                      return Transform.scale(
                                                        scale: scale,
                                                        child: Container(
                                                          width: 44,
                                                          height: 44,
                                                          decoration: BoxDecoration(
                                                            color: isSaved ? const Color(0xFFF06644) : Colors.white,
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: isSaved ? Colors.white : Colors.transparent,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Image.asset(
                                                              isSaved
                                                                  ? 'assets/icon_images/saved_active.png'
                                                                  : 'assets/icon_images/saved_inactive.png',
                                                              width: 23,
                                                              height: 23,
                                                              color: isSaved ? Colors.white : null,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            //<----- Recipe Details Container ----->
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.20),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [                            

                                    //<---- Name + Pills + Price ---->
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        //<---- Left Column ---->
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe?['name'] ?? widget.recipeName,
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -2,
                                                  color: Colors.black,
                                                  height: 1,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),                                                                                      

                                              const SizedBox(height: 12),

                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 6,
                                                children: [
                                                  _pill(
                                                    label: recipe?['cuisine_type']?.toString() ?? '-',
                                                    bgColor: const Color(0xFFD6FFFF),
                                                    outlineColor: const Color(0xFF0B9999),
                                                    textColor: const Color(0xFF0B9999),
                                                  ),
                                                  if ((recipe?['diet_type'] ?? '').toString().trim().isNotEmpty)
                                                    _pill(
                                                      label: (recipe?['diet_type'] ?? '').toString(),
                                                      bgColor: const Color(0xFFFFFACD),
                                                      outlineColor: const Color(0xFFCD901F),
                                                      textColor: const Color(0xFFCD901F),
                                                    ),
                                                  if ((recipe?['protein_type'] ?? '').toString().trim().isNotEmpty)
                                                    _pill(
                                                      label: (recipe?['protein_type'] ?? '').toString(),
                                                      bgColor: const Color(0xFFFFD0E5),
                                                      outlineColor: const Color(0xFFC73576),
                                                      textColor: const Color(0xFFC73576),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 13),

                                        //<---- Estimated Price ---->
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2FCEC),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Estimated Price",
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 11.8,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  letterSpacing: -0.2,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                _formatPeso(recipe?['estimated_price_centavos']),
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 27,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                  letterSpacing: -1,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    //<---- Flag for Ingredient based search results ---->
                                    buildIngredientFlag(),                                   

                                    const SizedBox(height: 16),

                                    //<---- Marker Boxes ---->
                                    Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _markerBox(
                                            iconAsset: 'assets/icon_images/clock.png',
                                            fallbackIcon: Icons.schedule,
                                            label: _prepTimeText(recipe?['prep_time']),
                                          ),
                                          const SizedBox(width: 20),
                                          _markerBox(
                                            iconAsset: 'assets/icon_images/cloche.png',
                                            fallbackIcon: Icons.restaurant_menu,
                                            label: _servingsText(recipe?['base_servings']),
                                          ),
                                          const SizedBox(width: 20),
                                          _markerBox(
                                            iconAsset: 'assets/icon_images/flame.png',
                                            fallbackIcon: Icons.local_fire_department,
                                            label: _caloriesText(recipe?['total_calories']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            //<----- Ingredients & Procedures ----->
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.20),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ingredients",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    recipeIngredients.isEmpty
                                        ? Text("No ingredients found.", style: GoogleFonts.dmSans())
                                        : Column(
                                            children:
                                                recipeIngredients.map((item) => _ingredientItem(item)).toList(),
                                          ),

                                    const SizedBox(height: 22),

                                    Container(
                                      height: 1,
                                      color: const Color(0xFF659689).withOpacity(0.30),
                                    ),

                                    const SizedBox(height: 22),

                                    Text(
                                      "Directions",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    if (recipe?['procedures'] is List)
                                      DefaultTextStyle.merge(
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w100,
                                          height: 1.5,
                                          letterSpacing: -0.3,
                                          color: Colors.black87,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: _buildProcedureList(recipe!['procedures']),
                                        ),
                                      )
                                    else
                                      Text(
                                        recipe?['procedures']?.toString() ?? "No procedures available.",
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 1.6,
                                        ),
                                      ),

                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
          ),
        
        //<------ Custom Snackbar after saving ----->
        if (showSaveSnackbar)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              offset: Offset(0, snackbarOffset), 
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: snackbarOffset == 0 ? 1 : 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPageSection(initialIndex: 2)),
                    );
                  },
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),      
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 11.5,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: _snackbarColor,

                            borderRadius: BorderRadius.circular(13),                            
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _snackbarTitle,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _snackbarSubtitle,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          

        ],
      ),
    );
  }

  
  //<------- Widget UI helpers ------>
  
  Widget buildIngredientFlag() {
    if (!widget.isIngredientSearch) return const SizedBox.shrink();

    final bool complete = widget.isComplete;
    final Color bg = complete ? const Color(0xFF0ABFB6) : const Color(0xFFFC4D4D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            complete
                ? 'Complete Ingredients'
                : 'Missing Ingredients (${widget.missingCount})',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 13.3,
              fontWeight: FontWeight.w700,
            ),
          ),          
          if (!complete) ...[
            const SizedBox(height: 2),
            Text(
              'See full ingredients below',
              style: GoogleFonts.dmSans(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // fallback image widget uses the uploaded local path as requested
  Widget _fallbackImageWidget() {
    // If the file exists locally, show Image.file; else try to use Image.network with path (file://).
    try {
      final file = File(Uri.parse(localFallbackImage).toFilePath());
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    } catch (_) {}
    // last resort: use Image.network with file:// url (platform will likely pick it up in your environment)
    return Image.network(localFallbackImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
      return Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 48)));
    });
  }

  Widget _circleIconButton({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _pill({
    required String label,
    required Color bgColor,
    required Color outlineColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineColor, width: 2),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _markerBox({
    required String iconAsset,
    required IconData fallbackIcon,
    required String label,
  }) {
    return Container(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF659689).withOpacity(0.30), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFC2EBD2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _iconForAsset(iconAsset, fallbackIcon),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _iconForAsset(String assetPath, IconData fallback) {
    //try loading asset; if not present, fallback to icon
    try {
      return Image.asset(assetPath, width: 30, height: 30, color: const Color(0xFF416F64), errorBuilder: (_, __, ___) {
        return Icon(fallback, color: const Color(0xFF416F64));
      });
    } catch (_) {
      return Icon(fallback, color: const Color(0xFF416F64));
    }
  }

  //helpers for ingredients
  String _formatUnit(String unitName, num convertedQty) {
    if (unitName.isEmpty) return "";

    if (convertedQty <= 1) return unitName;

    if (unitName.endsWith("s")) return unitName;

    return "${unitName}s";
  }

  

  Widget _ingredientItem(Map<String, dynamic> item) {
    final qty = item['quantity_q'] ?? 0;
    final ingr = item['ingredients'];
    final unit = item['ingredient_units'];

    final name = ingr?['name']?.toString() ?? "";
    final prepared = item['prepared_type']?.toString().trim();
    final unitName = unit?['unit_name']?.toString() ?? "";
    final conversion = unit?['conversion'] == null
        ? 1.0
        : double.tryParse(unit['conversion'].toString()) ?? 1.0;

    // Detect fractional units such as "1/2 cup", "1/4 kilo", "½ cup"
    final bool isFractionUnit =
        unitName.contains('/') || unitName.contains('½') || unitName.contains('¼') || unitName.contains('¾');

    String displayText;

    if (isFractionUnit) {
      // ---- Fraction units: ignore numeric conversion ----
      displayText = "$unitName $name";
    } else {
      // ---- Normal numeric units ----
      final value = qty * conversion;
      final qtyText = (value % 1 == 0) ? value.toInt().toString() : value.toString();
      final unitText = _formatUnit(unitName, value);

      displayText = "$qtyText $unitText $name";
    }

    if (prepared != null && prepared.isNotEmpty) {
      displayText += ", $prepared";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              "•",
              style: TextStyle(
                color: Color(0xFFF06644),
                fontSize: 20,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              displayText,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }



  List<Widget> _buildProcedureList(dynamic rawProcedures) {
    if (rawProcedures is List) {
      return List.generate(
        rawProcedures.length,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${i + 1}.",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  rawProcedures[i].toString(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return [Text(rawProcedures.toString())];
  }
}