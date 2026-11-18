
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/privacy/privacy_cubit.dart';
import 'package:wallet_unsaac/core/privacy/privacy_state.dart';

import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';

import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/firebase_status_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';

/// Pantalla principal de Wallet UNSAAC.
///
/// Utiliza BalanceCubit para gestionar los estados de carga,
/// éxito y error del resumen de la billetera.
///
/// También permite cambiar el tema y ocultar los importes.
class WalletHomePage extends StatefulWidget {
  const WalletHomePage({
    super.key,
    required this.firebaseStatus,
  });

  final FirebaseStatus firebaseStatus;

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {

  /// Muestra mensajes de funcionalidades pendientes.
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature se habilita en la Sesión 2.'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Vuelve a consultar el resumen mediante BalanceCubit.
  Future<void> _reload() async {
    await context.read<BalanceCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Obtener el modo actual del ThemeCubit.
    final themeMode = context.watch<ThemeCubit>().state.mode;

    // Icono y tooltip según el modo seleccionado.
    IconData themeIcon;
    String themeTooltip;

    switch (themeMode) {
      case ThemeMode.light:
        themeIcon = Icons.light_mode_rounded;
        themeTooltip = 'Tema claro';

      case ThemeMode.dark:
        themeIcon = Icons.dark_mode_rounded;
        themeTooltip = 'Tema oscuro';

      case ThemeMode.system:
        themeIcon = Icons.settings_brightness_rounded;
        themeTooltip = 'Tema del sistema';
    }

    return BlocProvider(
      create: (_) => PrivacyCubit(),
      child: BlocBuilder<PrivacyCubit, PrivacyState>(
        builder: (context, privacyState) {
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 20,
              title: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wallet UNSAAC',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: themeTooltip,
                  icon: Icon(themeIcon),
                  onPressed: () {
                    context.read<ThemeCubit>().toggle();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Gestión de los estados mediante BalanceCubit.
            body: BlocBuilder<BalanceCubit, BalanceState>(
              builder: (context, balanceState) {

                // ESTADO INICIAL Y CARGA.
                if (balanceState is BalanceInitial ||
                    balanceState is BalanceLoading) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando saldo...'),
                      ],
                    ),
                  );
                }

                // ESTADO DE ERROR.
                if (balanceState is BalanceFailure) {
                  return _ErrorView(
                    message: balanceState.message,
                    onRetry: _reload,
                  );
                }

                // ESTADO DE ÉXITO.
                if (balanceState is BalanceSuccess) {
                  final summary = balanceState.summary;

                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        32,
                      ),
                      children: [
                        Text(
                          'Hola, Ronal Franklin Choquenaira Garcia',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Este es el resumen de tus finanzas en noviembre de 2026.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Tarjeta de saldo con control de privacidad.
                        BalanceCard(
                          summary: summary,
                          hideBalance: privacyState.hidden,
                          onToggleVisibility: () {
                            context.read<PrivacyCubit>().toggle();
                          },
                        ),

                        const SizedBox(height: 20),

                        // Botones de ingresos y egresos.
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () {
                                  _showComingSoon('Registrar ingreso');
                                },
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Ingreso'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _showComingSoon('Registrar egreso');
                                },
                                icon: const Icon(Icons.remove_rounded),
                                label: const Text('Egreso'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Título de movimientos.
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Últimos movimientos',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _showComingSoon('El historial completo');
                              },
                              child: const Text('Ver todos'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Lista de movimientos.
                        if (summary.isEmpty)
                          const _EmptyMovements()
                        else
                          for (final movement in summary.movements) ...[
                            MovementTile(
                              movement: movement,
                              hideAmount: privacyState.hidden,
                            ),
                            const SizedBox(height: 10),
                          ],

                        const SizedBox(height: 12),

                        // Estado de Firebase.
                        FirebaseStatusCard(
                          status: widget.firebaseStatus,
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            'Datos de demostración · Wallet UNSAAC 1.0.0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}

/// Widget que representa el estado de error.
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: scheme.error,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Revisa la conexión y vuelve a intentarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para cuando todavía no existen movimientos.
class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text(
              'Todavía no registraste movimientos.',
            ),
          ],
        ),
      ),
    );
  }
}
