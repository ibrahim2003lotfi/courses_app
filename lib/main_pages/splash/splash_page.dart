import 'package:courses_app/core/utils/onboarding_manager.dart';
import 'package:courses_app/services/auth_service.dart';
import 'package:courses_app/widget_tree.dart';
import 'package:courses_app/welcome.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _navigateToNextScreen();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      // Check if onboarding is completed
      final isOnboardingCompleted =
          await OnboardingManager.isOnboardingCompleted();

      // Check if user is authenticated
      final authService = AuthService();
      final token = await authService.getToken();
      final isAuthenticated = token != null && token.isNotEmpty;

      if (!mounted) return;

      // Determine destination:
      // - Authenticated: WidgetTree (home) - always go home if logged in
      // - Not Authenticated + Not onboarded: WelcomePage (onboarding)
      // - Not Authenticated + Onboarded: WelcomePage (login/register)
      final Widget destination;
      if (isAuthenticated) {
        destination = const WidgetTree();
      } else if (!isOnboardingCompleted) {
        destination = const WelcomePage();
      } else {
        destination = const WelcomePage();
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
        children: [
          _buildBackgroundPattern(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedLogo(isSmallScreen, isVerySmallScreen),
                SizedBox(
                  height: isVerySmallScreen ? 20 : (isSmallScreen ? 30 : 40),
                ),
                _buildAnimatedText(isSmallScreen, isVerySmallScreen),
                SizedBox(
                  height: isVerySmallScreen ? 40 : (isSmallScreen ? 60 : 80),
                ),
                _buildLoadingIndicator(isSmallScreen, isVerySmallScreen),
              ],
            ),
          ),
          _buildVersionNumber(isSmallScreen, isVerySmallScreen),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              const Color(0xFF667EEA).withOpacity(0.03),
              Colors.transparent,
            ],
            stops: const [0.1, 0.8],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(bool isSmallScreen, bool isVerySmallScreen) {
    final logoSize = isVerySmallScreen
        ? 100.0
        : (isSmallScreen ? 130.0 : 160.0);
    final innerPadding = isVerySmallScreen
        ? 15.0
        : (isSmallScreen ? 20.0 : 25.0);
    final iconPadding = isVerySmallScreen
        ? 10.0
        : (isSmallScreen ? 12.0 : 15.0);

    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoFadeAnimation.value,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                    Color(0xFF667EEA),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 15,
                  ),
                  BoxShadow(
                    color: const Color(0xFF764BA2).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(innerPadding),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(iconPadding),
                    child: Image.asset(
                      'assets/images/logo_ed.png',
                      fit: BoxFit.contain,
                      color: const Color(0xFF667EEA),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText(bool isSmallScreen, bool isVerySmallScreen) {
    final titleFontSize = isVerySmallScreen
        ? 24.0
        : (isSmallScreen ? 30.0 : 36.0);
    final subtitleFontSize = isVerySmallScreen
        ? 14.0
        : (isSmallScreen ? 16.0 : 18.0);
    final taglineFontSize = isVerySmallScreen
        ? 11.0
        : (isSmallScreen ? 12.0 : 14.0);

    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value),
          child: Opacity(
            opacity: _textFadeAnimation.value,
            child: Column(
              children: [
                Text(
                  'Courses App',
                  style: GoogleFonts.tajawal(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
                ),
                Text(
                  'رحلتك التعليمية تبدأ هنا',
                  style: GoogleFonts.tajawal(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(
                  height: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8),
                ),
                Text(
                  'منصة التعلم الذكي',
                  style: GoogleFonts.tajawal(
                    fontSize: taglineFontSize,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(bool isSmallScreen, bool isVerySmallScreen) {
    final loadingWidth = isVerySmallScreen
        ? 160.0
        : (isSmallScreen ? 190.0 : 220.0);
    final loadingHeight = isVerySmallScreen ? 4.0 : (isSmallScreen ? 5.0 : 6.0);

    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value,
          child: Container(
            width: loadingWidth,
            height: loadingHeight,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: _loadingAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF667EEA),
                          Color(0xFF764BA2),
                          Color(0xFF667EEA),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: const Color(0xFF764BA2).withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionNumber(bool isSmallScreen, bool isVerySmallScreen) {
    final fontSize = isVerySmallScreen ? 9.0 : (isSmallScreen ? 10.0 : 12.0);
    final bottomPadding = isVerySmallScreen
        ? 20.0
        : (isSmallScreen ? 30.0 : 40.0);

    return Positioned(
      bottom: bottomPadding,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textController,
        builder: (context, child) {
          return Opacity(
            opacity: _textFadeAnimation.value,
            child: Column(
              children: [
                Text(
                  'منصة الكورسات الرائدة',
                  style: GoogleFonts.tajawal(
                    fontSize: fontSize,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isVerySmallScreen ? 2 : 4),
                Text(
                  'الإصدار 1.0.0',
                  style: GoogleFonts.tajawal(
                    fontSize: fontSize - 1,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
