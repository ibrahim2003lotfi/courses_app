import 'package:courses_app/bloc/course_management_bloc.dart';
import 'package:courses_app/services/review_service.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// نموذج بيانات الدفع
class PaymentData {
  String paymentMethod = 'syriatel';
  String subscriptionType = 'course';
  String phoneNumber = '';
  String confirmPhoneNumber = '';
}

class CourseHeader extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    course['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: isDarkMode
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFF3F4F6),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course['category'] ?? 'عام',
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          course['title'],
                          style: GoogleFonts.tajawal(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course['teacher'],
                          style: GoogleFonts.tajawal(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CourseInfoCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseInfoCard({super.key, required this.course});

  void _showPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentBottomSheet(
        course: course,
        onEnrollmentSuccess: () {
          // This will trigger the BLoC to enroll the user
          context.read<CourseManagementBloc>().add(
            EnrollCourseEvent(course),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseManagementBloc, CourseManagementState>(
      builder: (context, courseState) {
        final isEnrolled = courseState.enrolledCourses
            .any((c) => c['id'] == course['id']);
        
        if (isEnrolled) {
          return _buildEnrolledInfo(context);
        } else {
          return _buildPurchaseInfo(context);
        }
      },
    );
  }

  Widget _buildEnrolledInfo(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF10B981),
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'أنت مسجل في هذه الدورة',
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يمكنك الآن البدء في مشاهدة المحاضرات',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Scroll to lessons or show message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'انتقل إلى قائمة المحاضرات للبدء في التعلم',
                                style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            'ابدأ التعلم',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  Widget _buildPurchaseInfo(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return _buildMobileLayout(context, isDarkMode);
                    } else {
                      return _buildDesktopLayout(context, isDarkMode);
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRatingRow(isDarkMode),
        const SizedBox(height: 16),
        _buildInfoGrid(isDarkMode),
        const SizedBox(height: 16),
        _buildPriceSection(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDarkMode) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _buildPriceSection(context),
        const SizedBox(width: 24),
        _buildRatingRow(isDarkMode),
        const SizedBox(width: 24),
        Expanded(child: _buildInfoGrid(isDarkMode)),
      ],
    );
  }

  Widget _buildRatingRow(bool isDarkMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            Text(
              '(${course['reviews'] ?? 0} تقييم) ',
              style: GoogleFonts.tajawal(
                color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              course['rating'].toStringAsFixed(1),
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: Colors.amber, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${course['students']} طالب مسجل',
          style: GoogleFonts.tajawal(
            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoGrid(bool isDarkMode) {
    // Get real duration and lessons from course data
    final duration = course['duration'] ?? 0;
    final lessons = course['lessons'] ?? 0;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.5,
      children: [
        _buildInfoItem(
          Icons.schedule,
          '$duration ساعة',
          isDarkMode,
        ),
        _buildInfoItem(
          Icons.video_library,
          '$lessons محاضرة',
          isDarkMode,
        ),
        _buildInfoItem(Icons.bar_chart, course['level'] ?? 'متوسط', isDarkMode),
        _buildInfoItem(
          Icons.update,
          'محدث ${course['lastUpdated'] ?? '2026'}',
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF374151),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            size: 16,
            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return BlocBuilder<CourseManagementBloc, CourseManagementState>(
      builder: (context, courseState) {
        final isInWatchLater = courseState.watchLaterCourses
            .any((c) => c['id'] == course['id']);

        return Column(
          children: [
            Text(
              course['price'] ?? '200,000 S.P',
              style: GoogleFonts.tajawal(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF10B981),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Watch Later Button
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isInWatchLater ? 
                        const Color(0xFF10B981) : 
                        const Color(0xFFD1D5DB),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context.read<CourseManagementBloc>().add(
                    ToggleWatchLaterEvent(course),
                  );
                  
                  // Show feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isInWatchLater ? 
                        'تمت إزالة الدورة من قائمة المشاهدة لاحقاً' : 
                        'تمت إضافة الدورة إلى قائمة المشاهدة لاحقاً',
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: isInWatchLater ? Colors.orange : Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInWatchLater ? Icons.bookmark : Icons.bookmark_border,
                        color: isInWatchLater ? 
                              const Color(0xFF10B981) : 
                              const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isInWatchLater ? 'محفوظة' : 'حفظ للمشاهدة لاحقاً',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isInWatchLater ? 
                                const Color(0xFF10B981) : 
                                const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Enroll Button
            Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showPaymentBottomSheet(context),
                child: Center(
                  child: Text(
                    'اشترك الآن',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


class PaymentBottomSheet extends StatefulWidget {
  final Map<String, dynamic> course;
  final VoidCallback onEnrollmentSuccess;

  const PaymentBottomSheet({
    super.key, 
    required this.course,
    required this.onEnrollmentSuccess,
  });

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final PaymentData _paymentData = PaymentData();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final String _orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'syriatel',
      name: 'Syriatel Cash',
      imagePath: 'assets/images/syriatel_logo.jpg',
      color: Colors.blue,
    ),
    PaymentMethod(
      id: 'mtn',
      name: 'MTN Cash',
      imagePath: 'assets/images/MTN_logo.png',
      color: Colors.orange,
    ),
    PaymentMethod(
      id: 'sham',
      name: 'Sham Cash',
      imagePath: 'assets/images/shamcache_logo.jpg',
      color: Colors.green,
    ),
  ];

  final List<SubscriptionType> _subscriptionTypes = [
    SubscriptionType(
      id: 'course',
      name: 'شراء الكورس الحالي',
      priceMultiplier: 1.0,
    ),
    SubscriptionType(
      id: 'monthly',
      name: 'الباقة الشهرية',
      priceMultiplier: 1.5,
    ),
    SubscriptionType(
      id: 'yearly',
      name: 'الباقة السنوية',
      priceMultiplier: 10.0,
    ),
  ];

  bool get _isFreeCourse {
    final priceString = widget.course['price']?.toString() ?? '199';
    return priceString.toLowerCase().contains('مجاني') ||
        priceString.toLowerCase().contains('free') ||
        priceString == '0 S.P';
  }

  double get _basePrice {
    if (_isFreeCourse) return 0.0;

    final priceString = widget.course['price']?.toString() ?? '199';
    try {
      final cleanPrice = priceString
          .replaceAll('S.P', '')
          .replaceAll(',', '')
          .trim();
      return double.parse(cleanPrice);
    } catch (e) {
      print('Error parsing price: $e');
      return 0.0;
    }
  }

  double get _taxAmount => _isFreeCourse ? 0.0 : _basePrice * 0.1;
  double get _totalPrice {
    if (_isFreeCourse) return 0.0;

    final selectedType = _subscriptionTypes.firstWhere(
      (type) => type.id == _paymentData.subscriptionType,
      orElse: () => _subscriptionTypes.first,
    );
    return (_basePrice * selectedType.priceMultiplier) + _taxAmount;
  }

  void _processPayment() async {
    if (_isFreeCourse) {
      _enrollFreeCourse();
      return;
    }

    // For paid courses - show message that buying is not available yet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'شراء الكورسات غير متاح حالياً، سيتم تفعيله قريباً',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    
    // Close the payment bottom sheet
    Navigator.of(context).pop();
  }

  void _enrollFreeCourse() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onEnrollmentSuccess(); // Call the success callback for free courses too

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيلك في الكورس المجاني بنجاح!',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final bottomSheetHeight = screenHeight * 0.75;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: bottomSheetHeight,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Handle at the top - positioned to the left in RTL
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 32,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Text(
                          _isFreeCourse
                              ? 'تسجيل في الكورس المجاني'
                              : 'إتمام عملية الدفع',
                          style: GoogleFonts.tajawal(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w900,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 32,
                          vertical: 8,
                        ),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildCourseInfo(isMobile, isDarkMode),
                                const SizedBox(height: 24),

                                if (_isFreeCourse) ...[
                                  _buildFreeCourseEnrollment(
                                    isMobile,
                                    isDarkMode,
                                  ),
                                  const SizedBox(height: 24),
                                ] else ...[
                                  _buildPaymentMethods(isMobile, isDarkMode),
                                  const SizedBox(height: 24),

                                  _buildPaymentSummary(isMobile, isDarkMode),
                                  const SizedBox(height: 24),

                                  _buildPaymentInfo(isMobile, isDarkMode),
                                  const SizedBox(height: 32),
                                ],

                                _buildActionButtons(isMobile, isDarkMode),
                                SizedBox(
                                  height: MediaQuery.of(context).padding.bottom,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildFreeCourseEnrollment(bool isMobile, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.celebration, size: 40, color: const Color(0xFF10B981)),
          const SizedBox(height: 12),
          Text(
            'هذا الكورس مجاني بالكامل!',
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك التسجيل مباشرة دون أي تكاليف',
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF065F46).withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(bool isMobile, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'بيانات الكورس',
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.school,
            widget.course['title']?.toString() ?? 'دورة تعليمية',
            isMobile,
            isDarkMode,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.person,
            widget.course['teacher']?.toString() ?? 'مدرس متخصص',
            isMobile,
            isDarkMode,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.confirmation_number,
            'رقم الطلب: $_orderNumber',
            isMobile,
            isDarkMode,
            isSmall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    bool isMobile,
    bool isDarkMode, {
    bool isSmall = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          icon,
          size: isSmall ? 14 : (isMobile ? 16 : 18),
          color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: isSmall ? 12 : (isMobile ? 14 : 16),
              fontWeight: isSmall ? FontWeight.w500 : FontWeight.w600,
              color: isSmall
                  ? (isDarkMode ? Colors.white70 : const Color(0xFF6B7280))
                  : (isDarkMode ? Colors.white : const Color(0xFF374151)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(bool isMobile, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'طرق الدفع المتاحة',
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ..._paymentMethods.map(
          (method) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              value: method.id,
              groupValue: _paymentData.paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentData.paymentMethod = value!;
                });
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    method.name,
                    style: GoogleFonts.tajawal(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    method.imagePath,
                    width: isMobile ? 20 : 24,
                    height: isMobile ? 20 : 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: isMobile ? 20 : 24,
                        height: isMobile ? 20 : 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: isMobile ? 14 : 18,
                        ),
                      );
                    },
                  ),
                ],
              ),
              activeColor: const Color(0xFF10B981),
              contentPadding: EdgeInsets.zero,
              tileColor: isDarkMode
                  ? const Color(0xFF2D2D2D)
                  : Colors.transparent,
              controlAffinity:
                  ListTileControlAffinity.leading, // Radio on the left
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(bool isMobile, bool isDarkMode) {
    if (_isFreeCourse) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              'ملخص التسجيل',
              style: GoogleFonts.tajawal(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF065F46),
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('سعر الكورس', 'مجاني', isMobile, isDarkMode),
            _buildSummaryRow('الضرائب', ' 0.00 S.P ', isMobile, isDarkMode),
            Divider(color: isDarkMode ? Colors.grey[600] : Colors.grey[300]),
            _buildSummaryRow(
              'الإجمالي',
              'مجاني',
              isMobile,
              isDarkMode,
              isTotal: true,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A3C2A) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(isDarkMode ? 0.5 : 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'ملخص الدفع',
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w800,
              color: isDarkMode
                  ? const Color(0xFF34D399)
                  : const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'السعر الأساسي',
            '${_basePrice.toStringAsFixed(2)} S.P ',
            isMobile,
            isDarkMode,
          ),
          _buildSummaryRow(
            'الضرائب',
            '${_taxAmount.toStringAsFixed(2)} S.P ',
            isMobile,
            isDarkMode,
          ),
          Divider(color: isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          _buildSummaryRow(
            'الإجمالي',
            '${_totalPrice.toStringAsFixed(2)} S.P ',
            isMobile,
            isDarkMode,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isMobile,
    bool isDarkMode, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              color: isTotal
                  ? (isDarkMode
                        ? const Color(0xFF34D399)
                        : const Color(0xFF065F46))
                  : (isDarkMode ? Colors.white : const Color(0xFF374151)),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isTotal
                  ? (isDarkMode
                        ? const Color(0xFF34D399)
                        : const Color(0xFF065F46))
                  : (isDarkMode ? Colors.white : const Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(bool isMobile, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'معلومات الدفع',
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            labelText: 'رقم الهاتف',
            labelStyle: GoogleFonts.tajawal(
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
            suffixIcon: Icon(
              Icons.phone,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : const Color(0xFFD1D5DB),
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 12 : 16,
            ),
          ),
          style: GoogleFonts.tajawal(
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال رقم الهاتف';
            }
            if (value.length < 10) {
              return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
            }
            return null;
          },
          onChanged: (value) => _paymentData.phoneNumber = value,
        ),
        const SizedBox(height: 12),
        TextFormField(
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            labelText: 'تأكيد رقم الهاتف',
            labelStyle: GoogleFonts.tajawal(
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
            suffixIcon: Icon(
              Icons.phone_android,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : const Color(0xFFD1D5DB),
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 12 : 16,
            ),
          ),
          style: GoogleFonts.tajawal(
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != _paymentData.phoneNumber) {
              return 'رقم الهاتف غير متطابق';
            }
            return null;
          },
          onChanged: (value) => _paymentData.confirmPhoneNumber = value,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile, bool isDarkMode) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey[600]! : const Color(0xFFD1D5DB),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.tajawal(
                    fontSize: isMobile ? 16 : 18,
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
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: _isFreeCourse
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: _isFreeCourse ? const Color(0xFF10B981) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isLoading ? null : _processPayment,
              child: Center(
                child: _isLoading
                    ? SizedBox(
                        height: isMobile ? 20 : 24,
                        width: isMobile ? 20 : 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        _isFreeCourse ? 'سجل مجاناً' : 'تأكيد الدفع',
                        style: GoogleFonts.tajawal(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// نموذج لطريقة الدفع (قابل للتوسع)
class PaymentMethod {
  final String id;
  final String name;
  final String imagePath;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.color,
  });
}

// نموذج لنوع الاشتراك
class SubscriptionType {
  final String id;
  final String name;
  final double priceMultiplier;

  SubscriptionType({
    required this.id,
    required this.name,
    required this.priceMultiplier,
  });
}





class CourseTabs extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseTabs({super.key, required this.course});

  @override
  State<CourseTabs> createState() => _CourseTabsState();
}

class _CourseTabsState extends State<CourseTabs> {
  int _selectedTab = 0;
  final ReviewService _reviewService = ReviewService();
  Map<String, dynamic>? _ratingInfo;
  bool _isLoadingRatings = false;

  @override
  void initState() {
    super.initState();
    _fetchRatingInfo();
  }

  Future<void> _fetchRatingInfo() async {
    final courseId = widget.course['id']?.toString();
    if (courseId == null || courseId.isEmpty) return;

    setState(() {
      _isLoadingRatings = true;
    });

    try {
      final response = await _reviewService.getCourseRating(courseId);
      if (mounted && response['rating_info'] != null) {
        setState(() {
          _ratingInfo = response['rating_info'] as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print('Error fetching rating info: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRatings = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Responsive tabs - horizontal on desktop, scrollable on mobile
                  if (isMobile)
                    _buildMobileTabs(isDarkMode)
                  else
                    _buildDesktopTabs(isDarkMode),

                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                    ),
                    child: _buildTabContent(isDarkMode, isMobile),
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

  Widget _buildDesktopTabs(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _buildTab('الوصف', 0, isDarkMode),
          _buildTab('المحتويات', 1, isDarkMode),
          _buildTab('التقييمات', 2, isDarkMode),
          _buildTab('المدرب', 3, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMobileTabs(bool isDarkMode) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true, // RTL scrolling
        children: [
          _buildMobileTab('المدرب', 3, isDarkMode),
          _buildMobileTab('التقييمات', 2, isDarkMode),
          _buildMobileTab('المحتويات', 1, isDarkMode),
          _buildMobileTab('الوصف', 0, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, bool isDarkMode) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : (isDarkMode ? Colors.white70 : const Color(0xFF6B7280)),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTab(String title, int index, bool isDarkMode) {
    final isSelected = _selectedTab == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDarkMode ? Colors.white70 : const Color(0xFF6B7280)),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(bool isDarkMode, bool isMobile) {
    try {
      switch (_selectedTab) {
        case 0:
          return _buildDescription(isDarkMode, isMobile);
        case 1:
          return _buildCurriculum(isDarkMode, isMobile);
        case 2:
          return _buildReviews(isDarkMode, isMobile);
        case 3:
          return _buildInstructor(isDarkMode, isMobile);
        default:
          return _buildDescription(isDarkMode, isMobile);
      }
    } catch (e, stackTrace) {
      print('Error in _buildTabContent for tab $_selectedTab: $e');
      print('Stack trace: $stackTrace');
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'حدث خطأ في تحميل المحتوى. الرجاء المحاولة مرة أخرى.',
          style: GoogleFonts.tajawal(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
      );
    }
  }

  Widget _buildDescription(bool isDarkMode, bool isMobile) {
  // Get real description from course data
  final description = widget.course['description']?.toString();
  final hasDescription = description != null && description.isNotEmpty;
  // Get category name for tag
  final categoryName = widget.course['category']?.toString();
  final hasCategory = categoryName != null && categoryName.isNotEmpty;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          'عن هذا الكورس',
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          textAlign: TextAlign.right,
        ),
      ),
      const SizedBox(height: 12),
      if (hasDescription)
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            description!,
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      const SizedBox(height: 16),
      // Show category tag if available
      if (hasCategory)
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categoryName!,
                  style: GoogleFonts.tajawal(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

Widget _buildCurriculum(bool isDarkMode, bool isMobile) {
  // Get real sections data from course
  final sections = widget.course['sections'] as List? ?? [];
  
  // Debug logging
  print('DEBUG - Course sections: ${sections.length}');
  if (sections.isNotEmpty) {
    print('DEBUG - First section: ${sections[0]}');
    final lessons = sections[0]['lessons'] as List? ?? [];
    print('DEBUG - First section lessons count: ${lessons.length}');
    if (lessons.isNotEmpty) {
      print('DEBUG - First lesson: ${lessons[0]}');
    }
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          'محتويات الكورس',
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          textAlign: TextAlign.right,
        ),
      ),
      const SizedBox(height: 12),
      
      // If no sections available, show placeholder
      if (sections.isEmpty)
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2D2D2D)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'لا يوجد محتوى متاح حالياً',
                    style: GoogleFonts.tajawal(
                      fontSize: isMobile ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? Colors.white70
                          : const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        )
      else
        // Build lessons list from all sections
        ...sections.expand<Widget>((section) {
          final sectionTitle = section['title'] ?? 'قسم';
          final lessons = section['lessons'] as List? ?? [];
          
          return lessons.asMap().entries.map<Widget>((entry) {
            final lessonIndex = entry.key;
            final lesson = entry.value as Map<String, dynamic>;
            final lessonTitle = lesson['title'] ?? lesson['name'] ?? 'محاضرة ${lessonIndex + 1}';
            final lessonDescription = lesson['description']?.toString();
            final duration = lesson['duration'] ?? 0;
            final durationMinutes = duration > 0 ? (duration / 60).ceil() : 0;
            
            return Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Duration on the far right
                        if (duration > 0)
                          Text(
                            '$durationMinutes دقيقة',
                            style: GoogleFonts.tajawal(
                              fontSize: isMobile ? 11 : 12,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        if (duration > 0)
                          SizedBox(width: isMobile ? 8 : 12),
                        
                        // Lecture title in the middle
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              lessonTitle,
                              style: GoogleFonts.tajawal(
                                fontSize: isMobile ? 13 : 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF374151),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        
                        // Lock icon on the left
                        Container(
                          width: isMobile ? 28 : 32,
                          height: isMobile ? 28 : 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: isMobile ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                    // Show description if available
                    if (lessonDescription != null && lessonDescription.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 40),
                        child: Text(
                          lessonDescription,
                          style: GoogleFonts.tajawal(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode
                                ? Colors.white60
                                : const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList();
        }).toList(),
    ],
  );
}

Widget _buildReviews(bool isDarkMode, bool isMobile) {
  // Get real rating data
  final avgRating = _ratingInfo?['average_rating'] ?? widget.course['rating'] ?? 0.0;
  final totalRatings = _ratingInfo?['total_ratings'] ?? widget.course['reviews'] ?? 0;
  final ratingBreakdown = _ratingInfo?['breakdown'] as Map<String, dynamic>? ?? {};
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          'تقييمات الطلاب',
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          textAlign: TextAlign.right,
        ),
      ),
      const SizedBox(height: 16),
      
      // Rating Summary Card
      Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Average Rating
            Column(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: GoogleFonts.tajawal(
                    fontSize: isMobile ? 36 : 42,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < avgRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: isMobile ? 16 : 18,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalRatings تقييم',
                  style: GoogleFonts.tajawal(
                    fontSize: isMobile ? 12 : 13,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            
            // Rating Breakdown
            if (ratingBreakdown.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      final count = ratingBreakdown[star.toString()] ?? 0;
                      final percentage = totalRatings > 0
                          ? (count / totalRatings * 100).toInt()
                          : 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              '$star',
                              style: GoogleFonts.tajawal(
                                fontSize: isMobile ? 11 : 12,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              size: isMobile ? 12 : 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: totalRatings > 0 ? count / totalRatings : 0,
                                backgroundColor: isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFF59E0B),
                                ),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.tajawal(
                                fontSize: isMobile ? 10 : 11,
                                color: isDarkMode
                                    ? Colors.white60
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
      
      const SizedBox(height: 20),
      
      // Show message when no reviews or just the count
      if (_isLoadingRatings)
        const Center(
          child: CircularProgressIndicator(),
        )
      else if (totalRatings == 0)
        Center(
          child: Text(
            'لا توجد تقييمات بعد. كن أول من يقيم هذه الدورة!',
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              color: isDarkMode
                  ? Colors.white70
                  : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        )
      else
        // Show only the total count message
        Center(
          child: Text(
            'عدد التقييمات: $totalRatings',
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? Colors.white70
                  : const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ),
    ],
  );
}

Widget _buildInstructor(bool isDarkMode, bool isMobile) {
  // Get real instructor data from course
  final instructor = widget.course['instructor'] as Map<String, dynamic>?;
  final instructorName = widget.course['teacher']?.toString() ?? instructor?['name']?.toString() ?? 'مدرب';
  final instructorBio = instructor?['bio']?.toString() ?? instructor?['description']?.toString();
  final instructorCoursesCount = instructor?['courses_count']?.toString() ?? widget.course['instructor_courses_count']?.toString() ?? '0';
  final instructorRating = instructor?['average_rating'] ?? widget.course['instructor_rating'] ?? widget.course['rating'] ?? 0.0;
  
  // Use passed instructor stats if available, otherwise use defaults
  final totalStudents = widget.course['students']?.toString() ?? '0';
  final coursesCount = instructorCoursesCount != '0' ? instructorCoursesCount : '1';
  final avgRating = (instructorRating is num) ? instructorRating.toStringAsFixed(1) : '0.0';
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          'عن المدرب',
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          textAlign: TextAlign.right,
        ),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerRight,
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Text content on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      instructorName,
                      style: GoogleFonts.tajawal(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Only show subtitle if instructor bio is not available
                  if (instructorBio == null || instructorBio.isEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.course['category']?.toString() ?? '',
                        style: GoogleFonts.tajawal(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      textDirection: TextDirection.rtl,
                      children: [
                        _buildInstructorStat(coursesCount, 'كورس', isDarkMode, isMobile),
                        SizedBox(width: isMobile ? 12 : 16),
                        _buildInstructorStat(
                          totalStudents,
                          'طالب',
                          isDarkMode,
                          isMobile,
                        ),
                        SizedBox(width: isMobile ? 12 : 16),
                        _buildInstructorStat(
                          avgRating,
                          'التقييم',
                          isDarkMode,
                          isMobile,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            
            // Avatar on the left
            Container(
              width: isMobile ? 70 : 80,
              height: isMobile ? 70 : 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: isMobile ? 33 : 38,
                backgroundImage: instructor?['avatar'] != null
                    ? NetworkImage(instructor!['avatar'].toString())
                    : null,
                backgroundColor: isDarkMode
                    ? Colors.grey[700]
                    : Colors.grey[300],
                child: instructor?['avatar'] == null
                    ? Icon(
                        Icons.person,
                        size: isMobile ? 35 : 40,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (instructorBio != null && instructorBio.isNotEmpty)
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            instructorBio,
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
        ),
    ],
  );
}

  Widget _buildInstructorStat(
    String value,
    String label,
    bool isDarkMode,
    bool isMobile,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 15 : 16,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class RelatedCourses extends StatelessWidget {
  final List<Map<String, dynamic>> relatedCourses;
  final Function(Map<String, dynamic>) onCourseTap;

  const RelatedCourses({
    super.key,
    required this.relatedCourses,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final courseWidth = isMobile ? 280.0 : 320.0;
        final courseHeight = isMobile ? 200.0 : 220.0;

        // Create a reversed list for RTL display
        final reversedCourses = List<Map<String, dynamic>>.from(
          relatedCourses.reversed,
        );

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title aligned to the right
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: isMobile
                            ? 0
                            : 0, // Remove extra padding since Align handles positioning
                      ),
                      child: Text(
                        'كورسات ذات صلة',
                        style: GoogleFonts.tajawal(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: courseHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: reversedCourses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final course = reversedCourses[index];
                        return SizedBox(
                          width: courseWidth,
                          child: GestureDetector(
                            onTap: () => onCourseTap(course),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDarkMode ? 0.2 : 0.05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: isDarkMode
                                      ? Border.all(color: Colors.white30)
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Course Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        course['image'],
                                        width: courseWidth,
                                        height: courseHeight * 0.6,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                width: courseWidth,
                                                height: courseHeight * 0.6,
                                                color: isDarkMode
                                                    ? const Color(0xFF2D2D2D)
                                                    : const Color(0xFFF3F4F6),
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          isDarkMode
                                                              ? Colors.white70
                                                              : const Color(
                                                                  0xFF2563EB,
                                                                ),
                                                        ),
                                                  ),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: courseWidth,
                                                height: courseHeight * 0.6,
                                                color: isDarkMode
                                                    ? const Color(0xFF2D2D2D)
                                                    : const Color(0xFFF3F4F6),
                                                child: Icon(
                                                  Icons.error_outline,
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : const Color(0xFF6B7280),
                                                  size: isMobile ? 32 : 40,
                                                ),
                                              );
                                            },
                                      ),
                                    ),

                                    // Course Info
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          isMobile ? 10 : 12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Course Title
                                            Text(
                                              course['title'],
                                              style: GoogleFonts.tajawal(
                                                fontSize: isMobile ? 14 : 15,
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : const Color(0xFF374151),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                            ),

                                            // Course Rating and Price
                                            Row(
                                              textDirection: TextDirection.rtl,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Price on the right
                                                Flexible(
                                                  child: Text(
                                                    course['price'] ?? 'مجاني',
                                                    style: GoogleFonts.tajawal(
                                                      fontSize: isMobile
                                                          ? 14
                                                          : 15,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          course['price']
                                                                  ?.toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    'مجاني',
                                                                  ) ??
                                                              false
                                                          ? const Color(
                                                              0xFF10B981,
                                                            )
                                                          : const Color(
                                                              0xFF10B981,
                                                            ),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),

                                                // Rating on the left
                                                Row(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      course['rating']
                                                              ?.toStringAsFixed(
                                                                1,
                                                              ) ??
                                                          '5.0',
                                                      style:
                                                          GoogleFonts.tajawal(
                                                            fontSize: isMobile
                                                                ? 12
                                                                : 13,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isDarkMode
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF374151,
                                                                  ),
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      width: isMobile ? 2 : 4,
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      size: isMobile ? 12 : 14,
                                                      color: Colors.amber,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
