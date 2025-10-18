class ScoreBreakdown {
  final String title;
  final String formula;
  final String points;

  const ScoreBreakdown({
    required this.title,
    required this.formula,
    required this.points,
  });
}

class PrizeTier {
  final String rankLabel;
  final String reward;

  const PrizeTier({
    required this.rankLabel,
    required this.reward,
  });
}

class BonusMilestone {
  final String title;
  final String description;
  final bool isCompleted;

  const BonusMilestone({
    required this.title,
    required this.description,
    required this.isCompleted,
  });
}

class BonusTierProgress {
  final String label;
  final int current;
  final int target;

  const BonusTierProgress({
    required this.label,
    required this.current,
    required this.target,
  });

  double get progress => target == 0 ? 0 : current / target;

  String get progressLabel => '$current/$target';
}
