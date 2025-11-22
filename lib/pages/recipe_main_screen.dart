import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    final images = _normalizeImages(recipe?['images']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeName, style: GoogleFonts.dmSans()),
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: GoogleFonts.dmSans(color: Colors.red),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // =======================
                            // IMAGES (PageView)
                            // =======================
                            if (images.isNotEmpty)
                              SizedBox(
                                height: 220,
                                child: PageView.builder(
                                  itemCount: images.length,
                                  itemBuilder: (context, i) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      images[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // =======================
                            // NAME
                            // =======================
                            Text(
                              recipe!['name'] ?? widget.recipeName,
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // =======================
                            // BASIC DETAILS
                            // =======================
                            _field("Cuisine Type", recipe!["cuisine_type"]),
                            _field("Diet Type", recipe!["diet_type"]),
                            _field("Protein Type", recipe!["protein_type"]),
                            _field("Base Servings", recipe!["base_servings"]),
                            _field(
                              "Estimated Price (₱)",
                              _peso(recipe!["estimated_price_centavos"]),
                            ),
                            _field(
                              "Total Calories",
                              recipe!["total_calories"],
                            ),

                            const SizedBox(height: 24),

                            // =======================
                            // PROCEDURES
                            // =======================
                            Text(
                              "Procedures",
                              style: GoogleFonts.dmSans(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),

                            ..._buildProcedureList(
                                recipe!["procedures"] ?? []),
                          ],
                        ),
                      ),
                    ),

          // =======================
          // FLOATING FLAG (top-right)
          // =======================
          if (widget.isFlagged)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              ),
            ),
        ],
      ),
    );
  }

  // =======================
  // HELPERS
  // =======================

  Widget _field(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: ${value ?? "-"}",
        style: GoogleFonts.dmSans(fontSize: 15),
      ),
    );
  }

  String _peso(dynamic centavos) {
    if (centavos == null) return "-";
    return (centavos / 100).toStringAsFixed(2);
  }

  List<String> _normalizeImages(dynamic raw) {
    if (raw == null) return [];
    if (raw is String && raw.trim().isNotEmpty) return [raw];
    if (raw is List) return raw.cast<String>();
    return [];
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
