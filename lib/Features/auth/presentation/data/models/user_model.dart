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

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'phoneNumber': phoneNumber,
      'about': about,
      'isOnline': isOnline,
      'createdAt': createdAt,
      'lastSeen': lastSeen,
    };
  }

  // Create UserModel from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'],
      phoneNumber: map['phoneNumber'],
      about: map['about'],
      isOnline: map['isOnline'] ?? false,
      createdAt: map['createdAt'] ?? DateTime.now(),
      lastSeen: map['lastSeen'] ?? DateTime.now(),
    );
  }

  // Helper method to update specific fields
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
