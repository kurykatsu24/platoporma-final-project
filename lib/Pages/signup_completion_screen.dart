import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platoporma/Pages/mainpage_section.dart';

class SignUpCompletionScreen extends StatefulWidget {
  const SignUpCompletionScreen({super.key});

  @override
  State<SignUpCompletionScreen> createState() => _SignUpCompletionScreenState();
}

class _SignUpCompletionScreenState extends State<SignUpCompletionScreen>
    with TickerProviderStateMixin {
  bool _showCompletionText = false;

  late AnimationController _slideController;
  late Animation<Offset> _boxesSlideAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _boxesFade;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _boxesSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.5, 0)).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _boxesFade = Tween<double>(begin: 1.0, end: 0.0).animate(_slideController);
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(_slideController);
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    setState(() {
      _showCompletionText = true;
    });
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFFEC),
      resizeToAvoidBottomInset: true, // 👈 prevent overflow when keyboard opens
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),

                // Logo
                Image.asset(
                  'assets/images/platoporma_logo_whitebg1.png',
                  width: MediaQuery.of(context).size.width * 0.38
                ),
                const SizedBox(height: 5),

                // Reused Title Container from onboarding
                Transform.translate(
                      offset: const Offset(0, 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCEDD8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.translate(
                                offset: const Offset(13, 0),
                                child: Image.asset(
                                  'assets/images/fork_icon.png',
                                  width: 65,
                                  height: 65,
                                ),
                              ),
                              Column(
                                children: [
                                  Transform.translate(
                                    offset: const Offset(0, 12),
                                    child: Text(
                                      'Welcome to',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF27453E),
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, -5),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Plato',
                                            style: GoogleFonts.poppins(
                                              fontSize: 38,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF27453E),
                                              letterSpacing: -2,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Porma',
                                            style: GoogleFonts.poppins(
                                              fontSize: 38,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF27453E),
                                              letterSpacing: -2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Transform.translate(
                                offset: const Offset(-13, 0),
                                child: Image.asset(
                                  'assets/images/spoon_icon.png',
                                  width: 65,
                                  height: 65,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                const SizedBox(height: 40),

                // -------------- Animated area ----------------
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    //Boxes (slide out left)
                    FadeTransition(
                      opacity: _boxesFade,
                      child: SlideTransition(
                        position: _boxesSlideAnimation,
                        child: _buildFeatureBoxes(),
                      ),
                    ),

                    // ELLIPSE BACKGROUNDS (appear only on completion) ---
                    if (_showCompletionText) ...[
                      // Top-right ellipse
                      Positioned(
                        top: -450, // move freely up/down
                        right: -100, // move freely left/right
                        child: Opacity(
                          opacity: 0.65, //control transparency (0 = invisible, 1 = solid)
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(1.7) // scale size
                              ..rotateZ(-0.4), // rotate (in radians)
                            child: Image.asset(
                              'assets/images/ellipse_overlay.png',
                              width: 250,
                              height: 250,
                            ),
                          ),
                        ),
                      ),

                      // Bottom-left ellipse
                      Positioned(
                        bottom: -120,
                        left: -50,
                        child: Opacity(
                          opacity: 0.80,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(2.5)
                              ..rotateZ(2.5),
                            child: Image.asset(
                              'assets/images/ellipse_overlay.png',
                              width: 230,
                              height: 230,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // COMPLETION TEXT (slide in from right)
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: _showCompletionText
                            ? _buildCompletionText()
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Button
                ElevatedButton(
                  onPressed: () {
                    if (_showCompletionText) {
                      // Navigate to homepage when on final state
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder: (context, animation, secondaryAnimation) => const MainPageSection(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // slide in from right to left
                            const end = Offset.zero;
                            final curve = Curves.easeInOut;

                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    } else {
                      // Triggers the transition to final completion text
                      _onNextPressed();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE795C),
                    overlayColor: const Color.fromARGB(255, 218, 101, 71)
                        .withOpacity(0.15), // 👈 soft touch-down color
                    fixedSize: const Size(300, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _showCompletionText ? 'Proceed to Homepage' : 'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 14 * MediaQuery.of(context).textScaleFactor,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
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

  // --- FEATURE BOXES ---
  Widget _buildFeatureBoxes() {
    final List<Map<String, String>> features = [
      {
        'icon': 'assets/images/local_recipe_icon.png',
        'text':
            'Explore Diverse Recipes, more room to localized and budget-friendly',
      },
      {
        'icon': 'assets/images/ingredient_search_icon.png',
        'text': 'Offers Ingredient-Based Filter Search',
      },
      {
        'icon': 'assets/images/dynamic_recipe_editing.png',
        'text':
            'Dynamic Recipe Editing feature, to reedit ingredients fit to your liking',
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: features
          .map(
            (feature) => Container(
              width: MediaQuery.of(context).size.width * 0.80,
              height: MediaQuery.of(context).size.height * 0.11,
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFCCEDD8), width: 4),
              ),
              child: Stack(
                clipBehavior:
                    Clip.none, // allow icon to overflow outside the box
                children: [
                  Positioned(
                    top: -20,
                    left: -24,
                    child: Image.asset(feature['icon']!,
                    width: MediaQuery.of(context).size.width * 0.13),
                  ),
                  Positioned.fill(
                    left: 50,
                    right: 15,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      // center vertically, aligned left
                      child: Text(
                        feature['text']!,
                        style: GoogleFonts.dmSans(
                          fontSize: 17 * MediaQuery.of(context).textScaleFactor,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF27453E),
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // --- FINAL TEXT AFTER TRANSITION ---
  Widget _buildCompletionText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "You're all set!",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 50 * MediaQuery.of(context).textScaleFactor,
            fontWeight: FontWeight.bold,
            letterSpacing: -3,
            color: const Color(0xFF27453E),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Proceed to homepage, and let’s prepare meal\nrecipes tailored to your liking!",
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 16 * MediaQuery.of(context).textScaleFactor,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF27453E),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}