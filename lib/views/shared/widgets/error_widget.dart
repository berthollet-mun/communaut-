import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:flutter/material.dart';

/// Widget pour afficher les états d'erreur de manière responsive
/// Renommé pour éviter le conflit avec le ErrorWidget natif de Flutter
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final String? details;
  final IconData? icon;
  final Color? iconColor;
  final String? retryLabel;
  final VoidCallback? onReport;
  final Widget? customAction;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.details,
    this.icon,
    this.iconColor,
    this.retryLabel,
    this.onReport,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Center(
      child: ResponsiveContainer(
        maxWidth: responsive.value<double>(
          mobile: double.infinity,
          tablet: 500,
          desktop: 600,
          largeDesktop: 700,
        ),
        padding: EdgeInsets.all(responsive.spacing(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône d'erreur
            _buildErrorIcon(context, responsive),

            SizedBox(height: responsive.spacing(16)),

            // Titre (si fourni)
            if (title != null) ...[
              _buildTitle(context, responsive),
              SizedBox(height: responsive.spacing(12)),
            ],

            // Message d'erreur
            _buildMessage(context, responsive),

            // Détails supplémentaires (si fournis)
            if (details != null && responsive.isDesktop) ...[
              SizedBox(height: responsive.spacing(12)),
              _buildDetails(context, responsive),
            ],

            // Actions
            if (onRetry != null ||
                onReport != null ||
                customAction != null) ...[
              SizedBox(height: responsive.spacing(24)),
              _buildActions(context, responsive),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon(BuildContext context, ResponsiveHelper responsive) {
    final iconSize = responsive.value<double>(
      mobile: 56,
      tablet: 64,
      desktop: 72,
      largeDesktop: 80,
    );

    final color = iconColor ?? Colors.red;

    // Animation pulsante sur desktop
    if (responsive.isDesktop) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Container(
            padding: EdgeInsets.all(responsive.spacing(16)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2 * value),
                  blurRadius: 20 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: iconSize,
              color: color,
            ),
          );
        },
      );
    }

    // Version simple pour mobile/tablette
    return Icon(icon ?? Icons.error_outline, size: iconSize, color: color);
  }

  Widget _buildTitle(BuildContext context, ResponsiveHelper responsive) {
    return Text(
      title!,
      style: TextStyle(
        fontSize: responsive.fontSize(20),
        fontWeight: FontWeight.bold,
        color: iconColor ?? Colors.red,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(BuildContext context, ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.value<double>(
          mobile: 0,
          tablet: 20,
          desktop: 40,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: responsive.fontSize(15),
          color: (iconColor ?? Colors.red).withOpacity(0.9),
          height: 1.5,
        ),
        textAlign: TextAlign.center,
        maxLines: responsive.value<int>(mobile: 3, tablet: 4, desktop: 5),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(8)),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        details!,
        style: TextStyle(
          fontSize: responsive.fontSize(12),
          color: Colors.grey[600],
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(BuildContext context, ResponsiveHelper responsive) {
    if (customAction != null) {
      return customAction!;
    }

    final hasMultipleActions = onRetry != null && onReport != null;

    if (responsive.isDesktop && hasMultipleActions) {
      // Sur desktop avec plusieurs actions, afficher côte à côte
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (onRetry != null) _buildRetryButton(context, responsive),
          if (onRetry != null && onReport != null)
            SizedBox(width: responsive.spacing(16)),
          if (onReport != null) _buildReportButton(context, responsive),
        ],
      );
    }

    // Sur mobile ou avec une seule action
    return Column(
      children: [
        if (onRetry != null) _buildRetryButton(context, responsive),
        if (onRetry != null && onReport != null)
          SizedBox(height: responsive.spacing(12)),
        if (onReport != null) _buildReportButton(context, responsive),
      ],
    );
  }

  Widget _buildRetryButton(BuildContext context, ResponsiveHelper responsive) {
    return SizedBox(
      width: responsive.isMobile ? double.infinity : null,
      height: responsive.value<double>(mobile: 48, tablet: 52, desktop: 56),
      child: ElevatedButton.icon(
        onPressed: onRetry,
        icon: Icon(Icons.refresh, size: responsive.iconSize(20)),
        label: Text(
          retryLabel ?? 'Réessayer',
          style: TextStyle(fontSize: responsive.fontSize(15)),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(24),
            vertical: responsive.spacing(12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.spacing(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildReportButton(BuildContext context, ResponsiveHelper responsive) {
    return SizedBox(
      width: responsive.isMobile ? double.infinity : null,
      height: responsive.value<double>(mobile: 48, tablet: 52, desktop: 56),
      child: OutlinedButton.icon(
        onPressed: onReport,
        icon: Icon(Icons.bug_report, size: responsive.iconSize(20)),
        label: Text(
          'Signaler',
          style: TextStyle(fontSize: responsive.fontSize(15)),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(24),
            vertical: responsive.spacing(12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.spacing(8)),
          ),
        ),
      ),
    );
  }
}

/// Widget pour les erreurs de connexion réseau
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({super.key, this.onRetry, this.customMessage});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return ErrorStateWidget(
      title: 'Erreur de connexion',
      message:
          customMessage ??
          'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      onRetry: onRetry,
      retryLabel: 'Réessayer la connexion',
      details: responsive.isDesktop ? 'ERR_NETWORK_CONNECTION' : null,
    );
  }
}

/// Widget pour les erreurs de permission
class PermissionErrorWidget extends StatelessWidget {
  final String? resource;
  final VoidCallback? onRequestPermission;

  const PermissionErrorWidget({
    super.key,
    this.resource,
    this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Accès refusé',
      message:
          'Vous n\'avez pas les permissions nécessaires pour accéder à ${resource ?? 'cette ressource'}.',
      icon: Icons.lock_outline,
      iconColor: Colors.amber,
      onRetry: onRequestPermission,
      retryLabel: 'Demander l\'accès',
    );
  }
}

/// Widget pour afficher des erreurs avec code
class TechnicalErrorWidget extends StatelessWidget {
  final String errorCode;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onReport;

  const TechnicalErrorWidget({
    super.key,
    required this.errorCode,
    this.errorMessage,
    this.onRetry,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return ErrorStateWidget(
      title: 'Erreur technique',
      message: errorMessage ?? 'Une erreur inattendue s\'est produite.',
      icon: Icons.warning_amber,
      iconColor: Colors.deepOrange,
      details: 'Code erreur: $errorCode',
      onRetry: onRetry,
      onReport:
          onReport ??
          () {
            // Logique pour signaler l'erreur
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erreur signalée. Merci!',
                  style: TextStyle(fontSize: responsive.fontSize(14)),
                ),
                backgroundColor: Colors.green,
              ),
            );
          },
    );
  }
}

/// Widget minimaliste pour les petites erreurs inline
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const InlineErrorWidget({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Container(
      padding: EdgeInsets.all(responsive.spacing(12)),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(8)),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: responsive.iconSize(20),
            color: Colors.red,
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: Colors.red[700],
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, size: responsive.iconSize(18)),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}
