import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_tracker/providers/auth_provider.dart';
import 'package:workspace_tracker/utils/ui_helpers.dart';

/// Screen allowing existing users to authenticate.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      showAppSnackBar(
        context,
        message: authProvider.errorMessage ?? 'Login failed',
        color: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // App Title
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade400,
                      Colors.purple.shade400,
                      Colors.pink.shade400,
                    ],
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.indigo.shade400,
                      Colors.purple.shade400,
                      Colors.pink.shade400,
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'Workspace Tracker',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sign in to manage your projects',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 48),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      decoration: buildInputDecoration(
                        labelText: 'Username or Email',
                        hintText: 'Enter your username or email',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username or email is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: buildInputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.indigo.shade400,
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/register'),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.indigo.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
