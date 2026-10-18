import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/onboarding_gate.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/app/shell_scaffold.dart';
import 'package:pharmacy_expiry_tracker/features/alerts/alert_health_screen.dart';
import 'package:pharmacy_expiry_tracker/features/alerts/alert_history_screen.dart';
import 'package:pharmacy_expiry_tracker/features/alerts/alert_permission.dart';
import 'package:pharmacy_expiry_tracker/features/alerts/alert_settings_screen.dart';
import 'package:pharmacy_expiry_tracker/features/backup/backup_screen.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_screen.dart';
import 'package:pharmacy_expiry_tracker/features/home/home_screen.dart';
import 'package:pharmacy_expiry_tracker/features/more/alert_lab_screen.dart';
import 'package:pharmacy_expiry_tracker/features/more/more_screen.dart';
import 'package:pharmacy_expiry_tracker/features/more/reorder_screen.dart';
import 'package:pharmacy_expiry_tracker/features/more/settings_screen.dart';
import 'package:pharmacy_expiry_tracker/features/onboarding/onboarding_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/batch_detail_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/batch_form_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_detail_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_form_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/medicine_picker_screen.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/invoice_detail_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/invoice_form_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/payment_form_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/supplier_detail_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/supplier_form_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_screen.dart';

GoRouter buildRouter({
  String initialLocation = Routes.home,
  OnboardingState Function()? onboarding,
  Listenable? refreshListenable,
}) {
  // One key per router so several routers (e.g. in tests) never share it.
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    // First run goes through onboarding; afterwards it is never shown again.
    redirect: (context, state) {
      final stage = onboarding?.call() ?? OnboardingState.done;
      final atOnboarding = state.uri.path == Routes.onboarding;
      if (stage == OnboardingState.needed && !atOnboarding) {
        return Routes.onboarding;
      }
      if (stage == OnboardingState.done && atOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        parentNavigatorKey: rootKey,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.alertPermission,
        parentNavigatorKey: rootKey,
        builder: (_, _) => const AlertPermissionScreen(),
      ),
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
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const SupplierFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) => SupplierDetailScreen(
                      supplierId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => SupplierFormScreen(
                          supplierId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'pay',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => PaymentFormScreen(
                          supplierId: state.pathParameters['id']!,
                          invoiceId: state.uri.queryParameters['invoice'],
                        ),
                      ),
                      GoRoute(
                        path: 'invoice/new',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => InvoiceFormScreen(
                          supplierId: state.pathParameters['id']!,
                          args: state.extra is InvoiceFormArgs
                              ? state.extra! as InvoiceFormArgs
                              : const InvoiceFormArgs(),
                        ),
                      ),
                      GoRoute(
                        path: 'invoice/:iid',
                        parentNavigatorKey: rootKey,
                        builder: (_, state) => InvoiceDetailScreen(
                          supplierId: state.pathParameters['id']!,
                          invoiceId: state.pathParameters['iid']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            parentNavigatorKey: rootKey,
                            builder: (_, state) => InvoiceFormScreen(
                              supplierId: state.pathParameters['id']!,
                              invoiceId: state.pathParameters['iid'],
                            ),
                          ),
                        ],
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
                path: Routes.more,
                builder: (_, _) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'reorder',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const ReorderScreen(),
                  ),
                  GoRoute(
                    path: 'backup',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const BackupScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'alert-lab',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const AlertLabScreen(),
                  ),
                  GoRoute(
                    path: 'alerts',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const AlertSettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'health',
                        parentNavigatorKey: rootKey,
                        builder: (_, _) => const AlertHealthScreen(),
                      ),
                      GoRoute(
                        path: 'history',
                        parentNavigatorKey: rootKey,
                        builder: (_, _) => const AlertHistoryScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = OnboardingRefresh();
  ref.listen(onboardingStateProvider, (_, _) => refresh.poke());
  final router = buildRouter(
    onboarding: () => ref.read(onboardingStateProvider),
    refreshListenable: refresh,
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
