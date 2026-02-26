import 'package:community/app/routes/app_routes.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // Attendre que le controller soit initialisé
    await authController.checkAuth();

    final isLoggedIn = await authController.checkAuth();
    final currentRoute = route.currentPage?.name ?? '';

    // Routes publiques qui ne nécessitent pas d'authentification
    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.welcome,
      AppRoutes.features,
      AppRoutes.pricingInfo,
      AppRoutes.login,
      AppRoutes.register,
    ];

    // Routes protégées qui nécessitent une communauté sélectionnée
    final communityRoutes = [
      AppRoutes.communityDashboard,
      AppRoutes.projectsList,
      AppRoutes.kanbanBoard,
      AppRoutes.taskDetail,
      AppRoutes.activityLog,
    ];

    debugPrint('AuthMiddleware: Route $currentRoute, LoggedIn: $isLoggedIn');

    // 1. Si l'utilisateur n'est pas connecté et essaie d'accéder à une route protégée
    if (!isLoggedIn && !publicRoutes.contains(currentRoute)) {
      debugPrint('Redirecting to login from $currentRoute');
      return GetNavConfig.fromRoute(AppRoutes.login);
    }

    // 2. Si l'utilisateur est connecté et essaie d'accéder à une route publique (sauf splash)
    if (isLoggedIn &&
        publicRoutes.contains(currentRoute) &&
        currentRoute != AppRoutes.splash) {
      debugPrint('Redirecting to community select from $currentRoute');
      return GetNavConfig.fromRoute(AppRoutes.communitySelect);
    }

    // 3. Si l'utilisateur est connecté mais n'a pas sélectionné de communauté
    // et essaie d'accéder à une route nécessitant une communauté
    if (isLoggedIn &&
        communityRoutes.contains(currentRoute) &&
        !currentRoute.contains('community')) {
      // Vérifier si une communauté est sélectionnée (à implémenter)
      debugPrint('Redirecting to community select for community route');
      return GetNavConfig.fromRoute(AppRoutes.communitySelect);
    }

    return await super.redirectDelegate(route);
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    // Ajouter un délai pour le chargement si nécessaire
    return page;
  }
}
