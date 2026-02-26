import 'package:flutter/material.dart';
import '../responsive_helper.dart';

/// Widget qui construit différentes UI selon le type d'écran
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveHelper responsive)
  mobile;
  final Widget Function(BuildContext context, ResponsiveHelper responsive)?
  tablet;
  final Widget Function(BuildContext context, ResponsiveHelper responsive)?
  desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    if (responsive.isDesktop && desktop != null) {
      return desktop!(context, responsive);
    }

    if (responsive.isTablet && tablet != null) {
      return tablet!(context, responsive);
    }

    return mobile(context, responsive);
  }
}

/// Widget conteneur responsive avec largeur maximale centrée
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Container(
      color: backgroundColor,
      width: double.infinity,
      child: Center(
        child: Container(
          width: maxWidth ?? responsive.contentMaxWidth,
          padding:
              padding ??
              EdgeInsets.symmetric(horizontal: responsive.contentPadding),
          child: child,
        ),
      ),
    );
  }
}

/// Widget pour afficher/cacher selon le type d'écran
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    bool isVisible = false;

    if (responsive.isMobile && visibleOnMobile) {
      isVisible = true;
    } else if (responsive.isTablet && visibleOnTablet) {
      isVisible = true;
    } else if (responsive.isDesktop && visibleOnDesktop) {
      isVisible = true;
    }

    return isVisible ? child : const SizedBox.shrink();
  }
}
