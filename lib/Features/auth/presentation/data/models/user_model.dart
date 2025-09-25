import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profilePic;
  final String? phoneNumber;
  final String? about;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime lastSeen;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePic,
    this.phoneNumber,
    this.about,
    required this.isOnline,
    required this.createdAt,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'phoneNumber': phoneNumber ?? '',
      'about': about ?? '',
      'isOnline': isOnline,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // تحويل Timestamp إلى DateTime إذا لزم الأمر
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

    return UserModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      profilePic: map['profilePic']?.toString() ?? 'default_profile_pic_url',
      phoneNumber: map['phoneNumber']?.toString(),
      about: map['about']?.toString(),
      isOnline: map['isOnline'] ?? false,
      createdAt: parseDateTime(map['createdAt']),
      lastSeen: parseDateTime(map['lastSeen']),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? profilePic,
    String? phoneNumber,
    String? about,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      about: about ?? this.about,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}