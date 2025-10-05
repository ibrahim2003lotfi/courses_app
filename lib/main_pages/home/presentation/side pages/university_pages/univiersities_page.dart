import 'package:courses_app/main_pages/home/presentation/side%20pages/university_pages/faculties_page.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class UniversitiesPage extends StatelessWidget {
  const UniversitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
          body: CustomScrollView(
            slivers: [
              // Page Header with Back Button
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        // Back Button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF667EEA),
                                Color(0xFF764BA2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title
                        Expanded(
                          child: Text(
                            'الجامعات السورية',
                            style: GoogleFonts.tajawal(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Universities List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, index == 0 ? 20 : 0, 20, 16),
                    child: UniversityListItem(
                      university: syrianUniversities[index],
                    ),
                  );
                }, childCount: syrianUniversities.length),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}

class UniversityListItem extends StatelessWidget {
  final Map<String, dynamic> university;

  const UniversityListItem({super.key, required this.university});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: isDarkMode ? Border.all(color: Colors.white30) : null,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _showUniversityDetails(context, university, isDarkMode);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // University Image (Bigger size)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        university['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 80,
                            height: 80,
                            color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode ? Colors.white70 : const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // University Info (Name, details, and button)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // University Name
                          Text(
                            university['name'],
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // University Info (Location, Type, Faculties)
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              // Location
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: isDarkMode ? Colors.white70 : const Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    university['city'],
                                    style: GoogleFonts.tajawal(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),

                              // University Type
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(university['type']).withOpacity(isDarkMode ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getTypeColor(university['type']).withOpacity(isDarkMode ? 0.4 : 0.3),
                                  ),
                                ),
                                child: Text(
                                  university['type'],
                                  style: GoogleFonts.tajawal(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _getTypeColor(university['type']),
                                  ),
                                ),
                              ),

                              // Faculties Count
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 14,
                                    color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${university['faculties']} كلية',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Button as Container with InkWell
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF667EEA),
                                  Color(0xFF764BA2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FacultiesPage(
                                      universityName: university['name'],
                                    ),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  'عرض الكليات',
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'حكومية':
        return const Color(0xFF10B981);
      case 'خاصة':
        return const Color(0xFFF59E0B);
      case 'افتراضية':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _showUniversityDetails(
    BuildContext context,
    Map<String, dynamic> university,
    bool isDarkMode,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UniversityDetailsSheet(university: university, isDarkMode: isDarkMode),
    );
  }
}

class UniversityDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> university;
  final bool isDarkMode;

  const UniversityDetailsSheet({super.key, required this.university, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // University header
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  university['image'],
                  width: 80,
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
                      university['name'],
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      university['city'],
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // University info
          _buildInfoRow('نوع الجامعة', university['type'], isDarkMode),
          _buildInfoRow('عدد الكليات', '${university['faculties']} كلية', isDarkMode),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF667EEA),
                        Color(0xFF764BA2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FacultiesPage(universityName: university['name']),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        'عرض الاكليات',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? Colors.white30 : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'إلغاء',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// Syrian universities data
List<Map<String, dynamic>> syrianUniversities = [
  {
    'name': 'جامعة دمشق',
    'city': 'دمشق',
    'type': 'حكومية',
    'faculties': 23,
    'established': '1923',
    'image': 'https://picsum.photos/seed/damascusuni/300/200',
  },
  {
    'name': 'جامعة حلب',
    'city': 'حلب',
    'type': 'حكومية',
    'faculties': 25,
    'established': '1958',
    'image': 'https://picsum.photos/seed/aleppouni/300/200',
  },
  {
    'name': 'جامعة تشرين',
    'city': 'اللاذقية',
    'type': 'حكومية',
    'faculties': 18,
    'established': '1971',
    'image': 'https://picsum.photos/seed/tishreenuni/300/200',
  },
  {
    'name': 'جامعة البعث',
    'city': 'حمص',
    'type': 'حكومية',
    'faculties': 15,
    'established': '1979',
    'image': 'https://picsum.photos/seed/baathuni/300/200',
  },
  {
    'name': 'الجامعة الافتراضية السورية',
    'city': 'دمشق',
    'type': 'افتراضية',
    'faculties': 8,
    'established': '2002',
    'image': 'https://picsum.photos/seed/svu/300/200',
  },
  {
    'name': 'جامعة الوادي الدولية',
    'city': 'دمشق',
    'type': 'خاصة',
    'faculties': 12,
    'established': '2005',
    'image': 'https://picsum.photos/seed/wadiuni/300/200',
  },
  {
    'name': 'جامعة القلمون',
    'city': 'دمشق',
    'type': 'خاصة',
    'faculties': 10,
    'established': '2003',
    'image': 'https://picsum.photos/seed/qalamoununi/300/200',
  },
  {
    'name': 'جامعة الاتحاد',
    'city': 'حلب',
    'type': 'خاصة',
    'faculties': 9,
    'established': '2005',
    'image': 'https://picsum.photos/seed/ittehaduni/300/200',
  },
];