import 'package:flutter/material.dart';
import 'dart:async';

class SlideFromLeftPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideFromLeftPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return page; // Return the page directly
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); // Move from left
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

  @override
  TickerFuture didPush() {
    // Delay the loading of data here
    Future.delayed(Duration(milliseconds: 500), () {
      // Here, you can load your data or perform any actions needed after the delay
    });
    return super.didPush();
  }
}

class SlideFromRightPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideFromRightPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return page; // Return the page directly
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Move from right
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
          transitionDuration: Duration(milliseconds: 400),
          reverseTransitionDuration: Duration(milliseconds: 300),
        );

  @override
  TickerFuture didPush() {
    // Delay the loading of data here
    Future.delayed(Duration(milliseconds: 1200), () {
      // Here, you can load your data or perform any actions needed after the delay
    });
    return super.didPush();
  }
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
          transitionDuration: Duration(milliseconds: 700), // 0.7 giây
        );
}

class SlideAndZoomPageRoute extends PageRouteBuilder {
  final Widget page;

  SlideAndZoomPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Move from right
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            var scaleAnimation = Tween(begin: 0.9, end: 1.0)
                .animate(animation); // Zoom from 90% to 100%
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
          transitionDuration: Duration(milliseconds: 1000), // 1 giây
        );
}
