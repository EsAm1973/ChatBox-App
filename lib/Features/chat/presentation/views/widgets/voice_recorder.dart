import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(File voiceFile, int duration) onVoiceRecorded;
  final VoidCallback onCancel;

  const VoiceRecorderWidget({
    super.key,
    required this.onVoiceRecorded,
    required this.onCancel,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  // ignore: unused_field
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory appDocumentsDir =
            await getApplicationDocumentsDirectory();
        final String filePath =
            '${appDocumentsDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _audioPath = filePath;
        });

        _startTimer();
      } else {
        widget.onCancel();
      }
    } catch (e) {
      print('Error starting recording: $e');
      widget.onCancel();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });

      // حد أقصى للتسجيل 5 دقائق
      if (_recordDuration >= 300) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        widget.onVoiceRecorded(file, _recordDuration);
      }
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    await _audioRecorder.stop();

    if (_audioPath != null) {
      final file = File(_audioPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    widget.onCancel();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الإلغاء
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.error,
              size: 28.r,
            ),
            onPressed: _cancelRecording,
          ),

          SizedBox(width: 12.w),

          // مؤشر التسجيل
          Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),

          SizedBox(width: 12.w),

          // مدة التسجيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recording...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDuration(_recordDuration),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // زر الإرسال
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24.r,
              ),
              onPressed: _stopRecording,
            ),
          ),
        ],
      ),
    );
  }
}
