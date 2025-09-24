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
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.video_library,
      'title': 'كورسات مجانية ومدفوعة',
      'description': 'مجموعة متنوعة من الكورسات لجميع المستويات والميزانيات',
      'color': const Color(0xFF3B82F6),
    },
    {
      'icon': Icons.verified,
      'title': 'شهادات معتمدة',
      'description': 'احصل على شهادات رسمية معترف بها في السوق المهني',
      'color': const Color(0xFF10B981),
    },
    {
      'icon': Icons.update,
      'title': 'محتوى متجدد باستمرار',
      'description': 'كورسات جديدة ومحدثة باستمرار لمواكبة التطورات العالمية',
      'color': const Color(0xFFF59E0B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
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

    _animationController.forward();

    // Auto-scroll carousel
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  double _getResponsiveFontSize(BuildContext context, {double base = 16}) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return base * 1.2;
    if (width > 400) return base;
    return base * 0.9;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF3B82F6)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildFloatingElements(),
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildLogoAndTitle(),

                    _buildFeaturesSection(),
                    _buildCallToAction(),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
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
            Positioned(
              top: 50 + _floatingAnimation.value,
              right: 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              top: 120 - _floatingAnimation.value,
              left: 40,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_outline,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoAndTitle() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'مرحبًا بك في Courses App',
                    style: GoogleFonts.tajawal(
                      fontSize: _getResponsiveFontSize(context, base: 18),
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'ابدأ رحلتك التعليمية الآن',
                    style: GoogleFonts.tajawal(
                      fontSize: _getResponsiveFontSize(context, base: 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تعلم البرمجة، التصميم، اللغات، والعديد من المجالات الأخرى مع أفضل الخبراء',
                    style: GoogleFonts.tajawal(
                      fontSize: _getResponsiveFontSize(context, base: 16),
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'مزايا التطبيق',
            style: GoogleFonts.tajawal(
              fontSize: _getResponsiveFontSize(context, base: 24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ..._features.map(
            (feature) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: feature['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(feature['icon'], color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'],
                          style: GoogleFonts.tajawal(
                            fontSize: _getResponsiveFontSize(context, base: 16),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['description'],
                          style: GoogleFonts.tajawal(
                            fontSize: _getResponsiveFontSize(context, base: 14),
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: Text(
                'ابدأ الآن',
                style: GoogleFonts.tajawal(
                  fontSize: _getResponsiveFontSize(context, base: 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WidgetTree()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'تصفح كضيف',
                style: GoogleFonts.tajawal(
                  fontSize: _getResponsiveFontSize(context, base: 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'بإنشائك حسابًا، فإنك توافق على شروط الاستخدام وسياسة الخصوصية الخاصة بنا.',
            style: GoogleFonts.tajawal(
              fontSize: _getResponsiveFontSize(context, base: 12),
              fontWeight: FontWeight.w400,
              color: Colors.white60,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Show terms dialog
                  _showDialog('الشروط والأحكام', 'نص الشروط والأحكام...');
                },
                child: Text(
                  'الشروط والأحكام',
                  style: GoogleFonts.tajawal(
                    fontSize: _getResponsiveFontSize(context, base: 12),
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(' • ', style: TextStyle(color: Colors.white60)),
              TextButton(
                onPressed: () {
                  // Show privacy policy dialog
                  _showDialog('سياسة الخصوصية', 'نص سياسة الخصوصية...');
                },
                child: Text(
                  'سياسة الخصوصية',
                  style: GoogleFonts.tajawal(
                    fontSize: _getResponsiveFontSize(context, base: 12),
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(content, style: GoogleFonts.tajawal()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
