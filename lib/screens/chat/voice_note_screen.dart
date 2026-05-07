import 'package:flutter/material.dart';

class VoiceNoteScreen extends StatefulWidget {
  const VoiceNoteScreen({super.key});

  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordedDuration = Duration(seconds: 0);
  final Duration _playbackPosition = Duration(seconds: 0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentCyan = Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121A2A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF1A2332) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentCyan.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.person,
                color: accentCyan,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SwiftNest',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '🔒 End-to-end encrypted',
                  style: TextStyle(
                    color: accentCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Voice Memo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _recordedDuration.inSeconds == 0
                      ? 'Start recording your voice note'
                      : (_isRecording
                          ? 'Recording voice note...'
                          : 'High Fidelity Audio'),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Timer Display
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  _formatDuration(_recordedDuration),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _recordedDuration.inSeconds == 0
                      ? 'No recording'
                      : (_isPlaying ? 'Playing' : 'High Fidelity Audio'),
                  style: TextStyle(
                    fontSize: 12,
                    color: accentCyan,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Waveform Visualization (only show if has recording)
          if (_recordedDuration.inSeconds > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  _buildWaveform(isDark, accentCyan),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0:00',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey[500]
                              : Colors.grey[400],
                        ),
                      ),
                      Text(
                        _formatDuration(
                            _recordedDuration),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey[500]
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic_none,
                      size: 64,
                      color: isDark
                          ? Colors.grey[600]
                          : Colors.grey[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No voice recording yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                        color: isDark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 24),

          // Control Buttons (only show if has recording)
          if (_recordedDuration.inSeconds > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 24),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  // Delete Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _recordedDuration =
                            Duration(
                                seconds:
                                    0);
                        _isPlaying = false;
                      });
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        SnackBar(
                            content: Text(
                                'Voice note deleted')),
                      );
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: Colors.red
                            .withValues(
                                alpha:
                                    0.15),
                      ),
                      child: Icon(
                        Icons
                            .delete_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),

                  SizedBox(width: 24),

                  // Play/Pause Button
                  GestureDetector(
                    onTap: () {
                      setState(() =>
                          _isPlaying =
                              !_isPlaying);
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: accentCyan,
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause
                            : Icons
                                .play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  SizedBox(width: 24),

                  // Skip Button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: accentCyan
                            .withValues(
                                alpha:
                                    0.15),
                      ),
                      child: Icon(
                        Icons.skip_next,
                        color: accentCyan,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 24),
              child: GestureDetector(
                onTap: () {
                  // Start recording
                  setState(() {
                    _isRecording = true;
                    _recordedDuration =
                        Duration(
                            seconds: 5);
                  });
                  Future.delayed(
                      Duration(
                          seconds: 2))
                      .then((_) {
                    if (mounted) {
                      setState(() {
                        _isRecording =
                            false;
                      });
                      ScaffoldMessenger
                              .of(
                                  context)
                          .showSnackBar(
                        SnackBar(
                            content: Text(
                                'Voice recording complete')),
                      );
                    }
                  });
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color: _isRecording
                        ? Colors.red
                        : accentCyan,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? Colors.red
                                : accentCyan)
                            .withValues(
                                alpha:
                                    0.3),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording
                        ? Icons.stop
                        : Icons.mic,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),

          SizedBox(height: 32),

          // Send Button (only show if has recording)
          if (_recordedDuration.inSeconds > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      SnackBar(
                          content: Text(
                              'Voice note sent securely (${_formatDuration(_recordedDuration)})')),
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.send,
                      size: 20),
                  label: Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                        accentCyan,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                    ),
                  ),
                ),
              ),
            ),

          SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark, accentCyan),
    );
  }

  Widget _buildWaveform(bool isDark, Color accentCyan) {
    const int bars = 40;
    List<double> heights = [];
    for (int i = 0; i < bars; i++) {
      // Create wave pattern
      double normalizedPos = i / bars;
      double waveHeight = 0.3 + 0.7 * (0.5 + 0.5 * 
        (normalizedPos < 0.3 ? normalizedPos / 0.3 : (normalizedPos < 0.7 ? 1.0 : (1.0 - (normalizedPos - 0.7) / 0.3)))).toDouble();
      heights.add(waveHeight);
    }

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(bars, (index) {
          final isPlayed = _isPlaying && index < (bars * (_playbackPosition.inSeconds / _recordedDuration.inSeconds)).toInt();
          return Container(
            width: 3,
            height: 40 * heights[index],
            decoration: BoxDecoration(
              color: isPlayed ? accentCyan : (isDark ? Colors.grey[700] : Colors.grey[300]),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildBottomNav(bool isDark, Color accentCyan) {
    final items = ['Messages', 'Media', 'Vault', 'Settings'];
    final icons = [
      Icons.mail,
      Icons.image,
      Icons.lock,
      Icons.settings,
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A2332) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Color(0xFF252F3F) : Color(0xFFE0E0E0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons[index],
                color: index == 0 ? accentCyan : (isDark ? Colors.grey[600] : Colors.grey[400]),
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                items[index],
                style: TextStyle(
                  fontSize: 10,
                  color: index == 0 ? accentCyan : (isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
