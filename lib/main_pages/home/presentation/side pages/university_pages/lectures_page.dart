
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LecturesPage extends StatelessWidget {
  final String facultyName;
  final String universityName;

  const LecturesPage({
    super.key,
    required this.facultyName,
    required this.universityName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // Page Header with Back Button
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF10B981),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF10B981,
                        ).withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مواد $facultyName',
                            style: GoogleFonts.tajawal(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            universityName,
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
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

          // Search Bar
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: LecSearchField(),
            ),
          ),

          // Lectures List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20, index == 0 ? 0 : 0, 20, 16),
                child: LectureListItem(
                  lectureNumber: index + 1,
                  facultyName: facultyName,
                ),
              );
            }, childCount: 8), // Display 8 lectures
          ),

          // Show All Lectures Button

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class LectureListItem extends StatelessWidget {
  final int lectureNumber;
  final String facultyName;

  const LectureListItem({
    super.key,
    required this.lectureNumber,
    required this.facultyName,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showLectureDetails(context, lectureNumber);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Lecture Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_circle_filled,
                    size: 32,
                    color: Color(0xFF10B981),
                  ),
                ),

                const SizedBox(width: 12),

                // Lecture Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lecture Title
                      Text(
                        'مادة $lectureNumber',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Lecture Description
                      Text(
                        _getLectureDescription(lectureNumber, facultyName),
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Lecture Metadata
                      Row(
                        children: [
                          // Duration
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_getLectureDuration(lectureNumber)} دقيقة',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 16),

                          // Date
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getLectureDate(lectureNumber),
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Play Button
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLectureDescription(int lectureNumber, String facultyName) {
    final descriptions = {
      1: 'مقدمة في المواد الأساسية والتخصصية للفصل الدراسي الأول',
      2: 'الأسس النظرية والتطبيقية للمادة مع أمثلة عملية',
      3: 'التطبيقات العملية والتمارين التفاعلية',
      4: 'مراجعة شاملة وتحضير للاختبارات',
      5: 'مشاريع عملية وتطبيقات حقيقية',
      6: 'حلول ونماذج الاختبارات السابقة',
      7: 'ورشة عمل تفاعلية مع المحاضر',
      8: 'ملخص شامل للمادة قبل الاختبار النهائي',
    };
    return descriptions[lectureNumber] ?? 'محاضرة في $facultyName';
  }

  int _getLectureDuration(int lectureNumber) {
    return 45 + (lectureNumber * 5); // 50, 55, 60, etc.
  }

  String _getLectureDate(int lectureNumber) {
    final dates = [
      '2024-01-15',
      '2024-01-22',
      '2024-01-29',
      '2024-02-05',
      '2024-02-12',
      '2024-02-19',
      '2024-02-26',
      '2024-03-04',
    ];
    return dates[lectureNumber - 1];
  }

  void _showLectureDetails(BuildContext context, int lectureNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LectureDetailsSheet(
        lectureNumber: lectureNumber,
        facultyName: facultyName,
      ),
    );
  }
}

class LectureDetailsSheet extends StatelessWidget {
  final int lectureNumber;
  final String facultyName;

  const LectureDetailsSheet({
    super.key,
    required this.lectureNumber,
    required this.facultyName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Lecture header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  size: 32,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مادة $lectureNumber',
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      facultyName,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lecture info
          _buildInfoRow('المدة', '${_getLectureDuration(lectureNumber)} دقيقة'),
          _buildInfoRow('التاريخ', _getFormattedDate(lectureNumber)),
          _buildInfoRow('الحالة', 'متاحة'),
          _buildInfoRow('النوع', 'فيديو'),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _playLecture(context);
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
                    'الانتقال الى المحاضرات ',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
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

  Widget _buildInfoRow(String label, String value) {
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
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  int _getLectureDuration(int lectureNumber) {
    return 45 + (lectureNumber * 5);
  }

  String _getFormattedDate(int lectureNumber) {
    final dates = [
      '15 يناير 2024',
      '22 يناير 2024',
      '29 يناير 2024',
      '5 فبراير 2024',
      '12 فبراير 2024',
      '19 فبراير 2024',
      '26 فبراير 2024',
      '4 مارس 2024',
    ];
    return dates[lectureNumber - 1];
  }

  void _playLecture(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الانتقال اللى مادة  $lectureNumber'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}

class LecSearchField extends StatefulWidget {
  const LecSearchField({super.key});

  @override
  State<LecSearchField>  createState() => _LecSearchFieldState();
}

class _LecSearchFieldState extends State<LecSearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: _controller,
          style: GoogleFonts.tajawal(
            fontWeight: _hasText
                ? FontWeight.w700
                : FontWeight.w500, // Bolder when text exists
            fontSize: 16,
            color: const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن الكورسات, المحاضرات, و الدروس',
            hintStyle: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w500, // Normal weight for hint
              color: const Color(0xFF6B7280),
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
