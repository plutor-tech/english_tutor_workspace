import 'user_login.dart';
import 'user_preferences.dart';
import 'proficiency_profile.dart';

/// A class to represent a user's profile information.
class UserProfile {
  final String userid;
  final String displayname;// Reference to the user's login information
  late UserPreferences? preferences;
  late ProficiencyProfile? proficiency;

  UserProfile({
    required this.userid,
    required this.displayname,
  });

  /// Factory constructor to create a UserProfile instance from a map.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userid: map['userid'] as String? ?? '',
      displayname: map['displayName'] as String? ?? '',
    );
  }

  /// Converts the UserProfile instance to a map for serialization.
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'displayName': displayname,
      'preferences': preferences?.toMap(),
      'proficiency': proficiency?.toMap(),
    };
  }

  /// Creates a copy of the UserProfile instance with optional overrides.
  UserProfile copyWith({
    String? displayName,
    UserLogin? loginInfo,
    UserPreferences? preferences,
    ProficiencyProfile? proficiency,
  }) {
    return UserProfile(
      userid: userid ?? this.userid,
      displayname: displayName ?? this.displayname,
    );
  }
}