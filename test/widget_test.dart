
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';

void main() {
  testWidgets('WalletApp se construye correctamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const WalletApp(
        firebaseStatus: FirebaseStatus.notConfigured(),
      ),
    );

    expect(find.byType(WalletApp), findsOneWidget);
  });
}
