<<<<<<< HEAD
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
=======
import 'package:courses_app/main_pages/home/presentation/side%20pages/category_datail_page.dart';
>>>>>>> 9733b3b7817e2ac38d39d4067b5efb503841f1f1
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  // Organized categories by sections with darker colors
  final List<Map<String, dynamic>> _categorySections = const [
    {
      'sectionName': 'التقنية والبرمجة',
      'categories': [
        {
          'name': 'برمجة تطبيقات',
          'icon': Icons.code,
          'gradient': [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        },
        {
          'name': 'تطوير الويب',
          'icon': Icons.web,
          'gradient': [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        },
        {
          'name': 'الذكاء الاصطناعي',
          'icon': Icons.smart_toy,
          'gradient': [Color(0xFFDC2626), Color(0xFFB91C1C)],
        },
        {
          'name': 'أمن المعلومات',
          'icon': Icons.security,
          'gradient': [Color(0xFF059669), Color(0xFF047857)],
        },
        {
          'name': 'علم البيانات',
          'icon': Icons.analytics,
          'gradient': [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        },
        {
          'name': 'البلوك تشين',
          'icon': Icons.account_balance_wallet,
          'gradient': [Color(0xFFEA580C), Color(0xFFC2410C)],
        },
      ],
    },
    {
      'sectionName': 'التصميم والإبداع',
      'categories': [
        {
          'name': 'تصميم الجرافيك',
          'icon': Icons.palette,
          'gradient': [Color(0xFFDB2777), Color(0xFFBE185D)],
        },
        {
          'name': 'التصميم الداخلي',
          'icon': Icons.architecture,
          'gradient': [Color(0xFFEA580C), Color(0xFFC2410C)],
        },
        {
          'name': 'التصوير الفوتوغرافي',
          'icon': Icons.camera_alt,
          'gradient': [Color(0xFF059669), Color(0xFF047857)],
        },
        {
          'name': 'الرسم الرقمي',
          'icon': Icons.brush,
          'gradient': [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        },
        {
          'name': 'التصميم الجرافيكي',
          'icon': Icons.graphic_eq,
          'gradient': [Color(0xFFDC2626), Color(0xFFB91C1C)],
        },
      ],
    },
    {
      'sectionName': 'الأعمال والمالية',
      'categories': [
        {
          'name': 'إدارة الأعمال',
          'icon': Icons.business_center,
          'gradient': [Color(0xFF059669), Color(0xFF047857)],
        },
        {
          'name': 'التسويق الرقمي',
          'icon': Icons.trending_up,
          'gradient': [Color(0xFFEA580C), Color(0xFFC2410C)],
        },
        {
          'name': 'المحاسبة',
          'icon': Icons.calculate,
          'gradient': [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        },
        {
          'name': 'الاستثمار',
          'icon': Icons.attach_money,
          'gradient': [Color(0xFFDB2777), Color(0xFFBE185D)],
        },
        {
          'name': 'ريادة الأعمال',
          'icon': Icons.rocket_launch,
          'gradient': [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        },
      ],
    },
    {
      'sectionName': 'اللغات والتعليم',
      'categories': [
        {
          'name': 'اللغة الإنجليزية',
          'icon': Icons.language,
          'gradient': [Color(0xFFDC2626), Color(0xFFB91C1C)],
        },
        {
          'name': 'اللغة العربية',
          'icon': Icons.menu_book,
          'gradient': [Color(0xFF059669), Color(0xFF047857)],
        },
        {
          'name': 'التعليم الإلكتروني',
          'icon': Icons.school,
          'gradient': [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        },
        {
          'name': 'التدريس',
          'icon': Icons.psychology,
          'gradient': [Color(0xFFEA580C), Color(0xFFC2410C)],
        },
      ],
    },
    {
      'sectionName': 'الصحة واللياقة',
      'categories': [
        {
          'name': 'اللياقة البدنية',
          'icon': Icons.fitness_center,
          'gradient': [Color(0xFFDB2777), Color(0xFFBE185D)],
        },
        {
          'name': 'التغذية',
          'icon': Icons.restaurant,
          'gradient': [Color(0xFF059669), Color(0xFF047857)],
        },
        {
          'name': 'الصحة النفسية',
          'icon': Icons.psychology,
          'gradient': [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        },
        {
          'name': 'الطب البديل',
          'icon': Icons.medical_services,
          'gradient': [Color(0xFFDC2626), Color(0xFFB91C1C)],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _categorySections.length,
            itemBuilder: (context, sectionIndex) {
              final section = _categorySections[sectionIndex];
              return _buildSection(section, context, isDarkMode);
            },
          ),
        );
      },
=======
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'جميع الأقسام',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categorySections.length,
        itemBuilder: (context, sectionIndex) {
          final section = _categorySections[sectionIndex];
          return _buildSection(section, context);
        },
      ),
>>>>>>> 9733b3b7817e2ac38d39d4067b5efb503841f1f1
    );
  }

  Widget _buildSection(Map<String, dynamic> section, BuildContext context, bool isDarkMode) {
    final categories = section['categories'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Text(
            section['sectionName'],
            style: GoogleFonts.tajawal(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ),

        // Categories Grid for this section
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCube(category, context);
          },
        ),

        // Section separator
        if (section != _categorySections.last) const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryCube(
    Map<String, dynamic> category,
    BuildContext context,
  ) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
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
                0.4,
              ),
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
                builder: (_) => CategoryDetailPage(category: category),
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
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
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
