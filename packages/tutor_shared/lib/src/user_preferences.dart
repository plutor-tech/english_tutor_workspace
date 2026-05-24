/// Supported variants of the English language.
enum TargetEnglishVariant {
  british,
  american,
  global;

  /// Utility to parse string values to enum safely
  static TargetEnglishVariant fromString(String value) {
    switch (value.toLowerCase()) {
      case 'british':
        return TargetEnglishVariant.british;
      case 'american':
        return TargetEnglishVariant.american;
      case 'global':
      default:
        return TargetEnglishVariant.global;
    }
  }

  /// Convert enum to string representation
  String toMapValue() => name;
}

/// A structured model capturing details required to kickstart and 
/// personalize conversational interactions with the tutoring backend.
class UserPreferences {
  final String displayName;
  final int age;
  final String preferredCommunicationLanguage;
  final TargetEnglishVariant targetEnglishVariant;
  final List<String> topicsOfInterest;

  UserPreferences({
    required this.displayName,
    required this.age,
    this.preferredCommunicationLanguage = 'en',
    this.targetEnglishVariant = TargetEnglishVariant.global,
    this.topicsOfInterest = const [],
  });

  /// Factory constructor to parse map instances from JSON payloads.
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      displayName: map['display_name'] as String? ?? 'Learner',
      age: map['age'] as int? ?? 18,
      preferredCommunicationLanguage: map['preferred_communication_language'] as String? ?? 'en',
      targetEnglishVariant: TargetEnglishVariant.fromString(
        map['target_english_variant'] as String? ?? 'global',
      ),
      topicsOfInterest: List<String>.from(map['topics_of_interest'] ?? []),
    );
  }

  /// Converts the current instance data to a Map format for standard serialization.
  Map<String, dynamic> toMap() {
    return {
      'display_name': displayName,
      'age': age,
      'preferred_communication_language': preferredCommunicationLanguage,
      'target_english_variant': targetEnglishVariant.toMapValue(),
      'topics_of_interest': topicsOfInterest,
    };
  }

  /// Creates a copy of the preferences while overriding specified properties.
  UserPreferences copyWith({
    String? displayName,
    int? age,
    String? preferredCommunicationLanguage,
    TargetEnglishVariant? targetEnglishVariant,
    List<String>? topicsOfInterest,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      preferredCommunicationLanguage: preferredCommunicationLanguage ?? this.preferredCommunicationLanguage,
      targetEnglishVariant: targetEnglishVariant ?? this.targetEnglishVariant,
      topicsOfInterest: topicsOfInterest ?? this.topicsOfInterest,
    );
  }
}