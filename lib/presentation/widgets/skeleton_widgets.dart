import 'package:flutter/material.dart';

/// Skeleton loading widget with shimmer effect
class SkeletonLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB));
    final highlightColor = widget.highlightColor ??
        (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF3F4F6));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: Container(
            color: baseColor,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double percent;

  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0, 0);
  }
}

/// Skeleton container with rounded corners
class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const SkeletonContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      isLoading: isLoading,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for course card
class SkeletonCourseCard extends StatelessWidget {
  final bool isDarkMode;

  const SkeletonCourseCard({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail skeleton
          SkeletonContainer(
            width: double.infinity,
            height: 120,
            borderRadius: 12,
          ),
          const SizedBox(height: 12),
          // Title skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SkeletonContainer(
              width: double.infinity,
              height: 16,
              borderRadius: 4,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SkeletonContainer(
              width: 100,
              height: 12,
              borderRadius: 4,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Skeleton for university item
class SkeletonUniversityItem extends StatelessWidget {
  final bool isDarkMode;

  const SkeletonUniversityItem({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo skeleton
          SkeletonContainer(
            width: 80,
            height: 80,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name skeleton
                SkeletonContainer(
                  width: double.infinity,
                  height: 18,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                // Info row skeleton
                Row(
                  children: [
                    SkeletonContainer(
                      width: 60,
                      height: 12,
                      borderRadius: 4,
                    ),
                    const SizedBox(width: 12),
                    SkeletonContainer(
                      width: 50,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Button skeleton
                SkeletonContainer(
                  width: double.infinity,
                  height: 48,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for list items
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final bool isDarkMode;
  final EdgeInsets padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.isDarkMode = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SkeletonUniversityItem(isDarkMode: isDarkMode),
        );
      },
    );
  }
}

/// Skeleton grid for courses
class SkeletonCourseGrid extends StatelessWidget {
  final int itemCount;
  final bool isDarkMode;

  const SkeletonCourseGrid({
    super.key,
    this.itemCount = 4,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonCourseCard(isDarkMode: isDarkMode);
      },
    );
  }
}

/// Skeleton for profile page
class SkeletonProfile extends StatelessWidget {
  final bool isDarkMode;

  const SkeletonProfile({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cover image skeleton
        SkeletonContainer(
          width: double.infinity,
          height: 150,
          borderRadius: 0,
        ),
        Transform.translate(
          offset: const Offset(0, -50),
          child: Column(
            children: [
              // Avatar skeleton
              SkeletonContainer(
                width: 100,
                height: 100,
                borderRadius: 50,
              ),
              const SizedBox(height: 16),
              // Name skeleton
              SkeletonContainer(
                width: 200,
                height: 24,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              // Email skeleton
              SkeletonContainer(
                width: 150,
                height: 14,
                borderRadius: 4,
              ),
              const SizedBox(height: 24),
              // Stats row skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonContainer(
                    width: 80,
                    height: 50,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 16),
                  SkeletonContainer(
                    width: 80,
                    height: 50,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 16),
                  SkeletonContainer(
                    width: 80,
                    height: 50,
                    borderRadius: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
