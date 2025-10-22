import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/search/presentation/widgets/search_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/widgets/home_page_widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Sample data for search suggestions
  final List<Map<String, dynamic>> _searchSuggestions = [
    {
      'text': 'برمجة تطبيقات الجوال',
      'icon': Icons.phone_iphone,
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      'text': 'التسويق الرقمي',
      'icon': Icons.trending_up,
      'gradient': [Color(0xFFF093FB), Color(0xFFF5576C)],
    },
    {
      'text': 'تصميم الجرافيك',
      'icon': Icons.palette,
      'gradient': [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    },
    {
      'text': 'اللغة الإنجليزية',
      'icon': Icons.language,
      'gradient': [Color(0xFF43E97B), Color(0xFF38F9D7)],
    },
    {
      'text': 'تحليل البيانات',
      'icon': Icons.analytics,
      'gradient': [Color(0xFFFA709A), Color(0xFFFEE140)],
    },
    {
      'text': 'التجارة الإلكترونية',
      'icon': Icons.shopping_cart,
      'gradient': [Color(0xFFA8C0FF), Color(0xFF3F2B96)],
    },
    {
      'text': 'الذكاء الاصطناعي',
      'icon': Icons.smart_toy,
      'gradient': [Color(0xFFFD6585), Color(0xFF0D25B9)],
    },
    {
      'text': 'التصوير الفوتوغرافي',
      'icon': Icons.camera_alt,
      'gradient': [Color(0xFF92FE9D), Color(0xFF00C9FF)],
    },
  ];

  // Sample recent searches
  final List<String> _recentSearches = [
    'Flutter programming',
    'Web design course',
    'Python for beginners',
    'Digital marketing strategy',
  ];

  // Sample popular categories
  final List<Map<String, dynamic>> _popularCategories = [
    {
      'name': 'برمجة',
      'icon': Icons.code,
      'gradient': [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    },
    {
      'name': 'تصميم',
      'icon': Icons.design_services,
      'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
    },
    {
      'name': 'لغات',
      'icon': Icons.language,
      'gradient': [Color(0xFF10B981), Color(0xFF059669)],
    },
    {
      'name': 'أعمال',
      'icon': Icons.business_center,
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    },
    {
      'name': 'موسيقى',
      'icon': Icons.music_note,
      'gradient': [Color(0xFFEC4899), Color(0xFFDB2777)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;
        
        return Scaffold(
          backgroundColor: isDarkMode 
              ? ThemeManager.darkTheme.scaffoldBackgroundColor
              : ThemeManager.lightTheme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // Top Search Bar (from home page)
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: isDarkMode 
                    ? ThemeManager.darkTheme.appBarTheme.backgroundColor
                    : ThemeManager.lightTheme.appBarTheme.backgroundColor,
                elevation: 2,
                pinned: true,
                flexibleSpace: const TopSearchBar(),
              ),

              // Search Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Field (from home page)
                    const SearchPageField(),

                    // Recent Searches
                    SuggestedSearch(recentSearches: _recentSearches),

                    // Popular Categories
                    //PopularCategories(categories: _popularCategories),

                    // Search Suggestions Grid
                    SearchSuggestionsGrid(suggestions: _searchSuggestions),

                    // Empty space at bottom
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
}