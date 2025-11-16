import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePageSection extends StatefulWidget {
  const HomePageSection({super.key});

  @override
  State<HomePageSection> createState() => _HomePageSectionState();
}

class _HomePageSectionState extends State<HomePageSection> {
  String? firstName;

  @override
  void initState() {
    super.initState();
    _fetchFirstName();
  }

  Future<void> _fetchFirstName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('first_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          firstName = response['first_name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),

            // ------------------ Appbar ------------------
      body: CustomScrollView(
        slivers: [

          // ------------------ Appbar ------------------
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            backgroundColor: const Color(0xFFCCEDD8),
            elevation: 0,
            expandedHeight: 150,

            // Rounded bottom corners
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                bottom: false,

                //Custom appbar
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFCCEDD8),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),

                  //Appbar contents
                  child: Builder(
                    builder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenWidth * 0.05,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo
                            Image.asset(
                              'assets/images/platoporma_logo_whitebg2.png',
                              width: 85,
                            ),

                            SizedBox(width: screenWidth * 0.03),

                            //Text Column
                            ///THIS PART MAKES THE TEXT WRAP DOWN INSTEAD OF OVERFLOW(right)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Welcome,",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF27453E),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 30,
                                      letterSpacing: -0.5,
                                      height: 0.8,
                                    ),
                                  ),

                                  Text(
                                    "${firstName ?? ""}!",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF27453E),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 27,
                                      letterSpacing: -1,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),

                                  Text(
                                    "Let’s find something delicious and comforting today.",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF27453E),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -1,
                                    ),
                                    softWrap: true,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Sticky header (BLUE TEST BAR)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(),
          ),

          // ------------------ BODY ------------------
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    height: 120,
                    color: Colors.green[200],
                    child: Center(
                      child: Text(
                        "Test card #$index",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
              childCount: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      width: double.infinity,
      height: 50,
      color: Colors.blue, // test rectangle
      child: const Center(
        child: Text(
          "Sticky Blue Bar",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}