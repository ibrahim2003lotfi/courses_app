import 'dart:io';
import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/services/home_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:image_picker/image_picker.dart';

// نموذج بيانات الفيديو - updated with file instead of URL
class CourseVideo {
  String title;
  String description;
  File? videoFile; // Changed from URL to File
  String? fileName;

  CourseVideo({
    required this.title,
    required this.description,
    this.videoFile,
    this.fileName,
  });
}

class AddCoursePage extends StatefulWidget {
  final String? courseId;
  final String? initialTitle;
  final String? initialDescription;
  final num? initialPrice;
  final String? initialLevelBackend; // beginner/intermediate/advanced
  final String? initialCategoryName;
  final bool isEditing;

  const AddCoursePage({
    super.key,
    this.courseId,
    this.initialTitle,
    this.initialDescription,
    this.initialPrice,
    this.initialLevelBackend,
    this.initialCategoryName,
    this.isEditing = false,
  });

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _universityFormKey = GlobalKey<FormState>();

  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();
  final HomeApi _homeApi = HomeApi();

  // Controllers for Educational Course
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // Controllers for University Course (now has full fields like educational)
  final _uniTitleController = TextEditingController();
  final _uniDescriptionController = TextEditingController();
  final _uniPriceController = TextEditingController();

  // University-specific fields (first 3 fields)
  final _universityNameController = TextEditingController();
  final _facultyController = TextEditingController();
  final _lectureNameController = TextEditingController();

  // Course image files (file picker instead of URL)
  File? _courseImageFile;
  File? _universityCourseImageFile;

  // Video lists
  final List<CourseVideo> _courseVideos = [];
  final List<CourseVideo> _universityVideos = [];

  // Selections for Educational
  String? _selectedCategory;
  String _selectedLevel = 'مبتدئ';
  bool _isFree = false;

  // Selections for University
  String? _uniSelectedCategory;
  String _uniSelectedLevel = 'مبتدئ';
  bool _uniIsFree = false;

  bool _isLoading = false;
  bool _isLoadingCategories = true;
  
  // Categories from backend
  List<Map<String, dynamic>> _categories = [];

