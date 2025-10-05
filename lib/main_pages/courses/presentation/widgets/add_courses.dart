import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';

// نموذج بيانات الفيديو
class CourseVideo {
  String title;
  String description;
  String url;
  String duration;

  CourseVideo({
    required this.title,
    required this.description,
    required this.url,
    required this.duration,
  });
}

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _teacherController = TextEditingController();
  final _durationController = TextEditingController();
  final _lessonsController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _teacherImageController = TextEditingController();
  final _tagsController = TextEditingController();

  // قائمة الفيديوهات
  final List<CourseVideo> _courseVideos = [];

  String? _selectedCategory;
  String _selectedLevel = 'مبتدئ';
  bool _isFree = false;
  bool _isLoading = false;
  bool _showPreview = false;

  final List<String> _categories = [
    'برمجة',
    'تصميم',
    'تسويق',
    'أعمال',
    'تطوير شخصي',
    'لغات',
    'علوم',
    'رياضيات',
  ];

  final List<String> _levels = ['مبتدئ', 'متوسط', 'متقدم'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _teacherController.dispose();
    _durationController.dispose();
    _lessonsController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _teacherImageController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_courseVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إضافة فيديو واحد على الأقل',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // محاكاة عملية الحفظ
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ الدورة بنجاح مع ${_courseVideos.length} فيديو!',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // العودة إلى الصفحة السابقة بعد الحفظ
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  // دالة لإضافة فيديو جديد
  void _showAddVideoDialog(bool isDarkMode, {CourseVideo? video, int? index}) {
    final videoTitleController = TextEditingController(
      text: video?.title ?? '',
    );
    final videoDescriptionController = TextEditingController(
      text: video?.description ?? '',
    );
    final videoUrlController = TextEditingController(text: video?.url ?? '');
    final videoDurationController = TextEditingController(
      text: video?.duration ?? '',
    );
    final videoFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Form(
          key: videoFormKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        video == null ? 'إضافة فيديو جديد' : 'تعديل الفيديو',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF1F2937),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: videoTitleController,
                        label: 'عنوان الفيديو',
                        hint: 'مثال: مقدمة في البرمجة',
                        isDarkMode: isDarkMode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال عنوان الفيديو';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: videoDescriptionController,
                        label: 'وصف الفيديو',
                        hint: 'وصف مختصر لمحتوى الفيديو',
                        isDarkMode: isDarkMode,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: videoUrlController,
                        label: 'رابط الفيديو',
                        hint: 'https://example.com/video.mp4',
                        isDarkMode: isDarkMode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رابط الفيديو';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: videoDurationController,
                        label: 'مدة الفيديو',
                        hint: 'مثال: 15:30',
                        isDarkMode: isDarkMode,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال مدة الفيديو';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'صيغة المدة: MM:SS أو HH:MM:SS',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (videoFormKey.currentState!.validate()) {
                              final newVideo = CourseVideo(
                                title: videoTitleController.text,
                                description: videoDescriptionController.text,
                                url: videoUrlController.text,
                                duration: videoDurationController.text,
                              );

                              setState(() {
                                if (video == null) {
                                  _courseVideos.add(newVideo);
                                } else {
                                  _courseVideos[index!] = newVideo;
                                }
                              });

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    video == null
                                        ? 'تم إضافة الفيديو بنجاح'
                                        : 'تم تحديث الفيديو بنجاح',
                                    style: GoogleFonts.tajawal(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            video == null ? 'إضافة الفيديو' : 'تحديث الفيديو',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDarkMode ? Colors.white30 : Colors.black26,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'إلغاء',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1F2937),
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
    );
  }

  // دالة لحذف فيديو
  void _deleteVideo(int index) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.isDarkMode;
          return AlertDialog(
            backgroundColor: isDarkMode
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'حذف الفيديو',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            content: Text(
              'هل أنت متأكد من حذف هذا الفيديو؟',
              style: GoogleFonts.tajawal(
                color: isDarkMode ? Colors.white70 : const Color(0xFF4B5563),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _courseVideos.removeAt(index);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم حذف الفيديو بنجاح',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'حذف',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF3F4F6),
          appBar: AppBar(
            backgroundColor: isDarkMode
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            elevation: 0,
            title: Text(
              'إضافة دورة جديدة',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _showPreview ? Icons.edit : Icons.visibility,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                ),
                onPressed: () {
                  setState(() {
                    _showPreview = !_showPreview;
                  });
                },
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showPreview) ...[
                    _buildPreviewSection(isDarkMode),
                    const SizedBox(height: 24),
                  ] else ...[
                    _buildFormSection(isDarkMode),
                  ],

                  // أزرار الحفظ والإلغاء
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveCourse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'حفظ الدورة',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.white30
                                  : Colors.black26,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'إلغاء',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('المعلومات الأساسية', isDarkMode),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _titleController,
          label: 'عنوان الدورة',
          hint: 'أدخل عنوان الدورة',
          isDarkMode: isDarkMode,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال عنوان الدورة';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'وصف الدورة',
          hint: 'أدخل وصفاً تفصيلياً للدورة',
          isDarkMode: isDarkMode,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _teacherController,
          label: 'اسم المدرب',
          hint: 'أدخل اسم المدرب',
          isDarkMode: isDarkMode,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال اسم المدرب';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('تفاصيل الدورة', isDarkMode),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'الفئة',
          value: _selectedCategory,
          items: _categories,
          isDarkMode: isDarkMode,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'المستوى',
          value: _selectedLevel,
          items: _levels,
          isDarkMode: isDarkMode,
          onChanged: (value) {
            setState(() {
              _selectedLevel = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _durationController,
                label: 'المدة (بالساعات)',
                hint: '20',
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _lessonsController,
                label: 'عدد الدروس',
                hint: '30',
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('التسعير', isDarkMode),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'دورة مجانية',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              Switch(
                value: _isFree,
                onChanged: (value) {
                  setState(() {
                    _isFree = value;
                    if (value) {
                      _priceController.text = '0';
                    }
                  });
                },
                activeColor: const Color(0xFF667EEA),
              ),
            ],
          ),
        ),
        if (!_isFree) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _priceController,
            label: 'السعر',
            hint: '₪199',
            isDarkMode: isDarkMode,
            keyboardType: TextInputType.number,
          ),
        ],
        const SizedBox(height: 24),

        _buildSectionTitle('الصور والوسائط', isDarkMode),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _imageUrlController,
          label: 'رابط صورة الدورة',
          hint: 'https://example.com/course-image.jpg',
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _teacherImageController,
          label: 'رابط صورة المدرب',
          hint: 'https://example.com/teacher-image.jpg',
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 24),

        // قسم الفيديوهات الجديد
        _buildSectionTitle('فيديوهات الدورة', isDarkMode),
        const SizedBox(height: 8),
        Text(
          'أضف فيديوهات الدورة التعليمية',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: isDarkMode ? Colors.white60 : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),

        // زر إضافة فيديو
        InkWell(
          onTap: () => _showAddVideoDialog(isDarkMode),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF667EEA),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'إضافة فيديو جديد',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF667EEA),
                  ),
                ),
              ],
            ),
          ),
        ),

        // قائمة الفيديوهات المضافة
        if (_courseVideos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.video_library,
                        color: const Color(0xFF667EEA),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الفيديوهات المضافة (${_courseVideos.length})',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _courseVideos.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final video = _courseVideos[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        video.title,
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (video.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              video.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(
                                fontSize: 13,
                                color: isDarkMode
                                    ? Colors.white60
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isDarkMode
                                    ? Colors.white38
                                    : Colors.black38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                video.duration,
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: const Color(0xFF667EEA),
                              size: 20,
                            ),
                            onPressed: () => _showAddVideoDialog(
                              isDarkMode,
                              video: video,
                              index: index,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => _deleteVideo(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        _buildSectionTitle('معلومات إضافية', isDarkMode),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _tagsController,
          label: 'الكلمات المفتاحية',
          hint: 'برمجة, تطوير, ويب (مفصولة بفواصل)',
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildPreviewSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معاينة الدورة',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_imageUrlController.text.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imageUrlController.text,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: isDarkMode
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFF3F4F6),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: isDarkMode ? Colors.white30 : Colors.black26,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                _titleController.text.isEmpty
                    ? 'عنوان الدورة'
                    : _titleController.text,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _teacherController.text.isEmpty
                    ? 'اسم المدرب'
                    : _teacherController.text,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              if (_descriptionController.text.isNotEmpty) ...[
                Text(
                  _descriptionController.text,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    height: 1.5,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF4B5563),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedCategory != null)
                    _buildChip(_selectedCategory!, isDarkMode),
                  _buildChip(_selectedLevel, isDarkMode),
                  if (_durationController.text.isNotEmpty)
                    _buildChip('${_durationController.text} ساعة', isDarkMode),
                  if (_lessonsController.text.isNotEmpty)
                    _buildChip('${_lessonsController.text} درس', isDarkMode),
                  if (_courseVideos.isNotEmpty)
                    _buildChip('${_courseVideos.length} فيديو', isDarkMode),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _isFree
                        ? 'مجاني'
                        : (_priceController.text.isEmpty
                              ? '₪0'
                              : '₪${_priceController.text}'),
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // معاينة الفيديوهات
        if (_courseVideos.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'الفيديوهات (${_courseVideos.length})',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _courseVideos.length,
            itemBuilder: (context, index) {
              final video = _courseVideos[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    video.title,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Text(
                    video.duration,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: isDarkMode
                          ? Colors.white60
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  trailing: Icon(
                    Icons.play_circle_outline,
                    color: const Color(0xFF667EEA),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDarkMode,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.tajawal(
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.tajawal(
              color: isDarkMode ? Colors.white30 : const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white10 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required bool isDarkMode,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white10 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          style: GoogleFonts.tajawal(
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          hint: Text(
            'اختر $label',
            style: GoogleFonts.tajawal(
              color: isDarkMode ? Colors.white30 : const Color(0xFF9CA3AF),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء اختيار $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white70 : const Color(0xFF4B5563),
        ),
      ),
    );
  }
}
