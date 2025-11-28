import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  faculty,
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? rollNumber; // For students
  final String? department;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.rollNumber,
    this.department,
    this.phoneNumber,
    required this.createdAt,
    this.lastLogin,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role == UserRole.faculty ? 'faculty' : 'student',
      'rollNumber': rollNumber,
      'department': department,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  // Create UserModel from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] == 'faculty' ? UserRole.faculty : UserRole.student,
      rollNumber: map['rollNumber'],
      department: map['department'],
      phoneNumber: map['phoneNumber'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: map['lastLogin'] != null
          ? (map['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? rollNumber,
    String? department,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
