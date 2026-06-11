import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Design tokens
// ---------------------------------------------------------------------------

/// Centralised colour palette used across the mobile application.
///
/// Keeping colours here avoids scattering raw hex values throughout the
/// widget tree and ensures a single source of truth for theming.
abstract final class AppColors {
  static const Color background = Color(0xFF030712);
  static const Color surface = Color(0xFF0f172a);
  static const Color inputFill = Color(0xFF0f1422);
  static const Color border = Color(0xFF1e293b);
  static const Color textPrimary = Color(0xFFf1f5f9);
  static const Color textSecondary = Color(0xFF94a3b8);
  static const Color textTertiary = Color(0xFF64748b);
  static const Color hint = Color(0xFF475569);
  static const Color error = Color(0xFFef4444); // red.shade500
  static const Color success = Color(0xFF22c55e); // green.shade500
}

// ---------------------------------------------------------------------------
// Shared UI helpers
// ---------------------------------------------------------------------------

/// Builds a consistent [InputDecoration] used throughout the app.
InputDecoration buildInputDecoration({
  required String labelText,
  String? hintText,
}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.hint),
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

/// Shows a themed [SnackBar] with the given [message] and [color].
void showAppSnackBar(
  BuildContext context, {
  required String message,
  required Color color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
