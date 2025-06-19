import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/other/routes/route_names.dart';
import 'package:nerdycatcher_flutter/pages/auth_selection_page.dart';
import 'package:nerdycatcher_flutter/pages/dashboard_page.dart';
import 'package:nerdycatcher_flutter/pages/home_page.dart';
import 'package:nerdycatcher_flutter/pages/signin_page.dart';
import 'package:nerdycatcher_flutter/pages/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: RouteNames.authSelection,
      path: '/authSelection',
      builder: (context, state) => AuthSelectionPage(),
    ),
    GoRoute(
      name: RouteNames.signin,
      path: '/auth/signin',
      builder: (context, state) => SigninPage(),
    ),
    GoRoute(
      name: RouteNames.home,
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      name: RouteNames.dashboard,
      path: '/dashboard',
      builder: (context, state) => DashboardPage(),
    ),
    // GoRoute(
    //   name: RouteNames.settings,
    //   path: '/settings',
    //   builder: (context, state) => SettingsPage(),
    // ),
  ],
);
