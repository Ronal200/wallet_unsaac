import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_bootstrap.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseStatus = await FirebaseBootstrap.initialize();

  final preferences = ThemePreferences(await SharedPreferences.getInstance());

  final initialMode = await preferences.loadMode();

  runApp(
    WalletApp(
      firebaseStatus: firebaseStatus,
      initialThemeMode: initialMode,
      themePreferences: preferences,
    ),
  );
}
