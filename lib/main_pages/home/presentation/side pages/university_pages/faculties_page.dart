import 'package:courses_app/main_pages/home/presentation/side%20pages/university_pages/lectures_page.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FacultiesPage extends StatelessWidget {
  final String universityName;

  const FacultiesPage({super.key, required this.universityName});

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
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDarkMode ? Colors.white : const Color(0xFF10B981),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981).withOpacity(isDarkMode ? 0.2 : 0.1),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title
                        Expanded(
                          child: Text(
                            'كليات $universityName',
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

              // Faculties List
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, index == 0 ? 20 : 0, 20, 16),
                    child: FacultyListItem(
                      faculty: facultiesList[index],
                      universityName: universityName,
                    ),
                  );
                }, childCount: facultiesList.length),
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

class FacultyListItem extends StatelessWidget {
  final String faculty;
  final String universityName;

  const FacultyListItem({
    super.key,
    required this.faculty,
    required this.universityName,
  });

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
                _showFacultyDetails(context, faculty, isDarkMode);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Faculty Icon (Bigger size)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getFacultyColor(faculty).withOpacity(isDarkMode ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: isDarkMode ? Border.all(color: _getFacultyColor(faculty).withOpacity(0.4)) : null,
                      ),
                      child: Icon(
                        _getFacultyIcon(faculty),
                        size: 40,
                        color: _getFacultyColor(faculty),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Faculty Info and button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Faculty Name
                          Text(
                            faculty,
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Faculty Info
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              // University Name
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 14,
                                    color: isDarkMode ? Colors.white70 : const Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    universityName,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),

                              // Faculty Type
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getFacultyColor(faculty).withOpacity(isDarkMode ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getFacultyColor(faculty).withOpacity(isDarkMode ? 0.4 : 0.3),
                                  ),
                                ),
                                child: Text(
                                  _getFacultyType(faculty),
                                  style: GoogleFonts.tajawal(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _getFacultyColor(faculty),
                                  ),
                                ),
                              ),

                              // Students Count (Example)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 14,
                                    color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_getRandomStudentCount()} طالب',
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

                          // Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LecturesPage(
                                      facultyName: faculty,
                                      universityName: universityName,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'عرض المحاضرات',
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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

  IconData _getFacultyIcon(String faculty) {
    if (faculty.contains('طب')) return Icons.medical_services;
    if (faculty.contains('صيدلة')) return Icons.medication;
    if (faculty.contains('هندسة')) return Icons.engineering;
    if (faculty.contains('اقتصاد')) return Icons.attach_money;
    if (faculty.contains('فنون')) return Icons.palette;
    return Icons.school;
  }

  Color _getFacultyColor(String faculty) {
    if (faculty.contains('طب')) return const Color(0xFFEF4444);
    if (faculty.contains('صيدلة')) return const Color(0xFF8B5CF6);
    if (faculty.contains('هندسة')) return const Color(0xFFF59E0B);
    if (faculty.contains('اقتصاد')) return const Color(0xFF10B981);
    if (faculty.contains('فنون')) return const Color(0xFFEC4899);
    return const Color(0xFF6B7280);
  }

  String _getFacultyType(String faculty) {
    if (faculty.contains('هندسة')) return 'هندسية';
    if (faculty.contains('طب') || faculty.contains('صيدلة')) return 'طبية';
    if (faculty.contains('اقتصاد')) return 'إدارية';
    if (faculty.contains('فنون')) return 'فنية';
    return 'أكاديمية';
  }

  int _getRandomStudentCount() {
    return 500 + (faculty.hashCode % 2000);
  }

  void _showFacultyDetails(BuildContext context, String faculty, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FacultyDetailsSheet(
        faculty: faculty, 
        universityName: universityName,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class FacultyDetailsSheet extends StatelessWidget {
  final String faculty;
  final String universityName;
  final bool isDarkMode;

  const FacultyDetailsSheet({
    super.key,
    required this.faculty,
    required this.universityName,
    required this.isDarkMode,
  });

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

          // Faculty header
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getFacultyColor(faculty).withOpacity(isDarkMode ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isDarkMode ? Border.all(color: _getFacultyColor(faculty).withOpacity(0.4)) : null,
                ),
                child: Icon(
                  _getFacultyIcon(faculty),
                  size: 40,
                  color: _getFacultyColor(faculty),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty,
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      universityName,
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

          // Faculty info
          _buildInfoRow('نوع الكلية', _getFacultyType(faculty), isDarkMode),
          _buildInfoRow('عدد الطلاب', '${_getRandomStudentCount()} طالب', isDarkMode),
          _buildInfoRow('التخصص', _getFacultySpecialization(faculty), isDarkMode),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LecturesPage(
                          facultyName: faculty,
                          universityName: universityName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'عرض المحاضرات',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                    side: BorderSide(
                      color: isDarkMode ? Colors.white30 : const Color(0xFFD1D5DB),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
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

  IconData _getFacultyIcon(String faculty) {
    if (faculty.contains('طب')) return Icons.medical_services;
    if (faculty.contains('صيدلة')) return Icons.medication;
    if (faculty.contains('هندسة')) return Icons.engineering;
    if (faculty.contains('اقتصاد')) return Icons.attach_money;
    if (faculty.contains('فنون')) return Icons.palette;
    return Icons.school;
  }

  Color _getFacultyColor(String faculty) {
    if (faculty.contains('طب')) return const Color(0xFFEF4444);
    if (faculty.contains('صيدلة')) return const Color(0xFF8B5CF6);
    if (faculty.contains('هندسة')) return const Color(0xFFF59E0B);
    if (faculty.contains('اقتصاد')) return const Color(0xFF10B981);
    if (faculty.contains('فنون')) return const Color(0xFFEC4899);
    return const Color(0xFF6B7280);
  }

  String _getFacultyType(String faculty) {
    if (faculty.contains('هندسة')) return 'هندسية';
    if (faculty.contains('طب') || faculty.contains('صيدلة')) return 'طبية';
    if (faculty.contains('اقتصاد')) return 'إدارية';
    if (faculty.contains('فنون')) return 'فنية';
    return 'أكاديمية';
  }

  String _getFacultySpecialization(String faculty) {
    if (faculty.contains('طب البشري')) return 'العلوم الطبية البشرية';
    if (faculty.contains('طب الاسنان')) return 'طب الأسنان والجراحة';
    if (faculty.contains('صيدلة')) return 'العلوم الصيدلانية';
    if (faculty.contains('هندسة معلوماتية')) return 'تكنولوجيا المعلومات';
    if (faculty.contains('هندسة مدنية')) return 'الهندسة المدنية والإنشائية';
    if (faculty.contains('هندسة معمارية')) return 'التصميم المعماري';
    if (faculty.contains('اقتصاد')) return 'العلوم الاقتصادية والإدارية';
    if (faculty.contains('فنون')) return 'الفنون والتصميم';
    return 'متعددة التخصصات';
  }

  int _getRandomStudentCount() {
    return 500 + (faculty.hashCode % 2000);
  }
}

// Faculties data list
List<String> facultiesList = [
  'كلية الطب البشري',
  'كلية طب الاسنان',
  'كلية الصيدلة',
  'كلية الهندسة المعلوماتية',
  'كلية الهندسة المدنية',
  'كلية الهندسة المعمارية',
  'كلية الاقتصاد و ادارة الاعمال',
  'كلية الفنون والتصميم',
];