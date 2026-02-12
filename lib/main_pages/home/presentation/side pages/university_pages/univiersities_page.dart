import 'package:courses_app/main_pages/home/presentation/side%20pages/university_pages/faculties_page.dart';
import 'package:courses_app/presentation/widgets/course_image_widget.dart';
import 'package:courses_app/presentation/widgets/skeleton_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../bloc/university_bloc.dart';

class UniversitiesPage extends StatelessWidget {
  const UniversitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UniversityBloc()..add(LoadUniversitiesEvent()),
      child: const _UniversitiesPageBody(),
    );
  }
}

class _UniversitiesPageBody extends StatelessWidget {
  const _UniversitiesPageBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF9FAFB),
          body: BlocBuilder<UniversityBloc, UniversityState>(
            builder: (context, uniState) {
              final universities = uniState.universities;

              if (uniState.isLoading) {
                return SkeletonList(
                  itemCount: 6,
                  isDarkMode: isDarkMode,
                  padding: const EdgeInsets.all(16),
                );
              }

              return CustomScrollView(
                slivers: [
                  // Page Header with Back Button
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDarkMode ? 0.2 : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            // Back Button
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
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
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (uniState.isLoading)
                    SliverToBoxAdapter(
                      child: SkeletonList(
                        itemCount: 5,
                        isDarkMode: isDarkMode,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      ),
                    )
                  else if (uniState.error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'حدث خطأ: ${uniState.error}',
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (universities.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 48,
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد جامعات',
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Universities List from backend only
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final uni = universities[index] as Map<String, dynamic>;
                        final mappedUniversity = {
                          'id': (uni['id'] ?? '').toString(),
                          'name': (uni['name'] ?? '').toString(),
                          'city': (uni['city'] ?? '').toString(),
                          'type': (uni['type'] ?? 'حكومية').toString(),
                          'faculties': uni['faculties_count'] ?? 'غير معروف',
                          'image':
                              (uni['logo_url'] ??
                                      'https://via.placeholder.com/200x200/4B5563/FFFFFF?text=University')
                                  .toString(),
                        };

                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            index == 0 ? 20 : 0,
                            20,
                            16,
                          ),
                          child: UniversityListItem(
                            university: mappedUniversity,
                          ),
                        );
                      }, childCount: universities.length),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              );
            },
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
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 400,
            ), // Prevent overflow
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
                      child: CourseImageWidget(
                        imageUrl: university['image']?.toString(),
                        width: 80,
                        height: 80,
                        borderRadius: BorderRadius.zero,
                        placeholderIcon: Icons.account_balance,
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
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // University Info (Location, Type, Faculties)
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Location
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFFEF4444),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        university['city'],
                                        style: GoogleFonts.tajawal(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : const Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                  constraints: const BoxConstraints(
                                    maxWidth: 80,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(
                                      university['type'],
                                    ).withOpacity(isDarkMode ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _getTypeColor(
                                        university['type'],
                                      ).withOpacity(isDarkMode ? 0.4 : 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    university['type'],
                                    style: GoogleFonts.tajawal(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _getTypeColor(university['type']),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                // Faculties Count
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 14,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${university['faculties']} كلية',
                                        style: GoogleFonts.tajawal(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : const Color(0xFF6B7280),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Button as Container with InkWell
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
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
                                      universityId: university['id'] ?? '',
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
      builder: (context) => UniversityDetailsSheet(
        university: university,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class UniversityDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> university;
  final bool isDarkMode;

  const UniversityDetailsSheet({
    super.key,
    required this.university,
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

          // University header
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CourseImageWidget(
                  imageUrl: university['image']?.toString(),
                  width: 80,
                  height: 80,
                  borderRadius: BorderRadius.zero,
                  placeholderIcon: Icons.account_balance,
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
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      university['city'],
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFF6B7280),
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
          _buildInfoRow(
            'عدد الكليات',
            '${university['faculties']} كلية',
            isDarkMode,
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
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
                          builder: (context) => FacultiesPage(
                            universityName: university['name'],
                            universityId: university['id'],
                          ),
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
                      color: isDarkMode
                          ? Colors.white30
                          : const Color(0xFFD1D5DB),
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
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF6B7280),
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
