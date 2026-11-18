
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';

class MockWalletRepository extends Mock
    implements WalletRepository {}

void main() {
  late MockWalletRepository repository;
  late WalletSummary summary;

  setUp(() {
    repository = MockWalletRepository();
    summary = WalletSummary(movements: const []);
  });

  group('BalanceCubit', () {

    // PRUEBA 1: ÉXITO.
    blocTest<BalanceCubit, BalanceState>(
      'emite Loading y Success cuando la consulta funciona',
      build: () {
        when(() => repository.loadSummary())
            .thenAnswer((_) async => summary);

        return BalanceCubit(repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const BalanceLoading(),
        BalanceSuccess(summary),
      ],
      verify: (_) {
        verify(() => repository.loadSummary()).called(1);
      },
    );

    // PRUEBA 2: FALLO.
    blocTest<BalanceCubit, BalanceState>(
      'emite Loading y Failure cuando ocurre un error',
      build: () {
        when(() => repository.loadSummary())
            .thenThrow(Exception('sin conexión'));

        return BalanceCubit(repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const BalanceLoading(),
        const BalanceFailure(
          'No se pudo cargar el resumen de la billetera.',
        ),
      ],
      verify: (_) {
        verify(() => repository.loadSummary()).called(1);
      },
    );

    // PRUEBA 3: REINTENTO.
    blocTest<BalanceCubit, BalanceState>(
      'permite reintentar después de un error',
      build: () {
        var attempts = 0;

        when(() => repository.loadSummary()).thenAnswer((_) async {
          attempts++;

          if (attempts == 1) {
            throw Exception('sin conexión');
          }

          return summary;
        });

        return BalanceCubit(repository);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.load();
      },
      expect: () => [
        const BalanceLoading(),
        const BalanceFailure(
          'No se pudo cargar el resumen de la billetera.',
        ),
        const BalanceLoading(),
        BalanceSuccess(summary),
      ],
      verify: (_) {
        verify(() => repository.loadSummary()).called(2);
      },
    );
  });
}
