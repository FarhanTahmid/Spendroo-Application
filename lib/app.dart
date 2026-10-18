import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/auth/auth_repository.dart';
import 'core/providers.dart';
import 'core/push/push_controller.dart';
import 'core/ui.dart';
import 'features/goals/goal_page.dart';
import 'features/goals/goals_page.dart';
import 'features/home_widget/home_widget_controller.dart';
import 'features/home_widget/quick_add_page.dart';
import 'features/home_widget/widget_launch.dart';
import 'features/insights/year_review_page.dart';
import 'features/auth/auth_pages.dart';
import 'features/cashbook/access_page.dart';
import 'features/cashbook/cashbook_pages.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/personal/account_page.dart';
import 'features/personal/categories_page.dart';
import 'features/plan/keep_page.dart';
import 'features/plan/plan_page.dart';
import 'features/profile/profile_page.dart';
import 'features/recurring/inbox.dart';
import 'features/recurring/recurring_pages.dart';
import 'features/settings/notification_settings_page.dart';
import 'features/settings/settings_page.dart';
import 'features/shell/home_shell.dart';
import 'features/team/join_page.dart';
import 'features/team/member_page.dart';
import 'features/team/team_page.dart';
import 'l10n/app_localizations.dart';

/// Where each sign-in state belongs. The router re-evaluates this whenever
/// the auth or onboarding state changes, so screens never navigate on login.
String? _redirect(AuthState auth, bool? onboarded, String location) {
  if (!auth.ready) return '/splash';
  switch (auth.step) {
    case AuthStep.needsEmailCode:
      return '/verify';
    case AuthStep.needsResetCode:
      return '/reset';
    case AuthStep.signedOut:
      return const {'/login', '/signup', '/forgot'}.contains(location) ? null : '/login';
    case AuthStep.signedIn:
      if (onboarded == null) return '/splash';
      if (!onboarded) return '/onboarding';
      const signedOutOnly = {'/splash', '/login', '/signup', '/forgot', '/verify', '/reset', '/onboarding'};
      return signedOutOnly.contains(location) ? '/' : null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.listen(onboardedProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final target = _redirect(ref.read(authControllerProvider), ref.read(onboardedProvider), state.matchedLocation);
      return target == state.matchedLocation ? null : target;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const _SplashPage(),
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, _) => const LoginPage(signUp: true)),
      GoRoute(path: '/verify', builder: (_, _) => const VerifyEmailPage()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordPage()),
      GoRoute(path: '/reset', builder: (_, _) => const ResetPasswordPage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/', builder: (_, _) => const HomeShell()),
      // The add form on its own, for the home-screen widget's buttons
      GoRoute(
        path: '/add',
        pageBuilder: (_, state) => MaterialPage(
          fullscreenDialog: true,
          child: QuickAddPage(kind: state.uri.queryParameters['kind']),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsPage(),
        routes: [GoRoute(path: 'notifications', builder: (_, _) => const NotificationSettingsPage())],
      ),
      GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
      GoRoute(path: '/categories', builder: (_, _) => const CategoriesPage()),
      GoRoute(path: '/recurring', builder: (_, _) => const RecurringPage()),
      GoRoute(path: '/inbox', builder: (_, _) => const InboxPage()),
      GoRoute(
        path: '/plan',
        builder: (_, _) => const PlanPage(),
        routes: [GoRoute(path: 'keep', builder: (_, _) => const KeepPage())],
      ),
      GoRoute(path: '/account/:id', builder: (_, state) => AccountPage(accountId: state.pathParameters['id']!)),
      GoRoute(path: '/goals', builder: (_, _) => const GoalsPage()),
      GoRoute(
        path: '/team',
        builder: (_, _) => const TeamPage(),
        routes: [
          GoRoute(path: ':membershipId', builder: (_, state) => MemberPage(membershipId: state.pathParameters['membershipId']!)),
        ],
      ),
      GoRoute(path: '/join', builder: (_, _) => const JoinPage()),
      GoRoute(path: '/year-review', builder: (_, _) => const YearReviewPage()),
      GoRoute(path: '/goal/:id', builder: (_, state) => GoalPage(goalId: state.pathParameters['id']!)),
      GoRoute(
        path: '/cashbook/:id',
        builder: (_, state) => CashbookPage(bookId: state.pathParameters['id']!),
        routes: [
          GoRoute(path: 'report', builder: (_, state) => CashbookReportPage(bookId: state.pathParameters['id']!)),
          GoRoute(
            path: 'categories',
            builder: (_, state) => CashbookCategoriesPage(bookId: state.pathParameters['id']!),
          ),
          GoRoute(path: 'access', builder: (_, state) => CashbookAccessPage(bookId: state.pathParameters['id']!)),
        ],
      ),
    ],
  );
});

/// Shown while the app finds out who is signed in: the logo settles in, then the loader.
class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.header,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1),
              duration: context.motion(const Duration(milliseconds: 450)),
              curve: AppMotion.spring,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: const BrandLogo(layout: BrandLayout.stacked, onDark: true, height: 190),
            ),
            const SizedBox(height: 32),
            AppLoader(color: colors.mint),
          ],
        ),
      ),
    );
  }
}

class SpendrooApp extends ConsumerWidget {
  const SpendrooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the sync timer alive for as long as the app is open
    ref.watch(syncControllerProvider);
    // Registers this phone for push while someone is signed in
    ref.watch(pushControllerProvider);
    // Keeps the home-screen widget's figures current, and hears its buttons
    ref.watch(homeWidgetControllerProvider);
    ref.watch(widgetLaunchControllerProvider);
    final router = ref.watch(routerProvider);

    // A tapped notification opens its screen, once the app knows who is signed in
    void follow() {
      final route = ref.read(pushRouteProvider);
      if (route == null) return;
      if (ref.read(authControllerProvider).step != AuthStep.signedIn || ref.read(onboardedProvider) != true) return;
      ref.read(pushRouteProvider.notifier).done();
      // From home, so going back leads somewhere
      router.go('/');
      if (route != '/') WidgetsBinding.instance.addPostFrameCallback((_) => router.push(route));
    }

    ref.listen(pushRouteProvider, (_, _) => follow());
    ref.listen(authControllerProvider, (_, _) => follow());
    ref.listen(onboardedProvider, (_, _) => follow());
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      // Above every route and sheet, so the amount keypad can sit under all of them
      builder: (context, child) => AmountKeypadHost(child: child!),
    );
  }
}
