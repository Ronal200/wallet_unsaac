
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit(this._repository) : super(const BalanceInitial());

  final WalletRepository _repository;

  /// Consulta el resumen de la billetera.
  Future<void> load() async {
    emit(const BalanceLoading());

    try {
      final summary = await _repository.loadSummary();

      // Evita emitir estados si el Cubit ya fue cerrado.
      if (isClosed) return;

      emit(BalanceSuccess(summary));
    } catch (error) {
      if (isClosed) return;

      emit(
        const BalanceFailure(
          'No se pudo cargar el resumen de la billetera.',
        ),
      );
    }
  }
}
