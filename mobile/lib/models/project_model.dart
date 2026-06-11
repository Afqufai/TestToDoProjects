/// Data model representing a workspace project.
class Project {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final double completionPercentage;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.completionPercentage = 0.0,
  });

  /// Deserialises a [Project] from a JSON map returned by the API.
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serialises this project to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'completionPercentage': completionPercentage,
      };

  /// Returns a copy of this project with the given fields replaced.
  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    double? completionPercentage,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
