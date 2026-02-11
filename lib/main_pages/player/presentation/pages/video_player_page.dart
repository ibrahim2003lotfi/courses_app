import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/services/auth_service.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String courseSlug;
  final String lessonId;
  final String lessonTitle;
  final String? lessonDescription;

  const VideoPlayerPage({
    super.key,
    required this.courseSlug,
    required this.lessonId,
    required this.lessonTitle,
    this.lessonDescription,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final CourseApi _courseApi = CourseApi();
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPlaying = false;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  String _selectedQuality = 'Auto';
  final List<String> _availableQualities = ['Auto', '1080p', '720p', '480p', '360p'];
  final List<double> _playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      // Get video stream URL from backend
      final result = await _courseApi.getLessonStream(
        widget.courseSlug,
        widget.lessonId,
      );

      if (result['stream_url'] != null) {
        final streamUrl = result['stream_url'];
        _initializePlayer(streamUrl);
      } else {
        // Handle different error scenarios
        String errorMessage = 'فيديو غير متاح';
        
        // Check for 403 enrollment error
        if (result.containsKey('error_code') && result['error_code'] == 'unauthorized') {
          errorMessage = 'يجب شراء الكورس أولاً للوصول إلى هذا الفيديو. يرجى التأكد من إتمام عملية الشراء.';
        } else if (result['error_code'] == 'NO_VIDEO_UPLOADED') {
          errorMessage = 'لم يتم رفع فيديو لهذا الدرس بعد. يرجى التواصل مع المدرب.';
        } else if (result['error_code'] == 'VIDEO_FILE_NOT_FOUND') {
          errorMessage = 'ملف الفيديو غير موجود على الخادم. يرجى الإبلاغ عن المشكلة.';
        } else if (result['message'] != null) {
          errorMessage = result['message'];
        }
        
        setState(() {
          _isLoading = false;
          _errorMessage = errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل الفيديو: $e';
      });
    }
  }

  void _initializePlayer(String url) async {
    print('🟡 [VideoPlayer] Initializing with URL: $url');
    
    // Add auth headers to video request
    final authService = AuthService();
    final token = await authService.getToken();
    
    print('🟡 [VideoPlayer] Token exists: ${token != null}');
    
    _videoController = VideoPlayerController.network(
      url,
      httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
    )
      ..initialize().then((_) {
        print('🟢 [VideoPlayer] Initialized successfully');
        setState(() {
          _isLoading = false;
        });
        _videoController?.play();
        setState(() {
          _isPlaying = true;
        });
      }).catchError((error) {
        print('🔴 [VideoPlayer] Error: $error');
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل تحميل الفيديو: $error';
        });
      });

    _videoController?.addListener(_onVideoUpdate);
  }

  void _onVideoUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null) return;
    
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _videoController!.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _skipForward() {
    if (_videoController != null) {
      final newPosition = _videoController!.value.position + const Duration(seconds: 10);
      if (newPosition < _videoController!.value.duration) {
        _videoController!.seekTo(newPosition);
      }
    }
  }

  void _skipBackward() {
    if (_videoController != null) {
      final newPosition = _videoController!.value.position - const Duration(seconds: 10);
      if (newPosition.inSeconds > 0) {
        _videoController!.seekTo(newPosition);
      } else {
        _videoController!.seekTo(Duration.zero);
      }
    }
  }

  void _changePlaybackSpeed(double speed) {
    if (_videoController != null) {
      setState(() {
        _playbackSpeed = speed;
      });
      _videoController!.setPlaybackSpeed(speed);
    }
  }

  void _changeQuality(String quality) {
    setState(() {
      _selectedQuality = quality;
    });
    // TODO: Implement quality switching logic
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDarkMode) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.lessonTitle,
            style: GoogleFonts.tajawal(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: _toggleFullscreen,
            ),
          ],
        ),
      ),
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

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: _buildAppBar(theme, isDarkMode),
          body: _isFullscreen ? _buildFullscreenPlayer(theme, isDarkMode) : _buildNormalPlayer(theme, isDarkMode),
        );
      },
    );
  }

  Widget _buildNormalPlayer(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Video Player
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildVideoPlayer(),
            ),
          ),
        ),
        
        // Enhanced Controls
        _buildEnhancedControls(theme, isDarkMode),
        
        // Lesson Info
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: isDarkMode
                  ? null
                  : Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.lessonTitle,
                  style: GoogleFonts.tajawal(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right,
                ),
                if (widget.lessonDescription != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.lessonDescription!,
                    style: GoogleFonts.tajawal(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingControls(ThemeData theme, bool isDarkMode) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip Backward
          IconButton(
            onPressed: _skipBackward,
            icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: const CircleBorder(),
            ),
          ),
          
          // Play/Pause
          IconButton(
            onPressed: _togglePlayPause,
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 48,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: const CircleBorder(),
            ),
          ),
          
          // Skip Forward
          IconButton(
            onPressed: _skipForward,
            icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'جاري تحميل الفيديو...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'فيديو غير متاح',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEnhancedControls(ThemeData theme, bool isDarkMode) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDarkMode
            ? null
            : Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          // Progress Bar
          VideoProgressIndicator(
            _videoController!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: theme.colorScheme.primary,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Main Controls Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Skip Backward
              IconButton(
                onPressed: _skipBackward,
                icon: Icon(
                  Icons.replay_10,
                  color: theme.colorScheme.onSurface,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: const CircleBorder(),
                ),
              ),
              
              // Play/Pause
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: theme.colorScheme.primary,
                  size: 48,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: const CircleBorder(),
                ),
              ),
              
              // Skip Forward
              IconButton(
                onPressed: _skipForward,
                icon: Icon(
                  Icons.forward_10,
                  color: theme.colorScheme.onSurface,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Time Display and Advanced Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time Display
              Text(
                '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}',
                style: GoogleFonts.tajawal(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Speed Control
              PopupMenuButton<double>(
                onSelected: _changePlaybackSpeed,
                itemBuilder: (context) {
                  return _playbackSpeeds.map((speed) {
                    return PopupMenuItem<double>(
                      value: speed,
                      child: Text(
                        '${speed}x',
                        style: GoogleFonts.tajawal(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_playbackSpeed}x',
                      style: GoogleFonts.tajawal(
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quality Control
              PopupMenuButton<String>(
                onSelected: _changeQuality,
                itemBuilder: (context) {
                  return _availableQualities.map((quality) {
                    return PopupMenuItem<String>(
                      value: quality,
                      child: Text(
                        quality,
                        style: GoogleFonts.tajawal(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.high_quality,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedQuality,
                      style: GoogleFonts.tajawal(
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Widget _buildFullscreenPlayer(ThemeData theme, bool isDarkMode) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen Video
          Center(
            child: _buildVideoPlayer(),
          ),
          
          // Floating Controls
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildFloatingControls(theme, isDarkMode),
          ),
          
          // Exit fullscreen button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 28),
              onPressed: _toggleFullscreen,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
