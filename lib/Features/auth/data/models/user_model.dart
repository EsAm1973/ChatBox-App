import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profilePic;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime lastSeen;
  final String? phoneNumber;
  final String? about;
  final bool isDeleted;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePic,
    required this.isOnline,
    required this.createdAt,
    required this.lastSeen,
    this.phoneNumber,
    this.about,
    this.isDeleted = false,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'createdAt': createdAt,
      'lastSeen': lastSeen,
      'phoneNumber': phoneNumber,
      'about': about,
      'isDeleted': isDeleted,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is int) {
        return DateTime.fromMillisecondsSinceEpoch(date);
      }
      return DateTime.now(); // Fallback
    }

    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      createdAt: parseDateTime(map['createdAt']),
      lastSeen: parseDateTime(map['lastSeen']),
      phoneNumber: map['phoneNumber'],
      about: map['about'],
      isDeleted: map['isDeleted'] ?? false,
      fcmToken: map['fcmToken'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePic,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? lastSeen,
    String? phoneNumber,
    String? about,
    bool? isDeleted,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      about: about ?? this.about,
      isDeleted: isDeleted ?? this.isDeleted,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
