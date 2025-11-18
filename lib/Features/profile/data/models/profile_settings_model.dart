import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileSettingsModel {
  final bool lastSeenVisible;
  final bool profilePictureVisible;
  final bool onlineStatusVisible;
  final bool notificationsEnabled;
  final bool darkTheme;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileSettingsModel({
    this.lastSeenVisible = true,
    this.profilePictureVisible = true,
    this.onlineStatusVisible = true,
    this.notificationsEnabled = true,
    this.darkTheme = false,
    this.language = 'en',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'lastSeenVisible': lastSeenVisible,
      'profilePictureVisible': profilePictureVisible,
      'onlineStatusVisible': onlineStatusVisible,
      'notificationsEnabled': notificationsEnabled,
      'darkTheme': darkTheme,
      'language': language,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory ProfileSettingsModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is int) {
        return DateTime.fromMillisecondsSinceEpoch(date);
      } else if (date is String) {
        return DateTime.parse(date);
      } else {
        return DateTime.now();
      }
    }

    return ProfileSettingsModel(
      lastSeenVisible: map['lastSeenVisible'] ?? true,
      profilePictureVisible: map['profilePictureVisible'] ?? true,
      onlineStatusVisible: map['onlineStatusVisible'] ?? true,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkTheme: map['darkTheme'] ?? false,
      language: map['language'] ?? 'en',
      createdAt: map['createdAt'] != null ? parseDateTime(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? parseDateTime(map['updatedAt']) : null,
    );
  }

  ProfileSettingsModel copyWith({
    bool? lastSeenVisible,
    bool? profilePictureVisible,
    bool? onlineStatusVisible,
    bool? notificationsEnabled,
    bool? darkTheme,
    String? language,
    DateTime? updatedAt,
  }) {
    return ProfileSettingsModel(
      lastSeenVisible: lastSeenVisible ?? this.lastSeenVisible,
      profilePictureVisible: profilePictureVisible ?? this.profilePictureVisible,
      onlineStatusVisible: onlineStatusVisible ?? this.onlineStatusVisible,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkTheme: darkTheme ?? this.darkTheme,
      language: language ?? this.language,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}