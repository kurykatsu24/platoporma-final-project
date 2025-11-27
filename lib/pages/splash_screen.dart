import 'package:flutter/material.dart';
import 'package:platoporma/pages/mainpage_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:platoporma/pages/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Color bgColor = Color.fromARGB(255, 255, 255, 255);
  late AnimationController dropController;
  late AnimationController growController;
  late AnimationController textController;
  late AnimationController gradientController; // new for gradient animation

  late Animation<double> dropAnimation;
  late Animation<double> growAnimation;
  late Animation<double> textOpacity;
  late Animation<double> gradientProgress; // controls gradient transition

  @override
  void initState() {
    super.initState();

    // 1 Drop Animation
    dropController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1400));
    dropAnimation = CurvedAnimation(
        parent: dropController, curve: Curves.bounceOut); // slight bounce

    // 2 Grow Animation
    growController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    growAnimation = CurvedAnimation(
        parent: growController, curve: Curves.elasticOut); // spring effect

    // 3 Text Fade-in
    textController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    textOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: textController, curve: Curves.easeIn));

    // 4 Gradient Animation
    gradientController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1500));
    gradientProgress = CurvedAnimation(
        parent: gradientController, curve: Curves.easeInOut);

    // Start sequence after a 1-second initial delay
    Future.delayed(Duration(seconds: 5), () async {
      // Change background to white
      setState(() => bgColor = Colors.white);
      await dropController.forward(); // drop logo
      await growController.forward(); // grow logo
      await textController.forward(); // fade-in text

      // wait 1 second, then start gradient animation
      await Future.delayed(Duration(milliseconds: 700));
      await gradientController.forward();

      //After all animations are done, check auth state and navigate accordingly
      await Future.delayed(const Duration(milliseconds: 200)); // optional pause
      if (mounted) {
        final supabase = Supabase.instance.client;
        
        //Wait for Supabase to restore session
        await Future.delayed(const Duration(milliseconds: 500));
        final user = supabase.auth.currentUser;

        Widget nextScreen;

        if (user != null) {
          nextScreen = const MainPageSection();
        } else {
          nextScreen = const OnboardingScreen();
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    dropController.dispose();
    growController.dispose();
    textController.dispose();
    gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [dropController, growController, textController, gradientController]),
          builder: (context, child) {
            double dropY = dropAnimation.value * 565 - 500; // adjust starting top
            double size = 100 + (growAnimation.value * 80); // 100 -> 200

            // Gradient that transitions in
            final gradient = LinearGradient(
              colors: [
                Color.lerp(Color(0xFFEF5F3B),
                        Color(0xFFF06644), gradientProgress.value)!,
                Color.lerp(Color(0xffF06644), Color(0XFFA0EFBF),
                        gradientProgress.value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, dropY),
                  child: Image.asset(
                    'assets/images/platoporma_logo.png',
                    width: size,
                    height: size,
                  ),
                ),
                SizedBox(height: 85),
                FadeTransition(
                  opacity: textOpacity,
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Plato',
                            style: TextStyle(
                              fontFamily: 'NiceHoney',
                              fontSize: 45,
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // color overridden by ShaderMask
                              letterSpacing: 1,
                            ),
                          ),
                          TextSpan(
                            text: 'Porma',
                            style: TextStyle(
                              fontFamily: 'NiceHoney',
                              fontSize: 45,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
