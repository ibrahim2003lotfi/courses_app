import 'package:courses_app/main_pages/home/presentation/widgets/home_page_widgets.dart';
import 'package:flutter/material.dart';
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

class _HomePageBody extends StatelessWidget {
  const _HomePageBody();

  List<String> _buildHeroImages(Map<String, dynamic>? data) {
    // For now keep the same style: use static images if backend doesn't provide
    return [
      'https://picsum.photos/900/400?image=1067',
      'https://picsum.photos/900/400?image=1025',
      'https://picsum.photos/900/400?image=1003',
    ];
  }

  List<Map<String, dynamic>> _buildCategories(Map<String, dynamic>? data) {
    final backendCategories = (data?['categories'] as List?) ?? [];

    if (backendCategories.isEmpty) {
      // Fallback to static categories (preserve current look)
      return [
        {
          'name': 'برمجة',
          'icon': Icons.code,
          'color': const Color(0xFF3B82F6),
          'gradient': [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
        },
        {
          'name': 'تصميم',
          'icon': Icons.design_services,
          'color': const Color(0xFF8B5CF6),
          'gradient': [const Color(0xFFA78BFA), const Color(0xFF8B5CF6)],
        },
        {
          'name': 'تسويق',
          'icon': Icons.campaign,
          'color': const Color(0xFFF59E0B),
          'gradient': [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
        },
        {
          'name': 'لغات',
          'icon': Icons.language,
          'color': const Color(0xFF10B981),
          'gradient': [const Color(0xFF34D399), const Color(0xFF10B981)],
        },
      ];
    }

    return backendCategories.map<Map<String, dynamic>>((c) {
      return {
        'name': c['name'] ?? '',
        'icon': Icons.category,
        'color': const Color(0xFF3B82F6),
        'gradient': [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildRecommended(Map<String, dynamic>? data) {
    final sections = (data?['sections'] as List?) ?? [];
    final recommendedSection = sections.cast<Map<String, dynamic>?>().firstWhere(
          (s) => s?['type'] == 'recommended',
          orElse: () => null,
        );

    final courses =
        (recommendedSection?['courses'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (courses.isEmpty) {
      // fallback to old demo cards
      return List.generate(5, (i) {
        return {
          'title': 'كورس ${i + 1} لتعلم مهارة متقدمة في البرمجة',
          'teacher': 'د. أحمد محمد ${i + 1}',
          'rating': 4.5 - (i * 0.2),
          'students': (1500 + i * 200).toString(),
          'image': 'https://picsum.photos/seed/course${i}/200/120',
        };
      });
    }

    return courses
        .map((c) => {
              'title': c['title'] ?? '',
              'teacher': c['instructor']?['name'] ?? '',
              'rating': (c['rating'] ?? 0).toDouble(),
              'students': (c['total_students'] ?? 0).toString(),
              'image':
                  'https://picsum.photos/seed/${c['id'] ?? 'course'}/200/120', // placeholder
            })
        .toList();
  }

  List<Map<String, dynamic>> _buildTrending(Map<String, dynamic>? data) {
    final sections = (data?['sections'] as List?) ?? [];
    final trendingSection =
        sections.cast<Map<String, dynamic>?>().firstWhere(
              (s) => s?['type'] == 'trending',
              orElse: () => null,
            );

    final courses =
        (trendingSection?['courses'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (courses.isEmpty) {
      return List.generate(10, (i) {
        return {
          'title': 'كورس شائع ${i + 1} في مجال التكنولوجيا',
          'image': 'https://picsum.photos/seed/trend${i}/180/100',
          'price': i % 3 == 0 ? 'مجاني' : '${(i + 1) * 50} ريال',
        };
      });
    }

    return courses
        .map((c) => {
              'title': c['title'] ?? '',
              'image':
                  'https://picsum.photos/seed/trend${c['id'] ?? ''}/180/100',
              'price': (c['price'] ?? 0) == 0 ? 'مجاني' : '${c['price']}',
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopSearchBar(),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final data = state.data;
            final heroImages = _buildHeroImages(data);
            final categories = _buildCategories(data);
            final recommended = _buildRecommended(data);
            final trending = _buildTrending(data);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SearchField()),
                SliverToBoxAdapter(
                    child: HeroCarousel(heroImages: heroImages)),
                SliverToBoxAdapter(
                    child: CategoriesGrid(categories: categories)),
                SliverToBoxAdapter(
                    child: RecommendedCourses(recommended: recommended)),
                SliverToBoxAdapter(
                    child: TrendingCourses(trending: trending)),
                const SliverToBoxAdapter(child: ExtrasSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverToBoxAdapter(child: Footer()),
              ],
            );
          },
        ),
      ),
    );
  }
}