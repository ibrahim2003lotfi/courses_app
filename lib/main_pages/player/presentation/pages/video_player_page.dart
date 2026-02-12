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
import 'dart:async';

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
  final List<double> _playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  
  // Quality settings
  String _selectedQuality = 'Auto';
  Map<String, dynamic>? _qualityUrls;
  List<String> _availableQualities = ['Auto', '1080p', '720p', '480p', '360p'];
  
  bool _controlsVisible = true;
  Timer? _hideControlsTimer;
  bool _isDragging = false;
  
  // Progress bar drag state
  double _dragProgress = 0.0;
  bool _isDraggingProgress = false;

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
        // Store quality URLs if available
        if (result['quality_urls'] != null) {
          _qualityUrls = Map<String, dynamic>.from(result['quality_urls']);
        }
        if (result['available_qualities'] != null) {
          _availableQualities = List<String>.from(result['available_qualities']);
        }
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
    if (mounted && !_isDraggingProgress) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
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
      _startHideControlsTimer();
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      // Respect video aspect ratio for orientation
      final aspectRatio = _videoController?.value.aspectRatio ?? 16 / 9;
      if (aspectRatio < 1.0) {
        // Vertical video - stay in portrait
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
        // Horizontal video - go landscape
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _skipForward() {
    if (_videoController != null) {
      final newPosition = _videoController!.value.position + const Duration(seconds: 10);
      if (newPosition < _videoController!.value.duration) {
        _videoController!.seekTo(newPosition);
      }
    }
    _showControlsTemporarily();
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
    _showControlsTemporarily();
  }

  void _changePlaybackSpeed(double speed) {
    if (_videoController != null) {
      setState(() {
        _playbackSpeed = speed;
      });
      _videoController!.setPlaybackSpeed(speed);
    }
    _showControlsTemporarily();
  }

  void _changeQuality(String quality) async {
    if (_qualityUrls == null || !_qualityUrls!.containsKey(quality)) {
      _showControlsTemporarily();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خيارات الجودة غير متاحة لهذا الفيديو'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final newUrl = _qualityUrls![quality] as String;
    if (newUrl == _qualityUrls![_selectedQuality]) {
      // Same URL, just update the label
      setState(() {
        _selectedQuality = quality;
      });
      _showControlsTemporarily();
      return;
    }
    
    // Save current position
    final currentPosition = _videoController?.value.position ?? Duration.zero;
    final wasPlaying = _isPlaying;
    
    setState(() {
      _selectedQuality = quality;
      _isLoading = true;
    });
    
    // Dispose old controller
    _videoController?.removeListener(_onVideoUpdate);
    _videoController?.dispose();
    
    // Initialize with new quality URL
    final authService = AuthService();
    final token = await authService.getToken();
    
    _videoController = VideoPlayerController.network(
      newUrl,
      httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : {},
    )
      ..initialize().then((_) {
        // Restore position
        _videoController?.seekTo(currentPosition);
        if (wasPlaying) {
          _videoController?.play();
        }
        setState(() {
          _isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل تحميل الفيديو: $error';
        });
      });

    _videoController?.addListener(_onVideoUpdate);
    _showControlsTemporarily();
  }

  // YouTube-style controls auto-hide
  void _startHideControlsTimer() {
    if (_isDragging) return;
    _hideControlsTimer?.cancel();
    if (_isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isPlaying && !_isDragging) {
          setState(() {
            _controlsVisible = false;
          });
        }
      });
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _controlsVisible = true;
    });
    _startHideControlsTimer();
  }

  void _onVideoTap() {
    if (_controlsVisible) {
      setState(() {
        _controlsVisible = false;
      });
      _hideControlsTimer?.cancel();
    } else {
      _showControlsTemporarily();
    }
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
          appBar: _isFullscreen ? null : _buildAppBar(theme, isDarkMode),
          body: _isFullscreen ? _buildFullscreenPlayer(theme, isDarkMode) : _buildNormalPlayer(theme, isDarkMode),
        );
      },
    );
  }

  Widget _buildNormalPlayer(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Video Player - Bigger size (about 40% of screen height)
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.42, // 42% of screen height
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
            child: _buildVideoPlayer(),
          ),
        ),
        
        // Lesson Info - Beautiful Professional Design
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode 
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lesson Label
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'الدرس الحالي',
                                    style: GoogleFonts.tajawal(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          widget.lessonTitle,
                          style: GoogleFonts.tajawal(
                            color: theme.colorScheme.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description Card
                  if (widget.lessonDescription != null && widget.lessonDescription!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode 
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description Label
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 18,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'وصف الدرس',
                                style: GoogleFonts.tajawal(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Description Text
                          Text(
                            widget.lessonDescription!,
                            style: GoogleFonts.tajawal(
                              color: theme.colorScheme.onSurface.withOpacity(0.85),
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
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
      return GestureDetector(
        onTap: _onVideoTap,
        child: Stack(
          children: [
            // Video Player - Full size in container
            if (_isFullscreen)
              Center(
                child: VideoPlayer(_videoController!),
              )
            else
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            
            // Video Controls Overlay - Only show when visible
            if (_controlsVisible)
              Positioned.fill(
                child: _buildVideoControlsOverlay(),
              ),
          ],
        ),
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

  Widget _buildCustomProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final duration = _videoController?.value.duration ?? Duration.zero;
        final position = _isDraggingProgress 
            ? Duration(milliseconds: (_dragProgress * duration.inMilliseconds).toInt())
            : (_videoController?.value.position ?? Duration.zero);
        
        double progress = 0.0;
        if (duration.inMilliseconds > 0) {
          progress = position.inMilliseconds / duration.inMilliseconds;
        }
        progress = progress.clamp(0.0, 1.0);

        // Calculate thumb position with clamping
        final thumbWidth = 16.0;
        final thumbLeft = (progress * maxWidth) - (thumbWidth / 2);
        final clampedThumbLeft = thumbLeft.clamp(0.0, maxWidth - thumbWidth);

        return GestureDetector(
          onHorizontalDragStart: (details) {
            setState(() {
              _isDragging = true;
              _isDraggingProgress = true;
              _dragProgress = progress;
            });
            _hideControlsTimer?.cancel();
          },
          onHorizontalDragUpdate: (details) {
            if (_videoController != null && _videoController!.value.isInitialized) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPosition = box.globalToLocal(details.globalPosition);
              final double relativePosition = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
              
              setState(() {
                _dragProgress = relativePosition;
              });
            }
          },
          onHorizontalDragEnd: (details) {
            if (_videoController != null && _videoController!.value.isInitialized) {
              final newPosition = _videoController!.value.duration * _dragProgress;
              _videoController!.seekTo(newPosition);
            }
            setState(() {
              _isDragging = false;
              _isDraggingProgress = false;
            });
            _startHideControlsTimer();
          },
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localPosition = box.globalToLocal(details.globalPosition);
            final double relativePosition = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
            
            if (_videoController != null && _videoController!.value.isInitialized) {
              final newPosition = _videoController!.value.duration * relativePosition;
              _videoController!.seekTo(newPosition);
            }
            _showControlsTemporarily();
          },
          child: Container(
            height: 20, // Increased height for better touch target
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background track
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Buffered portion
                if (_videoController != null && _videoController!.value.isInitialized)
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _getBufferedProgress(),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                
                // Played portion (red)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _isDraggingProgress ? _dragProgress : progress,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Draggable thumb - properly positioned and always follows the red line
                Positioned(
                  left: _isDraggingProgress 
                      ? (_dragProgress * maxWidth - thumbWidth / 2).clamp(0.0, maxWidth - thumbWidth)
                      : clampedThumbLeft,
                  top: 2, // Center vertically (20 - 16) / 2
                  child: Container(
                    width: thumbWidth,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getBufferedProgress() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return 0.0;
    }
    
    final buffered = _videoController!.value.buffered;
    if (buffered.isEmpty) {
      return 0.0;
    }
    
    // Get the last buffered range
    final lastBuffered = buffered.last;
    final end = lastBuffered.end.inMilliseconds;
    final duration = _videoController!.value.duration.inMilliseconds;
    
    if (duration <= 0) return 0.0;
    return (end / duration).clamp(0.0, 1.0);
  }

  void _seekToPosition(TapDownDetails details, double progressBarWidth) {
    if (_videoController != null && _videoController!.value.isInitialized) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset localPosition = box.globalToLocal(details.globalPosition);
      final double relativePosition = (localPosition.dx / progressBarWidth).clamp(0.0, 1.0);
      final Duration newPosition = _videoController!.value.duration * relativePosition;
      _videoController!.seekTo(newPosition);
    }
  }

  Widget _buildVideoControlsOverlay() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onVideoTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.6),
            ],
            stops: const [0.0, 0.25, 0.75, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top controls (fullscreen button)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      _toggleFullscreen();
                      _showControlsTemporarily();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.4),
                      shape: const CircleBorder(),
                      minimumSize: const Size(44, 44),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom controls - COMPACT to prevent overflow
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time Display (above progress bar) - Current time LEFT, Duration RIGHT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Current position (LEFT)
                      
                      // Total duration (RIGHT)
                      Text(
                        _formatDuration(_videoController?.value.duration ?? Duration.zero),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDuration(_isDraggingProgress 
                            ? Duration(milliseconds: (_dragProgress * (_videoController?.value.duration.inMilliseconds ?? 0)).toInt())
                            : (_videoController?.value.position ?? Duration.zero)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Custom Progress Bar with draggable thumb
                  _buildCustomProgressBar(),
                  
                  const SizedBox(height: 8),
                  
                  // Control Buttons Row - COMPACT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     // Skip Forward
                      IconButton(
                        onPressed: _skipForward,
                        icon: const Icon(Icons.forward_10, color: Colors.white, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          shape: const CircleBorder(),
                          minimumSize: const Size(40, 40),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Play/Pause
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          shape: const CircleBorder(),
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      
                       // Skip Backward
                      IconButton(
                        onPressed: _skipBackward,
                        icon: const Icon(Icons.replay_10, color: Colors.white, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          shape: const CircleBorder(),
                          minimumSize: const Size(40, 40),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Speed Control Only (Quality disabled - backend doesn't support)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Speed Control
                      PopupMenuButton<double>(
                        onSelected: (speed) {
                          _changePlaybackSpeed(speed);
                        },
                        itemBuilder: (context) {
                          return _playbackSpeeds.map((speed) {
                            return PopupMenuItem<double>(
                              value: speed,
                              child: Text(
                                '${speed}x',
                                style: TextStyle(
                                  color: speed == _playbackSpeed ? Colors.red : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        color: Colors.black87,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            '${_playbackSpeed}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Quality Control
                      PopupMenuButton<String>(
                        onSelected: (quality) {
                          _changeQuality(quality);
                        },
                        itemBuilder: (context) {
                          return _availableQualities.map((quality) {
                            return PopupMenuItem<String>(
                              value: quality,
                              child: Text(
                                quality,
                                style: TextStyle(
                                  color: quality == _selectedQuality ? Colors.red : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        color: Colors.black87,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            _selectedQuality,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
      body: _buildVideoPlayer(),
    );
  }
}
