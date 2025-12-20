import 'dart:io';
import 'package:courses_app/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:courses_app/bloc/user_role_bloc.dart';
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  // Image variables
  XFile? _profileImage;
  XFile? _coverImage;

  // Loading state
  bool _isSaving = false;
  bool _isLoadingProfile = true;
  String? _errorMessage;

  // Certificates list
  List<Map<String, String>> _certificates = [
    {'title': 'شهادة Flutter المتقدم', 'date': '2024'},
    {'title': 'شهادة UI/UX Design', 'date': '2024'},
    {'title': 'شهادة التسويق الرقمي', 'date': '2023'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _errorMessage = null;
    });

    final result = await _profileService.getMe();
    if (!mounted) return;

    if (result['status'] == 200) {
      final data = result['data'] as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>?;
      final profile = data['profile'] as Map<String, dynamic>?;

      _nameController.text = user?['name'] ?? '';
      _emailController.text = user?['email'] ?? '';
      _usernameController.text = profile?['username'] ?? '';
      _bioController.text = profile?['bio'] ?? '';

      setState(() {
        _isLoadingProfile = false;
      });
    } else {
      setState(() {
        _errorMessage =
            (result['data']?['message'] as String?) ?? 'فشل تحميل البيانات';
        _isLoadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRoleBloc, UserRoleState>(
      builder: (context, roleState) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final isDarkMode = themeState.isDarkMode;

            if (_isLoadingProfile) {
              return Scaffold(
                backgroundColor: _getBackgroundColor(isDarkMode),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (_errorMessage != null) {
              return Scaffold(
                backgroundColor: _getBackgroundColor(isDarkMode),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.tajawal(
                            color: _getTextColor(isDarkMode),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProfile,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Theme(
              data: isDarkMode
                  ? ThemeManager.darkTheme
                  : ThemeManager.lightTheme,
              child: Scaffold(
                backgroundColor: _getBackgroundColor(isDarkMode),
                appBar: _buildAppBar(isDarkMode),
                body: Form(
                  key: _formKey,
                  child: CustomScrollView(
                    slivers: [
                      // Cover and Profile Images Section
                      SliverToBoxAdapter(
                        child: _buildImagesSection(isDarkMode),
                      ),

                      // Personal Information Section
                      SliverToBoxAdapter(
                        child: _buildPersonalInfoSection(isDarkMode),
                      ),

                      // Certificates Section
                      SliverToBoxAdapter(
                        child: _buildCertificatesEditSection(isDarkMode),
                      ),

                      // Action Buttons
                      SliverToBoxAdapter(
                        child: _buildActionButtons(isDarkMode),
                      ),

                      // Bottom Spacing
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper methods for colors
  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : const Color(0xFF1E293B);
  }

  Color _getCardColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
  }

  Color _getSecondaryTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: _getCardColor(isDarkMode),
      elevation: 0,
      title: Text(
        'تعديل الملف الشخصي',
        style: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _getTextColor(isDarkMode),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _getTextColor(isDarkMode)),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildImagesSection(bool isDarkMode) {
    return Container(
      height: 280,
      child: Stack(
        children: [
          // Cover Image
          GestureDetector(
            onTap: () => _pickImage(ImageSource.gallery, isCover: true),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
                ),
                image: _coverImage == null
                    ? DecorationImage(
                        image: NetworkImage(
                          'https://picsum.photos/seed/cover/800/300',
                        ),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.overlay,
                        ),
                      )
                    : null,
              ),
              child: _coverImage != null
                  ? Image.file(File(_coverImage!.path), fit: BoxFit.cover)
                  : null,
            ),
          ),

          // Camera Icon for Cover
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () =>
                  _showImageSourceDialog(isCover: true, isDarkMode: isDarkMode),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Profile Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 57,
                      backgroundImage: _profileImage == null
                          ? const NetworkImage(
                              'https://picsum.photos/seed/profile/200/200',
                            )
                          : FileImage(File(_profileImage!.path))
                                as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),

                  // Camera Icon for Profile
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImageSourceDialog(
                        isCover: false,
                        isDarkMode: isDarkMode,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلومات الشخصية',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getTextColor(isDarkMode),
              ),
            ),

            const SizedBox(height: 20),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'الاسم الكامل',
              icon: Icons.person,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email Field
            _buildTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              icon: Icons.email,
              isDarkMode: isDarkMode,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال البريد الإلكتروني';
                }
                if (!value.contains('@')) {
                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Username Field
            _buildTextField(
              controller: _usernameController,
              label: 'اسم المستخدم',
              icon: Icons.alternate_email,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المستخدم';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Bio Field
            _buildTextField(
              controller: _bioController,
              label: 'السيرة الذاتية',
              icon: Icons.description,
              isDarkMode: isDarkMode,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال السيرة الذاتية';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.tajawal(color: _getTextColor(isDarkMode)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.tajawal(
          color: _getSecondaryTextColor(isDarkMode),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
        filled: true,
        fillColor: isDarkMode
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildCertificatesEditSection(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _getCardColor(isDarkMode),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الشهادات المكتسبة',
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(isDarkMode),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF3B82F6)),
                  onPressed: () => _showAddCertificateDialog(isDarkMode),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_certificates.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'لا توجد شهادات بعد',
                    style: GoogleFonts.tajawal(
                      color: _getSecondaryTextColor(isDarkMode),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _certificates.length,
                itemBuilder: (context, index) {
                  final cert = _certificates[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.grey[700]!
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cert['title']!,
                                style: GoogleFonts.tajawal(
                                  fontWeight: FontWeight.bold,
                                  color: _getTextColor(isDarkMode),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cert['date']!,
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: _getSecondaryTextColor(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _certificates.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _saveProfile(isDarkMode),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'حفظ التغييرات',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDarkMode
                      ? Colors.grey[700]!
                      : const Color(0xFFE2E8F0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  color: _getTextColor(isDarkMode),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, {required bool isCover}) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (isCover) {
          _coverImage = image;
        } else {
          _profileImage = image;
        }
      });
    }
  }

  void _showImageSourceDialog({
    required bool isCover,
    required bool isDarkMode,
  }) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: isDarkMode ? ThemeManager.darkTheme : ThemeManager.lightTheme,
        child: AlertDialog(
          title: Text(
            'اختر مصدر الصورة',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF3B82F6),
                ),
                title: Text('المعرض', style: GoogleFonts.tajawal()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isCover: isCover);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF3B82F6)),
                title: Text('الكاميرا', style: GoogleFonts.tajawal()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isCover: isCover);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCertificateDialog(bool isDarkMode) {
    final titleController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Theme(
        data: isDarkMode ? ThemeManager.darkTheme : ThemeManager.lightTheme,
        child: AlertDialog(
          title: Text(
            'إضافة شهادة جديدة',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'اسم الشهادة',
                  labelStyle: GoogleFonts.tajawal(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'تاريخ الحصول عليها',
                  labelStyle: GoogleFonts.tajawal(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.tajawal()),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    dateController.text.isNotEmpty) {
                  setState(() {
                    _certificates.add({
                      'title': titleController.text,
                      'date': dateController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('إضافة', style: GoogleFonts.tajawal()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile(bool isDarkMode) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // تحديث البيانات الأساسية
      final updateResult = await _profileService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (updateResult['status'] != 200) {
        final message = (updateResult['data']?['message'] as String?) ??
            'فشل تحديث البيانات';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // رفع صورة البروفايل إن وُجدت
      if (_profileImage != null) {
        final avatarResult = await _profileService
            .uploadAvatar(File(_profileImage!.path));
        if (avatarResult['status'] != 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (avatarResult['data']?['message'] as String?) ??
                    'تم حفظ البيانات ولكن فشل رفع الصورة',
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ التغييرات بنجاح',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ غير متوقع، حاول مرة أخرى',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
