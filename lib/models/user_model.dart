import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String authProvider; // 'email', 'google', 'guest'
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isGuest;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.authProvider,
    required this.createdAt,
    required this.lastLoginAt,
    this.isGuest = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'authProvider': authProvider,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isGuest': isGuest,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      authProvider: map['authProvider'] ?? 'email',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isGuest: map['isGuest'] ?? false,
    );
  }

  // Create from Firebase User
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
    required String authProvider,
    bool isGuest = false,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      photoUrl: photoUrl,
      authProvider: authProvider,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isGuest: isGuest,
    );
  }

  // Copy with updated lastLoginAt
  UserModel copyWithLastLogin() {
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      photoUrl: photoUrl,
      authProvider: authProvider,
      createdAt: createdAt,
      lastLoginAt: DateTime.now(),
      isGuest: isGuest,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, provider: $authProvider)';
  }
}
