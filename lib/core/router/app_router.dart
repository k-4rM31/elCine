import 'package:go_router/go_router.dart';
import 'app_shell.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/shorts/presentation/screens/shorts_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/cine_ia/presentation/screens/cine_ia_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// Chemins nommés, centralisés pour éviter les fautes de frappe ailleurs
class AppRoutes {
  static const home = '/home';
  static const shorts = '/shorts';
  static const search = '/search';
  static const cineIa = '/cine-ia';
  static const profile = '/profile';
}

final List<String> _tabPaths = [
  AppRoutes.home,
  AppRoutes.shorts,
  AppRoutes.search,
  AppRoutes.cineIa,
  AppRoutes.profile,
];

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final index = _tabPaths.indexWhere(
          (path) => state.uri.toString().startsWith(path),
        );
        return AppShell(
          currentIndex: index < 0 ? 0 : index,
          onTap: (i) => context.go(_tabPaths[i]),
          child: child,
        );
      },
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
        GoRoute(path: AppRoutes.shorts, builder: (_, __) => const ShortsScreen()),
        GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchScreen()),
        GoRoute(path: AppRoutes.cineIa, builder: (_, __) => const CineIaScreen()),
        GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);