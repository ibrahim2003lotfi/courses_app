import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
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
      } else if (result['lesson_status'] == 'pending' || result['lesson_status'] == 'processing') {
        setState(() {
          _isLoading = false;
          _errorMessage = 'الفيديو قيد المعالجة، يرجى المحاولة لاحقاً';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'فيديو غير متاح';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل الفيديو: $e';
      });
    }
  }

  void _initializePlayer(String url) {
    _videoController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
        _videoController?.play();
        setState(() {
          _isPlaying = true;
        });
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل تحميل الفيديو';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.lessonTitle,
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Video Player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildVideoPlayer(),
              ),
              
              // Controls
              _buildControls(),
              
              // Lesson Info
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.lessonTitle,
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      if (widget.lessonDescription != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.lessonDescription!,
                          style: GoogleFonts.tajawal(
                            color: Colors.white70,
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
          ),
        );
      },
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

  Widget _buildControls() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Progress Bar
          VideoProgressIndicator(
            _videoController!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.blue,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.white24,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time Display
              Text(
                '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              
              // Play/Pause Button
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: _togglePlayPause,
              ),
              
              // Fullscreen Button
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: () {
                  // TODO: Implement fullscreen
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
