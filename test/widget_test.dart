import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:family_wallet/services/local_db_service.dart';
import 'package:family_wallet/services/supabase_service.dart';
import 'package:family_wallet/main.dart';
import 'package:family_wallet/features/splash/splash_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalDbService().initialize();
    await SupabaseService().initialize();
    
    // Setup mock family workspace session for instant demo execution
    await LocalDbService().setString('current_family_id', 'sadik-household-uuid-777');
    await LocalDbService().setString('current_user', 'mock-user-uuid-12345');
  });

  testWidgets('Family Wallet App smoke test - verifies splash screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: FamilyWalletApp(),
      ),
    );

    // Verify that the splash screen text/icon is displayed.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('FAMILY WALLET'), findsOneWidget);
  });
}
