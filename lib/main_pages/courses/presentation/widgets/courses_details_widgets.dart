import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
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
        
        return SliverAppBar(
          expandedHeight: 300,
          floating: false,
          pinned: true,
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
                      color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDarkMode ? Colors.white70 : const Color(0xFF2563EB),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          course['category'] ?? 'برمجة',
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
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course['teacher'],
                        style: GoogleFonts.tajawal(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
      builder: (context) => PaymentBottomSheet(course: course),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return SliverToBoxAdapter(
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
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDarkMode) {
    return Column(
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
      children: [
        Expanded(child: _buildInfoGrid(isDarkMode)),
        const SizedBox(width: 24),
        _buildRatingRow(isDarkMode),
        const SizedBox(width: 24),
        _buildPriceSection(context),
      ],
    );
  }

  Widget _buildRatingRow(bool isDarkMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              course['rating'].toStringAsFixed(1),
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            Text(
              ' (${course['reviews'] ?? 0} تقييم)',
              style: GoogleFonts.tajawal(
                color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${course['students']} طالب مسجل',
          style: GoogleFonts.tajawal(
            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(bool isDarkMode) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.5,
      children: [
        _buildInfoItem(Icons.schedule, '${course['duration'] ?? 20} ساعة', isDarkMode),
        _buildInfoItem(
          Icons.video_library,
          '${course['lessons'] ?? 30} محاضرة',
          isDarkMode,
        ),
        _buildInfoItem(Icons.bar_chart, course['level'] ?? 'متوسط', isDarkMode),
        _buildInfoItem(Icons.update, 'محدث ${course['lastUpdated'] ?? '2024'}', isDarkMode),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            size: 16, 
            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280)
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Column(
      children: [
        Text(
          course['price'] ?? '₪199',
          style: GoogleFonts.tajawal(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _showPaymentBottomSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            'اشترك الآن',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}


// Bottom Sheet للدفع
class PaymentBottomSheet extends StatefulWidget {
  final Map<String, dynamic> course;

  const PaymentBottomSheet({super.key, required this.course});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final PaymentData _paymentData = PaymentData();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final String _orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';

  // قائمة طرق الدفع القابلة للتوسع
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'syriatel',
      name: 'Syriatel Cash',
      icon: Icons.phone_iphone,
      color: Colors.blue,
    ),
    PaymentMethod(
      id: 'mtn',
      name: 'MTN Cash',
      icon: Icons.phone_android,
      color: Colors.orange,
    ),
  ];

  // قائمة أنواع الاشتراكات
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

  double get _basePrice {
    final priceString = widget.course['price'] ?? '199';
    return double.parse(priceString.replaceAll('₪', '').trim());
  }

  double get _taxAmount => _basePrice * 0.1; // 10% ضريبة
  double get _totalPrice {
    final selectedType = _subscriptionTypes.firstWhere(
      (type) => type.id == _paymentData.subscriptionType,
      orElse: () => _subscriptionTypes.first,
    );
    return (_basePrice * selectedType.priceMultiplier) + _taxAmount;
  }

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // محاكاة عملية الدفع
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pop();

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت عملية الدفع بنجاح! رقم الطلب: $_orderNumber',
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final bottomSheetHeight = screenHeight * 0.75; // ثلاثة أرباع الشاشة

        return AnimatedContainer(
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
                  // Handle للسحب
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // العنوان
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: 8,
                    ),
                    child: Center(
                      child: Text(
                        'إتمام عملية الدفع',
                        style: GoogleFonts.tajawal(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  ),

                  // المحتوى الرئيسي
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // بيانات الكورس
                              _buildCourseInfo(isMobile, isDarkMode),
                              const SizedBox(height: 24),

                              // طرق الدفع
                              _buildPaymentMethods(isMobile, isDarkMode),
                              const SizedBox(height: 24),

                              // نوع الاشتراك
                              _buildSubscriptionType(isMobile, isDarkMode),
                              const SizedBox(height: 24),

                              // ملخص الدفع
                              _buildPaymentSummary(isMobile, isDarkMode),
                              const SizedBox(height: 24),

                              // معلومات الدفع
                              _buildPaymentInfo(isMobile, isDarkMode),
                              const SizedBox(height: 32),

                              // أزرار الإجراءات
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
        );
      },
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
          _buildInfoRow(Icons.school, widget.course['title'], isMobile, isDarkMode),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person, widget.course['teacher'], isMobile, isDarkMode),
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
      children: [
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
        const SizedBox(width: 12),
        Icon(
          icon,
          size: isSmall ? 14 : (isMobile ? 16 : 18),
          color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
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
                children: [
                  Text(
                    method.name,
                    style: GoogleFonts.tajawal(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    method.icon,
                    color: method.color,
                    size: isMobile ? 20 : 24,
                  ),
                ],
              ),
              activeColor: const Color(0xFF10B981),
              contentPadding: EdgeInsets.zero,
              tileColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionType(bool isMobile, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'نوع الاشتراك',
          style: GoogleFonts.tajawal(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _paymentData.subscriptionType,
          onChanged: (value) {
            setState(() {
              _paymentData.subscriptionType = value!;
            });
          },
          items: _subscriptionTypes.map((type) {
            return DropdownMenuItem(
              value: type.id,
              child: Text(
                type.name,
                style: GoogleFonts.tajawal(
                  fontSize: isMobile ? 14 : 16,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.right,
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : const Color(0xFFD1D5DB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : const Color(0xFFD1D5DB),
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 12 : 16,
            ),
            isDense: true,
            alignLabelWithHint: true,
          ),
          dropdownColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          style: GoogleFonts.tajawal(
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(bool isMobile, bool isDarkMode) {
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
              color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'السعر الأساسي',
            '₪${_basePrice.toStringAsFixed(2)}',
            isMobile,
            isDarkMode,
          ),
          _buildSummaryRow(
            'الضرائب',
            '₪${_taxAmount.toStringAsFixed(2)}',
            isMobile,
            isDarkMode,
          ),
          Divider(color: isDarkMode ? Colors.grey[600] : Colors.grey[300]),
          _buildSummaryRow(
            'الإجمالي',
            '₪${_totalPrice.toStringAsFixed(2)}',
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
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              color: isTotal
                  ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF065F46))
                  : (isDarkMode ? Colors.white : const Color(0xFF374151)),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: isMobile ? 14 : 16,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              color: isTotal
                  ? (isDarkMode ? const Color(0xFF34D399) : const Color(0xFF065F46))
                  : (isDarkMode ? Colors.white : const Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(bool isMobile, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          decoration: InputDecoration(
            labelText: 'رقم الهاتف',
            labelStyle: GoogleFonts.tajawal(
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
            prefixIcon: Icon(
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
          decoration: InputDecoration(
            labelText: 'تأكيد رقم الهاتف',
            labelStyle: GoogleFonts.tajawal(
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
            prefixIcon: Icon(
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
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : const Color(0xFFD1D5DB),
              ),
              backgroundColor: isDarkMode ? const Color(0xFF2D2D2D) : Colors.transparent,
            ),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
                    'تأكيد الدفع',
                    style: GoogleFonts.tajawal(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
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
  final IconData icon;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildTab('الوصف', 0, isDarkMode),
                      _buildTab('المحتويات', 1, isDarkMode),
                      _buildTab('التقييمات', 2, isDarkMode),
                      _buildTab('المدرب', 3, isDarkMode),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTabContent(isDarkMode),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
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

  Widget _buildTabContent(bool isDarkMode) {
    switch (_selectedTab) {
      case 0:
        return _buildDescription(isDarkMode);
      case 1:
        return _buildCurriculum(isDarkMode);
      case 2:
        return _buildReviews(isDarkMode);
      case 3:
        return _buildInstructor(isDarkMode);
      default:
        return _buildDescription(isDarkMode);
    }
  }

  Widget _buildDescription(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عن هذا الكورس',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.course['description'] ??
              'دورة تعليمية شاملة تغطي أهم المفاهيم والمهارات في هذا المجال. تم تصميم المحتوى بعناية لضمان أفضل تجربة تعلم.',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            height: 1.6,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(widget.course['tags']?.length ?? 3, (index) {
            final tags = widget.course['tags'] ?? ['تعليم', 'تدريب', 'مهارات'];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: isDarkMode ? Border.all(color: Colors.white30) : null,
              ),
              child: Text(
                tags[index],
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2563EB),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCurriculum(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'محتويات الكورس',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: isDarkMode ? Border.all(color: Colors.white30) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'المحاضرة ${index + 1}: مقدمة في ${widget.course['category'] ?? 'الموضوع'}',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
                Text(
                  '${(index + 1) * 15} دقيقة',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isDarkMode 
                ? const LinearGradient(
                    colors: [Color(0xFF1E3A5F), Color(0xFF2D4A7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2563EB).withOpacity(isDarkMode ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'يمكنك مشاهدة باقي المحتوى عند شراء الكورس',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'اشترك الآن للوصول إلى ${widget.course['lessons'] ?? 30} محاضرة كاملة',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviews(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تقييمات الطلاب',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: isDarkMode ? Border.all(color: Colors.white30) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/seed/user${index}/100/100',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'محمد ${index + 1}',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '5.0',
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'منذ ${index + 1} أيام',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'كورس رائع ومفيد جداً، الشرح واضح والمحتوى منظم بشكل ممتاز',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? const LinearGradient(
                    colors: [Color(0xFF1A3C2A), Color(0xFF2D5A3D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(isDarkMode ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.star_rate_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'يمكنك اضافة تقييم خاص بك عند شراء الكورس',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'شارك تجربتك ومساعدة الآخرين في اتخاذ القرار',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructor(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عن المدرب',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  widget.course['instructorImage'] ??
                      'https://picsum.photos/seed/instructor/200/200',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course['teacher'],
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'خبير في ${widget.course['category'] ?? 'التخصص'}',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInstructorStat('5.0', 'التقييم', isDarkMode),
                      const SizedBox(width: 16),
                      _buildInstructorStat(widget.course['students'], 'طالب', isDarkMode),
                      const SizedBox(width: 16),
                      _buildInstructorStat('15', 'كورس', isDarkMode),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'مدرب محترف بخبرة تزيد عن 5 سنوات في المجال. حاصل على شهادات متقدمة ويتمتع بأسلوب شرح مبسط وسهل الفهم.',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            height: 1.6,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildInstructorStat(String value, String label, bool isDarkMode) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 12,
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

  const RelatedCourses({super.key, required this.relatedCourses});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كورسات ذات صلة',
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: relatedCourses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final course = relatedCourses[index];
                      return SizedBox(
                        width: 280,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: isDarkMode ? Border.all(color: Colors.white30) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  course['image'],
                                  width: 280,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 280,
                                      height: 120,
                                      color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isDarkMode ? Colors.white70 : const Color(0xFF2563EB),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 280,
                                      height: 120,
                                      color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course['title'],
                                      style: GoogleFonts.tajawal(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode ? Colors.white : const Color(0xFF374151),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          course['rating'].toStringAsFixed(1),
                                          style: GoogleFonts.tajawal(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode ? Colors.white : const Color(0xFF374151),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          course['price'],
                                          style: GoogleFonts.tajawal(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}