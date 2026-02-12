import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable widget for displaying course images with proper fallback handling.
/// Shows a placeholder icon when image is null, empty, or fails to load.
class CourseImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool showPlaceholderText;
  final String placeholderText;
  final IconData placeholderIcon;

  const CourseImageWidget({
    super.key,
    this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showPlaceholderText = false,
    this.placeholderText = 'لا توجد صورة',
    this.placeholderIcon = Icons.image_not_supported_outlined,
  });

  bool get _hasValidImage {
    if (imageUrl == null) return false;
    if (imageUrl!.isEmpty) return false;
    if (imageUrl == 'null') return false;
    // Check if URL is valid (starts with http, https, or at least has a domain)
    final trimmed = imageUrl!.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return true;
    // Handle relative URLs that start with /
    if (trimmed.startsWith('/')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    Widget imageWidget;

    if (!_hasValidImage) {
      imageWidget = _buildPlaceholder(isDarkMode);
    } else {
      // If it's a relative URL, we can't use Image.network
      final trimmedUrl = imageUrl!.trim();
      if (trimmedUrl.startsWith('/')) {
        // Relative URL - show placeholder since we can't construct full URL
        imageWidget = _buildPlaceholder(isDarkMode);
      } else {
        imageWidget = Image.network(
          trimmedUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder(isDarkMode);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(isDarkMode);
          },
        );
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(bool isDarkMode) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF2D2D2D),
                  const Color(0xFF1E1E1E),
                ]
              : [
                  const Color(0xFFF3F4F6),
                  const Color(0xFFE5E7EB),
                ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            placeholderIcon,
            size: (width < height ? width : height) * 0.3,
            color: isDarkMode
                ? const Color(0xFF6B7280)
                : const Color(0xFF9CA3AF),
          ),
          if (showPlaceholderText) ...[
            const SizedBox(height: 8),
            Text(
              placeholderText,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: isDarkMode
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(bool isDarkMode) {
    return Container(
      width: width,
      height: height,
      color: isDarkMode
          ? const Color(0xFF2D2D2D)
          : const Color(0xFFF3F4F6),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDarkMode
                ? const Color(0xFF6B7280)
                : const Color(0xFF9CA3AF),
          ),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// A compact version for small course cards
class CourseImageThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const CourseImageThumbnail({
    super.key,
    this.imageUrl,
    required this.size,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CourseImageWidget(
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      placeholderIcon: Icons.school_outlined,
    );
  }
}

/// A hero/header version for course details
class CourseImageHeader extends StatelessWidget {
  final String? imageUrl;
  final double height;

  const CourseImageHeader({
    super.key,
    this.imageUrl,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CourseImageWidget(
      imageUrl: imageUrl,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      placeholderIcon: Icons.play_circle_outline,
      showPlaceholderText: true,
      placeholderText: 'صورة الدورة غير متوفرة',
    );
  }
}