  final List<String> _levels = ['مبتدئ', 'متوسط', 'متقدم'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();

    // Prefill fields when editing an existing course (educational tab)
    if (widget.isEditing) {
      if (widget.initialTitle != null) {
        _titleController.text = widget.initialTitle!;
      }
      if (widget.initialDescription != null) {
        _descriptionController.text = widget.initialDescription!;
      }
      if (widget.initialPrice != null) {
        _priceController.text = widget.initialPrice!.toString();
        _isFree = widget.initialPrice == 0;
      }
      if (widget.initialCategoryName != null) {
        _selectedCategory = widget.initialCategoryName;
      }
      if (widget.initialLevelBackend != null) {
        // Map backend level to Arabic label used in UI
        switch (widget.initialLevelBackend) {
          case 'beginner':
            _selectedLevel = 'مبتدئ';
            break;
          case 'intermediate':
            _selectedLevel = 'متوسط';
            break;
          case 'advanced':
            _selectedLevel = 'متقدم';
            break;
        }
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _homeApi.getHome();
      if (mounted) {
        final categories = (response['categories'] as List<dynamic>?) ?? [];
        setState(() {
          _categories = categories.map((c) => c as Map<String, dynamic>).toList();
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  // Get category names for dropdown
  List<String> get _categoryNames {
    return _categories.map((c) => c['name']?.toString() ?? '').where((name) => name.isNotEmpty).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _uniTitleController.dispose();
    _uniDescriptionController.dispose();
    _uniPriceController.dispose();
    _universityNameController.dispose();
    _facultyController.dispose();
    _lectureNameController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickCourseImage(bool isUniversity) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (isUniversity) {
            _universityCourseImageFile = File(pickedFile.path);
          } else {
            _courseImageFile = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('فشل اختيار الصورة: $e');
    }
  }

  // Pick video from gallery
  Future<File?> _pickVideoFile() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      _showErrorSnackBar('فشل اختيار الفيديو: $e');
    }
    return null;
  }

  Future<void> _saveEducationalCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // عند إنشاء دورة جديدة نلزم بوجود فيديو، أما في وضع التعديل فقط نسمح بدون فيديوهات
    if (!widget.isEditing && _courseVideos.isEmpty) {
      _showErrorSnackBar('الرجاء إضافة فيديو واحد على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare lessons data
      final lessons = _courseVideos
          .map(
            (video) => {
              'title': video.title,
              'description': video.description,
              'file_name': video.fileName ?? 'video.mp4',
            },
          )
          .toList();

      print('🟡 Creating course with title: ${_titleController.text.trim()}');
      print('🟡 Lessons count: ${lessons.length}');
      print('🟡 Category: $_selectedCategory');
      print('🟡 Level: ${_mapLevelToBackend(_selectedLevel)}');
      print('🟡 Has thumbnail: ${_courseImageFile != null}');

      final api = CourseApi();
      Map<String, dynamic> response;

      if (widget.isEditing && widget.courseId != null) {
        // تحديث بيانات دورة موجودة في DB (بدون التعامل مع الفيديوهات هنا)
        response = await api.updateInstructorCourse(
          id: widget.courseId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          price: _isFree ? 0 : num.tryParse(_priceController.text.trim()) ?? 0,
          level: _mapLevelToBackend(_selectedLevel),
          categoryName: _selectedCategory,
        );
      } else {
        // إنشاء دورة جديدة كما كان سابقاً
        response = await api.createInstructorCourse(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          price: _isFree ? 0 : num.tryParse(_priceController.text.trim()) ?? 0,
          level: _mapLevelToBackend(_selectedLevel),
          categoryName: _selectedCategory,
          thumbnailImage: _courseImageFile,
          lessons: lessons,
        );
      }

      print('🟡 API Response: $response');

      if (!mounted) return;

      // Check for authentication/authorization errors
      if (response.containsKey('error')) {
        final errorCode = response['error'];
        if (errorCode == 'no_user' || errorCode == 'unauthenticated') {
          _showErrorSnackBar('يجب تسجيل الدخول أولاً');
          return;
        }
        if (errorCode == 'unauthorized') {
          _showErrorSnackBar(
            'ليس لديك صلاحية المعلم. يرجى التقدم بطلب للحصول على صلاحية المعلم',
          );
          return;
        }
        if (errorCode == 'middleware_error') {
          _showErrorSnackBar('حدث خطأ في الخادم. يرجى المحاولة مرة أخرى');
          return;
        }
      }

      if (response['success'] == true) {
        final courseId = response['course']?['id'];
        final sections = response['course']?['sections'];

        // في وضع الإنشاء فقط نرفع الفيديوهات
        if (!widget.isEditing &&
            courseId != null &&
            sections != null &&
            sections.isNotEmpty &&
            sections[0]['lessons'] != null) {
          final lessonsList = sections[0]['lessons'] as List;

          print('🟡 Uploading ${lessonsList.length} videos...');

          for (
            var i = 0;
            i < lessonsList.length && i < _courseVideos.length;
            i++
          ) {
            final lessonId = lessonsList[i]['id'];
            final videoFile = _courseVideos[i].videoFile;

            if (lessonId != null && videoFile != null) {
              print('🟡 Uploading video ${i + 1}/${lessonsList.length}');

              final uploadResponse = await api.uploadLessonVideo(
                courseId: courseId,
                lessonId: lessonId,
                videoFile: videoFile,
                duration: 0,
              );

              print('🟡 Video ${i + 1} upload response: $uploadResponse');

              if (uploadResponse['success'] != true) {
                print(
                  '🔴 Video ${i + 1} upload failed: ${uploadResponse['message']}',
                );
              }
            }
          }
        }

        _showSuccessSnackBar(
          widget.isEditing ? 'تم تحديث الدورة بنجاح!' : 'تم حفظ الدورة بنجاح!',
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        final errorMessage = response['message'] ?? 'فشل حفظ الدورة';
        _showErrorSnackBar(errorMessage);
      }
    } catch (e, stackTrace) {
      print('🔴 Course creation error: $e');
      print('🔴 Stack trace: $stackTrace');
      if (!mounted) return;

      // Handle specific error types
      String errorMessage = 'فشل حفظ الدورة';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage = 'لا يمكن الاتصال بالخادم. تأكد من تشغيل الخادم';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت';
      } else if (e.toString().contains('Unauthenticated') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'يجب تسجيل الدخول كمعلم لإضافة دورة';
      } else {
        errorMessage = 'فشل حفظ الدورة: ${e.toString()}';
      }
      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUniversityCourse() async {
    if (!_universityFormKey.currentState!.validate()) {
      return;
    }

    if (_universityVideos.isEmpty) {
      _showErrorSnackBar('الرجاء إضافة فيديو واحد على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare lessons data
      final lessons = _universityVideos
          .map(
            (video) => {
              'title': video.title,
              'description': video.description,
              'file_name': video.fileName ?? 'video.mp4',
            },
          )
          .toList();

      final api = CourseApi();
      final response = await api.createUniversityCourse(
        title: _lectureNameController.text.trim(),
        description: _uniDescriptionController.text.trim().isEmpty
            ? null
            : _uniDescriptionController.text.trim(),
        price: _uniIsFree
            ? 0
            : num.tryParse(_uniPriceController.text.trim()) ?? 0,
        level: _mapLevelToBackend(_uniSelectedLevel),
        universityName: _universityNameController.text.trim(),
        facultyName: _facultyController.text.trim(),
        categoryName: _uniSelectedCategory,
        thumbnailImage: _universityCourseImageFile,
        lessons: lessons,
      );

      if (!mounted) return;

      // Check for authentication/authorization errors
      if (response.containsKey('error')) {
        final errorCode = response['error'];
        if (errorCode == 'no_user' || errorCode == 'unauthenticated') {
          _showErrorSnackBar('يجب تسجيل الدخول أولاً');
          return;
        }
        if (errorCode == 'unauthorized') {
          _showErrorSnackBar(
            'ليس لديك صلاحية المعلم. يرجى التقدم بطلب للحصول على صلاحية المعلم',
          );
          return;
        }
        if (errorCode == 'middleware_error') {
          _showErrorSnackBar('حدث خطأ في الخادم. يرجى المحاولة مرة أخرى');
          return;
        }
      }

      if (response['success'] == true) {
        final courseId = response['course']?['id'];
        final sections = response['course']?['sections'];

        // Upload videos if we have course ID and lessons
        if (courseId != null &&
            sections != null &&
            sections.isNotEmpty &&
            sections[0]['lessons'] != null) {
          final lessons = sections[0]['lessons'] as List;

          print('🟡 Uploading ${lessons.length} university videos...');

          for (
            var i = 0;
            i < lessons.length && i < _universityVideos.length;
            i++
          ) {
            final lessonId = lessons[i]['id'];
            final videoFile = _universityVideos[i].videoFile;

            if (lessonId != null && videoFile != null) {
              print('🟡 Uploading video ${i + 1}/${lessons.length}');

              final uploadResponse = await api.uploadLessonVideo(
                courseId: courseId,
                lessonId: lessonId,
                videoFile: videoFile,
                duration: 0,
              );

              print('🟡 Video ${i + 1} upload response: $uploadResponse');

              if (uploadResponse['success'] != true) {
                print(
                  '🔴 Video ${i + 1} upload failed: ${uploadResponse['message']}',
                );
              }
            }
          }
        }

        _showSuccessSnackBar('تم حفظ الكورس الجامعي بنجاح!');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        final errorMessage = response['message'] ?? 'فشل حفظ الكورس';
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;

      // Handle specific error types
      String errorMessage = 'فشل حفظ الكورس الجامعي';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage = 'لا يمكن الاتصال بالخادم. تأكد من تشغيل الخادم';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت';
      } else if (e.toString().contains('Unauthenticated') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'يجب تسجيل الدخول كمعلم لإضافة كورس';
      } else {
        errorMessage = 'فشل حفظ الكورس الجامعي: ${e.toString()}';
      }
      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Video dialog with file picker
  void _showAddVideoDialog(
    bool isDarkMode,
    bool isUniversity, {
    CourseVideo? video,
    int? index,
  }) {
    final isEditing = video != null;
    final videoTitleController = TextEditingController(
      text: video?.title ?? '',
    );
    final videoDescriptionController = TextEditingController(
      text: video?.description ?? '',
    );
    File? selectedVideoFile = video?.videoFile;
    String? selectedFileName = video?.fileName;
    final videoFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
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
                            isEditing ? 'تعديل الفيديو' : 'إضافة فيديو جديد',
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
                          const SizedBox(height: 20),

                          // Video file picker
                          Text(
                            'ملف الفيديو',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final file = await _pickVideoFile();
                              if (file != null) {
                                setModalState(() {
                                  selectedVideoFile = file;
                                  selectedFileName = file.path.split('/').last;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF2D2D2D)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedVideoFile != null
                                      ? const Color(0xFF667EEA)
                                      : (isDarkMode
                                            ? Colors.white10
                                            : Colors.black12),
                                  width: selectedVideoFile != null ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF667EEA),
                                          Color(0xFF764BA2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.video_library,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedVideoFile != null
                                              ? 'تم اختيار الفيديو'
                                              : 'اختر ملف الفيديو',
                                          style: GoogleFonts.tajawal(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                        ),
                                        if (selectedFileName != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedFileName!,
                                            style: GoogleFonts.tajawal(
                                              fontSize: 12,
                                              color: isDarkMode
                                                  ? Colors.white60
                                                  : const Color(0xFF6B7280),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    selectedVideoFile != null
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_ios,
                                    color: selectedVideoFile != null
                                        ? const Color(0xFF667EEA)
                                        : (isDarkMode
                                              ? Colors.white38
                                              : Colors.black38),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (selectedVideoFile == null && !isEditing)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'الرجاء اختيار ملف الفيديو',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
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
                                if (videoFormKey.currentState!.validate() &&
                                    (selectedVideoFile != null || isEditing)) {
                                  final newVideo = CourseVideo(
                                    title: videoTitleController.text,
                                    description:
                                        videoDescriptionController.text,
                                    videoFile:
                                        selectedVideoFile ?? video?.videoFile,
                                    fileName:
                                        selectedFileName ?? video?.fileName,
                                  );

                                  setState(() {
                                    final targetList = isUniversity
                                        ? _universityVideos
                                        : _courseVideos;
                                    if (isEditing && index != null) {
                                      targetList[index] = newVideo;
                                    } else {
                                      targetList.add(newVideo);
                                    }
                                  });

                                  Navigator.pop(context);
                                  _showSuccessSnackBar(
                                    isEditing
                                        ? 'تم تحديث الفيديو بنجاح'
                                        : 'تم إضافة الفيديو بنجاح',
                                  );
                                } else if (selectedVideoFile == null &&
                                    !isEditing) {
                                  _showErrorSnackBar(
                                    'الرجاء اختيار ملف الفيديو',
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                isEditing ? 'تحديث الفيديو' : 'إضافة الفيديو',
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteVideo(int index, bool isUniversity) {
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
                    final targetList = isUniversity
                        ? _universityVideos
                        : _courseVideos;
                    targetList.removeAt(index);
                  });
                  Navigator.pop(context);
                  _showSuccessSnackBar('تم حذف الفيديو بنجاح');
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
            bottom: TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.tajawal(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: GoogleFonts.tajawal(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              indicatorColor: const Color(0xFF667EEA),
              labelColor: const Color(0xFF667EEA),
              unselectedLabelColor: isDarkMode
                  ? Colors.white60
                  : Colors.black54,
              tabs: const [
                Tab(text: 'كورس تعليمي'),
                Tab(text: 'كورس جامعي'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Educational Course
              _buildEducationalCourseTab(isDarkMode),
              // Tab 2: University Course
              _buildUniversityCourseTab(isDarkMode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEducationalCourseTab(bool isDarkMode) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormSection(isDarkMode, false),
            const SizedBox(height: 32),
            _buildActionButtons(
              isDarkMode,
              onSave: _saveEducationalCourse,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversityCourseTab(bool isDarkMode) {
    return Form(
      key: _universityFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University-specific first 3 fields
            _buildSectionTitle('معلومات الجامعة', isDarkMode),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _universityNameController,
              label: 'اسم الجامعة',
              hint: 'أدخل اسم الجامعة',
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم الجامعة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _facultyController,
              label: 'اسم الكلية',
              hint: 'أدخل اسم الكلية',
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم الكلية';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lectureNameController,
              label: 'اسم المحاضرة',
              hint: 'أدخل اسم المحاضرة',
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المحاضرة';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Rest same as educational
            _buildFormSection(isDarkMode, true),
            const SizedBox(height: 32),
            _buildActionButtons(
              isDarkMode,
              onSave: _saveUniversityCourse,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(bool isDarkMode, bool isUniversity) {
    final titleController = isUniversity
        ? _uniTitleController
        : _titleController;
    final descriptionController = isUniversity
        ? _uniDescriptionController
        : _descriptionController;
    final priceController = isUniversity
        ? _uniPriceController
        : _priceController;
    final selectedCategory = isUniversity
        ? _uniSelectedCategory
        : _selectedCategory;
    final selectedLevel = isUniversity ? _uniSelectedLevel : _selectedLevel;
    final isFree = isUniversity ? _uniIsFree : _isFree;
    final courseImageFile = isUniversity
        ? _universityCourseImageFile
        : _courseImageFile;
    final videos = isUniversity ? _universityVideos : _courseVideos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // المعلومات الأساسية - Keep only title and description (removed trainer name)
        _buildSectionTitle('المعلومات الأساسية', isDarkMode),
        const SizedBox(height: 16),
        _buildTextField(
          controller: titleController,
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
          controller: descriptionController,
          label: 'وصف الدورة',
          hint: 'أدخل وصفاً تفصيلياً للدورة',
          isDarkMode: isDarkMode,
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        // تفاصيل الدورة - Keep only category and level (removed hours and lessons count)
        _buildSectionTitle('تفاصيل الدورة', isDarkMode),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'الفئة',
          value: selectedCategory,
          items: _categoryNames,
          isDarkMode: isDarkMode,
          onChanged: (value) {
            setState(() {
              if (isUniversity) {
                _uniSelectedCategory = value;
              } else {
                _selectedCategory = value;
              }
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'المستوى',
          value: selectedLevel,
          items: _levels,
          isDarkMode: isDarkMode,
          onChanged: (value) {
            setState(() {
              if (isUniversity) {
                _uniSelectedLevel = value!;
              } else {
                _selectedLevel = value!;
              }
            });
          },
        ),
        // Note about auto-calculation
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF2D4A3D)
                : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: isDarkMode
                    ? Colors.green.shade300
                    : Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'سيتم احتساب المدة وعدد الدروس تلقائياً بناءً على الفيديوهات المضافة',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: isDarkMode
                        ? Colors.green.shade300
                        : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // التسعير - Keep as is
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
                value: isFree,
                onChanged: (value) {
                  setState(() {
                    if (isUniversity) {
                      _uniIsFree = value;
                    } else {
                      _isFree = value;
                    }
                    if (value) {
                      priceController.text = '0';
                    }
                  });
                },
                activeColor: const Color(0xFF667EEA),
              ),
            ],
          ),
        ),
        if (!isFree) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: priceController,
            label: 'السعر',
            hint: 'S.P 199',
            isDarkMode: isDarkMode,
            keyboardType: TextInputType.number,
          ),
        ],
        const SizedBox(height: 24),

        // الصور والوسائط - Changed to image file uploader, removed trainer image
        _buildSectionTitle('الصور والوسائط', isDarkMode),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _pickCourseImage(isUniversity),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: courseImageFile != null
                    ? const Color(0xFF667EEA)
                    : (isDarkMode ? Colors.white10 : Colors.black12),
                width: courseImageFile != null ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                if (courseImageFile != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      courseImageFile,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'اضغط لتغيير الصورة',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: isDarkMode
                          ? Colors.white60
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'اختر صورة الدورة',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // فيديوهات الدورة - Updated with file upload instead of URL
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
          onTap: () => _showAddVideoDialog(isDarkMode, isUniversity),
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
        if (videos.isNotEmpty) ...[
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
                        'الفيديوهات المضافة (${videos.length})',
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
                  itemCount: videos.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final video = videos[index];
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
                          if (video.fileName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              video.fileName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.white38
                                    : Colors.black38,
                              ),
                            ),
                          ],
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
                              isUniversity,
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
                            onPressed: () => _deleteVideo(index, isUniversity),
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
      ],
    );
  }

  Widget _buildActionButtons(
    bool isDarkMode, {
    required VoidCallback onSave,
    required bool isLoading,
  }) {
    return Row(
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
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
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
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ),
        ),
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

  String _mapLevelToBackend(String levelArabic) {
    switch (levelArabic) {
      case 'مبتدئ':
        return 'beginner';
      case 'متوسط':
        return 'intermediate';
      case 'متقدم':
        return 'advanced';
      default:
        return 'beginner';
    }
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
}
