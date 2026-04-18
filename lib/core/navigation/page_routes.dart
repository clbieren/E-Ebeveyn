import 'package:flutter/cupertino.dart';

/// Uygulama genelinde tutarlı ve hafif sayfa geçişleri.
///
/// BottomNavigationBar akışına dokunmadan, sadece `Navigator.push` çağrılarında
/// kullanılmak üzere tasarlanmıştır.
final class AppPageRoutes {
  const AppPageRoutes._();

  static Route<T> fade<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 260),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  static Route<T> cupertino<T>(Widget page) =>
      CupertinoPageRoute<T>(builder: (_) => page);
}
