import 'package:community/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Size get preferredSize {
    // Hauteur dynamique selon le contexte
    // Note: On ne peut pas utiliser ResponsiveHelper ici car on n'a pas le context
    // On utilise une hauteur standard qui sera ajustée dans build()
    double height = kToolbarHeight;

    // Si bottom est défini, ajouter sa hauteur
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }

    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    // Hauteur d'AppBar responsive
    final appBarHeight = responsive.value<double>(
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 4,
      desktop: kToolbarHeight + 8,
      largeDesktop: kToolbarHeight + 12,
    );

    return PreferredSize(
      preferredSize: Size.fromHeight(
        appBarHeight + (bottom?.preferredSize.height ?? 0),
      ),
      child: AppBar(
        toolbarHeight: appBarHeight,
        title: _buildTitle(responsive),
        leading: _buildLeading(context, responsive),
        actions: _buildActions(responsive),
        centerTitle: _getCenterTitle(responsive),
        elevation:
            elevation ??
            responsive.value<double>(mobile: 1, tablet: 1.5, desktop: 2),
        backgroundColor: backgroundColor,
        flexibleSpace: flexibleSpace,
        bottom: bottom,
        // Ajustement de l'espacement des titres selon l'écran
        titleSpacing: responsive.value<double>(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      ),
    );
  }

  /// Construction du titre responsive
  Widget _buildTitle(ResponsiveHelper responsive) {
    // Sur mobile, tronquer le titre s'il est trop long
    final maxLines = responsive.value<int>(mobile: 1, tablet: 2, desktop: 2);

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
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construction du bouton de retour responsive
  Widget? _buildLeading(BuildContext context, ResponsiveHelper responsive) {
    if (!showBackButton && leading == null) return null;

    if (leading != null) {
      // Si un widget leading personnalisé est fourni
      return _wrapWithResponsive(leading!, responsive);
    }

    if (showBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back, size: responsive.iconSize(24)),
        onPressed: () => Get.back(),
        padding: EdgeInsets.all(responsive.spacing(8)),
        // Ajout d'un tooltip pour l'accessibilité
        tooltip: 'Retour',
      );
    }

    return null;
  }

  /// Construction des actions responsive
  List<Widget>? _buildActions(ResponsiveHelper responsive) {
    if (actions == null || actions!.isEmpty) return null;

    // Limiter le nombre d'actions sur mobile
    final maxActions = responsive.value<int>(
      mobile: 2,
      tablet: 3,
      desktop: 4,
      largeDesktop: 5,
    );

    List<Widget> responsiveActions = [];

    if (actions!.length <= maxActions) {
      // Si on a moins d'actions que le maximum, les afficher toutes
      responsiveActions = actions!.map((action) {
        return _wrapWithResponsive(action, responsive);
      }).toList();
    } else {
      // Si on a trop d'actions, mettre les extras dans un menu
      responsiveActions = actions!.take(maxActions - 1).map((action) {
        return _wrapWithResponsive(action, responsive);
      }).toList();

      // Ajouter un menu "Plus" pour les actions restantes
      responsiveActions.add(
        PopupMenuButton<int>(
          icon: Icon(Icons.more_vert, size: responsive.iconSize(24)),
          tooltip: 'Plus d\'options',
          itemBuilder: (context) {
            return actions!.skip(maxActions - 1).map((action) {
              final index = actions!.indexOf(action);
              return PopupMenuItem<int>(
                value: index,
                child: _extractActionContent(action),
              );
            }).toList();
          },
          onSelected: (index) {
            // Déclencher l'action correspondante si c'est un IconButton
            final action = actions![index];
            if (action is IconButton && action.onPressed != null) {
              action.onPressed!();
            }
          },
        ),
      );
    }

    return responsiveActions;
  }

  /// Wrap un widget avec des ajustements responsive
  Widget _wrapWithResponsive(Widget widget, ResponsiveHelper responsive) {
    // Si c'est un IconButton, ajuster la taille de l'icône
    if (widget is IconButton) {
      return IconButton(
        icon: _adjustIconSize(widget.icon, responsive),
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        padding: EdgeInsets.all(responsive.spacing(8)),
        splashRadius: responsive.value<double>(
          mobile: 20,
          tablet: 24,
          desktop: 28,
        ),
      );
    }

    // Si c'est un TextButton
    if (widget is TextButton) {
      final style = widget.style ?? TextButton.styleFrom();
      return TextButton(
        onPressed: widget.onPressed,
        style: style.copyWith(
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: responsive.spacing(12),
              vertical: responsive.spacing(8),
            ),
          ),
        ),
        child: _adjustTextSize(widget.child!, responsive),
      );
    }

    // Pour les autres widgets, retourner tel quel
    return widget;
  }

  /// Ajuster la taille des icônes
  Widget _adjustIconSize(Widget icon, ResponsiveHelper responsive) {
    if (icon is Icon) {
      return Icon(
        icon.icon,
        size: icon.size ?? responsive.iconSize(24),
        color: icon.color,
        semanticLabel: icon.semanticLabel,
      );
    }
    return icon;
  }

  /// Ajuster la taille du texte
  Widget _adjustTextSize(Widget text, ResponsiveHelper responsive) {
    if (text is Text) {
      final currentStyle = text.style ?? const TextStyle();
      return Text(
        text.data ?? '',
        style: currentStyle.copyWith(
          fontSize: currentStyle.fontSize ?? responsive.fontSize(14),
        ),
        maxLines: text.maxLines,
        overflow: text.overflow,
      );
    }
    return text;
  }

  /// Extraire le contenu d'une action pour le menu popup
  Widget _extractActionContent(Widget action) {
    if (action is IconButton) {
      return Row(
        children: [
          action.icon,
          if (action.tooltip != null) ...[
            const SizedBox(width: 12),
            Text(action.tooltip!),
          ],
        ],
      );
    }

    if (action is TextButton && action.child != null) {
      return action.child!;
    }

    return const Text('Action');
  }

  /// Déterminer si le titre doit être centré selon l'écran
  bool _getCenterTitle(ResponsiveHelper responsive) {
    // Sur mobile, centrer le titre si spécifié ou par défaut
    // Sur desktop, ne pas centrer sauf si explicitement demandé
    if (centerTitle) return true;

    return responsive.value<bool>(
      mobile: false,
      tablet: false,
      desktop: false,
      largeDesktop: false,
    );
  }
}

/// Extension pour créer facilement un CustomAppBar responsive
extension ResponsiveAppBar on CustomAppBar {
  /// Créer un AppBar avec des actions responsive automatiques
  static CustomAppBar responsive({
    required String title,
    List<Widget>? actions,
    bool showBackButton = true,
    Widget? leading,
    bool centerTitle = false,
    double? elevation,
    Color? backgroundColor,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      leading: leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
    );
  }
}

/// Widget helper pour créer rapidement une action d'AppBar
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;
  final Color? color;
  final bool showBadge;
  final String? badgeText;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.showBadge = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    Widget iconButton = IconButton(
      icon: Icon(icon, size: responsive.iconSize(24), color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.all(responsive.spacing(8)),
    );

    if (showBadge) {
      return Stack(
        children: [
          iconButton,
          if (badgeText != null && badgeText!.isNotEmpty)
            Positioned(
              right: responsive.spacing(6),
              top: responsive.spacing(6),
              child: Container(
                padding: EdgeInsets.all(responsive.spacing(2)),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(responsive.spacing(10)),
                ),
                constraints: BoxConstraints(
                  minWidth: responsive.value<double>(
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  minHeight: responsive.value<double>(
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.fontSize(10),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }

    return iconButton;
  }
}
