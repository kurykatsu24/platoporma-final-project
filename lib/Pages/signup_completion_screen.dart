import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),

              // Logo
              Image.asset(
                'assets/images/platoporma_logo_whitebg1.png',
                width: 162,
                height: 162,
              ),
              const SizedBox(height: 15),

              // Reused Title Container from onboarding
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCEDD8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/fork_icon.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 2),
                    Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 6),
                          child: Text(
                            'Welcome to',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF27453E),
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -4),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Plato',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF27453E),
                                    letterSpacing: -2,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Porma',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
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
                    const SizedBox(width: 2),
                    Image.asset(
                      'assets/images/spoon_icon.png',
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Animated area
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // BOXES (slide out left)
                    FadeTransition(
                      opacity: _boxesFade,
                      child: SlideTransition(
                        position: _boxesSlideAnimation,
                        child: _buildFeatureBoxes(),
                      ),
                    ),

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
              ),

              const SizedBox(height: 90),

              // Button
              ElevatedButton(
                onPressed: _showCompletionText ? null : _onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE795C),
                  fixedSize: const Size(300, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  _showCompletionText ? 'Proceed to Homepage' : 'Next',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
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
              width: 340,
              height: 90,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFCCEDD8), width: 4),
              ),
              child: Stack(
                clipBehavior:
                    Clip.none, // allow icon to overflow outside the box
                children: [
                  Positioned(
                    top: -10,
                    left: 15,
                    child: Image.asset(feature['icon']!, width: 40, height: 40),
                  ),
                  Positioned(
                    left: 70,
                    right: 15,
                    child: Text(
                      feature['text']!,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF27453E),
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
            fontSize: 45,
            fontWeight: FontWeight.bold,
            letterSpacing: -2,
            color: const Color(0xFF27453E),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Proceed to homepage, and let’s prepare meal\nrecipes tailored to your liking!",
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 19,
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
