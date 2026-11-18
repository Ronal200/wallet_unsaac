import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la persistencia del tema de la aplicación.
class ThemePreferences {
  ThemePreferences(this._preferences);

  final SharedPreferences _preferences;

  static const String _themeKey = 'wallet.theme_mode';

  /// Recupera el tema guardado.
  /// Si no existe o está corrupto, utiliza ThemeMode.system.
  Future<ThemeMode> loadMode() async {
    final String? savedMode = _preferences.getString(_themeKey);

    return themeModeFromName(savedMode);
  }

  /// Guarda el modo seleccionado.
  Future<void> saveMode(ThemeMode mode) async {
    await _preferences.setString(_themeKey, mode.name);
  }

  /// Convierte el nombre almacenado en ThemeMode.
  /// Los valores desconocidos utilizan system.
  static ThemeMode themeModeFromName(String? name) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}
