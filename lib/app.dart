
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/loading_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/failing_wallet_repository.dart';

/// Raíz de la aplicación.
class WalletApp extends StatelessWidget {
  const WalletApp({
    super.key,
    required this.initialThemeMode,
    required this.themePreferences,
    required this.firebaseStatus,
  });

  final ThemeMode initialThemeMode;
  final ThemePreferences themePreferences;
  final FirebaseStatus firebaseStatus;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WalletRepository>(
          ///create: (_) => FailingWalletRepository(), para crear error de carga

          ///create: (_) => LoadingWalletRepository(),// simula la carga 
          create: (_) => InMemoryWalletRepository(), //utiliza la memoria
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Cubit para administrar el tema.
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(
              initialMode: initialThemeMode,
              preferences: themePreferences,
            ),
          ),

          // Cubit para administrar el saldo y sus estados.
          BlocProvider<BalanceCubit>(
            create: (context) => BalanceCubit(
              context.read<WalletRepository>(),
            )..load(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Wallet UNSAAC',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeState.mode,
              home: WalletHomePage(
                firebaseStatus: firebaseStatus,
              ),
            );
          },
        ),
      ),
    );
  }
}
