import 'package:flutter/material.dart';

/// Custom page transitions for smooth navigation
class PageTransitions {
  /// Slide transition from right to left
  static Route<T> slideFromRight<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Slide transition from bottom to top
  static Route<T> slideFromBottom<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Fade transition
  static Route<T> fade<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Scale transition
  static Route<T> scale<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return ScaleTransition(scale: animation.drive(tween), child: child);
      },
    );
  }

  /// Hero transition with custom curve
  static Route<T> hero<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: curve)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Extension for easy navigation with custom transitions
extension CustomNavigator on NavigatorState {
  /// Navigate with slide from right transition
  Future<T?> pushSlideFromRight<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.slideFromRight<T>(page: page));
  }

  /// Navigate with slide from bottom transition
  Future<T?> pushSlideFromBottom<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.slideFromBottom<T>(page: page));
  }

  /// Navigate with fade transition
  Future<T?> pushFade<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.fade<T>(page: page));
  }

  /// Navigate with scale transition
  Future<T?> pushScale<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.scale<T>(page: page));
  }

  /// Navigate with hero transition
  Future<T?> pushHero<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.hero<T>(page: page));
  }
}
