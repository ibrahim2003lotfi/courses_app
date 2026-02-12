import 'package:courses_app/main_pages/home/presentation/widgets/home_page_widgets.dart';
import 'package:courses_app/config/api.dart';
import 'package:courses_app/presentation/widgets/skeleton_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(LoadHomeEvent()),
      child: const _HomePageBody(),
    );
  }
}

class _HomePageBody extends StatefulWidget {
  const _HomePageBody();

  @override
  State<_HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<_HomePageBody> {
  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    context.read<HomeBloc>().add(LoadHomeEvent());
  }

  List<String> _buildHeroImages(Map<String, dynamic>? data) {
    // For now keep the same style: use static images if backend doesn't provide
    return [
      'https://picsum.photos/900/400?image=1067',
      'https://picsum.photos/900/400?image=1025',
      'https://picsum.photos/900/400?image=1003',
    ];
  }

  List<Map<String, dynamic>> _buildCategories(
    Map<String, dynamic>? data,
    bool isLoading,
  ) {
    // While loading, return empty list (don't show static fallback)
    if (isLoading) {
      return [];
    }

    final backendCategories = (data?['categories'] as List?) ?? [];

    // Define colorful gradients - 8 UNIQUE colors
    final List<Map<String, dynamic>> colorSchemes = [
      {
        'color': const Color(0xFF3B82F6), // أزرق
        'gradient': [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
      },
      {
        'color': const Color(0xFF8B5CF6), // بنفسجي
        'gradient': [const Color(0xFFA78BFA), const Color(0xFF8B5CF6)],
      },
      {
        'color': const Color(0xFFF59E0B), // برتقالي
        'gradient': [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
      },
      {
        'color': const Color(0xFFEC4899), // وردي
        'gradient': [const Color(0xFFF472B6), const Color(0xFFEC4899)],
      },
      {
        'color': const Color(0xFF10B981), // أخضر زمردي
        'gradient': [const Color(0xFF34D399), const Color(0xFF10B981)],
      },
      {
        'color': const Color(0xFF06B6D4), // سماوي
        'gradient': [const Color(0xFF22D3EE), const Color(0xFF06B6D4)],
      },
      {
        'color': const Color(0xFFEF4444), // أحمر
        'gradient': [const Color(0xFFF87171), const Color(0xFFEF4444)],
      },
      {
        'color': const Color(0xFF84CC16), // أخضر ليموني
        'gradient': [const Color(0xFFA3E635), const Color(0xFF84CC16)],
      },
    ];

    // Define all 8 fallback categories - each with UNIQUE color
    final List<Map<String, dynamic>> fallbackCategories = [
      {
        'name': 'برمجة',
        'icon': Icons.code,
        'color': const Color(0xFF3B82F6), // أزرق
        'gradient': [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
      },
      {
        'name': 'تصميم',
        'icon': Icons.design_services,
        'color': const Color(0xFF8B5CF6), // بنفسجي
        'gradient': [const Color(0xFFA78BFA), const Color(0xFF8B5CF6)],
      },
      {
        'name': 'تسويق',
        'icon': Icons.campaign,
        'color': const Color(0xFFF59E0B), // برتقالي
        'gradient': [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
      },
      {
        'name': 'فوتوجرافي',
        'icon': Icons.camera_alt,
        'color': const Color(0xFFEC4899), // وردي
        'gradient': [const Color(0xFFF472B6), const Color(0xFFEC4899)],
      },
      {
        'name': 'أعمال',
        'icon': Icons.business,
        'color': const Color(0xFF10B981), // أخضر زمردي
        'gradient': [const Color(0xFF34D399), const Color(0xFF10B981)],
      },
      {
        'name': 'ذكاء اصطناعي',
        'icon': Icons.smart_toy,
        'color': const Color(0xFF06B6D4), // سماوي
        'gradient': [const Color(0xFF22D3EE), const Color(0xFF06B6D4)],
      },
      {
        'name': 'لغات',
        'icon': Icons.language,
        'color': const Color(0xFFEF4444), // أحمر
        'gradient': [const Color(0xFFF87171), const Color(0xFFEF4444)],
      },
      {
        'name': 'علوم',
        'icon': Icons.science,
        'color': const Color(0xFF84CC16), // أخضر ليموني
        'gradient': [const Color(0xFFA3E635), const Color(0xFF84CC16)],
      },
    ];

    // If no backend categories, use fallback
    if (backendCategories.isEmpty) {
      return fallbackCategories;
    }

    // Map backend categories and ensure we have at least 8
    final mappedCategories = backendCategories.map<Map<String, dynamic>>((c) {
      final index = backendCategories.indexOf(c);
      final colorScheme = colorSchemes[index % colorSchemes.length];
      final categoryName = (c['name'] ?? '').toString();

      // Map category names to appropriate icons and convert to Arabic display name
      IconData categoryIcon;
      String displayName = categoryName; // default to original name

      switch (categoryName) {
        case 'برمجة':
        case 'Programming':
        case 'Code':
          categoryIcon = Icons.code;
          displayName = 'برمجة';
          break;
        case 'تصميم':
        case 'Design':
          categoryIcon = Icons.design_services;
          displayName = 'تصميم';
          break;
        case 'تسويق':
        case 'Marketing':
          categoryIcon = Icons.campaign;
          displayName = 'تسويق';
          break;
        case 'لغات':
        case 'Languages':
          categoryIcon = Icons.language;
          displayName = 'لغات';
          break;
        case 'أعمال':
        case 'Business':
          categoryIcon = Icons.business;
          displayName = 'أعمال';
          break;
        case 'تطوير شخصي':
        case 'Personal Development':
          categoryIcon = Icons.trending_up;
          displayName = 'تطوير شخصي';
          break;
        case 'رياضيات':
        case 'Mathematics':
          categoryIcon = Icons.calculate;
          displayName = 'رياضيات';
          break;
        case 'علوم':
        case 'Science':
          categoryIcon = Icons.science;
          displayName = 'علوم';
          break;
        case 'شبكات':
        case 'Networking':
          categoryIcon = Icons.network_check;
          displayName = 'شبكات';
          break;
        case 'قواعد بيانات':
        case 'Databases':
          categoryIcon = Icons.storage;
          displayName = 'قواعد بيانات';
          break;
        case 'ذكاء اصطناعي':
        case 'AI':
        case 'Artificial Intelligence':
          categoryIcon = Icons.smart_toy;
          displayName = 'ذكاء اصطناعي';
          break;
        case 'فوتوجرافي':
        case 'Photography':
          categoryIcon = Icons.camera_alt;
          displayName = 'فوتوجرافي';
          break;
        default:
          // Use different icons based on index for variety
          final defaultIcons = [
            Icons.code,
            Icons.design_services,
            Icons.campaign,
            Icons.language,
            Icons.business,
            Icons.trending_up,
            Icons.lightbulb,
            Icons.psychology,
          ];
          categoryIcon = defaultIcons[index % defaultIcons.length];
      }

      return {
        'id': c['id']?.toString() ?? '',
        'name': displayName,
        'icon': categoryIcon,
        'color': colorScheme['color'],
        'gradient': colorScheme['gradient'],
      };
    }).toList();

    // If backend returns less than 8 categories, supplement with fallback
    if (mappedCategories.length < 8) {
      // Get names of existing categories to avoid duplicates
      final existingNames = mappedCategories.map((c) => c['name']).toSet();

      // Add fallback categories that don't already exist
      for (final fallback in fallbackCategories) {
        if (mappedCategories.length >= 8) break;
        if (!existingNames.contains(fallback['name'])) {
          mappedCategories.add(fallback);
        }
      }
    }

    return mappedCategories.take(8).toList();
  }

  List<Map<String, dynamic>> _buildRecommended(
    Map<String, dynamic>? data,
    List<String> userInterests,
  ) {
    final sections = (data?['sections'] as List?) ?? [];

    // Get all courses from trending and other sections
    final allCourses = <Map<String, dynamic>>[];
    for (final section in sections) {
      final sectionCourses =
          (section['courses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      allCourses.addAll(sectionCourses);
    }

    // If user has interests, filter courses that match those interests
    List<Map<String, dynamic>> filteredCourses;
    if (userInterests.isNotEmpty) {
      // Map interest IDs to category names
      final interestToCategoryMap = {
        'programming': 'برمجة',
        'design': 'تصميم',
        'business': 'أعمال',
        'marketing': 'تسويق',
        'language': 'لغات',
        'science': 'علوم',
        'art': 'فن',
        'music': 'موسيقى',
        'sports': 'رياضة',
        'technology': 'تكنولوجيا',
        'health': 'صحة',
        'education': 'تعليم',
      };

      // Get category names from user interests
      final targetCategories = userInterests
          .map((interest) => interestToCategoryMap[interest] ?? interest)
          .toSet();

      print('🎯 Filtering courses for categories: $targetCategories');
      print('🎯 Total courses to filter: ${allCourses.length}');
      if (allCourses.isNotEmpty) {
        print('🎯 Sample course category: ${allCourses.first['category']}');
      }

      // Filter courses that match user interests
      filteredCourses = allCourses.where((course) {
        final categoryName = course['category']?['name']?.toString() ?? '';
        print('🎯 Checking course: ${course['title']}, category: $categoryName');
        return targetCategories.any(
          (interest) =>
              categoryName.toLowerCase().contains(interest.toLowerCase()),
        );
      }).toList();

      print('🎯 Found ${filteredCourses.length} matching courses');
    } else {
      // No interests, use trending courses as fallback
      filteredCourses = allCourses;
    }

    // Map to the format needed for RecommendedCourses widget
    return filteredCourses.map((c) {
      // Handle course image URL like in _buildTrending
      final rawImage = (c['course_image_url'] ?? '').toString();
      String imageUrl = '';
      if (rawImage.isNotEmpty) {
        if (rawImage.startsWith('http')) {
          imageUrl = rawImage;
        } else {
          // If relative path like /storage/...., add baseUrl without /api
          imageUrl = '${ApiConfig.baseUrlNoApi}$rawImage';
        }
      }

      return {
        'id': c['id'] ?? '',
        'slug': c['slug'] ?? '',
        'title': c['title'] ?? '',
        'teacher': c['instructor']?['name'] ?? '',
        'instructor': c['instructor'],
        'category': c['category']?['name'] ?? 'برمجة',
        'category_id': c['category_id'],
        'rating': (c['rating'] ?? 0).toDouble(),
        'students': (c['total_students'] ?? 0).toString(),
        'image': imageUrl.isNotEmpty
            ? imageUrl
            : 'https://picsum.photos/seed/${c['id'] ?? 'course'}/200/120',
        'price': c['price']?.toString() ?? '0',
        'level': c['level'] ?? 'متوسط',
        'description': c['description'] ?? '',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildTrending(Map<String, dynamic>? data) {
    final sections = (data?['sections'] as List?) ?? [];
    final trendingSection = sections.cast<Map<String, dynamic>?>().firstWhere(
      (s) => s?['type'] == 'trending',
      orElse: () => null,
    );

    final courses =
        (trendingSection?['courses'] as List?)?.cast<Map<String, dynamic>>() ??
        [];

    final mapped = courses.map<Map<String, dynamic>>((c) {
      // استخدم رابط صورة الكورس من الباك إند إن وجد، وابنِ رابط كامل إذا كان المسار نسبياً
      final rawImage = (c['course_image_url'] ?? '').toString();

      String imageUrl = '';
      if (rawImage.isNotEmpty) {
        if (rawImage.startsWith('http')) {
          imageUrl = rawImage;
        } else {
          // إذا كان المسار نسبي مثل /storage/....، نضيف baseUrl بدون /api
          imageUrl = '${ApiConfig.baseUrlNoApi}$rawImage';
        }
      }

      return {
        'id': c['id'] ?? '',
        'slug': c['slug'] ?? '',
        'title': c['title'] ?? '',
        'image': imageUrl,
        'rating': (c['rating'] ?? 0).toDouble(),
        'students': (c['total_students'] ?? 0).toString(),
        'teacher': c['instructor']?['name'] ?? '',
        'instructor': c['instructor'],
        'category': c['category']?['name'] ?? 'برمجة',
        'category_id': c['category_id'],
        'price': c['price']?.toString() ?? '0',
        'level': c['level'] ?? 'متوسط',
        'description': c['description'] ?? '',
      };
    }).toList();

    // حد أقصى 5 كورسات في قسم "الأكثر شيوعاً"
    return mapped.take(5).toList();
  }

  Widget _HomeSkeletonLoading(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      slivers: [
        // Search skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SkeletonContainer(
              width: double.infinity,
              height: 50,
              borderRadius: 12,
              isLoading: true,
            ),
          ),
        ),
        // Hero carousel skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonContainer(
              width: double.infinity,
              height: 180,
              borderRadius: 16,
              isLoading: true,
            ),
          ),
        ),
        // Categories title skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: SkeletonContainer(
              width: 150,
              height: 24,
              borderRadius: 4,
              isLoading: true,
            ),
          ),
        ),
        // Categories grid skeleton
        SliverToBoxAdapter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  SkeletonContainer(
                    width: 60,
                    height: 60,
                    borderRadius: 30,
                    isLoading: true,
                  ),
                  const SizedBox(height: 8),
                  SkeletonContainer(
                    width: 50,
                    height: 12,
                    borderRadius: 4,
                    isLoading: true,
                  ),
                ],
              );
            },
          ),
        ),
        // Recommended section skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: SkeletonContainer(
              width: 150,
              height: 24,
              borderRadius: 4,
              isLoading: true,
            ),
          ),
        ),
        // Recommended courses skeleton
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SkeletonCourseCard(isDarkMode: isDarkMode),
                );
              },
            ),
          ),
        ),
        // Trending section skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: SkeletonContainer(
              width: 180,
              height: 24,
              borderRadius: 4,
              isLoading: true,
            ),
          ),
        ),
        // Trending courses skeleton
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SkeletonCourseCard(isDarkMode: isDarkMode),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopSearchBar(),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            // Show skeleton loading while data is loading
            if (state.isLoading) {
              return _HomeSkeletonLoading(context);
            }

            final data = state.data;
            final heroImages = _buildHeroImages(data);
            final categories = _buildCategories(data, state.isLoading);
            final recommended = _buildRecommended(data, state.userInterests);
            final trending = _buildTrending(data);

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF667EEA),
              backgroundColor: Colors.white,
              displacement: 40,
              strokeWidth: 3,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                SliverToBoxAdapter(child: SearchField()),
                SliverToBoxAdapter(child: HeroCarousel(heroImages: heroImages)),
                SliverToBoxAdapter(
                  child: CategoriesGrid(categories: categories),
                ),
                SliverToBoxAdapter(
                  child: recommended.isNotEmpty
                      ? RecommendedCourses(recommended: recommended)
                      : Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'مقترح لك',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'لا يوجد كورسات مقترحة لك حاليا',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                SliverToBoxAdapter(child: TrendingCourses(trending: trending)),
                SliverToBoxAdapter(
                  child: ContinueLearning(courses: state.enrolledCourses),
                ),
                const SliverToBoxAdapter(child: ExtrasSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverToBoxAdapter(child: Footer()),
              ],
            ),
          );
          },
        ),
      ),
    );
  }
}
