//this page ties all the main pages together (homepage screen, search section, saved recipes section and user profile section) with a bottom navbar

import 'package:flutter/material.dart';
import '../Widgets/animated_navbar.dart';
import '../Pages/homepage_section.dart';
import '../Pages/search_section.dart';
import '../Pages/saved_section.dart';
import '../Pages/profile_section.dart';

class MainPageSection extends StatefulWidget {
  const MainPageSection({super.key});

  @override
  State<MainPageSection> createState() => _MainPageSectionState();
}

class _MainPageSectionState extends State<MainPageSection> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    SearchSection(),
    HomePageSection(),
    SavedSection(),
    ProfileSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      body: _screens[_selectedIndex],
      bottomNavigationBar: AnimatedNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
