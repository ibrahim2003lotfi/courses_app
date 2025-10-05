import 'package:courses_app/main_pages/home/presentation/widgets/home_page_widgets.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> heroImages = [
    'https://picsum.photos/900/400?image=1067',
    'https://picsum.photos/900/400?image=1025',
    'https://picsum.photos/900/400?image=1003',
  ];

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'برمجة',
      'icon': Icons.code,
      'color': Color(0xFF3B82F6),
      'gradient': [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    },
    {
      'name': 'تصميم',
      'icon': Icons.design_services,
      'color': Color(0xFF8B5CF6),
      'gradient': [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
    },
    {
      'name': 'تسويق',
      'icon': Icons.campaign,
      'color': Color(0xFFF59E0B),
      'gradient': [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    },
    {
      'name': 'لغات',
      'icon': Icons.language,
      'color': Color(0xFF10B981),
      'gradient': [Color(0xFF34D399), Color(0xFF10B981)],
    },
    {
      'name': 'ريادة أعمال',
      'icon': Icons.business_center,
      'color': Color(0xFFEF4444),
      'gradient': [Color(0xFFF87171), Color(0xFFEF4444)],
    },
    {
      'name': 'علوم البيانات',
      'icon': Icons.bar_chart,
      'color': Color(0xFF8B5CF6),
      'gradient': [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
    },
    {
      'name': 'تصوير',
      'icon': Icons.camera_alt,
      'color': Color(0xFFEC4899),
      'gradient': [Color(0xFFF472B6), Color(0xFFEC4899)],
    },
    {
      'name': 'صحة ورياضة',
      'icon': Icons.fitness_center,
      'color': Color(0xFF10B981),
      'gradient': [Color(0xFF34D399), Color(0xFF10B981)],
    },
  ];

  final List<Map<String, dynamic>> recommended = List.generate(5, (i) {
    return {
      'title': 'كورس ${i + 1} لتعلم مهارة متقدمة في البرمجة',
      'teacher': 'د. أحمد محمد ${i + 1}',
      'rating': 4.5 - (i * 0.2),
      'students': (1500 + i * 200).toString(),
      'image': 'https://picsum.photos/seed/course${i}/200/120',
    };
  });

  final List<Map<String, dynamic>> trending = List.generate(10, (i) {
    return {
      'title': 'كورس شائع ${i + 1} في مجال التكنولوجيا',
      'image': 'https://picsum.photos/seed/trend${i}/180/100',
      'price': i % 3 == 0 ? 'مجاني' : '${(i + 1) * 50} ريال',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopSearchBar(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
           // SliverToBoxAdapter(child: TopSearchBar()),
            SliverToBoxAdapter(child: SearchField()),
            SliverToBoxAdapter(child: HeroCarousel(heroImages: heroImages)),
            SliverToBoxAdapter(child: CategoriesGrid(categories: categories)),
            SliverToBoxAdapter(child: RecommendedCourses(recommended: recommended)),
            
            SliverToBoxAdapter(child: TrendingCourses(trending: trending)),
            SliverToBoxAdapter(child: ExtrasSection()),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: Footer()),
          ],
        ),
      ),
    );
  }
}