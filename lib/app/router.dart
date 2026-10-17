import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/app/shell_scaffold.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_screen.dart';
import 'package:pharmacy_expiry_tracker/features/home/home_screen.dart';
import 'package:pharmacy_expiry_tracker/features/more/more_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/batch_detail_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/batch_form_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_detail_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_form_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_picker_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_screen.dart';

GoRouter buildRouter({String initialLocation = Routes.home}) {
  // One key per router so several routers (e.g. in tests) never share it.
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootKey,
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
                // Sub-pages cover the whole screen (no bottom bar) so forms
                // have room for the keyboard.
                routes: [
                  GoRoute(
                    path: 'pick',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const MedicinePickerScreen(),
                  ),
                  GoRoute(
                    path: 'medicine/new',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const MedicineFormScreen(),
                  ),
                  GoRoute(
                    path: 'medicine/:id',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) => MedicineDetailScreen(
                      medicineId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => MedicineFormScreen(
                          medicineId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'batch/new',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => BatchFormScreen(
                          medicineId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'batch/:id',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) =>
                        BatchDetailScreen(batchId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => BatchFormScreen(
                          batchId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
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
