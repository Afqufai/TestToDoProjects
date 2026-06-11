import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_tracker/providers/auth_provider.dart';
import 'package:workspace_tracker/providers/project_provider.dart';
import 'package:workspace_tracker/providers/task_provider.dart';
import 'package:workspace_tracker/screens/login_screen.dart';
import 'package:workspace_tracker/screens/register_screen.dart';
import 'package:workspace_tracker/screens/project_list_screen.dart';
import 'package:workspace_tracker/screens/project_detail_screen.dart';
import 'package:workspace_tracker/services/api_service.dart';
import 'package:workspace_tracker/utils/ui_helpers.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() {
  runApp(const WorkspaceTrackerApp());
}

/// Root widget that configures providers, theming, and routing.
class WorkspaceTrackerApp extends StatelessWidget {
  const WorkspaceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Workspace Tracker',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const _AuthGate(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const ProjectListScreen(),
          '/project-detail': (context) {
            final projectId =
                ModalRoute.of(context)!.settings.arguments as String;
            return ProjectDetailScreen(projectId: projectId);
          },
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: Colors.indigo.shade600,
      colorScheme: ColorScheme.dark(
        primary: Colors.indigo.shade600,
        secondary: Colors.purple.shade400,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
      ),
      textTheme: const TextTheme(
        bodySmall: TextStyle(color: AppColors.textSecondary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Decides which screen to show based on [AuthProvider] state.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.indigo),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return auth.isAuthenticated
            ? const ProjectListScreen()
            : const LoginScreen();
      },
    );
  }
}
