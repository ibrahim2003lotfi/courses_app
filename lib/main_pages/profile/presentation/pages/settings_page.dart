import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool twoFactorAuth = false;
  bool dataSharing = true;
  String selectedLanguage = 'العربية';

  final List<String> languages = ['العربية', 'English', 'Français'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, isTablet),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Column(
            children: [
              // Account Section
              _buildSectionCard(
                title: 'الحساب',
                icon: Icons.person,
                children: [
                  _buildListTile(
                    icon: Icons.lock_outline,
                    title: 'تغيير كلمة المرور',
                    subtitle: 'تحديث كلمة المرور الخاصة بك',
                    onTap: () => _showChangePasswordDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.email_outlined,
                    title: 'إدارة البريد الإلكتروني',
                    subtitle: 'تحديث عنوان البريد الإلكتروني',
                    onTap: () => _showEmailManagementDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.delete_outline,
                    title: 'حذف الحساب',
                    subtitle: 'حذف حسابك نهائياً',
                    onTap: () => _showDeleteAccountDialog(),
                    trailing: const Icon(Icons.chevron_right),
                    titleColor: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Personalization Section
              _buildSectionCard(
                title: 'التخصيص',
                icon: Icons.palette,
                children: [
                  _buildSwitchTile(
                    icon: Icons.dark_mode,
                    title: 'الوضع الليلي',
                    subtitle: 'تفعيل المظهر المظلم',
                    value: isDarkMode,
                    onChanged: (value) => setState(() => isDarkMode = value),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.language,
                    title: 'لغة التطبيق',
                    subtitle: selectedLanguage,
                    onTap: () => _showLanguageDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.notifications,
                    title: 'الإشعارات',
                    subtitle: 'تلقي إشعارات التطبيق',
                    value: notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => notificationsEnabled = value),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Privacy & Security Section
              _buildSectionCard(
                title: 'الأمان والخصوصية',
                icon: Icons.security,
                children: [
                  _buildListTile(
                    icon: Icons.devices,
                    title: 'إدارة الأجهزة',
                    subtitle: 'عرض الأجهزة المرتبطة بحسابك',
                    onTap: () => _showDeviceManagementDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.verified_user,
                    title: 'التحقق بخطوتين',
                    subtitle: 'تأمين إضافي لحسابك',
                    value: twoFactorAuth,
                    onChanged: (value) => setState(() => twoFactorAuth = value),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.share,
                    title: 'مشاركة البيانات',
                    subtitle: 'السماح بمشاركة البيانات لتحسين الخدمة',
                    value: dataSharing,
                    onChanged: (value) => setState(() => dataSharing = value),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Support & Info Section
              _buildSectionCard(
                title: 'الدعم والمعلومات',
                icon: Icons.help_outline,
                children: [
                  _buildListTile(
                    icon: Icons.support_agent,
                    title: 'المساعدة والدعم',
                    subtitle: 'تواصل مع فريق الدعم',
                    onTap: () => _showSupportDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'من نحن',
                    subtitle: 'معلومات عن التطبيق',
                    onTap: () => _showAboutDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.description,
                    title: 'الشروط والأحكام',
                    subtitle: 'اطلع على شروط الاستخدام',
                    onTap: () => _showTermsDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    icon: Icons.privacy_tip,
                    title: 'سياسة الخصوصية',
                    subtitle: 'كيفية التعامل مع بياناتك',
                    onTap: () => _showPrivacyDialog(),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(),
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
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 16),
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
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'الإعدادات',
        style: GoogleFonts.tajawal(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                    color: const Color(0xFF1E293B),
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
          color: titleColor ?? const Color(0xFF1E293B),
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
          color: const Color(0xFF1E293B),
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

  Widget _buildDivider() {
    return Divider(color: Colors.grey[200], height: 1, indent: 72);
  }

  // Dialog methods
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

  void _showEmailManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إدارة البريد الإلكتروني',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: const Text('سيتم توجيهك لصفحة إدارة البريد الإلكتروني.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'اختر اللغة',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showDeviceManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إدارة الأجهزة',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: const Text('سيتم عرض الأجهزة المرتبطة بحسابك.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تسجيل الخروج',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من أنك تريد تسجيل الخروج من التطبيق؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل الخروج بنجاح', style: GoogleFonts.tajawal()),
        backgroundColor: Colors.green,
      ),
    );
    // Navigate to login page
    // Navigator.pushReplacementNamed(context, '/login');
  }
}
