import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> category;

  const CategoryDetailPage({super.key, required this.category});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  // Sample data for different sections
  final List<Map<String, dynamic>> beginnerCourses = [
    {
      'id': '1',
      'title': 'مقدمة في البرمجة - الأساسيات',
      'image': 'https://picsum.photos/seed/beginner1/400/300',
      'teacher': 'أحمد محمد',
      'rating': 4.8,
      'students': 2547,
      'price': '₪99',
      'level': 'مبتدئ',
      'duration': 12,
      'lessons': 25,
    },
    {
      'id': '2',
      'title': 'أساسيات الخوارزميات والهياكل',
      'image': 'https://picsum.photos/seed/beginner2/400/300',
      'teacher': 'فاطمة أحمد',
      'rating': 4.7,
      'students': 1834,
      'price': '₪149',
      'level': 'مبتدئ',
      'duration': 16,
      'lessons': 30,
    },
    {
      'id': '3',
      'title': 'تعلم أول لغة برمجة',
      'image': 'https://picsum.photos/seed/beginner3/400/300',
      'teacher': 'محمد علي',
      'rating': 4.6,
      'students': 3421,
      'price': '₪79',
      'level': 'مبتدئ',
      'duration': 10,
      'lessons': 20,
    },
  ];

  final List<Map<String, dynamic>> featuredCourses = [
    {
      'id': '4',
      'title': 'تطوير تطبيقات الويب الحديثة',
      'image': 'https://picsum.photos/seed/featured1/400/300',
      'teacher': 'سارة محمود',
      'rating': 4.9,
      'students': 5632,
      'price': '₪299',
      'level': 'متقدم',
      'duration': 35,
      'lessons': 60,
      'badge': 'الأكثر مبيعاً',
    },
    {
      'id': '5',
      'title': 'إتقان قواعد البيانات المتقدمة',
      'image': 'https://picsum.photos/seed/featured2/400/300',
      'teacher': 'خالد أحمد',
      'rating': 4.8,
      'students': 4123,
      'price': '₪399',
      'level': 'متقدم',
      'duration': 28,
      'lessons': 45,
      'badge': 'حديث',
    },
    {
      'id': '6',
      'title': 'أمان المعلومات والشبكات',
      'image': 'https://picsum.photos/seed/featured3/400/300',
      'teacher': 'نور الدين',
      'rating': 4.7,
      'students': 2987,
      'price': '₪449',
      'level': 'متقدم',
      'duration': 42,
      'lessons': 70,
      'badge': 'مميز',
    },
  ];

  final List<Map<String, dynamic>> subcategories = [
    {
      'id': 'sub1',
      'name': 'تطوير الويب',
      'icon': Icons.web,
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
      'courseCount': 45,
    },
    {
      'id': 'sub2',
      'name': 'تطوير التطبيقات',
      'icon': Icons.phone_android,
      'gradient': [Color(0xFF2196F3), Color(0xFF21CBF3)],
      'courseCount': 32,
    },
    {
      'id': 'sub3',
      'name': 'قواعد البيانات',
      'icon': Icons.storage,
      'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
      'courseCount': 28,
    },
    {
      'id': 'sub4',
      'name': 'أمان المعلومات',
      'icon': Icons.security,
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
      'courseCount': 19,
    },
    {
      'id': 'sub5',
      'name': 'الذكاء الاصطناعي',
      'icon': Icons.psychology,
      'gradient': [Color(0xFF9C27B0), Color(0xFFE91E63)],
      'courseCount': 24,
    },
    {
      'id': 'sub6',
      'name': 'علوم البيانات',
      'icon': Icons.analytics,
      'gradient': [Color(0xFFFF9800), Color(0xFFFF5722)],
      'courseCount': 36,
    },
  ];

  final List<Map<String, dynamic>> allCourses = [
    {
      'id': '7',
      'title': 'دورة شاملة في Python للمبتدئين والمحترفين',
      'image': 'https://picsum.photos/seed/all1/400/300',
      'teacher': 'د. أحمد علي',
      'rating': 4.8,
      'students': 8765,
      'price': '₪199',
      'level': 'جميع المستويات',
      'duration': 25,
      'lessons': 40,
    },
    {
      'id': '8',
      'title': 'تعلم JavaScript من الصفر إلى الاحتراف',
      'image': 'https://picsum.photos/seed/all2/400/300',
      'teacher': 'مريم محمد',
      'rating': 4.7,
      'students': 6543,
      'price': '₪249',
      'level': 'متوسط',
      'duration': 30,
      'lessons': 50,
    },
    {
      'id': '9',
      'title': 'إدارة المشاريع التقنية الاحترافية',
      'image': 'https://picsum.photos/seed/all3/400/300',
      'teacher': 'خالد محمود',
      'rating': 4.6,
      'students': 4321,
      'price': '₪179',
      'level': 'متقدم',
      'duration': 18,
      'lessons': 35,
    },
    {
      'id': '10',
      'title': 'تصميم واجهات المستخدم المتقدمة',
      'image': 'https://picsum.photos/seed/all4/400/300',
      'teacher': 'نادية أحمد',
      'rating': 4.9,
      'students': 5432,
      'price': '₪299',
      'level': 'متوسط',
      'duration': 22,
      'lessons': 38,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showAppBarTitle) {
        setState(() {
          _showAppBarTitle = true;
        });
      } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
        setState(() {
          _showAppBarTitle = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final themeData = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        return Scaffold(
          backgroundColor: themeData.scaffoldBackgroundColor,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar with Hero Header
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: true,
                backgroundColor: themeData.appBarTheme.backgroundColor,
                foregroundColor: themeData.appBarTheme.foregroundColor,
                elevation: 0,
                title: AnimatedOpacity(
                  opacity: _showAppBarTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.category['name'] ?? 'الفئة',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            widget.category['gradient'] ??
                            [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.1,
                            child: Image.network(
                              'https://picsum.photos/seed/pattern/800/400',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Content
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.category['icon'] ?? Icons.code,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.category['name'] ?? 'البرمجة',
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'اكتشف عالم البرمجة والتطوير مع أفضل الكورسات التعليمية',
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content sections
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Beginner Courses Section
                    _buildBeginnerCoursesSection(themeData, isDarkMode),

                    const SizedBox(height: 40),

                    // Featured Courses Section
                    _buildFeaturedCoursesSection(themeData, isDarkMode),

                    const SizedBox(height: 40),

                    // Subcategories Section
                    _buildSubcategoriesSection(themeData, isDarkMode),

                    const SizedBox(height: 40),

                    // All Courses Section
                    _buildAllCoursesSection(themeData, isDarkMode),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBeginnerCoursesSection(ThemeData themeData, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'كورسات للبدء',
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: themeData.colorScheme.onBackground,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: beginnerCourses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final course = beginnerCourses[index];
              return _buildHorizontalCourseCard(course, themeData, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCoursesSection(ThemeData themeData, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الكورسات المميزة',
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: themeData.colorScheme.onBackground,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.tajawal(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop/Tablet Grid
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: featuredCourses.length,
                  itemBuilder: (context, index) {
                    final course = featuredCourses[index];
                    return _buildFeaturedCourseCard(
                      course,
                      themeData,
                      isDarkMode,
                    );
                  },
                ),
              );
            } else {
              // Mobile Horizontal Scroll
              return SizedBox(
                height: 280,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredCourses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final course = featuredCourses[index];
                    return SizedBox(
                      width: 220,
                      child: _buildFeaturedCourseCard(
                        course,
                        themeData,
                        isDarkMode,
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSubcategoriesSection(ThemeData themeData, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'الفئات الفرعية',
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: themeData.colorScheme.onBackground,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = subcategories[index];
                  return _buildSubcategoryCard(
                    subcategory,
                    themeData,
                    isDarkMode,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAllCoursesSection(ThemeData themeData, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'جميع الكورسات',
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: themeData.colorScheme.onBackground,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop/Tablet Grid
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 1200 ? 3 : 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: allCourses.length,
                  itemBuilder: (context, index) {
                    final course = allCourses[index];
                    return _buildAllCourseCard(course, themeData, isDarkMode);
                  },
                ),
              );
            } else {
              // Mobile List
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: allCourses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final course = allCourses[index];
                  return _buildAllCourseListCard(course, themeData, isDarkMode);
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalCourseCard(
    Map<String, dynamic> course,
    ThemeData themeData,
    bool isDarkMode,
  ) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCourseDetails(course),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                course['image'],
                width: 160,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: themeData.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['teacher'],
                      style: GoogleFonts.tajawal(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              course['rating'].toString(),
                              style: GoogleFonts.tajawal(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          course['price'],
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCourseCard(
    Map<String, dynamic> course,
    ThemeData themeData,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCourseDetails(course),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    course['image'],
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                  if (course['badge'] != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course['badge'],
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: themeData.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course['teacher'],
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          course['rating'].toString(),
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${course['students']}',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course['price'],
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course['level'],
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryCard(
    Map<String, dynamic> subcategory,
    ThemeData themeData,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: subcategory['gradient'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: subcategory['gradient'][1].withOpacity(
              isDarkMode ? 0.4 : 0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to subcategory
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    subcategory['icon'],
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subcategory['name'],
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${subcategory['courseCount']} كورس',
                  style: GoogleFonts.tajawal(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllCourseCard(
    Map<String, dynamic> course,
    ThemeData themeData,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCourseDetails(course),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                course['image'],
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: themeData.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course['teacher'],
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          course['rating'].toString(),
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${course['students']}',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course['price'],
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course['level'],
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCourseListCard(
    Map<String, dynamic> course,
    ThemeData themeData,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCourseDetails(course),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course['image'],
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: themeData.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['teacher'],
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          course['rating'].toString(),
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${course['students']} طالب',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          course['price'],
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course['level'],
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course['duration']} ساعة',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course['lessons']} درس',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: Colors.grey[600],
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
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    // Enhance course data with missing fields for CourseDetailsPage compatibility
    Map<String, dynamic> enhancedCourse = {
      ...course,
      'category': widget.category['name'] ?? 'البرمجة',
      'reviews': course['reviews'] ?? (course['students'] * 0.1).round(),
      'lastUpdated': course['lastUpdated'] ?? 'ديسمبر 2024',
      'description':
          course['description'] ??
          'دورة تعليمية شاملة تغطي أهم المفاهيم والمهارات في مجال ${widget.category['name']}. تم تصميم هذه الدورة بعناية لتوفر للطلاب التعليم النظري والتطبيق العملي.',
      'tags':
          course['tags'] ??
          [widget.category['name'] ?? 'البرمجة', 'تعليم', 'تدريب', 'مهارات'],
      'instructorImage':
          course['instructorImage'] ??
          'https://picsum.photos/seed/instructor${course['id']}/200/200',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(course: enhancedCourse),
      ),
    );
  }
}
