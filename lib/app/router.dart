import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/app/shell_scaffold.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_screen.dart';
import 'package:pharmacy_expiry_tracker/features/home/home_screen.dart';
import 'package:pharmacy_expiry_tracker/features/more/more_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_screen.dart';

GoRouter buildRouter({String initialLocation = Routes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.stock,
                builder: (_, _) => const StockScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.expiry,
                builder: (_, state) => ExpiryScreen(
                  bucket: state.uri.queryParameters['bucket'],
                  date: state.uri.queryParameters['date'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.suppliers,
                builder: (_, _) => const SuppliersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.more, builder: (_, _) => const MoreScreen()),
            ],
          ),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter();
  ref.onDispose(router.dispose);
  return router;
});
