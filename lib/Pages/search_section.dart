import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe_prediction.dart';
import '../services/search_service.dart';
import '../Widgets/recipe_prediction_box.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

enum FilterType { none, recipe, ingredient }

class _SearchSectionState extends State<SearchSection> with SingleTickerProviderStateMixin {
  // State
  FilterType _activeFilter = FilterType.none; // initialized to recipe per your request
  bool _dropdownVisible = false;

  // predictions state
  List<RecipePrediction> _predictions = [];
  bool _isFetchingPrediction = false;
  Timer? _debounce;
  
  late final RecipeSearchService _searchService;

  // controls visual state:
  bool _filterVisible = true; // controls filter box opacity+slide
  bool _slideSearch = false; // when true -> search box slides left into filter space
  bool _isSearching = false; // true when search field is focused/tapped and Cancel visible

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Animation controller for subtle animations (optional)
  late final AnimationController _animController;


  // tweak durations/delays here
  final Duration animDuration = const Duration(milliseconds: 220);
  final Duration slideDelay = const Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _searchService = RecipeSearchService(client: Supabase.instance.client);
    _animController = AnimationController(vsync: this, duration: animDuration);

    // Keep logic centralized in focus listener (start/stop animations in order)
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _onFocusGained();
      } else {
        _onFocusLost();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Colors from spec
  static const Color bgColor = Color(0xFFFDFFEC);
  static const Color appbarColor = Color(0xFFCCEDD8);
  static const Color primaryText = Color(0xFF27453E);

  // CHANGED: inactive ellipse must be coral #E56A48 per your request
  static const Color filterInactiveEllipse = Color(0xFFE56A48);
  static const Color filterActiveEllipse = Color(0xFF659EF4);
  static const Color pillActiveText = Color(0xFFDD6A4D);

  // ---------------- Focus/animation handlers ----------------
  void _onFocusGained() {
    // When focus gained: first hide/filter (fade+slide left), then slide search
    setState(() {
      _filterVisible = false;
    });

    Future.delayed(slideDelay, () {
      // only slide search if still focused
      if (_focusNode.hasFocus) {
        setState(() {
          _slideSearch = true;
          _isSearching = true; // show cancel (outside)
        });
      }
    });
  }

  void _onFocusLost() {
    // Reverse: hide cancel + slide search back, then show filter again
    setState(() {
      _isSearching = false;
      _slideSearch = false;
    });

    Future.delayed(slideDelay, () {
      if (!_focusNode.hasFocus) {
        setState(() {
          _filterVisible = true;
        });
      }
    });
  }

  // ---------------- Utility: compute filter size (same logic as in your method) ----------------
  double _filterBoxSize(double screenW) {
    final containerWidth = (screenW - 32) * 0.15; // 16px horizontal padding both sides
    return containerWidth.clamp(56.0, 92.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final double filterSize = _filterBoxSize(screenW);
    final double gapBetween = 9.0; // gap you used between filter and search

    // width for overlay button (tweak this if you want it bigger/smaller)
    const double overlayBtnWidth = 69.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---------- Content (AppBar + Search Row) ----------
          Positioned.fill(
            child: MediaQuery.removeViewInsets(
              removeBottom: true,
              context: context,
              child: MediaQuery.removePadding(
                removeBottom: true,
                context: context,
                child: CustomScrollView(
                  slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: false,
                    floating: false,
                    backgroundColor: appbarColor,
                    elevation: 0,
                    expandedHeight: 135,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: SafeArea(
                        bottom: false,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: appbarColor,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenW * 0.04,
                              vertical: screenW * 0.05,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                
                                // Left icon
                                Image.asset(
                                  'assets/images/fork_icon.png',
                                  width: screenW * 0.17,
                                  height: screenW * 0.17,
                                  fit: BoxFit.contain,
                                ),

                                const SizedBox(width: 1),

                                // Center text
                                Flexible(
                                  child: Text(
                                    'What are we\ncooking today?',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'NiceHoney',
                                      color: primaryText,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 34,
                                      height: 1,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 1),

                                // Right icon
                                Image.asset(
                                  'assets/images/spoon_icon.png',
                                  width: screenW * 0.17,
                                  height: screenW * 0.17,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Small spacer before sticky header / rest of content
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 20),
                  ),

                  // ---------- Search Row (Filter + Search) as pinned header-ish
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          // Row container with shadow (height 60)
                          SizedBox(
                            height: 50,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Main Row (filter + search). The Cancel/Search is overlayed so it doesn't affect layout.
                                Row(
                                  children: [
                                    // Filter box - 20% width, but maintain 1:1 ratio (square)
                                    // We wrap in AnimatedSlide + AnimatedOpacity to both slide left and fade
                                    AnimatedSlide(
                                      duration: animDuration,
                                      offset: _filterVisible ? Offset.zero : const Offset(-0.25, 0),
                                      child: AnimatedOpacity(
                                        duration: animDuration,
                                        opacity: _filterVisible ? 1.0 : 0.0,
                                        child: _buildFilterBox(screenW),
                                      ),
                                    ),

                                    // space between filter and search
                                    SizedBox(width: _filterVisible ? gapBetween : gapBetween),

                                    // Search box - remaining width (80%)
                                    // We animate translation left by exactly (filterSize + gapBetween) when _slideSearch is true
                                    Expanded(
                                      child: AnimatedContainer(
                                        duration: animDuration,
                                        transform: Matrix4.translationValues(
                                          _slideSearch ? -(filterSize + gapBetween) : 0.0,
                                          0.0,
                                          0.0,
                                        ),
                                        child: _buildSearchBox(
                                          context,
                                          // Add right padding to the inner content so overlay won't cover typed text
                                          rightPadding: _isSearching ? (overlayBtnWidth + 8.0) : 16.0,
                                        ),
                                      ),
                                    ),

                                    // leave empty space here — Cancel/Search is overlayed via Positioned
                                    const SizedBox(width: 0),
                                  ],
                                ),

                                // Overlayed Cancel/Search button aligned to the right of the padded container.
                                Positioned(
                                  right: 0,
                                  child: IgnorePointer(
                                    ignoring: !_isSearching, // don't block taps when hidden
                                    child: AnimatedOpacity(
                                      duration: animDuration,
                                      opacity: _isSearching ? 1.0 : 0.0,
                                      child: AnimatedSlide(
                                        duration: animDuration,
                                        offset: _isSearching ? Offset.zero : const Offset(0.2, 0),
                                        child: Container(
                                          width: overlayBtnWidth,
                                          // align center vertically
                                          height: 50,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (_controller.text.isEmpty) {
                                                _focusNode.unfocus();
                                                _controller.clear();
                                                // on unfocus, _onFocusLost will run and hide overlay
                                              } else {
                                                final query = _controller.text.trim();
                                                debugPrint("Searching for: $query");
                                                _focusNode.unfocus();
                                              }
                                            },
                                            child: Text(
                                              _controller.text.isEmpty ? 'Cancel' : 'Search',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -1,
                                                color: const Color(0xFFEE795C),
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
                          ),


                          // --- Prediction box (floating style)
                          if (_isSearching && _controller.text.trim().isNotEmpty && _activeFilter == FilterType.recipe)
                            Align(
                              alignment: Alignment.topLeft,
                              child: RecipePredictionBox(
                                items: _predictions,
                                query: _controller.text.trim(),
                                width: MediaQuery.of(context).size.width - 30, // matches 15 padding each side
                               
                                topOffset: 0,
                                onTap: (p) {
                                  // When a prediction is tapped:
                                  if (p.itemType == 'recipe' && p.refId != null) {
                                    // fill the search box with the recipe name and perform search (or navigate)
                                    _controller.text = p.displayText;
                                    _focusNode.unfocus();
                                    // TODO: call your search results navigation or selection logic here
                                    debugPrint('Selected recipe: ${p.displayText} id=${p.refId}');
                                  } else if (p.itemType == 'category') {
                                    // user tapped a category suggestion
                                    _controller.text = p.displayText;
                                    _focusNode.unfocus();
                                    // TODO: handle category triggered search (filter by cuisine/diet/protein)
                                    debugPrint('Selected category: ${p.displayText} type=${p.categoryType}');
                                  }
                                },
                              ),
                            ),

                          // Dropdown floating box (positioned below filter). We'll render in column so it flows.
                          // Show it with Align left near filter box.
                          if (_dropdownVisible)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Material(
                                  elevation: 6,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildFilterPill(FilterType.recipe, 'Recipe'),
                                        const SizedBox(width: 8),
                                        _buildFilterPill(FilterType.ingredient, 'Ingredient'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // filler content so page can scroll (you can replace with your content)
                  SliverToBoxAdapter(
                    child: SizedBox(height: 650), // placeholder body space
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  // ---------------- Filter Box ----------------
  Widget _buildFilterBox(double screenW) {
    // Compute target size so it's roughly 20% of width but also 1:1 square
    final containerWidth = (screenW - 32) * 0.15; // 16px horizontal padding both sides
    final size = containerWidth.clamp(56.0, 92.0); // keep within reasonable bounds

    return AnimatedOpacity(
      duration: animDuration,
      opacity: _isSearching ? 0.0 : 1.0, // fade out when search focused (kept for safety)
      child: GestureDetector(
        onTap: () {
          // toggle dropdown
          setState(() {
            _dropdownVisible = !_dropdownVisible;
            // if dropdown opens, unfocus search
            if (_dropdownVisible) {
              _focusNode.unfocus();
            }
          });
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20), // 20% opacity shadow
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // filter icon centered
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Image.asset(
                    'assets/icon_images/filter.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // top-right small circle (indicator)
              Positioned(
                top: 3,
                right: 5,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    // CHANGED: use coral when inactive; blue when active
                    color: _activeFilter == FilterType.none ? filterInactiveEllipse : filterActiveEllipse,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Filter Pills in dropdown ----------------
  Widget _buildFilterPill(FilterType type, String label) {
    final isActive = _activeFilter == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = type;
          _dropdownVisible = false;
          // When selecting a filter, enable search
          // If you want ingredients to behave specially later, handle here.
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFFEE795C).withOpacity(0.30) 
              : const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(10),

          // NEW: border for BOTH active and inactive states
          border: Border.all(
            color: isActive 
                ? const Color(0xFFDD6A4D)                       // active border color
                : Colors.black.withOpacity(0.60),               // inactive border color
            width: isActive ? 2.0 : 1.5,                        // adjust width here
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? pillActiveText : const Color(0xFF6E6E6E),
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  // ---------------- Search Box ----------------
  // added optional rightPadding so overlay won't cover typed text
  Widget _buildSearchBox(BuildContext context, {double rightPadding = 16.0}) {
  final placeholder = _activeFilter == FilterType.none
      ? 'Select a filter type first to begin'
      : (_activeFilter == FilterType.ingredient
          ? 'Enter Ingredients'
          : 'Search for Recipes');

  final enabled = _activeFilter != FilterType.none;

    return AnimatedContainer(
      duration: animDuration,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20), // 20% opacity shadow
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon + text field area
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  // search icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: _isSearching ? 0 : 18,   // icon collapses
                    margin: EdgeInsets.only(right: _isSearching ? 0 : 10),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isSearching ? 0.0 : 1.0,
                      child: Image.asset(
                        'assets/icon_images/search_inactive.png',
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                        color: enabled ? null : Colors.grey.withOpacity(0.6),
                      ),
                    ),
                  ),

                  // TextField
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!enabled) return; // ignore taps if disabled
                        // Request focus (this will trigger the focus listener that coordinates the animations)
                        _focusNode.requestFocus();
                        setState(() {
                          _dropdownVisible = false;
                        });
                      },
                      child: AbsorbPointer(
                        absorbing: false, // allow typing
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          enabled: enabled,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            color: enabled ? const Color(0xFF333333) : Colors.grey,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: placeholder,
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: enabled ? Colors.grey.shade500 : Colors.grey.shade400,
                              letterSpacing: -0.2,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {}); // keeps your UI toggles working

                            // debounce fetch predictions
                            _debounce?.cancel();
                            _debounce = Timer(const Duration(milliseconds: 300), () async {
                              if (value.trim().isEmpty || _activeFilter == FilterType.none) {
                                setState(() {
                                  _predictions = [];
                                  _isFetchingPrediction = false;
                                });
                                return;
                              }

                              setState(() => _isFetchingPrediction = true);

                              final results = await _searchService.fetchPredictions(value.trim());
                              setState(() {
                                _predictions = results;
                                _isFetchingPrediction = false;
                              });
                            });
                          },
                          onSubmitted: (v) {
                            // For now we simply unfocus; actual search logic goes here
                            _focusNode.unfocus();
                          },
                        ),
                      ),
                    ),
                  ),

                  // show a small spinner while fetching predictions so the field is read
                  if (_isFetchingPrediction)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(Color(0xFFEE795C)),
                        ),
                      ),
                    ),
                  ),
                
                ],
              ),
            ),
          ),

          // NOTE: Cancel/Search has been moved outside the search box (see parent Row)
          // This widget no longer contains the Cancel button.
        ],
      ),
    );
  }
}
