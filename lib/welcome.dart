import 'package:courses_app/main_pages/auth/presentation/pages/login_page.dart';
import 'package:courses_app/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.video_library_rounded,
      'title': 'كورسات متنوعة',
      'description': 'مجانية ومدفوعة',
      'color': Color(0xFF667EEA),
    },
    {
      'icon': Icons.verified_rounded,
      'title': 'شهادات معتمدة',
      'description': 'معترف بها مهنيًا',
      'color': Color(0xFF764BA2),
    },
    {
      'icon': Icons.update_rounded,
      'title': 'محتوى متجدد',
      'description': 'محدث باستمرار',
      'color': Color(0xFFF093FB),
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A103C),
              Color(0xFF2D1B69),
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildBackgroundPattern(),
              _buildFloatingElements(),
              _buildContent(isSmallScreen, isVerySmallScreen, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.white.withOpacity(0.03),
              Colors.transparent,
            ],
            stops: const [0.1, 0.8],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Top right element
            Positioned(
              top: 60 + _floatingAnimation.value,
              right: 30,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Top left element
            Positioned(
              top: 100 - _floatingAnimation.value,
              left: 20,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF093FB),
                      Color(0xFFF5576C),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF5576C).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(bool isSmallScreen, bool isVerySmallScreen, double screenWidth) {
    // Calculate sizes based on screen dimensions
    final logoSize = isVerySmallScreen ? 80.0 : (isSmallScreen ? 100.0 : 110.0);
    final titleFontSize = isVerySmallScreen ? 20.0 : (isSmallScreen ? 22.0 : 24.0);
    final subtitleFontSize = isVerySmallScreen ? 12.0 : (isSmallScreen ? 13.0 : 14.0);
    final featuresTitleFontSize = isVerySmallScreen ? 16.0 : (isSmallScreen ? 18.0 : 20.0);
    final buttonHeight = isVerySmallScreen ? 48.0 : (isSmallScreen ? 52.0 : 56.0);
    final buttonFontSize = isVerySmallScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0);
    
    // Calculate feature card size based on available width
    final availableWidth = screenWidth - 48; // 24 padding on each side
    final cardWidth = (availableWidth - 24) / 3; // 12 spacing between cards

    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _glowController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo and Title Section - Flexible to take available space
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF667EEA),
                                Color(0xFF764BA2),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.5 * _glowAnimation.value),
                                blurRadius: 25,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/images/logo_ed.png',
                                  fit: BoxFit.contain,
                                  color: const Color(0xFF667EEA),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'مرحبًا بك في منصة الكورسات',
                          style: GoogleFonts.tajawal(
                            fontSize: isVerySmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ابدأ رحلتك التعليمية الآن',
                          style: GoogleFonts.tajawal(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'تعلم البرمجة، التصميم، اللغات والمزيد',
                          style: GoogleFonts.tajawal(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Features Section - Fixed height
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مميزات المنصة',
                          style: GoogleFonts.tajawal(
                            fontSize: featuresTitleFontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: isVerySmallScreen ? 100 : 110,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _features.map((feature) {
                              return SizedBox(
                                width: cardWidth,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              feature['color'].withOpacity(0.8),
                                              feature['color'].withOpacity(0.4),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          feature['icon'],
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        feature['title'],
                                        style: GoogleFonts.tajawal(
                                          fontSize: isVerySmallScreen ? 10 : 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        feature['description'],
                                        style: GoogleFonts.tajawal(
                                          fontSize: isVerySmallScreen ? 8 : 9,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withOpacity(0.8),
                                          height: 1.3,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Buttons Section - Fixed height
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Start Learning Button - Sapphire & Amethyst Gradient
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4F46E5), // Deep sapphire
                                  Color(0xFF7C3AED), // Royal purple
                                  Color(0xFF8B5CF6), // Light amethyst
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.rocket_launch_rounded,
                                    size: 22,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'ابدأ التعلم الآن',
                                    style: GoogleFonts.tajawal(
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Browse as Guest Button - Emerald & Teal Gradient
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF10B981), // Emerald
                                  Color(0xFF059669), // Dark emerald
                                  Color(0xFF047857), // Deep emerald
                                ],
                                stops: [0.0, 0.6, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF059669).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFF6EE7B7).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => WidgetTree()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.explore_rounded,
                                    size: 22,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'تصفح كضيف',
                                    style: GoogleFonts.tajawal(
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer - Minimal space
                  Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'بإنشائك حسابًا، فإنك توافق على',
                          style: GoogleFonts.tajawal(
                            fontSize: isVerySmallScreen ? 8 : 9,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                _showDialog('الشروط والأحكام', 'نص الشروط والأحكام...');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'الشروط والأحكام',
                                style: GoogleFonts.tajawal(
                                  fontSize: isVerySmallScreen ? 8 : 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.8),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              ' و ',
                              style: GoogleFonts.tajawal(
                                fontSize: isVerySmallScreen ? 8 : 9,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _showDialog('سياسة الخصوصية', 'نص سياسة الخصوصية...');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'سياسة الخصوصية',
                                style: GoogleFonts.tajawal(
                                  fontSize: isVerySmallScreen ? 8 : 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.8),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2D1B69),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF667EEA),
                        Color(0xFF764BA2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إغلاق',
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}