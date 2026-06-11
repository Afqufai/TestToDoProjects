/// Data model representing health and progress analytics for a project.
class ProjectAnalytics {
  final int totalTasks;
  final int completedTasks;
  final double completionPercentage;
  final int bottleneckTasks;

  const ProjectAnalytics({
    required this.totalTasks,
    required this.completedTasks,
    required this.completionPercentage,
    required this.bottleneckTasks,
  });

  /// Deserializes a [ProjectAnalytics] from a JSON map.
  factory ProjectAnalytics.fromJson(Map<String, dynamic> json) {
    return ProjectAnalytics(
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      bottleneckTasks: (json['bottleneckTasks'] as num?)?.toInt() ?? 0,
    );
  }
}
