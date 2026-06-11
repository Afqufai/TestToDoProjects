import 'package:flutter/foundation.dart';
import 'package:workspace_tracker/models/task_model.dart';
import 'package:workspace_tracker/services/api_service.dart';

/// Manages the task list for the currently viewed project.
class TaskProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  TaskProvider({required ApiService apiService}) : _apiService = apiService;

  // ---- Getters ----

  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tasks filtered by [TaskStatus.todo].
  List<TaskItem> get todoTasks =>
      _tasks.where((t) => t.status == TaskStatus.todo).toList();

  /// Tasks filtered by [TaskStatus.inProgress].
  List<TaskItem> get inProgressTasks =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).toList();

  /// Tasks filtered by [TaskStatus.done].
  List<TaskItem> get doneTasks =>
      _tasks.where((t) => t.status == TaskStatus.done).toList();

  // ---- Public API ----

  /// Fetches all tasks belonging to the given [projectId].
  Future<void> fetchProjectTasks(String projectId) async {
    await _guard(() async {
      _tasks = await _apiService.getProjectTasks(projectId);
    });
  }

  /// Creates a new task with [TaskStatus.todo] and prepends it to the list.
  Future<bool> createTask({
    required String title,
    required String description,
    required String projectId,
    DateTime? dueDate,
    TaskPriority? priority,
  }) async {
    return _guardWithResult(() async {
      final newTask = await _apiService.createTask(
        title: title,
        description: description,
        status: TaskStatus.todo.value,
        projectId: projectId,
        dueDate: dueDate,
        priority: priority?.value,
      );
      _tasks.insert(0, newTask);
    });
  }

  /// Updates an existing task both remotely and in local state.
  Future<bool> updateTask({
    required String id,
    required String title,
    required String description,
    required TaskStatus status,
    required String projectId,
    DateTime? dueDate,
    TaskPriority? priority,
  }) async {
    return _guardWithResult(() async {
      await _apiService.updateTask(
        id: id,
        title: title,
        description: description,
        status: status.value,
        projectId: projectId,
        dueDate: dueDate,
        priority: priority?.value,
      );

      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          title: title,
          description: description,
          status: status,
          projectId: projectId,
          dueDate: dueDate,
          priority: priority ?? TaskPriority.medium,
        );
      }
    });
  }

  /// Deletes a task by [id] and removes it from local state.
  Future<bool> deleteTask(String id) async {
    return _guardWithResult(() async {
      await _apiService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
    });
  }

  /// Convenience method to update only the status of a task.
  Future<bool> updateTaskStatus(String id, TaskStatus newStatus) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    return updateTask(
      id: id,
      title: task.title,
      description: task.description,
      status: newStatus,
      projectId: task.projectId,
      dueDate: task.dueDate,
      priority: task.priority,
    );
  }

  /// Clears any stored error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---- Private helpers ----

  /// Wraps a void async operation with loading state and error handling.
  Future<void> _guard(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Wraps an async operation and returns `true` on success, `false` on failure.
  Future<bool> _guardWithResult(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
