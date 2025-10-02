import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:courses_app/core/utils/theme_manager.dart';

/// Notification model to represent different types of notifications
class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? courseId;
  final String? courseName;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.courseId,
    this.courseName,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? courseId,
    String? courseName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
    );
  }
}

/// Enum for different notification types
enum NotificationType {
  newContent,
  deadline,
  message,
  announcement,
  enrollment,
  achievement,
}

/// Main Notifications Page
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  /// Simulate loading notifications from API or local storage
  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock notifications data
    notifications = _generateMockNotifications();

    setState(() => isLoading = false);
  }

  /// Generate mock notifications for demonstration
  List<NotificationModel> _generateMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'محتوى جديد متاح',
        description: 'تم إضافة محاضرة جديدة في كورس Flutter للمبتدئين',
        timestamp: now.subtract(const Duration(minutes: 30)),
        type: NotificationType.newContent,
        courseId: 'flutter_101',
        courseName: 'Flutter للمبتدئين',
      ),
      NotificationModel(
        id: '2',
        title: 'موعد تسليم قريب',
        description: 'باقي يومان على موعد تسليم مشروع React النهائي',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: NotificationType.deadline,
        courseId: 'react_advanced',
        courseName: 'React المتقدم',
        isRead: true,
      ),
      NotificationModel(
        id: '3',
        title: 'رسالة من المدرب',
        description: 'الأستاذ أحمد أرسل رسالة جديدة حول المشروع العملي',
        timestamp: now.subtract(const Duration(hours: 5)),
        type: NotificationType.message,
        courseId: 'python_data',
        courseName: 'Python لتحليل البيانات',
      ),
      NotificationModel(
        id: '4',
        title: 'إعلان مهم',
        description: 'تأجيل موعد الامتحان النهائي للأسبوع القادم',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationType.announcement,
        courseId: 'web_dev',
        courseName: 'تطوير الويب الشامل',
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'تم التسجيل بنجاح',
        description: 'تم تسجيلك في كورس UI/UX Design بنجاح',
        timestamp: now.subtract(const Duration(days: 2)),
        type: NotificationType.enrollment,
        courseId: 'uiux_design',
        courseName: 'تصميم واجهات المستخدم',
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'تهانينا! إنجاز جديد',
        description: 'لقد أكملت 50% من كورس JavaScript المتقدم',
        timestamp: now.subtract(const Duration(days: 3)),
        type: NotificationType.achievement,
        courseId: 'js_advanced',
        courseName: 'JavaScript المتقدم',
      ),
    ];
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    await _loadNotifications();
  }

  /// Mark notification as read
  void _markAsRead(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    });
  }

  /// Delete notification
  void _deleteNotification(String notificationId) {
    setState(() {
      notifications.removeWhere((n) => n.id == notificationId);
    });
  }

  /// Mark all as read
  void _markAllAsRead() {
    setState(() {
      notifications = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
  }

  /// Clear all notifications
  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return AlertDialog(
              backgroundColor: themeState.isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              title: Text(
                'حذف جميع الإشعارات',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w700,
                  color: themeState.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              content: Text(
                'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
                style: GoogleFonts.tajawal(
                  color: themeState.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.tajawal(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      notifications.clear();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'حذف الكل',
                    style: GoogleFonts.tajawal(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;
        final unreadCount = notifications.where((n) => !n.isRead).length;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _buildAppBar(context, isDarkMode, unreadCount),
          body: isLoading
              ? _buildLoadingState(isDarkMode)
              : notifications.isEmpty
              ? _buildEmptyState(isDarkMode)
              : _buildNotificationsList(isDarkMode),
        );
      },
    );
  }

  /// Build app bar with actions
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDarkMode,
    int unreadCount,
  ) {
    return AppBar(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: isDarkMode ? 1 : 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Text(
            'الإشعارات',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (notifications.isNotEmpty) ...[
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'clear_all':
                  _clearAllNotifications();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(
                      Icons.done_all,
                      size: 20,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'قراءة الكل',
                      style: GoogleFonts.tajawal(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.clear_all, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      'حذف الكل',
                      style: GoogleFonts.tajawal(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? Colors.white70 : const Color(0xFF2563EB),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الإشعارات...',
            style: GoogleFonts.tajawal(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF2D2D2D)
                    : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 64,
                color: isDarkMode ? Colors.white38 : Colors.black26,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'أنت في المقدمة!',
              style: GoogleFonts.tajawal(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد إشعارات جديدة في الوقت الحالي.\nسنقوم بإشعارك بأي جديد.',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: isDarkMode ? Colors.white60 : Colors.black54,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'تحديث',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build notifications list
  Widget _buildNotificationsList(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF2563EB),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, isDarkMode);
        },
      ),
    );
  }

  /// Build individual notification card
  Widget _buildNotificationCard(
    NotificationModel notification,
    bool isDarkMode,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف الإشعار',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
            backgroundColor: isDarkMode
                ? const Color(0xFF2D2D2D)
                : Colors.black87,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Material(
        elevation: isDarkMode ? 4 : 2,
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification.id);
            }
            // Navigate to relevant course or content
            _handleNotificationTap(notification);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: !notification.isRead
                  ? Border.all(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(
                      notification.type,
                    ).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and timestamp row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Description
                      Text(
                        notification.description,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Course name if available
                      if (notification.courseName != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification.courseName!,
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Unread indicator
                if (!notification.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get notification icon based on type
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newContent:
        return Icons.play_circle_outline;
      case NotificationType.deadline:
        return Icons.schedule;
      case NotificationType.message:
        return Icons.message_outlined;
      case NotificationType.announcement:
        return Icons.campaign_outlined;
      case NotificationType.enrollment:
        return Icons.school_outlined;
      case NotificationType.achievement:
        return Icons.emoji_events_outlined;
    }
  }

  /// Get notification color based on type
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newContent:
        return const Color(0xFF10B981);
      case NotificationType.deadline:
        return const Color(0xFFF59E0B);
      case NotificationType.message:
        return const Color(0xFF2563EB);
      case NotificationType.announcement:
        return const Color(0xFF8B5CF6);
      case NotificationType.enrollment:
        return const Color(0xFF06B6D4);
      case NotificationType.achievement:
        return const Color(0xFFEF4444);
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Handle notification tap (navigate to relevant content)
  void _handleNotificationTap(NotificationModel notification) {
    // Here you can implement navigation to the relevant course or content
    // For example:
    /*
    if (notification.courseId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailsPage(courseId: notification.courseId!),
        ),
      );
    }
    */

    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'فتح ${notification.title}',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
