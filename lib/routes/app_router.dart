import 'package:family_wallet/features/dashboard/screens/premium_subscription_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/dashboard/screens/navigation_shell_screen.dart';
import '../features/assistant/screens/ai_chat_screen.dart';
import '../features/assistant/screens/ocr_scanner_screen.dart';
import '../features/admin/screens/admin_shell_screen.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/reports/screens/monthly_savings_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isRestored = authState.isSessionRestored;
      final isLoggedIn = authState.user != null;

      final isSplash = state.matchedLocation == '/splash';
      final isAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/onboarding';

      if (!isRestored) {
        // Hold on splash until state resolves
        return isSplash ? null : '/splash';
      }

      if (!isLoggedIn) {
        // Force login if trying to access secure pages
        if (!isAuth) return '/onboarding';
        return null;
      }

      final isSuperAdmin =
          authState.user?.role == 'super_admin' ||
          authState.user?.email == 'alisadik99@gmail.com';

      // If logged in, don't allow auth screens
      if (isSplash || isAuth) {
        return isSuperAdmin ? '/admin' : '/home';
      }

      // If super admin tries to access normal pages, force them to admin panel
      if (isSuperAdmin && state.matchedLocation != '/admin') {
        return '/admin';
      }

      // If normal user tries to access admin panel, force them to home
      if (!isSuperAdmin && state.matchedLocation == '/admin') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => NavigationShellScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => AiChatScreen(),
      ),
      GoRoute(
        path: '/ocr-scanner',
        builder: (context, state) => OcrScannerScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => AdminShellScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => PremiumSubscriptionScreen(),
      ),
      GoRoute(
        path: '/monthly-savings',
        builder: (context, state) => MonthlySavingsView(),
      ),
    ],
  );
});
