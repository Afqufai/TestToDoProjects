/// Represents the lifecycle status of a task on the Kanban board.
enum TaskStatus {
  todo('Todo'),
  inProgress('InProgress'),
  done('Done');

  /// The string representation sent to / received from the API.
  final String value;

  const TaskStatus(this.value);

  /// Parses a status string from the API, defaulting to [TaskStatus.todo].
  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.todo,
    );
  }
}

/// Represents the priority of a task.
enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  final String value;

  const TaskPriority(this.value);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

/// Data model representing a task within a project.
class TaskItem {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final String projectId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskPriority priority;
  final String? assigneeId;

  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.projectId,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.assigneeId,
  });

  /// Deserialises a [TaskItem] from a JSON map returned by the API.
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: TaskStatus.fromString(json['status'] as String? ?? 'Todo'),
      projectId: json['projectId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      priority: TaskPriority.fromString(json['priority'] as String? ?? 'Medium'),
      assigneeId: json['assigneeId'] as String?,
    );
  }

  /// Serialises this task to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.value,
        'projectId': projectId,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority.value,
        'assigneeId': assigneeId,
      };

  /// Returns a copy of this task with the given fields replaced.
  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    String? projectId,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    String? assigneeId,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
    );
  }
}
