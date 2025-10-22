import 'dart:ui';

import 'package:courses_app/onboarding/onboarding_screen.dart';
import 'package:courses_app/widget_tree.dart';
import 'package:courses_app/main_pages/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Controllers للحقول
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedGender = 'ذكر';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  DateTime? _selectedDate;

  final List<String> _genderOptions = ['ذكر', 'أنثى'];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;
    final isWideScreen = screenWidth > 400;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundPattern(),
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(isSmallScreen, isVerySmallScreen),
                  _buildRegisterForm(
                    isSmallScreen,
                    isVerySmallScreen,
                    isWideScreen,
                  ),
                  _buildActions(isSmallScreen, isVerySmallScreen),
                  _buildFooter(isSmallScreen, isVerySmallScreen),
                ],
              ),
            ),
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              const Color(0xFF667EEA).withOpacity(0.03),
              Colors.transparent,
            ],
            stops: const [0.1, 0.8],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen, bool isVerySmallScreen) {
    final logoSize = isVerySmallScreen ? 60.0 : (isSmallScreen ? 80.0 : 100.0);
    final titleFontSize = isVerySmallScreen
        ? 18.0
        : (isSmallScreen ? 22.0 : 24.0);
    final subtitleFontSize = isVerySmallScreen
        ? 11.0
        : (isSmallScreen ? 13.0 : 14.0);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isVerySmallScreen ? 15 : (isSmallScreen ? 20 : 30),
              ),
              child: Column(
                children: [
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      size: isVerySmallScreen ? 30 : (isSmallScreen ? 35 : 40),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isVerySmallScreen ? 12 : 16),
                  Text(
                    'إنشاء حساب جديد',
                    style: GoogleFonts.tajawal(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isVerySmallScreen ? 6 : 8),
                  Text(
                    'أدخل بياناتك لإتمام التسجيل',
                    style: GoogleFonts.tajawal(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: Color(0xFF2D1B69),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667EEA),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إنشاء الحساب بنجاح!',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2D1B69),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إغلاق',
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildRegisterForm(
    bool isSmallScreen,
    bool isVerySmallScreen,
    bool isWideScreen,
  ) {
    final padding = isVerySmallScreen ? 12.0 : (isSmallScreen ? 16.0 : 24.0);
    final spacing = isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 20.0);
    final fieldFontSize = isVerySmallScreen ? 14.0 : 16.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isVerySmallScreen ? 16 : 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Name fields - stack vertically on small screens
                            if (isWideScreen)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFirstNameField(fieldFontSize),
                                  ),
                                  SizedBox(width: spacing),
                                  Expanded(
                                    child: _buildLastNameField(fieldFontSize),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildFirstNameField(fieldFontSize),
                                  SizedBox(height: spacing),
                                  _buildLastNameField(fieldFontSize),
                                ],
                              ),
                            SizedBox(height: spacing),
                            _buildBirthDateField(fieldFontSize),
                            SizedBox(height: spacing),
                            _buildGenderField(fieldFontSize),
                            SizedBox(height: spacing),
                            _buildPhoneField(fieldFontSize),
                            SizedBox(height: spacing),
                            _buildEmailField(fieldFontSize),
                            SizedBox(height: spacing),
                            _buildPasswordField(fieldFontSize),
                            SizedBox(height: spacing),
                            _buildConfirmPasswordField(fieldFontSize),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFirstNameField(double fontSize) {
    return TextFormField(
      controller: _firstNameController,
      style: GoogleFonts.tajawal(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        labelText: 'الاسم الأول',
        labelStyle: GoogleFonts.tajawal(color: Colors.white70),
        prefixIcon: const Icon(Icons.person_rounded, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال الاسم الأول';
        }
        if (value.length < 2) {
          return 'الاسم يجب أن يكون حرفين على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildLastNameField(double fontSize) {
    return TextFormField(
      controller: _lastNameController,
      style: GoogleFonts.tajawal(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        labelText: 'الاسم الأخير',
        labelStyle: GoogleFonts.tajawal(color: Colors.white70),
        prefixIcon: const Icon(
          Icons.person_outline_rounded,
          color: Colors.white70,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال الاسم الأخير';
        }
        if (value.length < 2) {
          return 'الاسم يجب أن يكون حرفين على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildBirthDateField(double fontSize) {
    return TextFormField(
      controller: _birthDateController,
      readOnly: true,
      style: GoogleFonts.tajawal(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        labelText: 'تاريخ الميلاد',
        labelStyle: GoogleFonts.tajawal(color: Colors.white70),
        prefixIcon: const Icon(
          Icons.calendar_today_rounded,
          color: Colors.white70,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month_rounded, color: Colors.white70),
          onPressed: _selectDate,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
      onTap: _selectDate,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى اختيار تاريخ الميلاد';
        }
        return null;
      },
    );
  }

  Widget _buildGenderField(double fontSize) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      style: GoogleFonts.tajawal(color: Colors.white, fontSize: fontSize),
      dropdownColor: const Color(0xFF2D1B69),
      decoration: InputDecoration(
        labelText: 'الجنس',
        labelStyle: GoogleFonts.tajawal(color: Colors.white70),
        prefixIcon: const Icon(Icons.person_2_rounded, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
      items: _genderOptions.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender, style: GoogleFonts.tajawal(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue!;
        });
      },
    );
  }

  Widget _buildPhoneField(double fontSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              '+963',
              style: GoogleFonts.tajawal(
                color: Colors.white70,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: fontSize),
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              labelStyle: GoogleFonts.tajawal(color: Colors.white70),
              prefixIcon: const Icon(
                Icons.phone_rounded,
                color: Colors.white70,
              ),
              hintText: '944123456',
              hintStyle: GoogleFonts.tajawal(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF667EEA),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              if (value.length != 9) {
                return 'رقم الهاتف يجب أن يكون 9 أرقام';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'يجب أن يحتوي على أرقام فقط';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(double fontSize) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.tajawal(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        labelStyle: GoogleFonts.tajawal(color: Colors.white70),
        prefixIcon: const Icon(Icons.email_rounded, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال البريد الإلكتروني';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'البريد الإلكتروني غير صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(double fontSize) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.tajawal(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        labelStyle: GoogleFonts.tajawal(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_rounded, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(double fontSize) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: GoogleFonts.tajawal(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        labelStyle: GoogleFonts.tajawal(color: Colors.white70),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: Colors.white70,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى تأكيد كلمة المرور';
        }
        if (value != _passwordController.text) {
          return 'كلمات المرور غير متطابقة';
        }
        return null;
      },
    );
  }

  Widget _buildActions(bool isSmallScreen, bool isVerySmallScreen) {
    final buttonHeight = isVerySmallScreen
        ? 44.0
        : (isSmallScreen ? 52.0 : 56.0);
    final buttonFontSize = isVerySmallScreen
        ? 13.0
        : (isSmallScreen ? 15.0 : 16.0);
    final smallButtonHeight = isVerySmallScreen
        ? 38.0
        : (isSmallScreen ? 44.0 : 48.0);
    final smallButtonFontSize = isVerySmallScreen
        ? 10.0
        : (isSmallScreen ? 11.0 : 12.0);

    return Container(
      margin: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
      child: Column(
        children: [
          // Register Button - Purple Gradient
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_rounded,
                            size: isVerySmallScreen ? 18 : 22,
                            color: Colors.white.withOpacity(0.95),
                          ),
                          SizedBox(width: isVerySmallScreen ? 6 : 10),
                          Text(
                            'إنشاء حساب جديد',
                            style: GoogleFonts.tajawal(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 12 : 20),

          // Action Buttons
          Row(
            children: [
              // Login Button
              Expanded(
                child: Container(
                  height: smallButtonHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login_rounded,
                          size: isVerySmallScreen ? 14 : 18,
                          color: Colors.white.withOpacity(0.95),
                        ),
                        SizedBox(width: isVerySmallScreen ? 4 : 8),
                        Flexible(
                          child: Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.tajawal(
                              fontSize: smallButtonFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: isVerySmallScreen ? 8 : 12),

              // Guest Button
              Expanded(
                child: Container(
                  height: smallButtonHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WidgetTree(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.explore_rounded,
                          size: isVerySmallScreen ? 14 : 18,
                          color: Colors.white.withOpacity(0.95),
                        ),
                        SizedBox(width: isVerySmallScreen ? 4 : 8),
                        Flexible(
                          child: Text(
                            'تصفح كضيف',
                            style: GoogleFonts.tajawal(
                              fontSize: smallButtonFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildFooter(bool isSmallScreen, bool isVerySmallScreen) {
    final fontSize = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0);

    return Container(
      margin: EdgeInsets.all(isVerySmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'بإنشائك حسابًا، فإنك توافق على شروط الاستخدام وسياسة الخصوصية الخاصة بنا.',
            style: GoogleFonts.tajawal(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: Colors.white60,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isVerySmallScreen ? 8 : 12),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  _showDialog(
                    'الشروط والأحكام',
                    'هذه هي شروط وأحكام استخدام التطبيق. يرجى قراءتها بعناية قبل الموافقة عليها.',
                  );
                },
                child: Text(
                  'الشروط والأحكام',
                  style: GoogleFonts.tajawal(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667EEA),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' • ',
                style: GoogleFonts.tajawal(
                  color: Colors.white60,
                  fontSize: fontSize,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showDialog(
                    'سياسة الخصوصية',
                    'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.',
                  );
                },
                child: Text(
                  'سياسة الخصوصية',
                  style: GoogleFonts.tajawal(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667EEA),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
