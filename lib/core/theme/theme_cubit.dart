
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

/// Cubit que gestiona el tema de la aplicación.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    required ThemeMode initialMode,
    required this._preferences,
  }) : super(ThemeState(mode: initialMode));

  final ThemePreferences _preferences;

  /// Recorre los modos claro → oscuro → sistema → claro.
  Future<void> toggle() async {
    final ThemeMode nextMode;

    switch (state.mode) {
      case ThemeMode.light:
        nextMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        nextMode = ThemeMode.light;
        break;
    }

    await setMode(nextMode);
  }

  /// Cambia el tema y guarda la selección.
  Future<void> setMode(ThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await _preferences.saveMode(mode);
  }

  /// Regresa al tema del sistema.
  Future<void> useSystemMode() async {
    await setMode(ThemeMode.system);
  }
}
