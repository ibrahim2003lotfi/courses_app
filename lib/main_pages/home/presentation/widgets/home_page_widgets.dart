import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/category_datail_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/category_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/recommended_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/university_pages/univiersities_page.dart';
import 'package:courses_app/main_pages/home/presentation/widgets/notifications_page.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class TopSearchBar extends StatelessWidget implements PreferredSizeWidget {
  const TopSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return SafeArea(
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: themeState.isDarkMode
                  ? const Color(0xFF1E1E1E) // Use dark theme card color
                  : Colors.white, // Use light theme background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    themeState.isDarkMode ? 0.1 : 0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    // Logo
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title text with theme-aware color
                    Expanded(
                      child: Text(
                        'منصة الكورسات',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: themeState.isDarkMode
                              ? Colors
                                    .white // White text for dark mode
                              : const Color(
                                  0xFF1F2937,
                                ), // Original dark gray for light mode
                        ),
                      ),
                    ),

                    // Bell Icon
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: themeState.isDarkMode
                            ? Colors.white
                            : const Color(0xFF1F2937),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Material(
            elevation: isDarkMode ? 1 : 2,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
            child: TextField(
              controller: _controller,
              style: GoogleFonts.tajawal(
                fontWeight: _hasText ? FontWeight.w700 : FontWeight.w500,
                fontSize: 16,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن الكورسات, المحاضرات, و الدروس',
                hintStyle: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
                  borderSide: BorderSide(
                    color: const Color(0xFF2563EB),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HeroCarousel extends StatefulWidget {
  final List<String> heroImages;

  const HeroCarousel({super.key, required this.heroImages});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _heroController = PageController();
  int _heroPage = 0;

  @override
  void initState() {
    super.initState();
    _heroController.addListener(() {
      final page = _heroController.page?.round() ?? 0;
      if (page != _heroPage) {
        setState(() {
          _heroPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _heroController,
                  itemCount: widget.heroImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.heroImages[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: isDarkMode
                                          ? const Color(0xFF2D2D2D)
                                          : const Color(0xFFF3F4F6),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: isDarkMode
                                              ? Colors.white70
                                              : const Color(0xFF3B82F6),
                                        ),
                                      ),
                                    );
                                  },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(
                                      isDarkMode ? 0.8 : 0.6,
                                    ),
                                    Colors.black.withOpacity(
                                      isDarkMode ? 0.4 : 0.2,
                                    ),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            // Centered content
                            Positioned(
                              bottom: 48, // Moved up to make space for dots
                              right: 0,
                              left: 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ابدأ رحلتك التعليمية اليوم 🚀',
                                    style: GoogleFonts.tajawal(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      height: 1.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  // Bigger centered button
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF667EEA),
                                          Color(0xFF764BA2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            isDarkMode ? 0.4 : 0.2,
                                          ),
                                          blurRadius: isDarkMode ? 4 : 2,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CategoriesPage(),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32, // Increased padding
                                          vertical: 14, // Increased padding
                                        ),
                                        child: Center(
                                          child: Text(
                                            'تصفح الكورسات',
                                            style: GoogleFonts.tajawal(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16, // Bigger font
                                              color: Colors.white,
                                            ),
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
                ),
                // Dots positioned below the content
                Positioned(
                  bottom: 16,
                  right: 0,
                  left: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.heroImages.length, (i) {
                      final active = i == _heroPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withOpacity(
                                  isDarkMode ? 0.7 : 0.5,
                                ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDarkMode ? 0.3 : 0.1,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CategoriesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoriesGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                      'الأقسام',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : null,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoriesPage(),
                          ),
                        );
                      },
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

              // Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  const crossAxisCount = 4;
                  final visibleCategories = categories.take(8).toList();

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: visibleCategories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (context, idx) {
                      final c = visibleCategories[idx];
                      return _buildCategoryCube(
                        context, // pass context here ✅
                        c,
                        constraints.maxWidth / crossAxisCount - 16,
                        isDarkMode: isDarkMode,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCube(
    BuildContext context, // add context ✅
    Map<String, dynamic> category,
    double itemSize, {
    required bool isDarkMode,
  }) {
    return Material(
      elevation: isDarkMode ? 4 : 3,
      borderRadius: BorderRadius.circular(16),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.transparent,
      shadowColor: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (category['gradient'] as List<Color>).last.withOpacity(
                isDarkMode ? 0.5 : 0.3,
              ),
              blurRadius: isDarkMode ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailPage(category: category),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isDarkMode ? 0.3 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: itemSize * 0.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: itemSize * 0.12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecommendedCourses extends StatelessWidget {
  final List<Map<String, dynamic>> recommended;

  const RecommendedCourses({super.key, required this.recommended});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مقترح لك',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : null,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecommendedPage(),
                          ),
                        );
                      },
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
              ...recommended.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDarkMode ? 0.1 : 0.05,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Use different layouts based on available width
                        if (constraints.maxWidth < 600) {
                          // Mobile layout - vertical
                          return Column(
                            children: [
                              // Image and title row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item['image'],
                                      width: 80,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: GoogleFonts.tajawal(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['teacher'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : null,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Rating and students row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['rating'].toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : null,
                                        ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.people_outline,
                                    size: 16,
                                    color: isDarkMode
                                        ? Colors.white60
                                        : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${item['students']} طالب',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode
                                                ? Colors.white70
                                                : null,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Button - full width on mobile
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isDarkMode
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 3,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Map<String, dynamic> enhancedCourse = {
                                        ...item, // Spread the original item
                                        'category': item['category'] ?? 'برمجة',
                                        'reviews': item['reviews'] ?? 100,
                                        'duration': item['duration'] ?? 20,
                                        'lessons': item['lessons'] ?? 30,
                                        'level': item['level'] ?? 'متوسط',
                                        'lastUpdated':
                                            item['lastUpdated'] ?? '2024',
                                        'price': item['price'] ?? '₪199',
                                        'description':
                                            item['description'] ??
                                            'دورة تعليمية شاملة تغطي أهم المفاهيم والمهارات في هذا المجال.',
                                        'tags':
                                            item['tags'] ??
                                            ['تعليم', 'تدريب', 'مهارات'],
                                        'instructorImage':
                                            item['instructorImage'] ??
                                            'https://picsum.photos/seed/instructor/200/200',
                                      };

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CourseDetailsPage(
                                                course: enhancedCourse,
                                              ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical:
                                            12, // Increased from 10 to 12 to make it taller
                                      ),
                                      child: Center(
                                        child: Text(
                                          'التفاصيل',
                                          style: GoogleFonts.tajawal(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Tablet/Desktop layout - horizontal
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item['image'],
                                  width: constraints.maxWidth < 800 ? 80 : 100,
                                  height: constraints.maxWidth < 800 ? 60 : 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: GoogleFonts.tajawal(
                                        fontSize: constraints.maxWidth < 800
                                            ? 14
                                            : 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['teacher'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode
                                                ? Colors.white70
                                                : null,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item['rating'].toStringAsFixed(1),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : null,
                                              ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.people_outline,
                                          size: 16,
                                          color: isDarkMode
                                              ? Colors.white60
                                              : const Color(0xFF6B7280),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item['students']} طالب',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : null,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF667EEA),
                                      Color(0xFF764BA2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isDarkMode
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 3,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Map<String, dynamic> enhancedCourse = {
                                      ...item,
                                      'category': item['category'] ?? 'برمجة',
                                      'reviews': item['reviews'] ?? 100,
                                      'duration': item['duration'] ?? 20,
                                      'lessons': item['lessons'] ?? 30,
                                      'level': item['level'] ?? 'متوسط',
                                      'lastUpdated':
                                          item['lastUpdated'] ?? '2024',
                                      'price': item['price'] ?? '₪199',
                                      'description':
                                          item['description'] ??
                                          'دورة تعليمية شاملة تغطي أهم المفاهيم والمهارات في هذا المجال.',
                                      'tags':
                                          item['tags'] ??
                                          ['تعليم', 'تدريب', 'مهارات'],
                                      'instructorImage':
                                          item['instructorImage'] ??
                                          'https://picsum.photos/seed/instructor/200/200',
                                    };

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CourseDetailsPage(
                                          course: enhancedCourse,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      'التفاصيل',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class TrendingCourses extends StatelessWidget {
  final List<Map<String, dynamic>> trending;

  const TrendingCourses({super.key, required this.trending});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الأكثر شيوعًا',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'عرض الكل',
                      style: GoogleFonts.tajawal(
                        color: const Color(0xFF2563EB), // Keep brand color
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal courses list edge-to-edge
            SizedBox(
              height: 180,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: trending.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, idx) {
                  final t = trending[idx];
                  return SizedBox(
                    width: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor, // Use theme card color
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDarkMode ? 0.1 : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image section
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Image.network(
                                  t['image'],
                                  width: 200,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEF4444,
                                      ), // Keep discount color
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      t['price'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content section
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    t['title'],
                                    style: GoogleFonts.tajawal(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: theme
                                          .colorScheme
                                          .onSurface, // Use theme text color
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
              ),
            ),
          ],
        );
      },
    );
  }
}

class ExtrasSection extends StatelessWidget {
  const ExtrasSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Lectures Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // الكتابة مع الأيقونة في السطر الأول
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'طور مهاراتك الجامعية',
                                style: GoogleFonts.tajawal(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'محاضرات ومواد دراسية متقدمة',
                                style: GoogleFonts.tajawal(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // الزر في السطر الثاني
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UniversitiesPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667EEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                        elevation: isDarkMode ? 4 : 2,
                        shadowColor: Colors.black.withOpacity(
                          isDarkMode ? 0.3 : 0.1,
                        ),
                      ),
                      child: Text(
                        'عرض المحاضرات',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // أفضل الأساتذة (بدلاً من أفضل المدربين)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'أفضل الأساتذة',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  return SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFF59E0B,
                                ).withOpacity(isDarkMode ? 0.4 : 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(
                              'https://picsum.photos/seed/professor${i}/100/100',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            'د. أحمد ${i + 1}',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme
                                  .colorScheme
                                  .onSurface, // Use theme text color
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // باقي الأقسام زي ما هي (إنجازات - تحميل - نشرة بريدية)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Add your other sections here with theme adaptation
                  // Achievements, Download buttons, Newsletter...
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        return Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? const LinearGradient(
                    colors: [Color(0xFF1F2937), Color(0xFF111827)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.1),
                      theme.scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            color: isDarkMode ? null : theme.scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            children: [
              // Responsive layout for main content
              LayoutBuilder(
                builder: (context, constraints) {
                  final textColor = isDarkMode
                      ? Colors.white
                      : theme.colorScheme.onBackground;
                  final textSecondaryColor = isDarkMode
                      ? Colors.white70
                      : theme.colorScheme.onSurface.withOpacity(0.8);

                  if (constraints.maxWidth < 600) {
                    // Mobile layout - vertical
                    return Column(
                      children: [
                        // Logo and description
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2563EB),
                                        Color(0xFF1D4ED8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.school,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'منصة الكورسات',
                                  style: GoogleFonts.tajawal(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'منصة تعليمية رائدة تقدم أفضل الكورسات بأعلى جودة وبأسعار مناسبة',
                              style: GoogleFonts.tajawal(
                                color: textSecondaryColor,
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Quick links
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'روابط سريعة',
                              style: GoogleFonts.tajawal(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'عن المنصة',
                                    style: GoogleFonts.tajawal(
                                      color: textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'اتصل بنا',
                                    style: GoogleFonts.tajawal(
                                      color: textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'سياسة الخصوصية',
                                    style: GoogleFonts.tajawal(
                                      color: textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Desktop layout - horizontal
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2563EB),
                                          Color(0xFF1D4ED8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'منصة الكورسات',
                                    style: GoogleFonts.tajawal(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'منصة تعليمية رائدة تقدم أفضل الكورسات\nبأعلى جودة وبأسعار مناسبة',
                                style: GoogleFonts.tajawal(
                                  color: textSecondaryColor,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'روابط سريعة',
                              style: GoogleFonts.tajawal(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'عن المنصة',
                                    style: GoogleFonts.tajawal(
                                      color: textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'اتصل بنا',
                                    style: GoogleFonts.tajawal(
                                      color: textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'سياسة الخصوصية',
                                    style: GoogleFonts.tajawal(
                                      color: textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
              Divider(color: isDarkMode ? Colors.white12 : Colors.black12),
              const SizedBox(height: 20),
              // Bottom section with copyright and social icons
              LayoutBuilder(
                builder: (context, constraints) {
                  final textColor = isDarkMode
                      ? Colors.white70
                      : theme.colorScheme.onSurface.withOpacity(0.8);
                  final iconColor = isDarkMode
                      ? Colors.white70
                      : theme.colorScheme.onSurface.withOpacity(0.7);

                  if (constraints.maxWidth < 600) {
                    // Mobile layout - vertical
                    return Column(
                      children: [
                        Text(
                          '© 2025 منصة الكورسات. جميع الحقوق محفوظة',
                          style: GoogleFonts.tajawal(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.facebook, color: iconColor),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.link_rounded, color: iconColor),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.alternate_email,
                                color: iconColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Desktop layout - horizontal
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '© 2025 منصة الكورسات. جميع الحقوق محفوظة',
                          style: GoogleFonts.tajawal(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.facebook, color: iconColor),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.link_rounded, color: iconColor),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.alternate_email,
                                color: iconColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
