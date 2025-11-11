import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  final Color activeColor = const Color(0xFFEE795C);
  final Color bgColor = const Color(0xFFFDFFEC);

  final List<Map<String, String>> items = [
    {
      'label': 'Home',
      'icon_active': 'assets/icon_images/home_active.png',
      'icon_inactive': 'assets/icon_images/home_inactive.png'
    },
    {
      'label': 'Search',
      'icon_active': 'assets/icon_images/search_active.png',
      'icon_inactive': 'assets/icon_images/search_inactive.png'
    },
    {
      'label': 'Saved',
      'icon_active': 'assets/icon_images/saved_active.png',
      'icon_inactive': 'assets/icon_images/saved_inactive.png'
    },
    {
      'label': 'Profile',
      'icon_active': 'assets/icon_images/user_active.png',
      'icon_inactive': 'assets/icon_images/user_inactive.png'
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache images safely here
    for (var item in items) {
      precacheImage(AssetImage(item['icon_active']!), context);
      precacheImage(AssetImage(item['icon_inactive']!), context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, -4), // shadow above
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final bool isActive = widget.currentIndex == index;
            final item = items[index];

            return GestureDetector(
              onTap: () => widget.onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 18 : 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    //widget para kaswitch between active and inactive icons with an animation and also wrap it in color filter (white)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ColorFiltered(
                        key: ValueKey<bool>(isActive),
                        colorFilter: isActive
                            ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                            : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                        child: Image.asset(
                          isActive ? item['icon_active']! : item['icon_inactive']!,
                          width: isActive ? 26 : 24,
                          height: isActive ? 26 : 24,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: isActive ? 70 : 0, // reserve width for label
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: isActive ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            item['label']!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}