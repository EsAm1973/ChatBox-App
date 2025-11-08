// services/zego_cloud_service.dart
import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/constants.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoCloudService {
  static final ZegoCloudService _instance = ZegoCloudService._internal();
  factory ZegoCloudService() => _instance;
  ZegoCloudService._internal();

  bool _isInitialized = false;
  String? _currentRoomId;
  // ignore: unused_field
  String? _currentUserId;

  // ZEGOCLOUD credentials - replace with your actual app ID and app sign
  final int _appId = appIdZegoCloud; // Your ZEGOCLOUD App ID
  final String _appSign = appSignZegoCloud; // Your ZEGOCLOUD App Sign

  /// Initialize ZEGOCLOUD SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create engine with profile - Corrected parameters
      await ZegoExpressEngine.createEngineWithProfile(
        ZegoEngineProfile(
          _appId,
          appSign: _appSign,
          ZegoScenario.Broadcast, // Scenario is now a positional parameter
        ),
      );

      // Set event handlers
      _setUpEventHandlers();

      _isInitialized = true;
      print('ZEGOCLOUD SDK initialized successfully');
    } catch (e) {
      print('Error initializing ZEGOCLOUD SDK: $e');
      throw FirebaseFailure(
        errorMessage: 'Failed to initialize voice call service',
      );
    }
  }

  /// Set up event handlers for call events
  void _setUpEventHandlers() {
    ZegoExpressEngine.onRoomStateUpdate = (
      String roomId,
      ZegoRoomState state,
      int errorCode,
      Map<String, dynamic> extendedData,
    ) {
      print('Room state update: $roomId, state: $state, error: $errorCode');

      if (state == ZegoRoomState.Connected) {
        print('Successfully connected to room: $roomId');
      } else if (state == ZegoRoomState.Disconnected) {
        print('Disconnected from room: $roomId');
        _currentRoomId = null;
      }
    };

    ZegoExpressEngine.onRoomUserUpdate = (
      String roomId,
      ZegoUpdateType updateType,
      List<ZegoUser> userList,
    ) {
      print(
        'Room user update: $roomId, updateType: $updateType, users: ${userList.length}',
      );

      if (updateType == ZegoUpdateType.Add) {
        print('User joined the call: ${userList.first.userID}');
      } else if (updateType == ZegoUpdateType.Delete) {
        print('User left the call: ${userList.first.userID}');
      }
    };

    // ✅ Corrected callback signature
    ZegoExpressEngine.onPublisherStateUpdate = (
      String streamID, // Added streamID parameter
      ZegoPublisherState state,
      int errorCode,
      Map<String, dynamic> extendedData,
    ) {
      print(
        'Publisher state update for stream: $streamID, state: $state, error: $errorCode',
      );
    };
  }

  /// Join a voice call room
  Future<void> joinVoiceCall({
    required String roomId,
    required String userId,
    required String userName,
    required String streamID, // ✅ Required parameter
  }) async {
    if (!_isInitialized) await initialize();

    try {
      _currentRoomId = roomId;
      _currentUserId = userId;

      // Join room
      await ZegoExpressEngine.instance.loginRoom(
        roomId,
        ZegoUser(userId, userName),
      );

      // ✅ Start publishing audio WITH the streamID
      await ZegoExpressEngine.instance.startPublishingStream(streamID);
      await ZegoExpressEngine.instance.enableAudioCaptureDevice(true);
      await ZegoExpressEngine.instance.muteMicrophone(false);

      print(
        'Successfully joined voice call room: $roomId with stream: $streamID',
      );
    } catch (e) {
      print('Error joining voice call: $e');
      throw FirebaseFailure(errorMessage: 'Failed to join voice call');
    }
  }

  /// Start playing stream (for the other user in the call)
  Future<void> startPlayingStream(String streamID) async {
    try {
      await ZegoExpressEngine.instance.startPlayingStream(streamID);
      print('Started playing stream: $streamID');
    } catch (e) {
      print('Error starting to play stream: $e');
      throw FirebaseFailure(errorMessage: 'Failed to start playing stream');
    }
  }

  /// Leave the current voice call
  Future<void> leaveVoiceCall() async {
    try {
      if (_currentRoomId != null) {
        await ZegoExpressEngine.instance.stopPublishingStream();
        await ZegoExpressEngine.instance.logoutRoom(_currentRoomId!);
        _currentRoomId = null;
        _currentUserId = null;
        print('Left voice call room');
      }
    } catch (e) {
      print('Error leaving voice call: $e');
    }
  }

  /// Toggle microphone mute
  Future<void> toggleMicrophone(bool isMuted) async {
    try {
      await ZegoExpressEngine.instance.muteMicrophone(isMuted);
      print('Microphone ${isMuted ? 'muted' : 'unmuted'}');
    } catch (e) {
      print('Error toggling microphone: $e');
    }
  }

  /// Toggle speaker
  Future<void> toggleSpeaker(bool useSpeaker) async {
    try {
      await ZegoExpressEngine.instance.setAudioRouteToSpeaker(useSpeaker);
      print('Speaker ${useSpeaker ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('Error toggling speaker: $e');
    }
  }

  /// Generate a unique room ID for the call
  String generateRoomId(String callerEmail, String receiverEmail) {
    final emails = [callerEmail, receiverEmail]..sort();
    return 'voice_call_${emails[0]}_${emails[1]}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Generate stream ID from call ID
  String generateStreamId(String callId) {
    return 'stream_$callId';
  }

  /// Clean up resources
  Future<void> dispose() async {
    try {
      await leaveVoiceCall();
      if (_isInitialized) {
        await ZegoExpressEngine.destroyEngine();
        _isInitialized = false;
      }
    } catch (e) {
      print('Error disposing ZEGOCLOUD service: $e');
    }
  }
}
