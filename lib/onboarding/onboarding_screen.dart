// lib/main_pages/onboarding/onboarding_screen.dart
import 'package:courses_app/core/utils/onboarding_manager.dart';
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/data/notifiers.dart';
import 'package:courses_app/services/profile_service.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:courses_app/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final ProfileService _profileService = ProfileService();

  // Store user selections
  String? _selectedLearningState;
  final List<String> _selectedInterests = [];

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'مرحبًا بك في منصة الكورسات',
      'subtitle': 'منصة تعليمية متكاملة تقدم أفضل المحتوى التعليمي',
      'image': 'assets/images/logo_ed.png',
      'description':
          'اكتشف آلاف الكورسات والدروس في مختلف المجالات، من أفضل المدربين والمؤسسات التعليمية',
    },
    {
      'title': 'ما هو مستواك التعليمي الحالي؟',
      'subtitle': 'اختر حالتك التعليمية لتقديم محتوى مناسب لك',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'ما هي اهتماماتك؟',
      'subtitle': 'اختر المجالات التي تهمك لتخصيص تجربتك',
      'image': 'assets/images/onboarding3.png',
    },
    {
      'title': 'أنت جاهز للبدء!',
      'subtitle': 'ابدأ رحلتك التعليمية الآن',
      'image': 'assets/images/onboarding4.png',
    },
  ];

  final List<Map<String, dynamic>> _learningStates = [
    {'title': 'طالب مدرسة', 'icon': Icons.school, 'value': 'school_student'},
    {
      'title': 'طالب جامعة',
      'icon': Icons.account_balance,
      'value': 'university_student',
    },
    {'title': 'خريج', 'icon': Icons.workspace_premium, 'value': 'graduated'},
    {'title': 'موظف', 'icon': Icons.work, 'value': 'employed'},
    {'title': 'باحث عن عمل', 'icon': Icons.search, 'value': 'job_seeker'},
    {
      'title': 'مهتم بالتعلم',
      'icon': Icons.self_improvement,
      'value': 'learner',
    },
  ];

  final List<Map<String, dynamic>> _interests = [
    {
      'title': 'برمجة وتطوير',
      'icon': Icons.code,
      'value': 'programming',
      'color': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'title': 'تصميم جرافيك',
      'icon': Icons.brush,
      'value': 'design',
      'color': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'title': 'تسويق رقمي',
      'icon': Icons.trending_up,
      'value': 'marketing',
      'color': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'title': 'لغات',
      'icon': Icons.language,
      'value': 'languages',
      'color': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'title': 'أعمال وإدارة',
      'icon': Icons.business_center,
      'value': 'business',
      'color': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'title': 'علوم وتكنولوجيا',
      'icon': Icons.science,
      'value': 'science',
      'color': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'title': 'فنون وإبداع',
      'icon': Icons.palette,
      'value': 'arts',
      'color': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'title': 'صحة ولياقة',
      'icon': Icons.fitness_center,
      'value': 'health',
      'color': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
  ];

  // Validation methods
  bool get _canContinue {
    switch (_currentPage) {
      case 1: // Learning state page
        return _selectedLearningState != null;
      case 2: // Interests page
        return _selectedInterests.length >= 3; // Require at least 3 interests
      default:
        return true; // Always allow continuing on other pages
    }
  }

  String get _continueButtonText {
    if (_currentPage == 1 && _selectedLearningState == null) {
      return 'اختر حالتك التعليمية للمتابعة';
    } else if (_currentPage == 2 && _selectedInterests.length < 3) {
      return 'اختر 3 اهتمامات على الأقل';
    } else if (_currentPage == _pages.length - 1) {
      return 'ابدأ الآن!';
    } else {
      return 'متابعة';
    }
  }

  void _nextPage() {
    if (!_canContinue) return;

    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Save onboarding preferences to backend (if user is logged in)
    if (_selectedLearningState != null && _selectedInterests.isNotEmpty) {
      try {
        await _profileService.saveOnboarding(
          learningState: _selectedLearningState!,
          interests: _selectedInterests,
        );
      } catch (_) {
        // Ignore errors in onboarding save – user can still continue
      }
    }

    await OnboardingManager.completeOnboarding();

    // Navigate to main app (home with bottom navigation)
    // Reset to home page
    selectedPageNotifier.value = 0;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WidgetTree()),
      (route) => false,
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Progress indicator - Fixed consistent positioning
                Container(
                  height: 80, // Fixed height to ensure consistent positioning
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Empty space where skip button used to be
                      const SizedBox(width: 80),

                      // Progress dots - Updated to purple gradient
                      Row(
                        children: List.generate(_pages.length, (index) {
                          final isActive = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isActive
                                  ? null
                                  : (isDarkMode
                                        ? Colors.white30
                                        : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),

                      // Back button - Updated to purple gradient text
                      if (_currentPage > 0)
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: _previousPage,
                            child: Text(
                              'رجوع',
                              style: GoogleFonts.tajawal(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _pages.length,
                    // Disable swipe when validation fails
                    physics:
                        _canContinue ||
                            _currentPage == 0 ||
                            _currentPage == _pages.length - 1
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildPageContent(index, isDarkMode, theme);
                    },
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Instruction message (shown initially instead of error)
                      if (!_canContinue &&
                          _currentPage != 0 &&
                          _currentPage != _pages.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _currentPage == 1
                                ? 'اختر حالتك التعليمية للمتابعة'
                                : 'اختر 3 اهتمامات على الأقل للمتابعة',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Continue button - Updated to purple gradient
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _canContinue
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF667EEA),
                                      Color(0xFF764BA2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: !_canContinue
                                ? const Color(0xFF9CA3AF)
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _canContinue
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF667EEA,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ElevatedButton(
                            onPressed: _canContinue ? _nextPage : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _continueButtonText,
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(int index, bool isDarkMode, ThemeData theme) {
    final page = _pages[index];

    switch (index) {
      case 0:
        return _buildWelcomePage(page, isDarkMode, theme);
      case 1:
        return _buildLearningStatePage(page, isDarkMode, theme);
      case 2:
        return _buildInterestsPage(page, isDarkMode, theme);
      case 3:
        return _buildReadyPage(page, isDarkMode, theme);
      default:
        return _buildWelcomePage(page, isDarkMode, theme);
    }
  }

  Widget _buildWelcomePage(
    Map<String, dynamic> page,
    bool isDarkMode,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Changed from MainAxisAlignment.center to regular Column
          const SizedBox(height: 20), // Added spacing to push content down
          // Logo image with purple gradient border
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8), // Border width
            child: ClipRRect(
              borderRadius: BorderRadius.circular(92), // 100 - 8
              child: Container(
                color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                child: Image.asset(
                  page['image'],
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          Text(
            page['title'],
            style: GoogleFonts.tajawal(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Text(
            page['subtitle'],
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Text(
            page['description'],
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? Colors.white60 : const Color(0xFF9CA3AF),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStatePage(
    Map<String, dynamic> page,
    bool isDarkMode,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Text(
            page['title'],
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            page['subtitle'],
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Learning state options - Updated selection to purple gradient
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _learningStates.length,
                itemBuilder: (context, index) {
                  final state = _learningStates[index];
                  final isSelected = _selectedLearningState == state['value'];

                  return Material(
                    elevation: isSelected ? 6 : 2,
                    borderRadius: BorderRadius.circular(16),
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    shadowColor: Colors.black.withOpacity(
                      isDarkMode ? 0.3 : 0.1,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLearningState = state['value'] as String;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF667EEA),
                                  width: 2,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF667EEA),
                                          Color(0xFF764BA2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : (isDarkMode
                                          ? Colors.white12
                                          : Colors.grey[100]),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state['icon'] as IconData,
                                color: isSelected
                                    ? Colors.white
                                    : (isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF6B7280)),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state['title'],
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsPage(
    Map<String, dynamic> page,
    bool isDarkMode,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Text(
            page['title'],
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            page['subtitle'],
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'اختر 3 مجالات على الأقل (${_selectedInterests.length}/3)',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _selectedInterests.length >= 3
                  ? const Color(0xFF10B981)
                  : (isDarkMode ? Colors.white60 : const Color(0xFF9CA3AF)),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Interests grid - All use purple gradient now
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(
                    interest['value'],
                  );

                  return Material(
                    elevation: isSelected ? 6 : 2,
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: Colors.black.withOpacity(
                      isDarkMode ? 0.4 : 0.2,
                    ),
                    child: InkWell(
                      onTap: () => _toggleInterest(interest['value'] as String),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected
                              ? null
                              : (isDarkMode
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: isDarkMode
                                      ? Colors.white24
                                      : Colors.grey[200]!,
                                ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : (isDarkMode
                                          ? Colors.white12
                                          : Colors.grey[100]),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                interest['icon'] as IconData,
                                color: isSelected
                                    ? Colors.white
                                    : (isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF6B7280)),
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              interest['title'],
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF1F2937)),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReadyPage(
    Map<String, dynamic> page,
    bool isDarkMode,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Changed from MainAxisAlignment.center to regular Column
          const SizedBox(height: 20), // Added spacing to push content down
          // Celebration icon with purple gradient
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.celebration, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 40),

          Text(
            page['title'],
            style: GoogleFonts.tajawal(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Text(
            page['subtitle'],
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Features list
          _buildFeatureItem(
            'آلاف الكورسات المجانية والمدفوعة',
            Icons.video_library,
            isDarkMode,
          ),
          _buildFeatureItem('تعلم من أفضل المدربين', Icons.people, isDarkMode),
          _buildFeatureItem('شهادات معتمدة', Icons.verified, isDarkMode),
          _buildFeatureItem(
            'تعلم في أي وقت ومن أي مكان',
            Icons.schedule,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
