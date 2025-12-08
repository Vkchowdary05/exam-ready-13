// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // <- add this

/// Holds current ThemeMode (light / dark).
/// Default is light mode.
///
/// Usage in widgets (with flutter_riverpod):
///   final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
///   ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});
