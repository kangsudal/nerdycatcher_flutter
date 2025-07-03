import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/app/routes/route_names.dart';
import 'package:nerdycatcher_flutter/pages/auth_selection_page.dart';
import 'package:nerdycatcher_flutter/pages/dashboard_page.dart';
import 'package:nerdycatcher_flutter/pages/home_page.dart';
import 'package:nerdycatcher_flutter/pages/notification_setting_page.dart';
import 'package:nerdycatcher_flutter/pages/plant_create_page.dart';
import 'package:nerdycatcher_flutter/pages/signin_page.dart';
import 'package:nerdycatcher_flutter/pages/signup_page.dart';
import 'package:nerdycatcher_flutter/pages/splash_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
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
      name: RouteNames.signup,
      path: '/auth/signup',
      builder: (context, state) => SignupPage(),
    ),
    GoRoute(
      name: RouteNames.home,
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      name: RouteNames.dashboard,
      path: '/dashboard/:plantId',
      builder: (context, state) {
        final plantId = int.parse(state.pathParameters['plantId']!);
        return DashboardPage(plantId: plantId);
      },
    ),
    GoRoute(
      name: RouteNames.notificationSetting,
      path: '/notificationSetting',
      builder: (context, state) => NotificationSettingPage(),
    ),
    GoRoute(
      name: RouteNames.plantCreate,
      path: '/plantCreate',
      builder: (context, state) => PlantCreatePage(),
    ),
    // GoRoute(
    //   name: RouteNames.settings,
    //   path: '/settings',
    //   builder: (context, state) => SettingsPage(),
    // ),
  ],
);
