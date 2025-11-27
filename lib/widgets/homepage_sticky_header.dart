import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:platoporma/helpers/category_pill.dart';

class HomepageStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Function(String) onCategoryTap;
  final String? selectedCategory;

  HomepageStickyHeaderDelegate({
    required this.onCategoryTap,
    required this.selectedCategory,
  });

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
                    color: Color(0xff27453E),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 8),

                // <--------- Horizontal Pills Carousel ------>
                SizedBox(
                  height: 35,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        CategoryPill(
                          label: "Budget-Friendly",
                          isActive: selectedCategory == "Budget-Friendly",
                          onTap: () => onCategoryTap("Budget-Friendly"),
                        ),
                        CategoryPill(
                          label: "Healthy",
                          isActive: selectedCategory == "Healthy",
                          onTap: () => onCategoryTap("Healthy"),
                        ),
                        CategoryPill(
                          label: "Quick & Easy",
                          isActive: selectedCategory == "Quick & Easy",
                          onTap: () => onCategoryTap("Quick & Easy"),
                        ),
                        CategoryPill(
                          label: "Creative Twists",
                          isActive: selectedCategory == "Creative Twists",
                          onTap: () => onCategoryTap("Creative Twists"),
                        ),
                        CategoryPill(
                          label: "International",
                          isActive: selectedCategory == "International",
                          onTap: () => onCategoryTap("International"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 130;

  @override
  double get minExtent => 130;

  @override
  bool shouldRebuild(_) => true;
}