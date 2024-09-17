import 'package:flutter/material.dart';

class SlideFromLeftPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideFromLeftPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); // Di chuyển từ trái
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 500), // 0.5 giây
        );
}

class SlideFromRightPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideFromRightPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Di chuyển từ phải
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 500), // 0.5 giây
        );
}

class ZoomPageRoute extends PageRouteBuilder {
  final Widget page;

  ZoomPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var scaleAnimation = animation.drive(tween);
            var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 700), // 0.5 giây
        );
}

class SlideAndZoomPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideAndZoomPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Di chuyển từ phải
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            // Tạo animation cho việc di chuyển và zoom
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            var scaleAnimation = Tween(begin: 0.9, end: 1.0)
                .animate(animation); // Zoom từ 90% đến 100%
            var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 1000), // 0.5 giây
        );
}
