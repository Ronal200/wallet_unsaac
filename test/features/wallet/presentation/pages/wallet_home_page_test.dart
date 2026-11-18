
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/utils/money.dart';

import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'muestra el saldo y los movimientos cuando BalanceCubit tiene éxito',
    (WidgetTester tester) async {

      // 1. Simular SharedPreferences en memoria.
      SharedPreferences.setMockInitialValues({});

      final preferences = await SharedPreferences.getInstance();

      // 2. Crear el repositorio en memoria.
      final repository = InMemoryWalletRepository(
        latency: Duration.zero,
      );

      // 3. Crear el BalanceCubit real.
      final balanceCubit = BalanceCubit(repository);

      // 4. Crear el ThemeCubit real.
      final themeCubit = ThemeCubit(
        initialMode: ThemeMode.light,
        preferences: ThemePreferences(preferences),
      );

      // 5. Cargar el resumen de la billetera.
      await balanceCubit.load();

      // 6. Obtener el resumen exitoso.
      final successState = balanceCubit.state as BalanceSuccess;
      final summary = successState.summary;

      // 7. Liberar los Cubits al terminar la prueba.
      addTearDown(() async {
        await balanceCubit.close();
        await themeCubit.close();
      });

      // 8. Construir la pantalla.
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<BalanceCubit>.value(
              value: balanceCubit,
            ),
            BlocProvider<ThemeCubit>.value(
              value: themeCubit,
            ),
          ],
          child: MaterialApp(
            home: WalletHomePage(
              firebaseStatus: const FirebaseStatus.notConfigured(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 9. COMPROBAR EL SALDO.
      expect(
        find.text('Saldo disponible'),
        findsOneWidget,
      );

      expect(
        find.text(MoneyFormat.soles(summary.balance)),
        findsOneWidget,
      );

      // 10. COMPROBAR EL TÍTULO DE MOVIMIENTOS.
      expect(
        find.text('Últimos movimientos'),
        findsOneWidget,
      );

      // 11. COMPROBAR EL PRIMER MOVIMIENTO.
      expect(
        find.text('Sueldo de prácticas'),
        findsOneWidget,
      );

      // 12. DESPLAZARSE HASTA EL SIGUIENTE MOVIMIENTO.
      await tester.scrollUntilVisible(
        find.text('Beca de comedor'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.pumpAndSettle();

      // 13. COMPROBAR EL SEGUNDO MOVIMIENTO.
      expect(
        find.text('Beca de comedor'),
        findsOneWidget,
      );
    },
  );
}
