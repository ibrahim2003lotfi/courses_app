import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendedCoursesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recommended;

  const RecommendedCoursesWidget({super.key, required this.recommended});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(bottom: 16)),
              ...recommended.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: GoogleFonts.tajawal(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
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
                                                color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
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
                                    style: Theme.of(context).textTheme.bodyMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                        ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.people_outline,
                                    size: 16,
                                    color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${item['students']} طالب',
                                      style: Theme.of(context).textTheme.bodyMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
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
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: Text(
                                    'التفاصيل',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
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
                                        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['teacher'],
                                      style: Theme.of(context).textTheme.bodyMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
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
                                                color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                              ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.people_outline,
                                          size: 16,
                                          color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item['students']} طالب',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text(
                                  'التفاصيل',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
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