/// Trust score payload returned by the backend Trust Engine.
/// Flutter only displays these values — it never calculates the score.
class TrustScoreDetail {
  const TrustScoreDetail({
    required this.score,
    required this.confidence,
    required this.updatedAt,
    required this.trendLabel,
    required this.history,
    required this.signals,
    this.cropBatchId,
    this.cropLabel,
    this.explanation,
  });

  final double score;
  final double confidence;
  final DateTime updatedAt;
  final String trendLabel;
  final List<TrustHistoryPoint> history;
  final List<TrustSignal> signals;
  final String? cropBatchId;
  final String? cropLabel;
  final String? explanation;
}

class TrustHistoryPoint {
  const TrustHistoryPoint({
    required this.date,
    required this.score,
  });

  final DateTime date;
  final double score;
}

class TrustSignal {
  const TrustSignal({
    required this.id,
    required this.name,
    required this.contribution,
    required this.statusLabel,
    this.description,
  });

  final String id;
  final String name;

  /// Signed contribution weight from the trust engine (-1.0 to 1.0 typical).
  final double contribution;
  final String statusLabel;
  final String? description;
}
