// courses_page.dart
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/main_pages/home/presentation/widgets/home_page_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data for different tabs
  final List<Map<String, dynamic>> subscribedCourses = [
    {
      'id': '1',
      'title': 'دورة Flutter المتقدمة - بناء تطبيقات احترافية',
      'image': 'https://picsum.photos/seed/flutter1/400/300',
      'teacher': 'أحمد محمد',
      'category': 'برمجة',
      'rating': 4.8,
      'reviews': 1247,
      'students': '10,258',
      'duration': 28,
      'lessons': 45,
      'level': 'متقدم',
      'lastUpdated': 'ديسمبر 2024',
      'price': '₪299',
      'progress': 0.65,
      'description':
          'هذه الدورة الشاملة تغطي جميع جوانب تطوير تطبيقات Flutter بشكل احترافي.',
      'tags': ['Flutter', 'Dart', 'Mobile', 'Firebase', 'API'],
      'instructorImage': 'https://picsum.photos/seed/instructor1/200/200',
    },
    {
      'id': '2',
      'title': 'تعلم React Native من الصفر',
      'image': 'https://picsum.photos/seed/react/400/300',
      'teacher': 'سارة أحمد',
      'category': 'برمجة',
      'rating': 4.6,
      'reviews': 892,
      'students': '7,543',
      'duration': 22,
      'lessons': 38,
      'level': 'مبتدئ',
      'lastUpdated': 'نوفمبر 2024',
      'price': '₪199',
      'progress': 0.32,
      'description': 'تعلم تطوير تطبيقات الهاتف المحمول باستخدام React Native.',
      'tags': ['React Native', 'JavaScript', 'Mobile'],
      'instructorImage': 'https://picsum.photos/seed/instructor2/200/200',
    },
    {
      'id': '3',
      'title': 'UI/UX Design للمبتدئين',
      'image': 'https://picsum.photos/seed/design1/400/300',
      'teacher': 'محمد علي',
      'category': 'تصميم',
      'rating': 4.9,
      'reviews': 1543,
      'students': '12,847',
      'duration': 18,
      'lessons': 32,
      'level': 'مبتدئ',
      'lastUpdated': 'يناير 2025',
      'price': '₪149',
      'progress': 0.78,
      'description': 'تعلم أساسيات تصميم واجهات المستخدم وتجربة المستخدم.',
      'tags': ['UI', 'UX', 'Design', 'Figma'],
      'instructorImage': 'https://picsum.photos/seed/instructor3/200/200',
    },
  ];

  final List<Map<String, dynamic>> favoriteCourses = [
    {
      'id': '4',
      'title': 'التسويق الرقمي الشامل',
      'image': 'https://picsum.photos/seed/marketing/400/300',
      'teacher': 'فاطمة حسن',
      'category': 'تسويق',
      'rating': 4.7,
      'reviews': 756,
      'students': '5,432',
      'duration': 15,
      'lessons': 28,
      'level': 'متوسط',
      'lastUpdated': 'ديسمبر 2024',
      'price': '₪179',
      'description':
          'دورة شاملة في التسويق الرقمي وإدارة وسائل التواصل الاجتماعي.',
      'tags': ['Marketing', 'Social Media', 'SEO'],
      'instructorImage': 'https://picsum.photos/seed/instructor4/200/200',
    },
    {
      'id': '1',
      'title': 'دورة Flutter المتقدمة - بناء تطبيقات احترافية',
      'image': 'https://picsum.photos/seed/flutter1/400/300',
      'teacher': 'أحمد محمد',
      'category': 'برمجة',
      'rating': 4.8,
      'reviews': 1247,
      'students': '10,258',
      'duration': 28,
      'lessons': 45,
      'level': 'متقدم',
      'lastUpdated': 'ديسمبر 2024',
      'price': '₪299',
      'description':
          'هذه الدورة الشاملة تغطي جميع جوانب تطوير تطبيقات Flutter بشكل احترافي.',
      'tags': ['Flutter', 'Dart', 'Mobile', 'Firebase', 'API'],
      'instructorImage': 'https://picsum.photos/seed/instructor1/200/200',
    },
  ];

  final List<Map<String, dynamic>> watchLaterCourses = [
    {
      'id': '5',
      'title': 'إدارة المشاريع الاحترافية',
      'image': 'https://picsum.photos/seed/project/400/300',
      'teacher': 'خالد محمود',
      'category': 'إدارة',
      'rating': 4.5,
      'reviews': 432,
      'students': '3,210',
      'duration': 12,
      'lessons': 24,
      'level': 'متوسط',
      'lastUpdated': 'نوفمبر 2024',
      'price': '₪129',
      'description': 'تعلم أساسيات إدارة المشاريع وأدوات التخطيط والتنظيم.',
      'tags': ['Project Management', 'Planning', 'Leadership'],
      'instructorImage': 'https://picsum.photos/seed/instructor5/200/200',
    },
    {
      'id': '6',
      'title': 'تطوير مواقع الويب بـ HTML & CSS',
      'image': 'https://picsum.photos/seed/web/400/300',
      'teacher': 'مريم أحمد',
      'category': 'برمجة',
      'rating': 4.4,
      'reviews': 698,
      'students': '8,765',
      'duration': 20,
      'lessons': 35,
      'level': 'مبتدئ',
      'lastUpdated': 'أكتوبر 2024',
      'price': 'مجاني',
      'description': 'تعلم أساسيات تطوير مواقع الويب باستخدام HTML و CSS.',
      'tags': ['HTML', 'CSS', 'Web Development'],
      'instructorImage': 'https://picsum.photos/seed/instructor6/200/200',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to get responsive font size
  double _getResponsiveFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 600) {
      // Tablet
      return 26;
    } else if (width > 400) {
      // Large phone
      return 22;
    } else {
      // Small phone
      return 18;
    }
  }

  // Helper method to get responsive small font size
  double _getResponsiveSmallFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 18;
    } else if (width > 400) {
      return 16;
    } else {
      return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseFontSize = _getResponsiveFontSize(context);
    final smallFontSize = _getResponsiveSmallFontSize(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // TopSearchBar widget
            const TopSearchBar(),

            // Custom AppBar with Tabs - without nested Scaffold
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    
                  ),

                  // TabBar
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.school),
                        child: Text(
                          'المشتركة',
                          style: GoogleFonts.tajawal(
                            fontSize: smallFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Tab(
                        icon: const Icon(Icons.favorite),
                        child: Text(
                          'المفضلة',
                          style: GoogleFonts.tajawal(
                            fontSize: smallFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Tab(
                        icon: const Icon(Icons.watch_later),
                        child: Text(
                          'لاحقاً',
                          style: GoogleFonts.tajawal(
                            fontSize: smallFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3,
                  ),
                ],
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  CoursesListView(
                    courses: subscribedCourses,
                    showProgress: true,
                    emptyMessage: 'لم تشترك في أي دورة بعد',
                    emptyDescription:
                        'ابدأ رحلتك التعليمية واشترك في دورة جديدة!',
                    emptyIcon: Icons.school_outlined,
                    baseFontSize: baseFontSize,
                    smallFontSize: smallFontSize,
                  ),
                  CoursesListView(
                    courses: favoriteCourses,
                    showProgress: false,
                    emptyMessage: 'لا توجد دورات مفضلة',
                    emptyDescription: 'أضف دوراتك المفضلة لتجدها هنا بسهولة!',
                    emptyIcon: Icons.favorite_outline,
                    baseFontSize: baseFontSize,
                    smallFontSize: smallFontSize,
                  ),
                  CoursesListView(
                    courses: watchLaterCourses,
                    showProgress: false,
                    emptyMessage: 'لا توجد دورات محفوظة',
                    emptyDescription: 'احفظ الدورات التي تود مشاهدتها لاحقاً!',
                    emptyIcon: Icons.watch_later_outlined,
                    baseFontSize: baseFontSize,
                    smallFontSize: smallFontSize,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... Rest of the code remains the same (CoursesListView, CourseCard, EmptyState classes)

class CoursesListView extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final bool showProgress;
  final String emptyMessage;
  final String emptyDescription;
  final IconData emptyIcon;
  final double baseFontSize;
  final double smallFontSize;

  const CoursesListView({
    super.key,
    required this.courses,
    required this.showProgress,
    required this.emptyMessage,
    required this.emptyDescription,
    required this.emptyIcon,
    required this.baseFontSize,
    required this.smallFontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        message: emptyMessage,
        description: emptyDescription,
        baseFontSize: baseFontSize,
        smallFontSize: smallFontSize,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return CourseCard(
                  course: courses[index],
                  showProgress: showProgress,
                  isGridView: true,
                  baseFontSize: baseFontSize,
                  smallFontSize: smallFontSize,
                );
              },
            ),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CourseCard(
                  course: courses[index],
                  showProgress: showProgress,
                  isGridView: false,
                  baseFontSize: baseFontSize,
                  smallFontSize: smallFontSize,
                ),
              );
            },
          );
        }
      },
    );
  }
}

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final bool showProgress;
  final bool isGridView;
  final double baseFontSize;
  final double smallFontSize;

  const CourseCard({
    super.key,
    required this.course,
    required this.showProgress,
    required this.isGridView,
    required this.baseFontSize,
    required this.smallFontSize,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.course['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف "${widget.course['title']}" من القائمة',
              style: GoogleFonts.tajawal(
                fontSize: widget.smallFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {
                // Implement undo functionality
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(course: widget.course),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.isGridView ? _buildGridLayout() : _buildListLayout(),
        ),
      ),
    );
  }

  Widget _buildGridLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              widget.course['image'],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course['title'],
                  style: GoogleFonts.tajawal(
                    fontSize: widget.baseFontSize * 0.7,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.course['teacher'],
                  style: GoogleFonts.tajawal(
                    fontSize: widget.smallFontSize * 0.8,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (widget.showProgress && widget.course['progress'] != null)
                  _buildProgressIndicator(),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.course['image'],
              width: 120,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course['title'],
                  style: GoogleFonts.tajawal(
                    fontSize: widget.baseFontSize * 0.8,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.course['teacher'],
                  style: GoogleFonts.tajawal(
                    fontSize: widget.smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.course['rating'].toString(),
                      style: GoogleFonts.tajawal(
                        fontSize: widget.smallFontSize * 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.course['students'],
                      style: GoogleFonts.tajawal(
                        fontSize: widget.smallFontSize * 0.8,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (widget.showProgress &&
                    widget.course['progress'] != null) ...[
                  const SizedBox(height: 8),
                  _buildProgressIndicator(),
                ],
                const SizedBox(height: 8),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = widget.course['progress'] ?? 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقدم',
              style: GoogleFonts.tajawal(
                fontSize: widget.smallFontSize * 0.8,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.tajawal(
                fontSize: widget.smallFontSize * 0.8,
                fontWeight: FontWeight.w900,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Handle play action
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: Text(
              'تشغيل',
              style: GoogleFonts.tajawal(
                fontSize: widget.smallFontSize * 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String description;
  final double baseFontSize;
  final double smallFontSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.description,
    required this.baseFontSize,
    required this.smallFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.tajawal(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.tajawal(
                fontSize: smallFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to explore courses
              },
              icon: const Icon(Icons.explore),
              label: Text(
                'استكشف الدورات',
                style: GoogleFonts.tajawal(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for TopSearchBar widget - replace with your actual implementation
