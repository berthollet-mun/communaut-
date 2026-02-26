import 'package:flutter/material.dart';

/// Classe utilitaire pour gérer le responsive design
class ResponsiveHelper {
  // Breakpoints standards
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final Orientation orientation;
  late final DeviceType deviceType;

  ResponsiveHelper(this.context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    orientation = mediaQuery.orientation;
    deviceType = _getDeviceType();
  }

  /// Détermine le type d'appareil basé sur la largeur d'écran
  DeviceType _getDeviceType() {
    if (screenWidth < mobileBreakpoint) {
      return DeviceType.mobileSmall;
    } else if (screenWidth < tabletBreakpoint) {
      return DeviceType.mobile;
    } else if (screenWidth < desktopBreakpoint) {
      return DeviceType.tablet;
    } else if (screenWidth < largeDesktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  // === Getters pour les types d'appareils ===
  bool get isMobileSmall => deviceType == DeviceType.mobileSmall;
  bool get isMobile => deviceType == DeviceType.mobile || isMobileSmall;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop || isLargeDesktop;
  bool get isLargeDesktop => deviceType == DeviceType.largeDesktop;

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // === Méthodes pour les tailles adaptatives ===

  /// Retourne une valeur selon le type d'appareil
  T value<T>({required T mobile, T? tablet, T? desktop, T? largeDesktop}) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Largeur proportionnelle (pourcentage de l'écran)
  double wp(double percentage) => screenWidth * (percentage / 100);

  /// Hauteur proportionnelle (pourcentage de l'écran)
  double hp(double percentage) => screenHeight * (percentage / 100);

  /// Taille de police responsive
  double fontSize(double baseSize) {
    double scaleFactor = value<double>(
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.15,
      largeDesktop: 1.2,
    );
    return baseSize * scaleFactor;
  }

  /// Padding/Margin responsive
  double spacing(double baseSpacing) {
    double scaleFactor = value<double>(
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.4,
      largeDesktop: 1.6,
    );
    return baseSpacing * scaleFactor;
  }

  /// Taille d'icône responsive
  double iconSize(double baseSize) {
    return value<double>(
      mobile: baseSize,
      tablet: baseSize * 1.2,
      desktop: baseSize * 1.3,
      largeDesktop: baseSize * 1.4,
    );
  }

  /// Largeur maximale du contenu (pour centrer sur grands écrans)
  double get contentMaxWidth {
    return value<double>(
      mobile: screenWidth,
      tablet: 600,
      desktop: 500,
      largeDesktop: 550,
    );
  }

  /// Padding horizontal du contenu
  double get contentPadding {
    return value<double>(mobile: 16, tablet: 24, desktop: 32, largeDesktop: 40);
  }

  /// Nombre de colonnes pour les grilles
  int get gridColumns {
    return value<int>(mobile: 1, tablet: 2, desktop: 3, largeDesktop: 4);
  }

  /// Ratio d'aspect pour les cards
  double get cardAspectRatio {
    return value<double>(
      mobile: 1.2,
      tablet: 1.3,
      desktop: 1.4,
      largeDesktop: 1.5,
    );
  }
}

/// Types d'appareils supportés
enum DeviceType {
  mobileSmall, // < 480px
  mobile, // 480px - 768px
  tablet, // 768px - 1024px
  desktop, // 1024px - 1440px
  largeDesktop, // > 1440px
}
