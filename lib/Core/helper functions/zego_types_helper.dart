import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// Extension to convert ZegoCallInvitationType to CallType
extension ZegoCallInvitationTypeExtension on ZegoCallInvitationType {
  CallType toCallType() {
    switch (this) {
      case ZegoCallInvitationType.videoCall:
        return CallType.video;
      case ZegoCallInvitationType.voiceCall:
        return CallType.voice;
    }
  }
}

/// Helper class for ZegoCloud integration
class ZegoCallHelper {
  /// Convert ZegoCallInvitationType to CallType enum
  static CallType getCallType(ZegoCallInvitationType type) {
    return type == ZegoCallInvitationType.videoCall
        ? CallType.video
        : CallType.voice;
  }

  /// Format call duration for display
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes}m ${remainingSeconds}s';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
  }

  /// Get call icon based on status and type
  static IconData getCallIcon(CallModel call, bool isOutgoing) {
    switch (call.status) {
      case CallStatus.completed:
        return isOutgoing ? Icons.call_made : Icons.call_received;
      case CallStatus.missed:
        return Icons.call_missed;
      case CallStatus.rejected:
        return Icons.call_missed_outgoing;
      case CallStatus.cancelled:
        return Icons.call_end;
      default:
        return Icons.call;
    }
  }

  /// Get call status color
  static Color getStatusColor(CallStatus status) {
    switch (status) {
      case CallStatus.completed:
        return Colors.green;
      case CallStatus.missed:
        return Colors.red;
      case CallStatus.rejected:
        return Colors.orange;
      case CallStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
