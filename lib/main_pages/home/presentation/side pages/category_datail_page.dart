import 'package:cached_network_image/cached_network_image.dart';
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/presentation/widgets/course_image_widget.dart';
import 'package:courses_app/presentation/widgets/skeleton_widgets.dart';
import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/services/home_api.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
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
  final CourseApi _courseApi = CourseApi();
  final HomeApi _homeApi = HomeApi();
  bool _showAppBarTitle = false;
  bool _isLoading = true;

  // All categories from backend
  List<Map<String, dynamic>> _allCategories = [];
  Map<String, dynamic>? _currentCategory;
  List<Map<String, dynamic>> _otherCategories = [];

  // Course lists from backend
  List<Map<String, dynamic>> beginnerCourses = [];
  List<Map<String, dynamic>> featuredCourses = [];
  List<Map<String, dynamic>> allCourses = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!mounted) return;
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
    _loadData();
  }

  Future<void> _loadData() async {
    final clickedCategoryId = widget.category['id']?.toString();
    if (clickedCategoryId == null || clickedCategoryId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Fetch all categories from home API
      final homeResponse = await _homeApi.getHome();
      final categories = (homeResponse['categories'] as List<dynamic>?) ?? [];

      // Separate current category from others
      Map<String, dynamic>? current;
      List<Map<String, dynamic>> others = [];
      
      for (var cat in categories) {
        final catId = cat['id']?.toString();
        if (catId == clickedCategoryId) {
          current = cat as Map<String, dynamic>;
        } else {
          others.add(cat as Map<String, dynamic>);
        }
      }

      // If not found in backend, use the passed category
      current ??= widget.category;

      // Fetch courses for the current category
      final allResponse = await _courseApi.getPublicCourses(
        categoryId: clickedCategoryId,
        perPage: 100,
      );
      
      final beginnerResponse = await _courseApi.getPublicCourses(
        categoryId: clickedCategoryId,
        level: 'beginner',
        perPage: 10,
      );

      final advancedResponse = await _courseApi.getPublicCourses(
        categoryId: clickedCategoryId,
        level: 'advanced',
        perPage: 10,
      );

      if (mounted) {
        setState(() {
          _allCategories = categories.map((c) => c as Map<String, dynamic>).toList();
          _currentCategory = current;
          // Use related categories algorithm instead of all others
          _otherCategories = _getRelatedCategories(
            categories.map((c) => c as Map<String, dynamic>).toList(),
            current!,
          );
          allCourses = _mapCourses(allResponse['data'] ?? []);
          beginnerCourses = _mapCourses(beginnerResponse['data'] ?? []);
          featuredCourses = _mapCourses(advancedResponse['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading category data: $e');
      if (mounted) {
        setState(() {
          _currentCategory = widget.category;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getRelatedCategories(
    List<Map<String, dynamic>> allCategories,
    Map<String, dynamic> currentCategory,
  ) {
    final currentId = currentCategory['id']?.toString();
    final currentName = currentCategory['name']?.toString().toLowerCase() ?? '';
    
    // Define related categories mapping
    final Map<String, List<String>> relatedMap = {
      'ai': ['برمجة', 'علوم البيانات', 'بايثون', 'تعلم الآلة', 'التعلم العميق', 'الشبكات العصبية'],
      'artificial intelligence': ['برمجة', 'علوم البيانات', 'بايثون', 'تعلم الآلة', 'التعلم العميق', 'الشبكات العصبية'],
      'data science': ['ai', 'تحليل البيانات', 'إحصاء', 'برمجة', 'بايثون', 'آر'],
      'programming': ['تطوير الويب', 'تطوير التطبيقات', 'قواعد البيانات', 'الأمن السيبراني', 'الذكاء الاصطناعي', 'علوم البيانات'],
      'web development': ['javascript', 'html', 'css', 'react', 'node.js', 'قواعد البيانات'],
      'mobile development': ['flutter', 'android', 'ios', 'dart', 'kotlin', 'swift'],
      'design': ['ui/ux', 'جرافيك ديزاين', 'تصميم المواقع', 'فوتوشوب', 'الموشن جرافيك', 'التصوير'],
      'business': ['إدارة الأعمال', 'التسويق', 'ريادة الأعمال', 'المبيعات', 'القيادة', 'المالية'],
      'marketing': ['التسويق الرقمي', 'سوشل ميديا', 'seo', 'الإعلانات', 'المحتوى', 'العلامة التجارية'],
      'language': ['الإنجليزية', 'الفرنسية', 'الألمانية', 'الإسبانية', 'الصينية', 'العربية'],
    };
    
    // Find related category names for current category
    List<String> relatedNames = [];
    for (var entry in relatedMap.entries) {
      if (currentName.contains(entry.key) || entry.key.contains(currentName)) {
        relatedNames = entry.value;
        break;
      }
    }
    
    // Score categories based on relation
    List<Map<String, dynamic>> scoredCategories = [];
    for (var cat in allCategories) {
      final catId = cat['id']?.toString();
      if (catId == currentId) continue; // Skip current category
      
      final catName = cat['name']?.toString().toLowerCase() ?? '';
      int score = 0;
      
      // Check if category name matches related names
      for (var related in relatedNames) {
        if (catName.contains(related.toLowerCase()) || 
            related.toLowerCase().contains(catName)) {
          score += 10;
        }
      }
      
      // Add some randomness for variety (0-5 points)
      score += (catName.length % 6);
      
      scoredCategories.add({...cat, 'score': score});
    }
    
    // Sort by score descending
    scoredCategories.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    
    // Return top 6 (or all if less than 6)
    return scoredCategories.take(6).map((c) {
      final Map<String, dynamic> result = Map<String, dynamic>.from(c);
      result.remove('score');
      return result;
    }).toList();
  }

  List<Map<String, dynamic>> _mapCourses(List<dynamic> courses) {
    return courses.map<Map<String, dynamic>>((c) {
      final rawImage = (c['course_image_url'] ?? '').toString();
      String imageUrl = '';
      if (rawImage.isNotEmpty) {
        if (rawImage.startsWith('http')) {
          imageUrl = rawImage;
        } else {
          imageUrl = 'http://192.168.1.5:8000$rawImage';
        }
      }

      return {
        'id': c['id']?.toString() ?? '',
        'title': c['title']?.toString() ?? 'دورة تعليمية',
        'image': imageUrl.isNotEmpty ? imageUrl : 'https://picsum.photos/seed/${c['id'] ?? 'course'}/400/300',
        'teacher': c['instructor']?['name']?.toString() ?? 'مدرس متخصص',
        'rating': (c['rating'] ?? 0).toDouble(),
        'students': (c['total_students'] ?? 0).toString(),
        'price': c['price']?.toString() ?? '0',
        'level': c['level']?.toString() ?? 'متوسط',
        'duration': c['duration_hours'] ?? 0,
        'lessons': c['lessons_count'] ?? 0,
        'badge': c['badge']?.toString(),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _extractSubcategories(
    Map<String, dynamic> response,
    String currentCategoryId,
  ) {
    final courses = (response['data'] as List<dynamic>?) ?? [];
    final categoriesMap = <String, Map<String, dynamic>>{};

    for (final course in courses) {
      final category = course['category'];
      if (category != null) {
        final id = category['id']?.toString() ?? '';
        if (id.isNotEmpty && id != currentCategoryId && !categoriesMap.containsKey(id)) {
          categoriesMap[id] = {
            'id': id,
            'name': category['name']?.toString() ?? 'عام',
          };
        }
      }
    }

    return categoriesMap.values.take(6).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSkeletonLoading(bool isDarkMode) {
    return CustomScrollView(
      slivers: [
        // AppBar skeleton
        SliverAppBar(
          expandedHeight: 250,
          floating: false,
          pinned: true,
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.category['gradient'] ??
                      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        // Beginner courses skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            child: SkeletonContainer(
              width: 150,
              height: 24,
              borderRadius: 4,
              isLoading: true,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 160,
                    child: SkeletonCourseCard(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),
          ),
        ),
        // Featured courses skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: SkeletonContainer(
              width: 150,
              height: 24,
              borderRadius: 4,
              isLoading: true,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 220,
                    child: SkeletonCourseCard(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),
          ),
        ),
        // Subcategories skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: SkeletonContainer(
              width: 150,
              height: 24,
              borderRadius: 4,
              isLoading: true,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return SkeletonContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
                isLoading: true,
              );
            },
          ),
        ),
        // All courses skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: SkeletonContainer(
              width: 150,
              height: 24,
              borderRadius: 4,
              isLoading: true,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SkeletonUniversityItem(isDarkMode: isDarkMode),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme directly without creating BLoC dependencies
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDarkMode = brightness == Brightness.dark;
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      body: _isLoading
          ? _buildSkeletonLoading(isDarkMode)
          : CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ✅ Optimized SliverAppBar
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
                    // ✅ Cached + lightweight background
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://picsum.photos/seed/pattern/800/400',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const SizedBox.shrink(),
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
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

          // ✅ Replace SliverToBoxAdapter+Column with SliverList
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              const SizedBox(height: 32),

              // Beginner Courses Section
              RepaintBoundary(
                child: _buildBeginnerCoursesSection(themeData, isDarkMode),
              ),

              const SizedBox(height: 40),

              // Featured Courses Section
              RepaintBoundary(
                child: _buildFeaturedCoursesSection(themeData, isDarkMode),
              ),

              const SizedBox(height: 40),

              // Subcategories Section
              RepaintBoundary(
                child: _buildSubcategoriesSection(themeData, isDarkMode),
              ),

              const SizedBox(height: 40),

              // All Courses Section
              RepaintBoundary(
                child: _buildAllCoursesSection(themeData, isDarkMode),
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
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
        if (beginnerCourses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'لا توجد كورسات للبدء في هذا القسم',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          )
        else
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
        if (featuredCourses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'لا توجد كورسات مميزة في هذا القسم',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          )
        else
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
        if (_otherCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'لا توجد فئات فرعية متاحة',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          )
        else
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
                itemCount: _otherCategories.length,
                itemBuilder: (context, index) {
                  final subcategory = _otherCategories[index];
                  return _buildSubcategoryCard(
                    subcategory,
                    themeData,
                    isDarkMode,
                    index,
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
        if (allCourses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'لا توجد كورسات في هذا القسم',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          )
        else
          LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop/Tablet Grid (responsive aspect ratio to avoid overflows)
              const horizontalPadding = 40.0; // 20 left + 20 right
              const spacing = 16.0;
              final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
              final availableWidth =
                  constraints.maxWidth -
                  horizontalPadding -
                  (spacing * (crossAxisCount - 1));
              final itemWidth = availableWidth / crossAxisCount;
              // Give items enough vertical room so content doesn't overflow
              final itemHeight = crossAxisCount == 3 ? 320.0 : 300.0;
              final childAspectRatio = itemWidth / itemHeight;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
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
    final String imageUrl = course['image'] ?? 'https://picsum.photos/400/300';
    final String title = course['title'] ?? 'عنوان غير متوفر';
    final String teacher = course['teacher'] ?? 'مدرس غير معروف';
    final dynamic rating = course['rating'] ?? 0.0;
    final String price = course['price'] ?? '0 S.P';
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
              child: CourseImageWidget(
                imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                width: 160,
                height: 90,
                borderRadius: BorderRadius.zero,
                placeholderIcon: Icons.school_outlined,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                      teacher,
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
                              rating.toString(),
                              style: GoogleFonts.tajawal(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          price,
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
                    course['image']?.toString() ?? '',
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return CourseImageWidget(
                        imageUrl: null,
                        width: double.infinity,
                        height: 140,
                        borderRadius: BorderRadius.zero,
                        placeholderIcon: Icons.school_outlined,
                      );
                    },
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

  // Define color schemes for subcategories
  final List<List<Color>> _subcategoryGradients = const [
    [Color(0xFF667EEA), Color(0xFF764BA2)],
    [Color(0xFF2196F3), Color(0xFF21CBF3)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    [Color(0xFF9C27B0), Color(0xFFE91E63)],
    [Color(0xFFFF9800), Color(0xFFFF5722)],
    [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    [Color(0xFF7C3AED), Color(0xFF6D28D9)],
  ];

  final List<IconData> _subcategoryIcons = const [
    Icons.web,
    Icons.phone_android,
    Icons.storage,
    Icons.security,
    Icons.psychology,
    Icons.analytics,
    Icons.code,
    Icons.design_services,
  ];

  Widget _buildSubcategoryCard(
    Map<String, dynamic> subcategory,
    ThemeData themeData,
    bool isDarkMode,
    int index,
  ) {
    final gradient = _subcategoryGradients[index % _subcategoryGradients.length];
    final icon = _subcategoryIcons[index % _subcategoryIcons.length];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withOpacity(
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryDetailPage(category: {
                ...subcategory,
                'gradient': gradient,
                'icon': icon,
              }),
            ),
          );
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
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subcategory['name'] ?? 'عام',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
              child: CourseImageWidget(
                imageUrl: course['image']?.toString(),
                width: double.infinity,
                height: 120,
                borderRadius: BorderRadius.zero,
                placeholderIcon: Icons.school_outlined,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // If space is tight (phones / narrow parents), stack vertically to avoid overflow
        final bool isNarrow = constraints.maxWidth < 500;

        Widget image = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CourseImageWidget(
            imageUrl: course['image']?.toString(),
            width: isNarrow ? double.infinity : 96,
            height: isNarrow ? 160 : 80,
            borderRadius: BorderRadius.zero,
            placeholderIcon: Icons.school_outlined,
          ),
        );

        Widget metricsWrap = Wrap(
          spacing: 12,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  course['rating'].toString(),
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                SizedBox(
                  width: 110,
                  child: Text(
                    '${course['students']} طالب',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 110,
              child: Text(
                course['price'],
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2563EB),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        );

        Widget bottomWrap = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            // Duration
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
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
            // Lessons
            Row(
              mainAxisSize: MainAxisSize.min,
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
        );

        Widget contentColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
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
            // Teacher
            Text(
              course['teacher'],
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            metricsWrap,
            const SizedBox(height: 8),
            bottomWrap,
          ],
        );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
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
              child: isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        image,
                        const SizedBox(height: 12),
                        contentColumn,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        image,
                        const SizedBox(width: 16),
                        Expanded(child: contentColumn),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToCourseDetails(Map<String, dynamic> course) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch full course details with sections and lessons
      Map<String, dynamic> fullCourseData = {};
      int totalDuration = 0;
      int totalLessons = 0;

      // Try to fetch course details using course slug or id
      final slug = (course['slug']?.toString().isNotEmpty == true) 
          ? course['slug'] 
          : course['id'];
      
      if (slug != null && slug.toString().isNotEmpty) {
        try {
          final response = await _courseApi.getCourseDetails(slug.toString());
          
          // Handle different response formats
          if (response['course'] != null) {
            fullCourseData = response['course'] as Map<String, dynamic>;
          } else if (response['data'] != null) {
            fullCourseData = response['data'] as Map<String, dynamic>;
          } else if (response['id'] != null) {
            fullCourseData = response;
          }

          // Calculate total duration and lessons from sections
          final sections = fullCourseData['sections'] as List? ?? [];
          for (final section in sections) {
            final lessons = section['lessons'] as List? ?? [];
            totalLessons += lessons.length;
            for (final lesson in lessons) {
              final duration = lesson['duration'] as int? ?? 0;
              totalDuration += duration;
            }
          }
        } catch (e) {
          print('Error fetching course details from category page: $e');
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Convert duration from seconds to hours (round up)
      final durationHours = totalDuration > 0 ? (totalDuration / 3600).ceil() : 0;

      // Build enhanced course data from API response
      Map<String, dynamic> enhancedCourse = {
        'id': fullCourseData['id'] ?? course['id'] ?? '',
        'slug': fullCourseData['slug'] ?? course['slug'] ?? '',
        'title': fullCourseData['title'] ?? course['title'] ?? 'دورة تعليمية',
        'image': fullCourseData['course_image_url'] ?? course['image'] ?? 'https://picsum.photos/400/300',
        'teacher': fullCourseData['instructor']?['name'] ?? course['teacher'] ?? 'مدرس متخصص',
        'instructor': fullCourseData['instructor'] ?? course['instructor'],
        'category': fullCourseData['category']?['name'] ?? course['category'] ?? 'عام',
        'rating': (fullCourseData['rating'] ?? course['rating'] ?? 4.5).toDouble(),
        'reviews': fullCourseData['total_ratings'] ?? course['reviews'] ?? 0,
        'students': (fullCourseData['total_students'] ?? course['students'] ?? 0).toString(),
        'duration': durationHours > 0 ? durationHours : (fullCourseData['duration_hours'] ?? course['duration'] ?? 0),
        'lessons': totalLessons > 0 ? totalLessons : (fullCourseData['lessons_count'] ?? course['lessons'] ?? 0),
        'level': fullCourseData['level'] ?? course['level'] ?? 'متوسط',
        'lastUpdated': _extractYear(fullCourseData['updated_at']) ?? _extractYear(course['lastUpdated']) ?? '2026',
        'price': fullCourseData['price']?.toString() ?? course['price']?.toString() ?? '0',
        'description': fullCourseData['description'] ?? course['description'] ?? '',
        'tags': fullCourseData['category']?['name'] != null ? [fullCourseData['category']['name']] : (course['tags'] ?? []),
        'instructorImage': fullCourseData['instructor']?['avatar'] ?? course['instructorImage'] ?? 'https://picsum.photos/200/200',
        'sections': fullCourseData['sections'] ?? course['sections'] ?? [],
        'category_id': fullCourseData['category_id'] ?? course['category_id'],
      };

      // Navigate to course details page
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: enhancedCourse),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      print('Navigation error from category page: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل فتح الدورة: $e',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String? _extractYear(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      final dateStr = dateValue.toString();
      // Try to extract year from ISO date format (2024-01-15T10:30:00.000000Z)
      if (dateStr.contains('T')) {
        return dateStr.split('T')[0].split('-')[0];
      }
      // Try to extract year from date format (2024-01-15)
      if (dateStr.contains('-')) {
        return dateStr.split('-')[0];
      }
      return dateStr;
    } catch (e) {
      return null;
    }
  }
}
