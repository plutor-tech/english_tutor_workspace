import 'dart:convert';

/// Standard Common European Framework of Reference for Languages (CEFR) levels.
enum CefrLevel { A1, A2, B1, B2, C1, C2 }

/// Individual vocabulary item tracker for active and passive lexical diagnostics.
class VocabularyItem {
  final String word;
  final String context;
  final DateTime capturedAt;
  final int usageCount;

  VocabularyItem({
    required this.word,
    required this.context,
    required this.capturedAt,
    this.usageCount = 1,
  });

  VocabularyItem copyWith({
    String? word,
    String? context,
    DateTime? capturedAt,
    int? usageCount,
  }) {
    return VocabularyItem(
      word: word ?? this.word,
      context: context ?? this.context,
      capturedAt: capturedAt ?? this.capturedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'context': context,
      'capturedAt': capturedAt.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  factory VocabularyItem.fromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      word: map['word'] as String,
      context: map['context'] as String,
      capturedAt: DateTime.parse(map['capturedAt'] as String),
      usageCount: map['usageCount'] as int? ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory VocabularyItem.fromJson(String source) =>
      VocabularyItem.fromMap(json.decode(source) as Map<String, dynamic>);
}

/// Metrics representing vocabulary range, idiom integration, and word pairing logic.
class LexicalDimension {
  final int rangeScore; // 0 - 100
  final int idiomaticCompetenceScore; // 0 - 100
  final int collocationAccuracyScore; // 0 - 100

  LexicalDimension({
    required this.rangeScore,
    required this.idiomaticCompetenceScore,
    required this.collocationAccuracyScore,
  });

  LexicalDimension copyWith({
    int? rangeScore,
    int? idiomaticCompetenceScore,
    int? collocationAccuracyScore,
  }) {
    return LexicalDimension(
      rangeScore: rangeScore ?? this.rangeScore,
      idiomaticCompetenceScore: idiomaticCompetenceScore ?? this.idiomaticCompetenceScore,
      collocationAccuracyScore: collocationAccuracyScore ?? this.collocationAccuracyScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rangeScore': rangeScore,
      'idiomaticCompetenceScore': idiomaticCompetenceScore,
      'collocationAccuracyScore': collocationAccuracyScore,
    };
  }

  factory LexicalDimension.fromMap(Map<String, dynamic> map) {
    return LexicalDimension(
      rangeScore: map['rangeScore'] as int? ?? 0,
      idiomaticCompetenceScore: map['idiomaticCompetenceScore'] as int? ?? 0,
      collocationAccuracyScore: map['collocationAccuracyScore'] as int? ?? 0,
    );
  }
}

/// Metrics tracking grammatical correctness, complexity, and idiomatic syntax.
class StructuralDimension {
  final int grammaticalAccuracyScore; // 0 - 100
  final int structuralComplexityScore; // 0 - 100
  final int nativePhrasingIndex; // 0 - 100

  StructuralDimension({
    required this.grammaticalAccuracyScore,
    required this.structuralComplexityScore,
    required this.nativePhrasingIndex,
  });

  StructuralDimension copyWith({
    int? grammaticalAccuracyScore,
    int? structuralComplexityScore,
    int? nativePhrasingIndex,
  }) {
    return StructuralDimension(
      grammaticalAccuracyScore: grammaticalAccuracyScore ?? this.grammaticalAccuracyScore,
      structuralComplexityScore: structuralComplexityScore ?? this.structuralComplexityScore,
      nativePhrasingIndex: nativePhrasingIndex ?? this.nativePhrasingIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grammaticalAccuracyScore': grammaticalAccuracyScore,
      'structuralComplexityScore': structuralComplexityScore,
      'nativePhrasingIndex': nativePhrasingIndex,
    };
  }

  factory StructuralDimension.fromMap(Map<String, dynamic> map) {
    return StructuralDimension(
      grammaticalAccuracyScore: map['grammaticalAccuracyScore'] as int? ?? 0,
      structuralComplexityScore: map['structuralComplexityScore'] as int? ?? 0,
      nativePhrasingIndex: map['nativePhrasingIndex'] as int? ?? 0,
    );
  }
}

/// Metrics reflecting conversational flow, cohesion, and register adjustments.
class DiscourseDimension {
  final int coherenceCohesionScore; // 0 - 100
  final int registerAdaptabilityScore; // 0 - 100

  DiscourseDimension({
    required this.coherenceCohesionScore,
    required this.registerAdaptabilityScore,
  });

  DiscourseDimension copyWith({
    int? coherenceCohesionScore,
    int? registerAdaptabilityScore,
  }) {
    return DiscourseDimension(
      coherenceCohesionScore: coherenceCohesionScore ?? this.coherenceCohesionScore,
      registerAdaptabilityScore: registerAdaptabilityScore ?? this.registerAdaptabilityScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coherenceCohesionScore': coherenceCohesionScore,
      'registerAdaptabilityScore': registerAdaptabilityScore,
    };
  }

  factory DiscourseDimension.fromMap(Map<String, dynamic> map) {
    return DiscourseDimension(
      coherenceCohesionScore: map['coherenceCohesionScore'] as int? ?? 0,
      registerAdaptabilityScore: map['registerAdaptabilityScore'] as int? ?? 0,
    );
  }
}

/// Dynamic contextual database used by the AI engine to steer curriculum adjustments.
class GrowthLedger {
  final List<String> persistentWeaknesses;
  final List<String> masteredConcepts;
  final List<VocabularyItem> receptiveVocabulary;
  final List<VocabularyItem> productiveVocabulary;

  GrowthLedger({
    required this.persistentWeaknesses,
    required this.masteredConcepts,
    required this.receptiveVocabulary,
    required this.productiveVocabulary,
  });

  GrowthLedger copyWith({
    List<String>? persistentWeaknesses,
    List<String>? masteredConcepts,
    List<VocabularyItem>? receptiveVocabulary,
    List<VocabularyItem>? productiveVocabulary,
  }) {
    return GrowthLedger(
      persistentWeaknesses: persistentWeaknesses ?? this.persistentWeaknesses,
      masteredConcepts: masteredConcepts ?? this.masteredConcepts,
      receptiveVocabulary: receptiveVocabulary ?? this.receptiveVocabulary,
      productiveVocabulary: productiveVocabulary ?? this.productiveVocabulary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'persistentWeaknesses': persistentWeaknesses,
      'masteredConcepts': masteredConcepts,
      'receptiveVocabulary': receptiveVocabulary.map((x) => x.toMap()).toList(),
      'productiveVocabulary': productiveVocabulary.map((x) => x.toMap()).toList(),
    };
  }

  factory GrowthLedger.fromMap(Map<String, dynamic> map) {
    return GrowthLedger(
      persistentWeaknesses: List<String>.from(map['persistentWeaknesses'] as List? ?? []),
      masteredConcepts: List<String>.from(map['masteredConcepts'] as List? ?? []),
      receptiveVocabulary: (map['receptiveVocabulary'] as List? ?? [])
          .map((x) => VocabularyItem.fromMap(x as Map<String, dynamic>))
          .toList(),
      productiveVocabulary: (map['productiveVocabulary'] as List? ?? [])
          .map((x) => VocabularyItem.fromMap(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Metadata structure required to compute progress trends and trigger evaluations.
class TemporalMetadata {
  final DateTime lastUpdated;
  final int sessionCountAtEvaluation;
  final double progressionVelocity; // Average score change per standard window (e.g. monthly)

  TemporalMetadata({
    required this.lastUpdated,
    required this.sessionCountAtEvaluation,
    required this.progressionVelocity,
  });

  TemporalMetadata copyWith({
    DateTime? lastUpdated,
    int? sessionCountAtEvaluation,
    double? progressionVelocity,
  }) {
    return TemporalMetadata(
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sessionCountAtEvaluation: sessionCountAtEvaluation ?? this.sessionCountAtEvaluation,
      progressionVelocity: progressionVelocity ?? this.progressionVelocity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastUpdated': lastUpdated.toIso8601String(),
      'sessionCountAtEvaluation': sessionCountAtEvaluation,
      'progressionVelocity': progressionVelocity,
    };
  }

  factory TemporalMetadata.fromMap(Map<String, dynamic> map) {
    return TemporalMetadata(
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      sessionCountAtEvaluation: map['sessionCountAtEvaluation'] as int? ?? 0,
      progressionVelocity: (map['progressionVelocity'] as num? ?? 0.0).toDouble(),
    );
  }
}

/// Root container class managing the dynamic state of a user's English Proficiency Profile.
class ProficiencyProfile {
  final double overallProficiencyScore; // 0.0 - 100.0
  final CefrLevel cefrEquivalent;
  final double confidenceRating; // 0.0 - 1.0

  final LexicalDimension lexical;
  final StructuralDimension structural;
  final DiscourseDimension discourse;
  final GrowthLedger growthLedger;
  final TemporalMetadata metadata;

  ProficiencyProfile({
    required this.overallProficiencyScore,
    required this.cefrEquivalent,
    required this.confidenceRating,
    required this.lexical,
    required this.structural,
    required this.discourse,
    required this.growthLedger,
    required this.metadata,
  });

  /// Allows for non-mutating state changes inside standard updates.
  ProficiencyProfile copyWith({
    double? overallProficiencyScore,
    CefrLevel? cefrEquivalent,
    double? confidenceRating,
    LexicalDimension? lexical,
    StructuralDimension? structural,
    DiscourseDimension? discourse,
    GrowthLedger? growthLedger,
    TemporalMetadata? metadata,
  }) {
    return ProficiencyProfile(
      overallProficiencyScore: overallProficiencyScore ?? this.overallProficiencyScore,
      cefrEquivalent: cefrEquivalent ?? this.cefrEquivalent,
      confidenceRating: confidenceRating ?? this.confidenceRating,
      lexical: lexical ?? this.lexical,
      structural: structural ?? this.structural,
      discourse: discourse ?? this.discourse,
      growthLedger: growthLedger ?? this.growthLedger,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallProficiencyScore': overallProficiencyScore,
      'cefrEquivalent': cefrEquivalent.name, // Maps Enum to String representation
      'confidenceRating': confidenceRating,
      'lexical': lexical.toMap(),
      'structural': structural.toMap(),
      'discourse': discourse.toMap(),
      'growthLedger': growthLedger.toMap(),
      'metadata': metadata.toMap(),
    };
  }

  factory ProficiencyProfile.fromMap(Map<String, dynamic> map) {
    return ProficiencyProfile(
      overallProficiencyScore: (map['overallProficiencyScore'] as num? ?? 0.0).toDouble(),
      cefrEquivalent: CefrLevel.values.firstWhere(
        (e) => e.name == map['cefrEquivalent'],
        orElse: () => CefrLevel.A1,
      ),
      confidenceRating: (map['confidenceRating'] as num? ?? 0.0).toDouble(),
      lexical: LexicalDimension.fromMap(map['lexical'] as Map<String, dynamic>),
      structural: StructuralDimension.fromMap(map['structural'] as Map<String, dynamic>),
      discourse: DiscourseDimension.fromMap(map['discourse'] as Map<String, dynamic>),
      growthLedger: GrowthLedger.fromMap(map['growthLedger'] as Map<String, dynamic>),
      metadata: TemporalMetadata.fromMap(map['metadata'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProficiencyProfile.fromJson(String source) =>
      ProficiencyProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}