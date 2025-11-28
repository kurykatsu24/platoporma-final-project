import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:platoporma/pages/onboarding_screen.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final supabase = Supabase.instance.client;

  String fullName = "";
  String email = "";
  String savedRecipesCount = "Loading...";
  bool isLoading = true;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //<---Method for Load user data from supabase ---->
  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      final profile = await supabase
          .from("user_profiles")
          .select("first_name, last_name")
          .eq("id", user.id)
          .single();

      final firstName = profile["first_name"] ?? "";
      final lastName = profile["last_name"] ?? "";

      fullName = "$firstName $lastName".trim();
      email = user.email ?? "";

      final saved = await supabase
          .from("saved_recipes")
          .select("id")
          .eq("user_id", user.id);

      if (saved.isEmpty) {
        savedRecipesCount = "None";
      } else {
        savedRecipesCount = saved.length.toString();
      }
    } catch (e) {
      final errorText = e.toString();

      // detect offline state
      final bool offlineError =
          errorText.contains("Failed host lookup") ||
          errorText.contains("SocketException") ||
          errorText.contains("ClientException");

      if (offlineError) {
        setState(() {
          isLoading = false;
          isOffline = true;   // <-- NEW FLAG (add this as a field)
        });
        return;
      }
      
      //normal error fallback
      fullName = "Unknown";
      email = "Unknown";
      savedRecipesCount = "None";
    }

    setState(() {
      isLoading = false;
    });
  }

  //Sign out button logic
  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),

      //<------ Appbar--------->
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFC2EBD2),
            expandedHeight: 135,
            pinned: false,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/fork_icon.png',
                        width: screenW * 0.19,
                        height: screenW * 0.19,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "User Profile",
                        style: TextStyle(
                          fontFamily: 'NiceHoney',
                          color: Color(0xFF27453E),
                          fontSize: 37,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/spoon_icon.png',
                        width: screenW * 0.19,
                        height: screenW * 0.19,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
              child: Column(
                children: [
                  //<--- White container with name, email, and saved recipe count----->
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 22,
                          right: 22,
                          top: 65,
                          bottom: 30,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : isOffline
                                ? _buildOfflineSticker()
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildHeader("Name"),
                                      _buildValue(fullName),

                                      const SizedBox(height: 25),

                                      _buildHeader("Email"),
                                      _buildValue(email),

                                      const SizedBox(height: 25),

                                      _buildHeader("Saved Recipes"),
                                      _buildValue(savedRecipesCount),
                                    ],
                                  ),
                      ),

                      //<----stacked circular Avatar with Initials ----->
                      Positioned(
                        top: -50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: const Offset(0, 2),
                                  blurRadius: 5,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 6, // <-- THICK BORDER
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFF0ABFB6),
                              child: Text(
                                _getInitials(fullName),
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 47,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 38),

                  // logout button UI
                  ElevatedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf06644),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    label: Text(
                      "Logout",
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //UI helpers--->
  Widget _buildHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF27453E),
        letterSpacing: -0.6,
      ),
    );
  }

  Widget _buildValue(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";

    final parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  //<---helper to catch error when supabase is not retriving due to internet issues or no internet ---->
  Widget _buildOfflineSticker() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orangeAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 60, color: Colors.orangeAccent),
            const SizedBox(height: 15),
            Text(
              "You're offline!\nCannot load your profile",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orangeAccent.shade700,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                 isLoading = true;
                 isOffline = false;
                });
                _loadUserData();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text("Retry",
                style: TextStyle(
                color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf06644),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}
