import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workspace_tracker/models/user_model.dart';
import 'package:workspace_tracker/services/api_service.dart';

/// Manages authentication state — login, registration, logout, and
/// persisted JWT session restoration from [SharedPreferences].
class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required ApiService apiService}) : _apiService = apiService {
    _restoreSession();
  }

  // ---- Getters ----

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;

  // ---- Public API ----

  /// Registers a new user and, on success, auto-logs them in.
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      final response = await _apiService.register(
        username: username,
        email: email,
        password: password,
      );

      _user = User(id: '', username: response.username, email: response.email);
      _token = response.token;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiService.keyToken, response.token);
      await prefs.setString(
        ApiService.keyUserData,
        '${response.username}|${response.email}',
      );
    });
  }

  /// Authenticates a user with their credentials.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    return _guard(() async {
      final response = await _apiService.login(
        username: username,
        password: password,
      );

      _user = User(id: '', username: response.username, email: response.email);
      _token = response.token;
    });
  }

  /// Clears all session data and navigates the user back to the login screen.
  Future<void> logout() async {
    _user = null;
    _token = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiService.keyToken);
    await prefs.remove(ApiService.keyUserData);

    notifyListeners();
  }

  // ---- Private helpers ----

  /// Restores a previously persisted JWT session from local storage.
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiService.keyToken);

    if (_token != null) {
      final userData = prefs.getString(ApiService.keyUserData);
      if (userData != null) {
        final parts = userData.split('|');
        _user = User(
          id: '',
          username: parts[0],
          email: parts.length > 1 ? parts[1] : '',
        );
      }
    }
    notifyListeners();
  }

  /// Wraps an async operation with loading state management and error
  /// handling, reducing boilerplate across [register] and [login].
  Future<bool> _guard(Future<void> Function() action) async {
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
