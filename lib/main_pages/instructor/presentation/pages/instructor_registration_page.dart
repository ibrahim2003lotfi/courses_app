// lib/main_pages/instructor/presentation/instructor_registration_page.dart

import 'package:courses_app/bloc/user_role_bloc.dart';
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/services/instructor_service.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class InstructorRegistrationPage extends StatefulWidget {
  const InstructorRegistrationPage({super.key});

  @override
  State<InstructorRegistrationPage> createState() =>
      _InstructorRegistrationPageState();
}

class _InstructorRegistrationPageState extends State<InstructorRegistrationPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final InstructorService _instructorService = InstructorService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form Controllers
  final _experienceController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();

  // Form Variables
  String? _selectedEducationLevel;
  String? _selectedDepartment;
  double _yearsOfExperience = 0;
  List<PlatformFile> _uploadedCertificates = [];
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  // Education Levels
  final List<String> _educationLevels = [
    'طالب/طالبة في المدرسة',
    'طالب/طالبة جامعي (بكالوريوس)',
    'طالب/طالبة دراسات عليا (ماجستير)',
    'طالب/طالبة دراسات عليا (دكتوراه)',
    'خريج/خريجة',
    'موظف/موظفة',
    'غير ذلك / فئة أخرى',
  ];

  // Departments with subcategories
  final Map<String, List<String>> _departmentsMap = {
    'التكنولوجيا والبرمجة': [
      'تطوير الويب - Front-end',
      'تطوير الويب - Back-end',
      'تطوير الويب - Full-Stack',
      'تطوير تطبيقات iOS',
      'تطوير تطبيقات Android',
      'تطوير تطبيقات Flutter',
      'React Native',
      'الذكاء الاصطناعي',
      'تعلم الآلة',
      'علم البيانات',
      'الأمن السيبراني',
      'قواعد البيانات',
      'الشبكات',
      'برمجة الألعاب',
      'أنظمة التشغيل',
    ],
    'الأعمال والإدارة': [
      'ريادة الأعمال',
      'إدارة الأعمال',
      'التسويق الرقمي',
      'تحسين محركات البحث SEO',
      'التسويق بالمحتوى',
      'إعلانات وسائل التواصل',
      'المبيعات',
      'المالية والمحاسبة',
      'إدارة المشاريع',
      'الموارد البشرية',
    ],
    'الإبداع والتصميم': [
      'التصميم الجرافيكي',
      'UI/UX Design',
      'تصميم الويب',
      'التصوير الفوتوغرافي',
      'مونتاج الفيديو',
      'الرسوم المتحركة',
      'التصميم ثلاثي الأبعاد',
      'الموسيقى والصوت',
    ],
    'التنمية الشخصية والمهارات العامة': [
      'اللغات',
      'القيادة والإدارة',
      'التواصل والعرض',
      'الإنتاجية وتطوير الذات',
      'الذكاء العاطفي',
    ],
    'الفنون والعلوم الإنسانية': [
      'الكتابة الإبداعية',
      'التاريخ والفلسفة',
      'الأدب',
      'الموسيقى',
      'علم النفس',
    ],
    'الصحة واللياقة البدنية': [
      'اللياقة البدنية',
      'التغذية',
      'الصحة النفسية',
      'الطب البديل',
    ],
    'المجالات الأكاديمية والتخصصية': [
      'العلوم',
      'الهندسة',
      'الطب والصحة',
      'القانون',
      'التعليم',
    ],
    'المهارات الحياتية والأعمال اليدوية': [
      'الطهي',
      'الأعمال اليدوية',
      'الإدارة المالية الشخصية',
      'الرعاية الشخصية',
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _loadSavedData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _experienceController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  // Load saved form data
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('instructor_form_data');
    if (savedData != null) {
      final data = json.decode(savedData);
      setState(() {
        _experienceController.text = data['experience'] ?? '';
        _linkedinController.text = data['linkedin'] ?? '';
        _portfolioController.text = data['portfolio'] ?? '';
        _selectedEducationLevel = data['educationLevel'];
        _selectedDepartment = data['department'];
        _yearsOfExperience = data['yearsOfExperience'] ?? 0;
      });
    }
  }

  // Save form data
  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'experience': _experienceController.text,
      'linkedin': _linkedinController.text,
      'portfolio': _portfolioController.text,
      'educationLevel': _selectedEducationLevel,
      'department': _selectedDepartment,
      'yearsOfExperience': _yearsOfExperience,
    };
    await prefs.setString('instructor_form_data', json.encode(data));
  }

  // Calculate form completion percentage
  double _calculateProgress() {
    double progress = 0;
    double stepValue = 1 / 5; // 5 حقول إجبارية

    // 1. المستوى التعليمي
    if (_selectedEducationLevel != null) progress += stepValue;

    // 2. التخصص
    if (_selectedDepartment != null) progress += stepValue;

    // 3. الخبرة التدريسية (يجب أن تكون أكثر من 0)
    if (_yearsOfExperience > 0) progress += stepValue;

    // 4. وصف الخبرات (40 حرف على الأقل)
    if (_experienceController.text.length >= 40) progress += stepValue;

    // 5. الموافقة على الشروط
    if (_agreedToTerms) progress += stepValue;

    return progress.clamp(0.0, 1.0);
  }

  // Pick files for certificates
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.size <= 15 * 1024 * 1024) {
            // 15MB limit
            setState(() {
              _uploadedCertificates.add(file);
            });
          } else {
            _showErrorSnackbar('حجم الملف ${file.name} أكبر من 15MB');
          }
        }
      }
    } catch (e) {
      _showErrorSnackbar('حدث خطأ في رفع الملفات');
    }
  }

  // Remove certificate
  void _removeCertificate(int index) {
    setState(() {
      _uploadedCertificates.removeAt(index);
    });
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal()),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackbar('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    // التحقق من سنوات الخبرة
    if (_yearsOfExperience == 0) {
      _showErrorSnackbar('يجب تحديد سنوات الخبرة');
      return;
    }

    if (!_agreedToTerms) {
      _showErrorSnackbar('يجب الموافقة على الشروط والأحكام');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert PlatformFile to File for upload
      List<File> certificateFiles = [];
      for (var platformFile in _uploadedCertificates) {
        if (platformFile.path != null) {
          certificateFiles.add(File(platformFile.path!));
        }
      }

      // Call real API
      final result = await _instructorService.applyToInstructor(
        educationLevel: _selectedEducationLevel!,
        department: _selectedDepartment!,
        yearsOfExperience: _yearsOfExperience,
        experienceDescription: _experienceController.text,
        linkedinUrl: _linkedinController.text.trim().isEmpty 
            ? null 
            : _linkedinController.text.trim(),
        portfolioUrl: _portfolioController.text.trim().isEmpty 
            ? null 
            : _portfolioController.text.trim(),
        certificates: certificateFiles.isNotEmpty ? certificateFiles : null,
      );

      if (!mounted) return;

      // Clear saved data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('instructor_form_data');

      setState(() {
        _isSubmitting = false;
      });

      if (result['success']) {
        // Switch user role to instructor immediately
        context.read<UserRoleBloc>().add(const BecomeTeacherEvent());
        
        // Show success dialog
        _showSuccessDialog();
      } else {
        _showErrorSnackbar(result['message'] ?? 'فشل إرسال الطلب');
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isSubmitting = false;
      });
      
      _showErrorSnackbar('حدث خطأ: ${e.toString()}');
    }
  }

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'تم التحويل إلى مدرس بنجاح!',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'أنت الآن مدرس في المنصة\nيمكنك البدء في إنشاء الدورات',
                style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'حسناً',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show terms dialog
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الشروط والأحكام',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '''شروط الانضمام كمدرس:

