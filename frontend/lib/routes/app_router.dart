import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/rice_stock_screen.dart';
import '../screens/plant_stock_screen.dart';
import '../screens/production_screen.dart';
import '../screens/shop_sales_screen.dart';
import '../screens/other_sales_screen.dart';
import '../screens/expenses_screen.dart';
import '../widgets/main_layout.dart';

import '../providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoginRoute = state.uri.path == '/login' || state.uri.path == '/signup';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/rice-stock',
          builder: (context, state) => const RiceStockScreen(),
        ),
        GoRoute(
          path: '/plant-stock',
          builder: (context, state) => const PlantStockScreen(),
        ),
        GoRoute(
          path: '/production',
          builder: (context, state) => const ProductionScreen(),
        ),
        GoRoute(
          path: '/shop-sales',
          builder: (context, state) => const ShopSalesScreen(),
        ),
        GoRoute(
          path: '/other-sales',
          builder: (context, state) => const OtherSalesScreen(),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const ExpensesScreen(),
        ),
      ],
    ),
  ],
  );
}
