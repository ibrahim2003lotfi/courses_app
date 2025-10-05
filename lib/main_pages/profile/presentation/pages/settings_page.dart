// lib/main_pages/.../settings_page.dart
import 'package:courses_app/main_pages/auth/presentation/pages/login_page.dart';
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool twoFactorAuth = false;
  bool dataSharing = true;
  String selectedLanguage = 'العربية';

  final List<String> languages = ['العربية', 'English', 'Français'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? ThemeManager.darkTheme.scaffoldBackgroundColor
              : ThemeManager.lightTheme.scaffoldBackgroundColor,
          appBar: _buildAppBar(context, isTablet, isDarkMode),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              child: Column(
                children: [
                  // Account Section
                  _buildSectionCard(
                    title: 'الحساب',
                    icon: Icons.person,
                    isDarkMode: isDarkMode,
                    children: [
                      _buildListTile(
                        icon: Icons.lock_outline,
                        title: 'تغيير كلمة المرور',
                        subtitle: 'تحديث كلمة المرور الخاصة بك',
                        onTap: () => _showChangePasswordDialog(),
                        trailing: const Icon(Icons.chevron_right),
                        isDarkMode: isDarkMode,
                      ),

                      _buildDivider(isDarkMode),
                      _buildListTile(
                        icon: Icons.delete_outline,
                        title: 'حذف الحساب',
                        subtitle: 'حذف حسابك نهائياً',
                        onTap: () => _showDeleteAccountDialog(),
                        trailing: const Icon(Icons.chevron_right),
                        titleColor: Colors.red,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Personalization Section
                  _buildSectionCard(
                    title: 'التخصيص',
                    icon: Icons.palette,
                    isDarkMode: isDarkMode,
                    children: [
                      _buildSwitchTile(
                        icon: Icons.dark_mode,
                        title: 'الوضع الليلي',
                        subtitle: 'تفعيل المظهر المظلم',
                        value: isDarkMode,
                        onChanged: (value) =>
                            context.read<ThemeCubit>().toggleTheme(),
                        isDarkMode: isDarkMode,
                      ),

                      _buildDivider(isDarkMode),
                      _buildSwitchTile(
                        icon: Icons.notifications,
                        title: 'الإشعارات',
                        subtitle: 'تلقي إشعارات التطبيق',
                        value: notificationsEnabled,
                        onChanged: (value) =>
                            setState(() => notificationsEnabled = value),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Privacy & Security Section
                  _buildSectionCard(
                    title: 'الأمان والخصوصية',
                    icon: Icons.security,
                    isDarkMode: isDarkMode,
                    children: [
                      _buildDivider(isDarkMode),
                      _buildSwitchTile(
                        icon: Icons.verified_user,
                        title: 'التحقق بخطوتين',
                        subtitle: 'تأمين إضافي لحسابك',
                        value: twoFactorAuth,
                        onChanged: (value) =>
                            setState(() => twoFactorAuth = value),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Support & Info Section
                  _buildSectionCard(
                    title: 'الدعم والمعلومات',
                    icon: Icons.help_outline,
                    isDarkMode: isDarkMode,
                    children: [
                      _buildListTile(
                        icon: Icons.support_agent,
                        title: 'المساعدة والدعم',
                        subtitle: 'تواصل مع فريق الدعم',
                        onTap: () => _showSupportDialog(),
                        trailing: const Icon(Icons.chevron_right),
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(isDarkMode),
                      _buildListTile(
                        icon: Icons.info_outline,
                        title: 'من نحن',
                        subtitle: 'معلومات عن التطبيق',
                        onTap: () => _showAboutDialog(),
                        trailing: const Icon(Icons.chevron_right),
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(isDarkMode),
                      _buildListTile(
                        icon: Icons.description,
                        title: 'الشروط والأحكام',
                        subtitle: 'اطلع على شروط الاستخدام',
                        onTap: () => _showTermsDialog(),
                        trailing: const Icon(Icons.chevron_right),
                        isDarkMode: isDarkMode,
                      ),
                      _buildDivider(isDarkMode),
                      _buildListTile(
                        icon: Icons.privacy_tip,
                        title: 'سياسة الخصوصية',
                        subtitle: 'كيفية التعامل مع بياناتك',
                        onTap: () => _showPrivacyDialog(),
                        trailing: const Icon(Icons.chevron_right),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'تسجيل الخروج',
                        style: GoogleFonts.tajawal(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 18 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
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

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isTablet,
    bool isDarkMode,
  ) {
    return AppBar(
      backgroundColor: isDarkMode
          ? ThemeManager.darkTheme.appBarTheme.backgroundColor
          : ThemeManager.lightTheme.appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDarkMode
              ? ThemeManager.darkTheme.appBarTheme.iconTheme?.color
              : ThemeManager.lightTheme.appBarTheme.iconTheme?.color,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'الإعدادات',
        style: GoogleFonts.tajawal(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? ThemeManager.darkTheme.cardColor
            : ThemeManager.lightTheme.cardColor,
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
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 40 : 36,
                  height: isTablet ? 40 : 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF3B82F6),
                    size: isTablet ? 24 : 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
    required bool isDarkMode,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 4,
      ),
      leading: Container(
        width: isTablet ? 40 : 36,
        height: isTablet ? 40 : 36,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: titleColor ?? Colors.grey[600],
          size: isTablet ? 22 : 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w600,
          color:
              titleColor ??
              (isDarkMode ? Colors.white : const Color(0xFF1E293B)),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.tajawal(
          fontSize: isTablet ? 16 : 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 8 : 4,
      ),
      leading: Container(
        width: isTablet ? 40 : 36,
        height: isTablet ? 40 : 36,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[600], size: isTablet ? 22 : 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.tajawal(
          fontSize: isTablet ? 16 : 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF3B82F6),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
      height: 1,
      indent: 72,
    );
  }

  // Dialog methods (unchanged)...
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تغيير كلمة المرور',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: const Text('سيتم توجيهك لصفحة تغيير كلمة المرور.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'حذف الحساب',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: const Text(
          'تحذير: سيتم حذف حسابك وجميع بياناتك نهائياً. هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'حذف الحساب',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'المساعدة والدعم',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'يمكنك التواصل معنا:\n'
          'البريد الإلكتروني: support@example.com\n'
          'الهاتف: +970-123-456-789\n'
          'ساعات العمل: من 9 صباحاً إلى 5 مساءً',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'من نحن',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'تطبيق تعليمي شامل يهدف إلى توفير أفضل الدورات التعليمية باللغة العربية. '
          'نسعى لتطوير المهارات وتوفير فرص التعلم للجميع.\n\n'
          'الإصدار: 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'الشروط والأحكام',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: const Text('سيتم توجيهك لصفحة الشروط والأحكام الكاملة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'سياسة الخصوصية',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: const Text('سيتم توجيهك لصفحة سياسة الخصوصية الكاملة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
