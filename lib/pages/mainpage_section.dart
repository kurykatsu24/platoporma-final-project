//this page ties all the main pages together (homepage screen, search section, saved recipes section and user profile section) with a bottom navbar
import 'package:flutter/material.dart';
import '../widgets/animated_navbar.dart';
import 'package:platoporma/pages/homepage_section.dart';
import 'package:platoporma/pages/search_section.dart';
import 'package:platoporma/pages/saved_section.dart';
import 'package:platoporma/pages/profile_section.dart';

class MainPageSection extends StatefulWidget {
  const MainPageSection({super.key});

  @override
  State<MainPageSection> createState() => _MainPageSectionState();
}

class _MainPageSectionState extends State<MainPageSection> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomePageSection(),
    SearchSection(),
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
