import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_tracker/providers/auth_provider.dart';
import 'package:workspace_tracker/utils/ui_helpers.dart';

/// Screen allowing new users to create an account.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      showAppSnackBar(
        context,
        message: 'Passwords do not match',
        color: AppColors.error,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      showAppSnackBar(
        context,
        message: 'Registration successful! Logging you in...',
        color: AppColors.success,
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      showAppSnackBar(
        context,
        message: authProvider.errorMessage ?? 'Registration failed',
        color: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Create an account to start tracking your projects',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      decoration: buildInputDecoration(
                        labelText: 'Username',
                        hintText: 'Choose a username',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: buildInputDecoration(
                        labelText: 'Email Address',
                        hintText: 'name@example.com',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email address';
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
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: buildInputDecoration(
                        labelText: 'Confirm Password',
                        hintText: '••••••••',
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Register Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleRegister,
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
                                  'Create Account',
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

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Sign In',
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
