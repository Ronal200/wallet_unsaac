
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WalletApp se construye correctamente', (tester) async {
    // Inicializar las preferencias simuladas.
    final sharedPreferences =
        await SharedPreferences.getInstance();

    final preferences = ThemePreferences(sharedPreferences);

    // Construir la aplicación.
    await tester.pumpWidget(
      WalletApp(
        initialThemeMode: ThemeMode.system,
        themePreferences: preferences,
        firebaseStatus: const FirebaseStatus.notConfigured(),
      ),
    );

    // Verificar que la aplicación se construyó.
    expect(find.text('Wallet UNSAAC'), findsOneWidget);

    // Completar el retraso del repositorio (350 ms).
    await tester.pump(const Duration(milliseconds: 400));

    // Completar las reconstrucciones pendientes.
    await tester.pumpAndSettle();
  });
}
