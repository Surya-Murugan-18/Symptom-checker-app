import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:symtom_checker/language/app_strings.dart';

/// Agora video or voice call. Uses dynamic [channelName] so doctor and patient
/// join the same room. For hackathon, [token] can be empty (Agora testing mode).
class VideoCallPage extends StatefulWidget {
  /// e.g. "appointment-42" — must match for both doctor and patient
  final String channelName;
  /// Optional; empty string = testing mode (10k free min/month)
  final String token;
  /// Your Agora App ID from console.agora.io
  final String appId;
  /// false = voice only (audio call)
  final bool isVideoCall;

  const VideoCallPage({
    super.key,
    required this.channelName,
    this.token = '',
    this.appId = '045765ddaaba4893932d57fbfa58c6a5',
    this.isVideoCall = true,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      await [Permission.camera, Permission.microphone].request();

      final engine = createAgoraRtcEngine();
      _engine = engine;
      await _engine!.initialize(RtcEngineContext(appId: widget.appId));

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onUserJoined: (connection, uid, elapsed) {
            if (mounted) setState(() => _remoteUid = uid);
          },
          onUserOffline: (connection, uid, reason) {
            if (mounted) setState(() => _remoteUid = null);
          },
        ),
      );

      if (widget.isVideoCall) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.enableAudio();
      }

      await _engine!.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() {
        final msg = e.toString();
        // Show user-friendly message for Agora web SDK not loaded (e.g. createlrisApiEngine / initIrisRtc undefined)
        _error = (msg.contains('createlrisApiEngine') ||
                msg.contains('createIrisApiEngine') ||
                msg.contains('initIrisRtc'))
            ? AppStrings.s('call_unavailable', 'Video or voice call is not available on this device or browser.')
            : msg;
        _isInitialized = false;
      });
    }
  }

  Future<void> _leaveCall() async {
    final engine = _engine;
    if (engine != null) {
      await engine.leaveChannel();
      await engine.release();
      _engine = null;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    final engine = _engine;
    if (engine != null) {
      engine.leaveChannel();
      engine.release();
      _engine = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(AppStrings.s('call_title', 'Call'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(_error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppStrings.s('back', 'Back'))),
              ],
            ),
          ),
        ),
      );
    }

    // Not initialized yet: show loading so we never read _engine before it's set
    if (!_isInitialized || _engine == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(AppStrings.s('call_title', 'Call'))),
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final engine = _engine!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.isVideoCall
            ? AppStrings.s('video_consultation', 'Video Consultation')
            : AppStrings.s('voice_call', 'Voice Call')),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: _leaveCall,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (widget.isVideoCall)
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            )
          else
            const Center(
              child: Icon(Icons.mic, color: Colors.white54, size: 80),
            ),
          if (_remoteUid != null && widget.isVideoCall)
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 120,
                height: 160,
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: engine,
                    canvas: VideoCanvas(uid: _remoteUid!),
                    connection: RtcConnection(channelId: widget.channelName),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
