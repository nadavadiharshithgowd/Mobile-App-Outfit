import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/outfit/data/models/outfit_model.dart';
import '../features/outfit/presentation/screens/daily_suggestion_screen.dart';
import '../features/outfit/presentation/screens/outfit_detail_screen.dart';
import '../features/outfit/presentation/screens/outfit_history_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/tryon/presentation/screens/tryon_result_screen.dart';
import '../features/tryon/presentation/screens/tryon_screen.dart';
import '../features/wardrobe/presentation/screens/closet_screen.dart';
import '../features/wardrobe/presentation/screens/item_detail_screen.dart';
import '../features/wardrobe/presentation/screens/upload_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorClosetKey = GlobalKey<NavigatorState>(debugLabel: 'closet');
final _shellNavigatorTryOnKey = GlobalKey<NavigatorState>(debugLabel: 'tryon');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshListenable(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/login/otp' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (context, state) {
              final email = state.extra as String?;
              return OTPScreen(email: email);
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home / Daily Suggestion
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) =>
                    const DailySuggestionScreen(),
                routes: [
                  GoRoute(
                    path: 'outfit/:id',
                    builder: (context, state) => OutfitDetailScreen(
                      outfitId: state.pathParameters['id']!,
                      outfit: state.extra as OutfitModel?,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Closet / Wardrobe
          StatefulShellBranch(
            navigatorKey: _shellNavigatorClosetKey,
            routes: [
              GoRoute(
                path: '/closet',
                builder: (context, state) => const ClosetScreen(),
                routes: [
                  GoRoute(
                    path: 'item/:id',
                    builder: (context, state) => ItemDetailScreen(
                      itemId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'upload',
                    builder: (context, state) => const UploadScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Try-On
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTryOnKey,
            routes: [
              GoRoute(
                path: '/tryon',
                builder: (context, state) => const TryOnScreen(),
                routes: [
                  GoRoute(
                    path: 'result/:id',
                    builder: (context, state) => TryOnResultScreen(
                      tryonId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Profile
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) =>
                        const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'history',
                    builder: (context, state) =>
                        const OutfitHistoryScreen(),
                    routes: [
                      GoRoute(
                        path: 'outfit/:id',
                        builder: (context, state) => OutfitDetailScreen(
                          outfitId: state.pathParameters['id']!,
                          outfit: state.extra as OutfitModel?,
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
    ],
  );
}

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined),
              activeIcon: Icon(Icons.wb_sunny),
              label: AppStrings.tabToday,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_outlined),
              activeIcon: Icon(Icons.checkroom),
              label: AppStrings.tabCloset,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: AppStrings.tabTryOn,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: AppStrings.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(AuthBloc authBloc) {
    authBloc.stream.listen((_) => notifyListeners());
  }
}
