
import 'package:equatable/equatable.dart';

import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

sealed class BalanceState extends Equatable {
  const BalanceState();

  @override
  List<Object?> get props => const [];
}

/// Estado inicial.
final class BalanceInitial extends BalanceState {
  const BalanceInitial();
}

/// Estado de carga.
final class BalanceLoading extends BalanceState {
  const BalanceLoading();
}

/// Estado de éxito: contiene el resumen de la billetera.
final class BalanceSuccess extends BalanceState {
  const BalanceSuccess(this.summary);

  final WalletSummary summary;

  @override
  List<Object?> get props => [summary];
}

/// Estado de error: contiene un mensaje comprensible.
final class BalanceFailure extends BalanceState {
  const BalanceFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
