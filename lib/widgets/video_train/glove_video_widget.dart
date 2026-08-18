import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_theme.dart';

class GloveVideoWidget extends StatefulWidget {
  final bool isTraining;

  const GloveVideoWidget({super.key, required this.isTraining});

  @override
  State<GloveVideoWidget> createState() => _GloveVideoWidgetState();
}

class _GloveVideoWidgetState extends State<GloveVideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/glove_motion.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.setVolume(0.0);
          if (widget.isTraining) {
            _controller.play();
          }
        }
      }).catchError((error) {
        // 🟢 ถ้าโหลดไฟล์วิดีโอไม่ได้ มันจะปริ้นต์บอกใน Debug Console ทันที!
        debugPrint("❌ Video Load Error: $error");
      });
  }

  @override
  void didUpdateWidget(covariant GloveVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🟢 2. ควบคุมการเล่น/หยุดเล่น ตามสถานะ _isTraining จากหน้าหลัก
    if (_isInitialized) {
      if (widget.isTraining && !_controller.value.isPlaying) {
        _controller.play();
      } else if (!widget.isTraining && _controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    // 🛑 3. คืน Memory เมื่อปิดหน้าจอ (สำคัญมากสำหรับ Production)
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return  SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Container(
      width: 250,
      height: 180,
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
        color: Colors.black, // พื้นหลังสีดำช่วยให้วิดีโอเด่นขึ้น
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isTraining ? AppTheme.primaryColor : Colors.grey.shade300,
          width: 3,
        ),
        boxShadow: widget.isTraining
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}