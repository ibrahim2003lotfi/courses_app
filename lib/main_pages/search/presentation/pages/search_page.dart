import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/category_datail_page.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/services/home_api.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final CourseApi _courseApi = CourseApi();
  final HomeApi _homeApi = HomeApi();
  final TextEditingController _searchController = TextEditingController();
  
  // Data from backend
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _suggestedCourses = [];
  List<Map<String, dynamic>> _searchResults = [];
  
  bool _isLoadingCategories = true;
  bool _isLoadingCourses = true;
  bool _isSearching = false;
  bool _hasSearched = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadSuggestedCourses(),
    ]);
  }
  
  Future<void> _loadCategories() async {
    try {
      final response = await _homeApi.getHome();
      final categories = (response['categories'] as List<dynamic>?) ?? [];
      
      List<Map<String, dynamic>> selectedCategories = categories
          .map((c) => c as Map<String, dynamic>)
          .toList();
      
      if (selectedCategories.length > 5) {
        selectedCategories.shuffle();
        selectedCategories = selectedCategories.take(5).toList();
      }
      
      if (mounted) {
        setState(() {
          _categories = selectedCategories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }
  
  Future<void> _loadSuggestedCourses() async {
    try {
      final response = await _courseApi.getPublicCourses(perPage: 100);
      final courses = (response['data'] as List<dynamic>?) ?? [];
      
      List<Map<String, dynamic>> shuffledCourses = courses
          .map((c) => _mapCourse(c as Map<String, dynamic>))
          .toList();
      
      if (shuffledCourses.length > 10) {
        shuffledCourses.shuffle(Random());
        shuffledCourses = shuffledCourses.take(10).toList();
      }
      
      if (mounted) {
        setState(() {
          _suggestedCourses = shuffledCourses;
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      print('Error loading suggested courses: $e');
      if (mounted) {
        setState(() => _isLoadingCourses = false);
      }
    }
  }
  
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });
    
    try {
      final response = await _courseApi.getPublicCourses(
        search: query,
        perPage: 50,
      );
      final courses = (response['data'] as List<dynamic>?) ?? [];
      
      List<Map<String, dynamic>> results = courses
          .map((c) => _mapCourse(c as Map<String, dynamic>))
          .toList();
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Error searching: $e');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }
  
  Map<String, dynamic> _mapCourse(Map<String, dynamic> c) {
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
      'slug': c['slug']?.toString() ?? '',
      'title': c['title']?.toString() ?? 'دورة تعليمية',
      'image': imageUrl.isNotEmpty ? imageUrl : 'https://picsum.photos/seed/${c['id'] ?? 'course'}/400/300',
      'teacher': c['instructor']?['name']?.toString() ?? 'مدرس متخصص',
      'instructor': c['instructor'],
      'category': c['category']?['name']?.toString() ?? 'عام',
      'rating': (c['rating'] ?? 0).toDouble(),
      'students': (c['total_students'] ?? 0).toString(),
      'price': c['price']?.toString() ?? '0',
      'level': c['level']?.toString() ?? 'متوسط',
      'duration': c['duration_hours'] ?? 0,
      'lessons': c['lessons_count'] ?? 0,
      'description': c['description']?.toString() ?? '',
    };
  }
  
  void _navigateToCategory(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(category: category),
      ),
    );
  }
  
  Future<void> _navigateToCourseDetails(Map<String, dynamic> course) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final slug = course['slug']?.toString().isNotEmpty == true 
          ? course['slug'] 
          : course['id'];
      
      Map<String, dynamic> fullCourseData = {};
      
      if (slug != null && slug.toString().isNotEmpty) {
        final response = await _courseApi.getCourseDetails(slug.toString());
        if (response['course'] != null) {
          fullCourseData = response['course'] as Map<String, dynamic>;
        } else if (response['data'] != null) {
          fullCourseData = response['data'] as Map<String, dynamic>;
        }
      }
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      Map<String, dynamic> enhancedCourse = {
        'id': course['id'] ?? fullCourseData['id'] ?? '',
        'slug': course['slug'] ?? fullCourseData['slug'] ?? '',
        'title': course['title'] ?? fullCourseData['title'] ?? 'دورة تعليمية',
        'image': fullCourseData['course_image_url'] ?? course['image'] ?? 'https://picsum.photos/400/300',
        'teacher': fullCourseData['instructor']?['name'] ?? course['teacher'] ?? 'مدرس متخصص',
        'instructor': fullCourseData['instructor'] ?? course['instructor'],
        'category': fullCourseData['category']?['name'] ?? course['category'] ?? 'عام',
        'rating': (fullCourseData['rating'] ?? course['rating'] ?? 4.5).toDouble(),
        'reviews': fullCourseData['total_ratings'] ?? 0,
        'students': (fullCourseData['total_students'] ?? 0).toString(),
        'duration': fullCourseData['duration_hours'] ?? course['duration'] ?? 0,
        'lessons': fullCourseData['lessons_count'] ?? course['lessons'] ?? 0,
        'level': fullCourseData['level'] ?? course['level'] ?? 'متوسط',
        'lastUpdated': fullCourseData['updated_at']?.toString().substring(0, 4) ?? '2026',
        'price': fullCourseData['price']?.toString() ?? course['price']?.toString() ?? '0',
        'description': fullCourseData['description'] ?? course['description'] ?? '',
        'sections': fullCourseData['sections'] ?? [],
        'category_id': fullCourseData['category_id'] ?? course['category_id'],
      };
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: enhancedCourse),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      print('Error navigating to course: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode ? ThemeManager.darkTheme : ThemeManager.lightTheme;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // Top Search Bar
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: theme.appBarTheme.backgroundColor,
                elevation: 2,
                pinned: true,
                flexibleSpace: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo_ed.png',
                          width: 43,
                          height: 43,
                          errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 40),
                        ),
                        const SizedBox(width: 12),
                        // App Name
                        Expanded(
                          child: Text(
                            'تَعَلَّم',
                            style: GoogleFonts.tajawal(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDarkMode ? Colors.white : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Functional Search Field
                    _buildSearchField(theme, isDarkMode),
                    
                    // Search Results or Default Content
                    if (_hasSearched)
                      _buildSearchResults(theme, isDarkMode)
                    else ...[
                      // Categories Section (5 categories from backend)
                      _buildCategoriesSection(theme, isDarkMode),
                      
                      // Suggested Courses Section (10 random courses)
                      _buildSuggestedCoursesSection(theme, isDarkMode),
                    ],
                    
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
  
  Widget _buildSearchField(ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        shadowColor: Colors.black.withOpacity(0.1),
        child: TextField(
          controller: _searchController,
          onSubmitted: _performSearch,
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                _hasSearched = false;
                _searchResults = [];
              });
            }
          },
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _hasSearched = false;
                        _searchResults = [];
                      });
                    },
                  )
                : null,
            hintText: 'ابحث عن الكورسات, المدرسين, أو الفئات',
            hintStyle: GoogleFonts.tajawal(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: isDarkMode ? Colors.grey[500] : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoriesSection(ThemeData theme, bool isDarkMode) {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'البحوث المقترحة',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
          
          // Categories List
          Column(
            children: _categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isDarkMode
                          ? null
                          : Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF667EEA),
                              Color(0xFF764BA2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 14,
                      ),
                      title: Text(
                        category['name']?.toString() ?? 'فئة',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      onTap: () => _navigateToCategory(category),
                      minLeadingWidth: 0,
                      minVerticalPadding: 8,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestedCoursesSection(ThemeData theme, bool isDarkMode) {
    if (_isLoadingCourses) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_suggestedCourses.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'كورسات مقترحة',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          
          // Courses List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestedCourses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course = _suggestedCourses[index];
              return _buildCourseCard(course, theme, isDarkMode);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCourseCard(Map<String, dynamic> course, ThemeData theme, bool isDarkMode) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToCourseDetails(course),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Course Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                child: Image.network(
                  course['image'],
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 80,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    child: Icon(Icons.image_not_supported, color: isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                  ),
                ),
              ),
              
              // Course Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'],
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['teacher'],
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            course['rating'].toStringAsFixed(1),
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${course['students']} طالب',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Price
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '${course['price']} SYP',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchResults(ThemeData theme, bool isDarkMode) {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد نتائج للبحث',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'نتائج البحث (${_searchResults.length})',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          
          // Results List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course = _searchResults[index];
              return _buildCourseCard(course, theme, isDarkMode);
            },
          ),
        ],
      ),
    );
  }
}
