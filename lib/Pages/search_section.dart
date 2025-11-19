// lib/Sections/search_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

enum FilterType { none, recipe, ingredient }

class _SearchSectionState extends State<SearchSection> with SingleTickerProviderStateMixin {
  // State
  FilterType _activeFilter = FilterType.recipe; // initialized to recipe per your request
  bool _dropdownVisible = false;
  bool _isSearching = false; // true when search field is focused/tapped
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Animation controller for subtle animations (optional)
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _focusNode.addListener(() {
      setState(() {
        _isSearching = _focusNode.hasFocus;
      });
      // when focus is gained show/animate
      if (_focusNode.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Colors from spec
  static const Color bgColor = Color(0xFFFDFFEC);
  static const Color appbarColor = Color(0xFFCCEDD8);
  static const Color primaryText = Color(0xFF27453E);
  static const Color filterInactiveEllipse = Color(0xFFEE795C);
  static const Color filterActiveEllipse = Color(0xFF659EF4);
  static const Color pillActiveText = Color(0xFFDD6A4D);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ---------- Watermark centered ----------
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.15, // ~15%
              child: Image.asset(
                'assets/images/platoporma_logo.png',
                width: screenW * 0.7, // 70% of screen width
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ---------- Content (AppBar + Search Row) ----------
          CustomScrollView(
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
                            // Left icon (fork)
                            Image.asset(
                              'assets/images/fork_icon.png',
                              width: (screenW * 0.08).clamp(24.0, 48.0), // responsive size
                              height: (screenW * 0.08).clamp(24.0, 48.0),
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(width: 10),

                            // Centered two-line text
                            Expanded(
                              child: Text(
                                'What are we\ncooking today?',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: primaryText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 30, // slightly bigger than Welcome
                                  height: 0.95,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Right icon (spoon)
                            Image.asset(
                              'assets/images/spoon_icon.png',
                              width: (screenW * 0.08).clamp(24.0, 48.0),
                              height: (screenW * 0.08).clamp(24.0, 48.0),
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
                child: const SizedBox(height: 18),
              ),

              // ---------- Search Row (Filter + Search) as pinned header-ish
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Row container with shadow (height 73)
                      SizedBox(
                        height: 73,
                        child: Row(
                          children: [
                            // Filter box - 20% width, but maintain 1:1 ratio (square)
                            _buildFilterBox(screenW),

                            const SizedBox(width: 12),

                            // Search box - remaining width (80%)
                            Expanded(
                              child: _buildSearchBox(context),
                            ),
                          ],
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
        ],
      ),
    );
  }

  // ---------------- Filter Box ----------------
  Widget _buildFilterBox(double screenW) {
    // Compute target size so it's roughly 20% of width but also 1:1 square
    final containerWidth = (screenW - 32) * 0.2; // 16px horizontal padding both sides
    final size = containerWidth.clamp(56.0, 92.0); // keep within reasonable bounds

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: _isSearching ? 0.0 : 1.0, // fade out when search focused
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
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(
                    'assets/icon_images/filter.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // top-right small circle (indicator)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEE795C).withOpacity(0.30) : const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(18),
          border: isActive ? Border.all(color: const Color(0xFFDD6A4D)) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? pillActiveText : const Color(0xFF6E6E6E),
          ),
        ),
      ),
    );
  }

  // ---------------- Search Box ----------------
  Widget _buildSearchBox(BuildContext context) {
    final placeholder = _activeFilter == FilterType.ingredient ? 'Enter Ingredients' : 'Search for Recipes';
    final enabled = _activeFilter != FilterType.none;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 73,
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
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  // search icon
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Image.asset(
                      'assets/icon_images/search_inactive.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      color: enabled ? null : Colors.grey.withOpacity(0.6),
                    ),
                  ),

                  // TextField
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!enabled) return; // ignore taps if disabled
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
                            fontSize: 18,
                            color: enabled ? const Color(0xFF333333) : Colors.grey,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: placeholder,
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 18,
                              color: enabled ? Colors.grey.shade500 : Colors.grey.shade400,
                            ),
                          ),
                          onChanged: (v) {
                            setState(() {
                              // this toggles Cancel -> Search text
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
                ],
              ),
            ),
          ),

          // Cancel or Search text on the right; visible when searching (focused)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _isSearching ? 1.0 : 0.0,
            child: GestureDetector(
              onTap: () {
                if (_controller.text.isEmpty) {
                  // ---- Cancel behavior ----
                  _focusNode.unfocus();
                  _controller.clear();
                  setState(() {
                    _isSearching = false; // hide cancel/search
                  });
                } else {
                  // ---- Search behavior ----
                  final query = _controller.text.trim();
                  debugPrint("Searching for: $query"); // optional
                  _focusNode.unfocus();
                  
                  // Add search logic later if needed
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  _controller.text.isEmpty ? 'Cancel' : 'Search',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEE795C),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}