import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workspace_tracker/models/auth_response_model.dart';
import 'package:workspace_tracker/models/project_model.dart';
import 'package:workspace_tracker/models/task_model.dart';

/// Centralised HTTP client for communicating with the Workspace Tracker API.
///
/// Uses [Dio] with an interceptor that automatically attaches the JWT bearer
/// token from [SharedPreferences] and clears stored credentials on 401
/// responses.
class ApiService {
  static const String _baseUrl = 'http://localhost:5000';

  /// SharedPreferences key for the JWT token.
  static const String keyToken = 'jwt_token';

  /// SharedPreferences key for serialised user data.
  static const String keyUserData = 'user_data';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(keyToken);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(keyToken);
            await prefs.remove(keyUserData);
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// Registers a new user account.
  ///
  /// Returns the raw [AuthResponse] — note the backend returns a success
  /// message (not a token) for registration, so the caller should handle
  /// this accordingly.
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {'username': username, 'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Registration failed: ${_extractMessage(response.data)}');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Authenticates a user and persists the JWT token locally.
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final authResponse =
            AuthResponse.fromJson(response.data as Map<String, dynamic>);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(keyToken, authResponse.token);
        await prefs.setString(
          keyUserData,
          '${authResponse.username}|${authResponse.email}',
        );

        return authResponse;
      }
      throw Exception('Login failed: ${_extractMessage(response.data)}');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------------------------------------------------------------------
  // Projects
  // ---------------------------------------------------------------------------

  /// Fetches all projects for the authenticated user.
  Future<List<Project>> getProjects() async {
    try {
      final response = await _dio.get('/api/projects');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data
            .map((item) => Project.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch projects.');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Fetches a single project by [id].
  Future<Project> getProjectById(String id) async {
    try {
      final response = await _dio.get('/api/projects/$id');

      if (response.statusCode == 200) {
        return Project.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch project.');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Creates a new project and returns the created resource.
  Future<Project> createProject({
    required String name,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/projects',
        data: {'name': name, 'description': description},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Project.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create project.');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Updates an existing project.
  Future<void> updateProject({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      final response = await _dio.put(
        '/api/projects/$id',
        data: {'name': name, 'description': description},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to update project.');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Deletes a project and all its associated tasks.
  Future<void> deleteProject(String id) async {
    try {
      final response = await _dio.delete('/api/projects/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete project.');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------------------

  /// Fetches all tasks belonging to the given [projectId].
  Future<List<TaskItem>> getProjectTasks(String projectId) async {
    try {
      final response = await _dio.get('/api/projects/$projectId/tasks');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data
            .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch tasks.');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Fetches a single task by [id].
  Future<TaskItem> getTaskById(String id) async {
    try {
      final response = await _dio.get('/api/tasks/$id');

      if (response.statusCode == 200) {
        return TaskItem.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch task.');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Creates a new task and returns the created resource.
  Future<TaskItem> createTask({
    required String title,
    required String description,
    required String status,
    required String projectId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/tasks',
        data: {
          'title': title,
          'description': description,
          'status': status,
          'projectId': projectId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TaskItem.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create task.');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Updates an existing task.
  Future<void> updateTask({
    required String id,
    required String title,
    required String description,
    required String status,
    required String projectId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/tasks/$id',
        data: {
          'title': title,
          'description': description,
          'status': status,
          'projectId': projectId,
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to update task.');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Deletes a task by [id].
  Future<void> deleteTask(String id) async {
    try {
      final response = await _dio.delete('/api/tasks/$id');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete task.');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts a human-readable error message from a [DioException].
  ///
  /// Checks the `detail`, `message`, and `title` fields of the response body
  /// in order of priority, falling back to the Dio error message.
  String _getErrorMessage(DioException error) {
    final message = _extractMessage(error.response?.data);
    return message ?? error.message ?? 'An unexpected error occurred.';
  }

  /// Attempts to pull a message string from a generic API response body.
  String? _extractMessage(dynamic data) {
    if (data is Map) {
      return data['detail'] as String? ??
          data['message'] as String? ??
          data['title'] as String?;
    }
    return null;
  }
}
