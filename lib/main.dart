import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
import 'services/local_db_service.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/controllers/profile_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load .env file
  await dotenv.load(fileName: '.env');

  // 2. Force premium portrait visual orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 3. Initialize SharedPreferences local database
  final localDb = LocalDbService();
  await localDb.initialize();

  // 4. Initialize Supabase Client
  final supabase = SupabaseService();
  await supabase.initialize();

  // Removed mock family workspace setup so real users can recover their sessions.

  runApp(ProviderScope(child: FamilyWalletApp()));
}

class FamilyWalletApp extends ConsumerWidget {
  const FamilyWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final isDark = profileState.isDarkMode;

    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Family Wallet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}
