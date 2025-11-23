import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeMainScreen extends StatefulWidget {
  final String recipeName;
  final bool isFlagged;

  const RecipeMainScreen({
    super.key,
    required this.recipeName,
    required this.isFlagged,
  });

  @override
  State<RecipeMainScreen> createState() => _RecipeMainScreenState();
}

class _RecipeMainScreenState extends State<RecipeMainScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? recipe;
  bool _loading = true;
  String? _error;

  // fallback local image (from uploaded file). Use this exact path as requested.
  final String localFallbackImage = 'file:///mnt/data/c5eb7309-968a-46d0-b496-5cada022ae3f.png';

  @override
  void initState() {
    super.initState();
    _fetchRecipeByName();
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
      });
    } catch (e, st) {
      debugPrint('Fetch recipe error: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFFDFFEC);
    final images = _normalizeImages(recipe?['images']);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: GoogleFonts.dmSans(color: Colors.red)))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        //<----- Recipe Image ----->
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            // important: clipped to 1:1 aspect ratio
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
                                    //Image displayed on top
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

                                    //top-left back button (hindi fixed kay part of stack so scrolls along with image)
                                    Positioned(
                                      top: 15,
                                      left: 15,
                                      child: _circleIconButton(
                                        child: IconButton(
                                          iconSize: 22,
                                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                                          onPressed: () => Navigator.pop(context),  
                                        ),
                                      ),
                                    ),

                                    //top-right save button
                                    Positioned(
                                      top: 14,
                                      right: 14,
                                      child: _circleIconButton(
                                        child: SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 22,
                                            // Using asset image; if asset not available fallback to bookmark icon
                                            icon: Image.asset(
                                              'assets/icon_images/saved_inactive.png',
                                              width: 23,
                                              height: 23,
                                            ),
                                            onPressed: () {
                                              //need to connect to saved recipes section later
                                            },
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

                                //<---- Presented in a row: on the left (Name + Pills (column), and on the right (Estimated Price box) ---->
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // left column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          //Recipe name
                                          Text(
                                            recipe?['name'] ?? widget.recipeName,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w800, // extrabold
                                              letterSpacing: -2,
                                              color: Colors.black,
                                              height: 1,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 12),

                                          //Pills for cuisine_type, diet_type, protein_type (eithe of the three can show, mostly optional
                                          //if recipe has both diet type and cuisine type
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              _pill(
                                                label: recipe?['cuisine_type']?.toString() ?? '-',
                                                bgColor: const Color(0xFFD6FFFF),
                                                outlineColor: const Color(0xFF0B9999).withOpacity(1), // OB9999 approximated
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

                                    //Estimated price container
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

                                const SizedBox(height: 25),

                                //Recipe markers (prep time, no. of servings, and total calories)
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

                        // ===============================
                        // Ingredients & Procedures placeholder container
                        // ===============================
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
                                // Placeholder: you said you're tired, so keep placeholder style
                                Text(
                                  "Ingredients will appear here (placeholder).",
                                  style: GoogleFonts.dmSans(),
                                ),
                                const SizedBox(height: 30),
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
                                  ..._buildProcedureList(recipe!['procedures'])
                                else
                                  Text(
                                    recipe?['procedures']?.toString() ?? "No procedures available.",
                                    style: GoogleFonts.dmSans(),
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
      // floating FLAG (top-right) if flagged: kept as before, but positioned via Stack previously; since we removed the outer stack, keep as overlay via this builder:
      persistentFooterButtons: widget.isFlagged
          ? [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "FLAGGED",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ]
          : null,
    );
  }

  // -------------------------
  // Widgets & helpers
  // -------------------------

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
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
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

  List<Widget> _buildProcedureList(dynamic rawProcedures) {
    if (rawProcedures is List) {
      return List.generate(
        rawProcedures.length,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${i + 1}.  ", style: GoogleFonts.dmSans()),
              Expanded(
                child: Text(
                  rawProcedures[i].toString(),
                  style: GoogleFonts.dmSans(),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return [
      Text(
        rawProcedures?.toString() ?? "No procedures",
        style: GoogleFonts.dmSans(),
      )
    ];
  }
}