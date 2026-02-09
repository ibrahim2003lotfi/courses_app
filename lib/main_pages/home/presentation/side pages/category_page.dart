import 'package:courses_app/main_pages/home/presentation/side%20pages/category_datail_page.dart';
import 'package:courses_app/services/home_api.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final HomeApi _homeApi = HomeApi();
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // Fetch categories from the home API (same as home page)
      final response = await _homeApi.getHome();
      
      if (mounted) {
        final categories = (response['categories'] as List<dynamic>?) ?? [];
        setState(() {
          _categories = categories.map((c) => c as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final List<Map<String, dynamic>> _colorSchemes = const [
    {
      'gradient': [Color(0xFF2563EB), Color(0xFF1D4ED8)], // Blue
      'icon': Icons.code,
    },
    {
      'gradient': [Color(0xFF7C3AED), Color(0xFF6D28D9)], // Purple
      'icon': Icons.design_services,
    },
    {
      'gradient': [Color(0xFFDC2626), Color(0xFFB91C1C)], // Red
      'icon': Icons.smart_toy,
    },
    {
      'gradient': [Color(0xFF059669), Color(0xFF047857)], // Green
      'icon': Icons.security,
    },
    {
      'gradient': [Color(0xFFDB2777), Color(0xFFBE185D)], // Pink
      'icon': Icons.campaign,
    },
    {
      'gradient': [Color(0xFFEA580C), Color(0xFFC2410C)], // Orange
      'icon': Icons.business_center,
    },
    {
      'gradient': [Color(0xFF0D9488), Color(0xFF0F766E)], // Teal
      'icon': Icons.language,
    },
    {
      'gradient': [Color(0xFF6366F1), Color(0xFF4F46E5)], // Indigo
      'icon': Icons.science,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: Text(
              'جميع الأقسام',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            backgroundColor: isDarkMode
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _categories.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد أقسام متاحة',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final colorScheme = _colorSchemes[index % _colorSchemes.length];
                        return _buildCategoryCube(
                          category,
                          colorScheme,
                          context,
                          isDarkMode,
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildCategoryCube(
    Map<String, dynamic> category,
    Map<String, dynamic> colorScheme,
    BuildContext context,
    bool isDarkMode,
  ) {
    final gradient = colorScheme['gradient'] as List<Color>;
    final icon = colorScheme['icon'] as IconData;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryDetailPage(category: {
                  ...category,
                  'gradient': gradient,
                  'icon': icon,
                }),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name']?.toString() ?? '',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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
