/// A class to handle user login functionality.
class UserLogin {  
  // Implementation for user login
  final String userid;
  final String username;
  final String password;

  const UserLogin({
    required this.userid,
    required this.username,
    required this.password,
  });

  /// Factory constructor to create a UserLogin instance from a map.
  factory UserLogin.fromMap(Map<String, dynamic> map) {
    return UserLogin(
      userid: map['userid'] as String? ?? '',
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  /// Converts the UserLogin instance to a map for serialization.
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'username': username,
      'password': password,
    };
  }

  /// Creates a copy of the UserLogin instance with optional overrides.
  UserLogin copyWith({
    String? userid,
    String? username,
    String? password,
  }) {
    return UserLogin(
      userid: userid ?? this.userid,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
