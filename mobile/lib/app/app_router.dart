import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_provider.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/cart/presentation/cart_page.dart';
import '../features/categories/presentation/categories_page.dart';
import '../features/coupons/presentation/coupons_page.dart';
import '../features/farms/presentation/farm_page.dart';
import '../features/group_buys/presentation/group_buy_detail_page.dart';
import '../features/group_buys/presentation/group_buys_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/orders/presentation/checkout_page.dart';
import '../features/orders/presentation/order_detail_page.dart';
import '../features/orders/presentation/orders_page.dart';
import '../features/presales/presentation/presale_detail_page.dart';
import '../features/presales/presentation/presales_page.dart';
import '../features/products/presentation/product_detail_page.dart';
import '../features/products/presentation/products_page.dart';
import '../features/products/presentation/reports_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/profile/presentation/settings_page.dart';
import '../features/search/presentation/search_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/subscriptions/presentation/subscription_create_page.dart';
import '../features/subscriptions/presentation/subscriptions_page.dart';
import '../features/trace/presentation/trace_query_page.dart';
import '../features/trace/presentation/trace_result_page.dart';
import 'router_refresh.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authed = ref.read(authProvider) != null;
      final loc = state.matchedLocation;
      const publicRoutes = ['/splash', '/login'];
      if (publicRoutes.contains(loc)) {
        if (authed && loc == '/login') return '/home';
        return null;
      }
      if (!authed) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/categories', builder: (_, __) => const CategoriesPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          ]),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/products',
        builder: (_, s) => ProductsPage(categoryId: s.uri.queryParameters['categoryId']),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/product/:id',
        builder: (_, s) => ProductDetailPage(productId: s.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/product/:id/reports',
        builder: (_, s) => ReportsPage(productId: s.pathParameters['id']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/trace', builder: (_, __) => const TraceQueryPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/trace/:code',
        builder: (_, s) => TraceResultPage(code: s.pathParameters['code']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/farm/:id',
        builder: (_, s) => FarmPage(farmId: s.pathParameters['id']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/presales', builder: (_, __) => const PresalesPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/presale/:id',
        builder: (_, s) => PresaleDetailPage(presaleId: s.pathParameters['id']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/group-buys', builder: (_, __) => const GroupBuysPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/group-buy/:id',
        builder: (_, s) => GroupBuyDetailPage(groupBuyId: s.pathParameters['id']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/checkout', builder: (_, __) => const CheckoutPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/orders', builder: (_, __) => const OrdersPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/order/:id',
        builder: (_, s) => OrderDetailPage(orderId: s.pathParameters['id']!),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/subscriptions', builder: (_, __) => const SubscriptionsPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/subscription/create',
        builder: (_, __) => const SubscriptionCreatePage(),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/search', builder: (_, __) => const SearchPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/coupons', builder: (_, __) => const CouponsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
  );
});
