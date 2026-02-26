import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? iconColor;
  final Color? textColor;
  final Widget? customAction;
  final Widget? customIcon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionLabel,
    this.iconColor,
    this.textColor,
    this.customAction,
    this.customIcon,
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
        padding: EdgeInsets.all(
          responsive.value<double>(
            mobile: 24,
            tablet: 32,
            desktop: 40,
            largeDesktop: 48,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône ou widget personnalisé
            _buildIcon(context, responsive),

            SizedBox(height: responsive.spacing(20)),

            // Titre
            _buildTitle(context, responsive),

            SizedBox(height: responsive.spacing(10)),

            // Message
            _buildMessage(context, responsive),

            // Action button
            if ((onAction != null && actionLabel != null) ||
                customAction != null) ...[
              SizedBox(height: responsive.spacing(24)),
              _buildAction(context, responsive),
            ],

            // Espacement supplémentaire sur desktop
            if (responsive.isDesktop) SizedBox(height: responsive.spacing(40)),
          ],
        ),
      ),
    );
  }

  /// Construction de l'icône responsive
  Widget _buildIcon(BuildContext context, ResponsiveHelper responsive) {
    if (customIcon != null) {
      return customIcon!;
    }

    final iconSize = responsive.value<double>(
      mobile: 56,
      tablet: 64,
      desktop: 72,
      largeDesktop: 80,
    );

    // Container avec animation subtile sur desktop
    if (responsive.isDesktop) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Container(
                padding: EdgeInsets.all(responsive.spacing(20)),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.grey[400])!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? Colors.grey[400],
                ),
              ),
            ),
          );
        },
      );
    }

    // Version simple pour mobile/tablette
    return Icon(icon, size: iconSize, color: iconColor ?? Colors.grey[400]);
  }

  /// Construction du titre responsive
  Widget _buildTitle(BuildContext context, ResponsiveHelper responsive) {
    return Text(
      title,
      style: TextStyle(
        fontSize: responsive.value<double>(
          mobile: 18,
          tablet: 20,
          desktop: 22,
          largeDesktop: 24,
        ),
        fontWeight: responsive.value<FontWeight>(
          mobile: FontWeight.w600,
          tablet: FontWeight.w600,
          desktop: FontWeight.w700,
        ),
        color: textColor ?? Colors.grey[700],
        letterSpacing: responsive.value<double>(
          mobile: 0,
          tablet: 0.2,
          desktop: 0.3,
        ),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construction du message responsive
  Widget _buildMessage(BuildContext context, ResponsiveHelper responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.value<double>(
          mobile: 0,
          tablet: 20,
          desktop: 40,
          largeDesktop: 60,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: responsive.value<double>(
            mobile: 14,
            tablet: 15,
            desktop: 16,
            largeDesktop: 17,
          ),
          color: textColor?.withOpacity(0.7) ?? Colors.grey[600],
          height: 1.5,
        ),
        textAlign: TextAlign.center,
        maxLines: responsive.value<int>(mobile: 3, tablet: 4, desktop: 5),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Construction du bouton d'action responsive
  Widget _buildAction(BuildContext context, ResponsiveHelper responsive) {
    if (customAction != null) {
      return customAction!;
    }

    final buttonWidth = responsive.value<double>(
      mobile: double.infinity,
      tablet: 200,
      desktop: 220,
      largeDesktop: 240,
    );

    final buttonHeight = responsive.value<double>(
      mobile: 48,
      tablet: 52,
      desktop: 56,
      largeDesktop: 60,
    );

    return SizedBox(
      width: responsive.isMobile ? double.infinity : buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onAction,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(24),
            vertical: responsive.spacing(12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsive.value<double>(mobile: 8, tablet: 10, desktop: 12),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              actionLabel!,
              style: TextStyle(
                fontSize: responsive.fontSize(15),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (responsive.isDesktop) ...[
              SizedBox(width: responsive.spacing(8)),
              Icon(Icons.arrow_forward, size: responsive.iconSize(18)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget Empty State avec illustration
class IllustratedEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? imagePath;
  final Widget? illustration;
  final VoidCallback? onAction;
  final String? actionLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;

  const IllustratedEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.imagePath,
    this.illustration,
    this.onAction,
    this.actionLabel,
    this.onSecondaryAction,
    this.secondaryActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Center(
      child: ResponsiveContainer(
        maxWidth: responsive.value<double>(
          mobile: double.infinity,
          tablet: 600,
          desktop: 700,
          largeDesktop: 800,
        ),
        padding: EdgeInsets.all(responsive.contentPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            if (illustration != null)
              illustration!
            else if (imagePath != null)
              _buildImage(responsive),

            SizedBox(height: responsive.spacing(32)),

            // Titre
            Text(
              title,
              style: TextStyle(
                fontSize: responsive.fontSize(22),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: responsive.spacing(12)),

            // Message
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.value<double>(
                  mobile: 0,
                  tablet: 30,
                  desktop: 50,
                ),
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: responsive.fontSize(15),
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Actions
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: responsive.spacing(32)),
              _buildActions(context, responsive),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ResponsiveHelper responsive) {
    final imageSize = responsive.value<double>(
      mobile: 200,
      tablet: 250,
      desktop: 300,
      largeDesktop: 350,
    );

    return Container(
      width: imageSize,
      height: imageSize * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
      ),
      child: Image.asset(
        imagePath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: responsive.iconSize(64),
            color: Colors.grey[400],
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context, ResponsiveHelper responsive) {
    if (responsive.isDesktop && onSecondaryAction != null) {
      // Sur desktop, afficher les boutons côte à côte
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPrimaryButton(context, responsive),
          SizedBox(width: responsive.spacing(16)),
          _buildSecondaryButton(context, responsive),
        ],
      );
    }

    // Sur mobile/tablette, afficher en colonne
    return Column(
      children: [
        _buildPrimaryButton(context, responsive),
        if (onSecondaryAction != null && secondaryActionLabel != null) ...[
          SizedBox(height: responsive.spacing(12)),
          _buildSecondaryButton(context, responsive),
        ],
      ],
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return SizedBox(
      width: responsive.isMobile ? double.infinity : null,
      height: responsive.value<double>(mobile: 48, tablet: 52, desktop: 56),
      child: ElevatedButton(
        onPressed: onAction,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(32),
            vertical: responsive.spacing(12),
          ),
        ),
        child: Text(
          actionLabel!,
          style: TextStyle(fontSize: responsive.fontSize(15)),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return SizedBox(
      width: responsive.isMobile ? double.infinity : null,
      height: responsive.value<double>(mobile: 48, tablet: 52, desktop: 56),
      child: OutlinedButton(
        onPressed: onSecondaryAction,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(32),
            vertical: responsive.spacing(12),
          ),
        ),
        child: Text(
          secondaryActionLabel!,
          style: TextStyle(fontSize: responsive.fontSize(15)),
        ),
      ),
    );
  }
}