1. يجب أن يكون لديك خبرة في المجال الذي تريد التدريس فيه
2. الالتزام بجودة المحتوى المقدم
3. احترام حقوق الملكية الفكرية
4. الالتزام بسياسات المنصة
5. تقديم محتوى تعليمي قيّم ومفيد

بالموافقة على هذه الشروط، فإنك توافق على جميع سياسات المنصة.''',
                    style: GoogleFonts.tajawal(height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'إغلاق',
                    style: GoogleFonts.tajawal(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Theme(
          data: isDarkMode ? ThemeManager.darkTheme : ThemeManager.lightTheme,
          child: Scaffold(
            backgroundColor: _getBackgroundColor(isDarkMode),
            appBar: AppBar(
              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: _getTextColor(isDarkMode)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'التسجيل كمدرس',
                style: GoogleFonts.tajawal(
                  color: _getTextColor(isDarkMode),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  onChanged: _saveFormData,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator
                      _buildProgressIndicator(isDarkMode),
                      const SizedBox(height: 24),
                      
                      // Education level section
                      _buildEducationSection(isDarkMode),
                      const SizedBox(height: 24),
                      
                      // Department section
                      _buildDepartmentSection(isDarkMode),
                      const SizedBox(height: 24),
                      
                      // Experience section
                      _buildExperienceSection(isDarkMode),
                      const SizedBox(height: 24),
                      
                      // Additional info section
                      _buildAdditionalInfoSection(isDarkMode),
                      const SizedBox(height: 24),
                      
                      // Certificates section
                      _buildCertificatesSection(isDarkMode),
                      const SizedBox(height: 24),
                      
                      // Terms section
                      _buildTermsSection(isDarkMode),
                      const SizedBox(height: 32),
                      
                      // Submit button
                      _buildSubmitButton(isDarkMode),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اكمال النموذج',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getTextColor(isDarkMode),
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _calculateProgress(),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_calculateProgress() * 100).toInt()}% مكتمل',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: _getSecondaryTextColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('المستوى التعليمي', Icons.school, isDarkMode),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedEducationLevel,
            decoration: InputDecoration(
              hintText: 'اختر المستوى التعليمي',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
            items: _educationLevels.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(
                  level,
                  style: GoogleFonts.tajawal(),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEducationLevel = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('التخصص', Icons.category, isDarkMode),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: InputDecoration(
              hintText: 'اختر التخصص',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
            items: _departmentsMap.entries.expand((entry) {
              return [
                DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.key,
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                  ),
                ),
                ...entry.value.map((subDept) => DropdownMenuItem<String>(
                  value: subDept,
                  child: Text(
                    '  $subDept',
                    style: GoogleFonts.tajawal(),
                  ),
                )),
              ];
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('الخبرة التدريسية', Icons.work, isDarkMode),
          const SizedBox(height: 12),
          TextFormField(
            controller: _experienceController,
            decoration: InputDecoration(
              hintText: 'صف خبرتك التدريسية (40 حرف على الأقل)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.length < 40) {
                return 'يجب كتابة 40 حرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'سنوات الخبرة: ${_yearsOfExperience.toInt()}',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: _getTextColor(isDarkMode),
            ),
          ),
          Slider(
            value: _yearsOfExperience,
            min: 0,
            max: 50,
            divisions: 50,
            activeColor: Color(0xFF667EEA),
            onChanged: (value) {
              setState(() {
                _yearsOfExperience = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('معلومات إضافية', Icons.info, isDarkMode),
          const SizedBox(height: 12),
          TextFormField(
            controller: _linkedinController,
            decoration: InputDecoration(
              hintText: 'رابط ملف LinkedIn (اختياري)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _portfolioController,
            decoration: InputDecoration(
              hintText: 'رابط معرض الأعمال (اختياري)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('الشهادات', Icons.description, isDarkMode),
          const SizedBox(height: 12),
          if (_uploadedCertificates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file, 
                    size: 48, 
                    color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط لإضافة شهادات',
                    style: GoogleFonts.tajawal(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          if (_uploadedCertificates.isNotEmpty)
            Column(
              children: [
                ...List.generate(
                  _uploadedCertificates.length,
                  (index) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Color(0xFF667EEA)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _uploadedCertificates[index].name,
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${(_uploadedCertificates[index].size / 1024 / 1024).toStringAsFixed(2)} MB',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: _getSecondaryTextColor(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeCertificate(index),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add),
                  label: Text('إضافة المزيد', style: GoogleFonts.tajawal()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
            activeColor: Color(0xFF667EEA),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _showTermsDialog,
              child: Text(
                'أوافق على الشروط والأحكام',
                style: GoogleFonts.tajawal(
                  color: _agreedToTerms ? _getTextColor(isDarkMode) : Colors.grey,
                  decoration: TextDecoration.combine([
                    TextDecoration.underline,
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDarkMode) {
    final isFormValid = _selectedEducationLevel != null &&
        _selectedDepartment != null &&
        _yearsOfExperience > 0 &&
        _experienceController.text.length >= 40 &&
        _agreedToTerms;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFormValid && !_isSubmitting ? _submitForm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? Color(0xFF667EEA) : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جاري الإرسال...',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                'إرسال الطلب',
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF667EEA), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getTextColor(isDarkMode),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : Colors.black;
  }

  Color _getCardColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  }

  Color _getSecondaryTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
  }
}
