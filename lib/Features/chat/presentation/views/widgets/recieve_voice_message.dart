import 'package:audioplayers/audioplayers.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReceivedVoiceMessage extends StatefulWidget {
  final String voiceUrl;
  final int duration;
  final String time;

  const ReceivedVoiceMessage({
    super.key,
    required this.voiceUrl,
    required this.duration,
    required this.time,
  });

  @override
  State<ReceivedVoiceMessage> createState() => _ReceivedVoiceMessageState();
}

class _ReceivedVoiceMessageState extends State<ReceivedVoiceMessage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initializePlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isLoading = true);
        if (_position == Duration.zero) {
          await _audioPlayer.play(UrlSource(widget.voiceUrl));
        } else {
          await _audioPlayer.resume();
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error playing audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration =
        _duration != Duration.zero
            ? _duration
            : Duration(seconds: widget.duration);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر Play/Pause
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child:
                        _isLoading
                            ? Padding(
                              padding: EdgeInsets.all(8.r),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                            : Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 20.r,
                            ),
                  ),
                ),

                SizedBox(width: 8.w),

                // Waveform and Duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Slider
                    SizedBox(
                      width: 150.w,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.h,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 5.r,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 10.r,
                          ),
                          activeTrackColor:
                              Theme.of(context).colorScheme.primary,
                          inactiveTrackColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.2),
                          thumbColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble(),
                          max: totalDuration.inSeconds.toDouble(),
                          onChanged: (value) async {
                            final position = Duration(seconds: value.toInt());
                            await _audioPlayer.seek(position);
                          },
                        ),
                      ),
                    ),

                    // Duration Text
                    SizedBox(
                      width: 150.w,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: AppTextStyles.semiBold14.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              _formatDuration(totalDuration),
                              style: AppTextStyles.semiBold14.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 7.h),

            // Time only (no status for received messages)
            Text(
              widget.time,
              style: AppTextStyles.regular12.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
