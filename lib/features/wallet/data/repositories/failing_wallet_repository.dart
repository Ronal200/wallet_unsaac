
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';

class FailingWalletRepository implements WalletRepository {
  @override
  Future<WalletSummary> loadSummary() async {
    await Future<void>.delayed(
      const Duration(seconds: 2),
    );

    throw Exception('Sin conexión');
  }
}
