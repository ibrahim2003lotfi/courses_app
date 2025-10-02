import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/main_pages/home/presentation/widgets/home_page_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:courses_app/bloc/user_role_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// New Published Courses Tab Widget
class PublishedCoursesTab extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final BuildContext parentContext; // Add this

  const PublishedCoursesTab({
    super.key,
    required this.courses,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    required this.parentContext, // Add this
  });

  @override
  State<PublishedCoursesTab> createState() => _PublishedCoursesTabState();
}

class _PublishedCoursesTabState extends State<PublishedCoursesTab> {
  @override
  Widget build(BuildContext context) {
    // Use widget.parentContext for dialogs and navigation
    final themeData = widget.isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Column(
      children: [
        // Add New Course Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddCourseDialog(widget.parentContext),
            icon: const Icon(Icons.add),
            label: Text(
              'إضافة دورة جديدة',
              style: GoogleFonts.tajawal(
                fontSize: widget.baseFontSize * 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeData.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),

        // Courses List
        Expanded(
          child: widget.courses.isEmpty
              ? EmptyState(
                  icon: Icons.publish_outlined,
                  message: 'لا توجد دورات منشورة',
                  description: 'انقر على زر "إضافة دورة جديدة" لبدء النشر',
                  baseFontSize: widget.baseFontSize,
                  smallFontSize: widget.smallFontSize,
                  isDarkMode: widget.isDarkMode,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth > 600;

                    if (isTablet) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: widget.courses.length,
                          itemBuilder: (context, index) {
                            return PublishedCourseCard(
                              course: widget.courses[index],
                              isGridView: true,
                              baseFontSize: widget.baseFontSize,
                              smallFontSize: widget.smallFontSize,
                              isDarkMode: widget.isDarkMode,
                              onTap: () => _showCourseOptionsBottomSheet(
                                widget.parentContext,
                                widget.courses[index],
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: widget.courses.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: PublishedCourseCard(
                              course: widget.courses[index],
                              isGridView: false,
                              baseFontSize: widget.baseFontSize,
                              smallFontSize: widget.smallFontSize,
                              isDarkMode: widget.isDarkMode,
                              onTap: () => _showCourseOptionsBottomSheet(
                                widget.parentContext,
                                widget.courses[index],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCourseDialog(
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        onCourseAdded: (newCourse) {
          // Handle adding new course to the list
          setState(() {
            // In a real app, you would add to your data source
          });
        },
      ),
    );
  }

  void _showCourseOptionsBottomSheet(BuildContext context, Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseOptionsBottomSheet(
        course: course,
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        onEdit: () {
          Navigator.pop(context);
          _showEditCourseDialog(context, course);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmationDialog(context, course);
        },
        onView: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(course: course),
            ),
          );
        },
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AddCourseDialog(
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        courseToEdit: course,
        onCourseAdded: (editedCourse) {
          // Handle course editing
          setState(() {
            // In a real app, you would update your data source
          });
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        course: course,
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        onConfirm: () {
          Navigator.pop(context);
          // Handle course deletion
          setState(() {
            // In a real app, you would remove from your data source
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حذف "${course['title']}" بنجاح',
                style: GoogleFonts.tajawal(
                  fontSize: widget.smallFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Published Course Card Widget
class PublishedCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isGridView;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final VoidCallback onTap;

  const PublishedCourseCard({
    super.key,
    required this.course,
    required this.isGridView,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isGridView
            ? _buildGridLayout(themeData)
            : _buildListLayout(themeData),
      ),
    );
  }

  Widget _buildGridLayout(ThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Stack(
            children: [
              Image.network(
                course['image'],
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  );
                },
              ),
              // Status Badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: course['status'] == 'نشط'
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course['status'],
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.7,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Course Info
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title'],
                style: GoogleFonts.tajawal(
                  fontSize: baseFontSize * 0.7,
                  fontWeight: FontWeight.w900,
                  color: themeData.colorScheme.onBackground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                course['teacher'],
                style: GoogleFonts.tajawal(
                  fontSize: smallFontSize * 0.8,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 14,
                    color: themeData.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course['enrollments']}',
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    course['price'],
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.8,
                      fontWeight: FontWeight.w900,
                      color: themeData.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout(ThemeData themeData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Course Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course['image'],
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 80,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        size: 30,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              // Status Badge
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: course['status'] == 'نشط'
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course['status'],
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.6,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: GoogleFonts.tajawal(
                    fontSize: baseFontSize * 0.8,
                    fontWeight: FontWeight.w900,
                    color: themeData.colorScheme.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course['teacher'],
                  style: GoogleFonts.tajawal(
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 14,
                      color: themeData.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course['enrollments']} مشترك',
                      style: GoogleFonts.tajawal(
                        fontSize: smallFontSize * 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      course['price'],
                      style: GoogleFonts.tajawal(
                        fontSize: smallFontSize * 0.9,
                        fontWeight: FontWeight.w900,
                        color: themeData.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}

// Add/Edit Course Dialog
class AddCourseDialog extends StatefulWidget {
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final Map<String, dynamic>? courseToEdit;
  final Function(Map<String, dynamic>) onCourseAdded;

  const AddCourseDialog({
    super.key,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    this.courseToEdit,
    required this.onCourseAdded,
  });

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _teacherController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      _titleController.text = widget.courseToEdit!['title'];
      _teacherController.text = widget.courseToEdit!['teacher'];
      _priceController.text = widget.courseToEdit!['price'];
      _descriptionController.text = widget.courseToEdit!['description'];
      _categoryController.text = widget.courseToEdit!['category'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _teacherController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newCourse = {
        'id':
            widget.courseToEdit?['id'] ??
            'p${DateTime.now().millisecondsSinceEpoch}',
        'title': _titleController.text,
        'teacher': _teacherController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'image':
            'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300',
        'rating': 4.5,
        'reviews': 0,
        'students': '0',
        'duration': 0,
        'lessons': 0,
        'level': 'مبتدئ',
        'lastUpdated': '2024',
        'status': 'مسودة',
        'enrollments': 0,
      };

      widget.onCourseAdded(newCourse);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Dialog(
      backgroundColor: themeData.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseToEdit == null
                      ? 'إضافة دورة جديدة'
                      : 'تعديل الدورة',
                  style: GoogleFonts.tajawal(
                    fontSize: widget.baseFontSize,
                    fontWeight: FontWeight.w900,
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _titleController,
                  label: 'عنوان الدورة',
                  hintText: 'أدخل عنوان الدورة',
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال العنوان' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _teacherController,
                  label: 'اسم المدرس',
                  hintText: 'أدخل اسم المدرس',
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال اسم المدرس' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _categoryController,
                  label: 'الفئة',
                  hintText: 'أدخل فئة الدورة',
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال الفئة' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _priceController,
                  label: 'السعر',
                  hintText: 'أدخل سعر الدورة',
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال السعر' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _descriptionController,
                  label: 'الوصف',
                  hintText: 'أدخل وصف الدورة',
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال الوصف' : null,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: GoogleFonts.tajawal(
                            fontSize: widget.smallFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          widget.courseToEdit == null ? 'إضافة' : 'حفظ',
                          style: GoogleFonts.tajawal(
                            fontSize: widget.smallFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    final themeData = widget.isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: widget.smallFontSize,
            fontWeight: FontWeight.w700,
            color: themeData.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.tajawal(fontSize: widget.smallFontSize),
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// Course Options Bottom Sheet
class CourseOptionsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> course;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const CourseOptionsBottomSheet({
    super.key,
    required this.course,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Container(
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with course image and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      course['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          child: Icon(
                            Icons.image,
                            size: 24,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course['title'],
                      style: GoogleFonts.tajawal(
                        fontSize: baseFontSize * 0.8,
                        fontWeight: FontWeight.w900,
                        color: themeData.colorScheme.onBackground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Options List
            _buildOptionItem(
              context: context,
              icon: Icons.visibility,
              title: 'عرض الدورة',
              onTap: onView,
            ),
            _buildOptionItem(
              context: context,
              icon: Icons.edit,
              title: 'تعديل الدورة',
              onTap: onEdit,
            ),
            _buildOptionItem(
              context: context,
              icon: Icons.bar_chart,
              title: 'إحصائيات الدورة',
              onTap: () {
                Navigator.pop(context);
                _showStatisticsDialog(context);
              },
            ),
            _buildOptionItem(
              context: context,
              icon: Icons.delete,
              title: 'حذف الدورة',
              titleColor: Colors.red,
              onTap: onDelete,
            ),

            const SizedBox(height: 16),

            // Cancel Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return ListTile(
      leading: Icon(icon, color: titleColor ?? themeData.colorScheme.primary),
      title: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: smallFontSize,
          fontWeight: FontWeight.w700,
          color: titleColor ?? themeData.colorScheme.onBackground,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CourseStatisticsDialog(
        course: course,
        baseFontSize: baseFontSize,
        smallFontSize: smallFontSize,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

// Course Statistics Dialog
class CourseStatisticsDialog extends StatelessWidget {
  final Map<String, dynamic> course;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const CourseStatisticsDialog({
    super.key,
    required this.course,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Dialog(
      backgroundColor: themeData.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات الدورة',
              style: GoogleFonts.tajawal(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w900,
                color: themeData.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            _buildStatItem('عدد المشتركين', '${course['enrollments']}'),
            _buildStatItem('التقييم', '${course['rating']} ⭐'),
            _buildStatItem('عدد التقييمات', '${course['reviews']}'),
            _buildStatItem('الحالة', course['status']),
            _buildStatItem('آخر تحديث', course['lastUpdated']),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'حسناً',
                  style: GoogleFonts.tajawal(
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w700,
              color: themeData.colorScheme.onBackground,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w500,
              color: themeData.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Delete Confirmation Dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final Map<String, dynamic> course;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.course,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return AlertDialog(
      backgroundColor: themeData.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'تأكيد الحذف',
        style: GoogleFonts.tajawal(
          fontSize: baseFontSize,
          fontWeight: FontWeight.w900,
          color: themeData.colorScheme.onBackground,
        ),
      ),
      content: Text(
        'هل أنت متأكد من أنك تريد حذف "${course['title']}"؟ لا يمكن التراجع عن هذا الإجراء.',
        style: GoogleFonts.tajawal(
          fontSize: smallFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            'حذف',
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// Existing CoursesListView Widget (keep as is)
class CoursesListView extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final bool showProgress;
  final String emptyMessage;
  final String emptyDescription;
  final IconData emptyIcon;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const CoursesListView({
    super.key,
    required this.courses,
    required this.showProgress,
    required this.emptyMessage,
    required this.emptyDescription,
    required this.emptyIcon,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return courses.isEmpty
        ? EmptyState(
            icon: emptyIcon,
            message: emptyMessage,
            description: emptyDescription,
            baseFontSize: baseFontSize,
            smallFontSize: smallFontSize,
            isDarkMode: isDarkMode,
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

              if (isTablet) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.3,
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
                        isDarkMode: isDarkMode,
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
                        isDarkMode: isDarkMode,
                      ),
                    );
                  },
                );
              }
            },
          );
  }
}

// Existing CourseCard Widget (keep as is)
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool showProgress;
  final bool isGridView;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const CourseCard({
    super.key,
    required this.course,
    required this.showProgress,
    required this.isGridView,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: course),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isGridView
            ? _buildGridLayout(themeData)
            : _buildListLayout(themeData),
      ),
    );
  }

  Widget _buildGridLayout(ThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            course['image'],
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 120,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              );
            },
          ),
        ),

        // Course Info
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title'],
                style: GoogleFonts.tajawal(
                  fontSize: baseFontSize * 0.7,
                  fontWeight: FontWeight.w900,
                  color: themeData.colorScheme.onBackground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                course['teacher'],
                style: GoogleFonts.tajawal(
                  fontSize: smallFontSize * 0.8,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    course['rating'].toString(),
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    course['price'],
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.8,
                      fontWeight: FontWeight.w900,
                      color: themeData.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (showProgress) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: course['progress'],
                  backgroundColor: isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  color: themeData.colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(course['progress'] * 100).toInt()}% مكتمل',
                  style: GoogleFonts.tajawal(
                    fontSize: smallFontSize * 0.7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout(ThemeData themeData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Course Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              course['image'],
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 80,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  child: Icon(
                    Icons.image,
                    size: 30,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: GoogleFonts.tajawal(
                    fontSize: baseFontSize * 0.8,
                    fontWeight: FontWeight.w900,
                    color: themeData.colorScheme.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course['teacher'],
                  style: GoogleFonts.tajawal(
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      course['rating'].toString(),
                      style: GoogleFonts.tajawal(
                        fontSize: smallFontSize * 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      course['price'],
                      style: GoogleFonts.tajawal(
                        fontSize: smallFontSize * 0.9,
                        fontWeight: FontWeight.w900,
                        color: themeData.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (showProgress) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: course['progress'],
                    backgroundColor: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    color: themeData.colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(course['progress'] * 100).toInt()}% مكتمل',
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Existing EmptyState Widget (keep as is)
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String description;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.description,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.tajawal(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w900,
                color: themeData.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.tajawal(
                fontSize: smallFontSize,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
