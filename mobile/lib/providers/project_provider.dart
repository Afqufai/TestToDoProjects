import 'package:flutter/foundation.dart';
import 'package:workspace_tracker/models/project_model.dart';
import 'package:workspace_tracker/services/api_service.dart';

/// Manages the list of projects and the currently selected project.
class ProjectProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _errorMessage;

  ProjectProvider({required ApiService apiService}) : _apiService = apiService;

  // ---- Getters ----

  List<Project> get projects => List.unmodifiable(_projects);
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---- Public API ----

  /// Fetches all projects from the API.
  Future<void> fetchProjects() async {
    await _guard(() async {
      _projects = await _apiService.getProjects();
    });
  }

  /// Fetches a single project by [id] and sets it as [selectedProject].
  Future<void> fetchProjectById(String id) async {
    await _guard(() async {
      _selectedProject = await _apiService.getProjectById(id);
    });
  }

  /// Creates a new project and prepends it to the local list.
  Future<bool> createProject({
    required String name,
    required String description,
  }) async {
    return _guardWithResult(() async {
      final newProject = await _apiService.createProject(
        name: name,
        description: description,
      );
      _projects.insert(0, newProject);
    });
  }

  /// Updates an existing project both remotely and in local state.
  Future<bool> updateProject({
    required String id,
    required String name,
    required String description,
  }) async {
    return _guardWithResult(() async {
      await _apiService.updateProject(
        id: id,
        name: name,
        description: description,
      );

      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = _projects[index].copyWith(
          name: name,
          description: description,
        );
      }

      if (_selectedProject?.id == id) {
        _selectedProject = _selectedProject!.copyWith(
          name: name,
          description: description,
        );
      }
    });
  }

  /// Deletes a project and removes it from local state.
  Future<bool> deleteProject(String id) async {
    return _guardWithResult(() async {
      await _apiService.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);

      if (_selectedProject?.id == id) {
        _selectedProject = null;
      }
    });
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
