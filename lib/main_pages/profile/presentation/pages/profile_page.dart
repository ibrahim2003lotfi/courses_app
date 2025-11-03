import 'package:courses_app/bloc/user_role_bloc.dart';
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/instructor/presentation/pages/instructor_registration_page.dart';
import 'package:courses_app/main_pages/profile/presentation/edit_profile.dart';
import 'package:courses_app/main_pages/profile/presentation/pages/settings_page.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRoleBloc, UserRoleState>(
      builder: (context, roleState) {
        final bool isTeacher = roleState.isTeacher;

        // بيانات المستخدم النموذجية - updated to use BLoC
        final Map<String, dynamic> userProfile = {
          'name': 'أحمد محمد السالم',
          'email': 'ahmed.salem@example.com',
          'username': '@ahmed_salem',
          'type': isTeacher ? 'مدرس' : 'انضم الينا كمدرس',
          'profileImage': 'https://picsum.photos/seed/profile/200/200',
          'coverImage': 'https://picsum.photos/seed/cover/800/300',
          'joinDate': 'انضم في مارس 2023',
          'bio': isTeacher
              ? 'مدرس متخصص في تطوير التطبيقات وتقنية المعلومات.'
              : 'مطور تطبيقات محمول ومهتم بالتعلم المستمر في مجال التكنولوجيا والبرمجة.',
        };

        // إحصائيات المستخدم
        final Map<String, dynamic> userStats = {
          'enrolled': 12,
          'completed': 8,
          'certificates': 5,
        };

        // الشهادات المكتسبة
        final List<Map<String, dynamic>> certificates = [
          {
            'title': 'شهادة Flutter المتقدم',
            'date': '2024',
            'color': Colors.blue,
            'icon': Icons.code,
          },
          {
            'title': 'شهادة UI/UX Design',
            'date': '2024',
            'color': Colors.purple,
            'icon': Icons.design_services,
          },
          {
            'title': 'شهادة التسويق الرقمي',
            'date': '2023',
            'color': Colors.orange,
            'icon': Icons.campaign,
          },
          {
            'title': 'شهادة إدارة المشاريع',
            'date': '2023',
            'color': Colors.green,
            'icon': Icons.business_center,
          },
          {
            'title': 'شهادة تحليل البيانات',
            'date': '2023',
            'color': Colors.teal,
            'icon': Icons.analytics,
          },
        ];

        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final isDarkMode = themeState.isDarkMode;

            return Theme(
              data: isDarkMode
                  ? ThemeManager.darkTheme
                  : ThemeManager.lightTheme,
              child: Scaffold(
                backgroundColor: _getBackgroundColor(isDarkMode),
                body: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      // Header with Cover and Profile Image
                      SliverToBoxAdapter(
                        child: _buildProfileHeader(isDarkMode),
                      ),

                      // User Info Section
                      SliverToBoxAdapter(
                        child: _buildUserInfo(
                          isDarkMode,
                          isTeacher,
                          userProfile,
                        ),
                      ),

                      // User Statistics
                      SliverToBoxAdapter(
                        child: _buildUserStats(isDarkMode, userStats),
                      ),

                      // Certificates Section
                      SliverToBoxAdapter(
                        child: _buildCertificatesSection(
                          isDarkMode,
                          certificates,
                        ),
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

  // Helper method to get text color based on theme
  Color _getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : const Color(0xFF1E293B);
  }

  // Helper method to get card color based on theme
  Color _getCardColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  // Helper method to get background color based on theme
  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
  }

  // Helper method to get secondary text color based on theme
  Color _getSecondaryTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    return Container(
      height: 280,
      child: Stack(
        children: [
          // Cover Image with Gradient Overlay
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
              ),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/cover/800/300'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.3),
                  BlendMode.overlay,
                ),
              ),
            ),
          ),

          // Settings Button - Added in top right corner
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: IconButton(
                  icon: Icon(Icons.settings, color: Colors.white, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 36, minHeight: 36),
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
              child: Container(
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
                  backgroundImage: const NetworkImage(
                    'https://picsum.photos/seed/profile/200/200',
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(
    bool isDarkMode,
    bool isTeacher,
    Map<String, dynamic> userProfile,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // User Name
          Text(
            userProfile['name'],
            style: GoogleFonts.tajawal(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getTextColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Email and Username
          Text(
            userProfile['email'],
            style: TextStyle(
              fontSize: 16,
              color: _getSecondaryTextColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            userProfile['username'],
            style: TextStyle(
              fontSize: 14,
              color: _getSecondaryTextColor(isDarkMode),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // User Level Badge - Make it clickable if user is student
          GestureDetector(
            onTap: !isTeacher
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InstructorRegistrationPage(),
                      ),
                    );
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTeacher ? Icons.school : Icons.menu_book_sharp,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isTeacher ? 'مدرس' : 'انضم الينا كمدرس',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bio
          if (userProfile['bio'] != null)
            Text(
              userProfile['bio'],
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: _getSecondaryTextColor(isDarkMode),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 8),

          // Join Date
          Text(
            userProfile['joinDate'],
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: _getSecondaryTextColor(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(bool isDarkMode, Map<String, dynamic> userStats) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;

            if (isTablet) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildStatItems(isDarkMode, userStats),
              );
            } else {
              return IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _buildStatItems(isDarkMode, userStats)[0]),
                    _buildVerticalDivider(isDarkMode),
                    Expanded(child: _buildStatItems(isDarkMode, userStats)[1]),
                    _buildVerticalDivider(isDarkMode),
                    Expanded(child: _buildStatItems(isDarkMode, userStats)[2]),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildStatItems(
    bool isDarkMode,
    Map<String, dynamic> userStats,
  ) {
    return [
      _buildStatItem(
        icon: Icons.school,
        count: userStats['enrolled'].toString(),
        label: 'الكورسات المشتركة',
        color: const Color(0xFF3B82F6),
        isDarkMode: isDarkMode,
      ),
      _buildStatItem(
        icon: Icons.check_circle,
        count: userStats['completed'].toString(),
        label: 'الكورسات المكتملة',
        color: const Color(0xFF10B981),
        isDarkMode: isDarkMode,
      ),
      _buildStatItem(
        icon: Icons.workspace_premium,
        count: userStats['certificates'].toString(),
        label: 'الشهادات',
        color: const Color(0xFFF59E0B),
        isDarkMode: isDarkMode,
      ),
    ];
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          count,
          style: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getTextColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _getTextColor(isDarkMode),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDarkMode) {
    return Container(
      width: 1,
      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildCertificatesSection(
    bool isDarkMode,
    List<Map<String, dynamic>> certificates,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.workspace_premium,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'الشهادات المكتسبة',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(isDarkMode),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final certificate = certificates[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: _getCardColor(isDarkMode),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              certificate['color'].withOpacity(0.2),
                              certificate['color'].withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          certificate['icon'],
                          color: certificate['color'],
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          certificate['title'],
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(isDarkMode),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certificate['date'],
                        style: GoogleFonts.tajawal(
                          fontSize: 10,
                          color: _getSecondaryTextColor(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Edit Profile Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'تعديل الملف الشخصي',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Help Button - Removed Settings button from here since we added it to the header
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showHelpDialog(isDarkMode);
              },
              icon: const Icon(Icons.help_outline),
              label: Text(
                'المساعدة',
                style: TextStyle(color: _getTextColor(isDarkMode)),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDarkMode
                      ? Colors.grey[700]!
                      : const Color(0xFFE2E8F0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                _showLogoutDialog(isDarkMode);
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(
                'تسجيل الخروج',
                style: GoogleFonts.tajawal(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.red, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: isDarkMode ? ThemeManager.darkTheme : ThemeManager.lightTheme,
        child: AlertDialog(
          title: Text('المساعدة والدعم'),
          content: Text(
            'يمكنك التواصل مع فريق الدعم من خلال البريد الإلكتروني: support@example.com',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: isDarkMode ? ThemeManager.darkTheme : ThemeManager.lightTheme,
        child: AlertDialog(
          title: Text('تسجيل الخروج'),
          content: Text('هل أنت متأكد من أنك تريد تسجيل الخروج من التطبيق؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performLogout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performLogout() {
    // Implement logout functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الخروج بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    // Navigate to login page or main page
  }
}
