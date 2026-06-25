import 'package:go_router/go_router.dart';
import 'package:quizlett/core/routes/route_name.dart';

class RouteConfig {
  GoRouter goRouter = GoRouter(
    initialLocation: RouteName.splash,

    routes: [
      //     GoRoute(
      //       path: RouteName.messageScreen,
      //       builder: (context, state) => const MessageScreen(),
      //     ),

      //     GoRoute(
      //       name: RouteName.splash,
      //       path: RouteName.splash,
      //       pageBuilder: (context, state) {
      //         return const MaterialPage(child: SplashScreen());
      //       },
      //     ),
      // GoRoute(
      //       name: RouteName.parentScreen,
      //       path: RouteName.parentScreen,
      //       pageBuilder: (context, state) {
      //         return buildPageWithTransition(
      //           transitionType: PageTransitionType.fade,
      //           context: context,
      //           state: state,
      //           child: ParentScreen(),
      //         );
      //       },
      //     ),

      //     GoRoute(
      //       name: RouteName.userProfile,
      //       path: RouteName.userProfile,
      //       pageBuilder: (context, state) {
      //         return const MaterialPage(child: UserProfile());
      //       },
      //     ),
      //     GoRoute(
      //       name: RouteName.onboarding,
      //       path: RouteName.onboarding,
      //       pageBuilder: (context, state) {
      //         return buildPageWithTransition(
      //           transitionType: PageTransitionType.fade,
      //           context: context,
      //           state: state,
      //           child: OnboardingScreen(),
      //         );
      //       },
      //     ),
      // GoRoute(
      //       name: RouteName.paymentMethodScreen,
      //       path: RouteName.paymentMethodScreen,
      //       pageBuilder: (context, state) {
      //         return buildPageWithTransition(
      //           transitionType: PageTransitionType.slideRightToLeft,
      //           context: context,
      //           state: state,
      //           child: PaymentMethodScreen());}
      //         ),
    ],
  );
}
