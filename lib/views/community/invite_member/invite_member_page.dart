import 'package:community/app/themes/app_theme.dart';
import 'package:community/controllers/community_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/widgets/responsive_builder.dart';
import 'package:community/data/models/community_model.dart';
import 'package:community/views/shared/widgets/button.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({super.key});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final CommunityController _communityController = Get.find();

  late CommunityModel _community;
  bool _isLoading = false;
  String _inviteCode = '';

  @override
  void initState() {
    super.initState();
    _community = _communityController.currentCommunity.value!;
    _inviteCode = _community.invite_code.toString();
  }

  Future<void> _generateNewCode() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final invite = await _communityController.generateInviteCode(
        _community.community_id,
      );

      if (invite != null) {
        setState(() {
          _inviteCode = invite.inviteCode;
        });

        Get.snackbar(
          'Nouveau code généré',
          invite.message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de générer un nouveau code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

void _copyToClipboard() async {
  // ✅ Copier le code dans le presse-papiers
  await Clipboard.setData(ClipboardData(text: _inviteCode));

  // ✅ Message de confirmation
  Get.snackbar(
    'Copié !',
    'Le code d\'invitation "$_inviteCode" a été copié dans le presse-papier',
    backgroundColor: Colors.green,
    colorText: Colors.white,
  );
}

  void _shareInvite() {
    Get.snackbar(
      'Partager',
      'La fonction de partage sera disponible bientôt',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialiser le ResponsiveHelper
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inviter - ${_community.nom}',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: responsive.value<double>(
            mobile: double.infinity,
            tablet: 700,
            desktop: 800,
            largeDesktop: 900,
          ),
          padding: EdgeInsets.all(responsive.contentPadding),
          child: Column(
            children: [
              // En-tête responsive
              _buildHeader(responsive),

              SizedBox(height: responsive.spacing(40)),

              // Code d'invitation responsive
              _buildInviteCodeCard(responsive),

              SizedBox(height: responsive.spacing(32)),

              // Instructions responsive
              _buildInstructionsCard(responsive),

              SizedBox(height: responsive.spacing(32)),

              // Boutons d'action responsive
              _buildActionButtons(responsive),

              SizedBox(height: responsive.spacing(24)),

              // Note de sécurité responsive
              _buildSecurityNote(responsive),

              SizedBox(height: responsive.spacing(24)),
            ],
          ),
        ),
      ),
    );
  }

  /// En-tête avec icône et texte responsive
  Widget _buildHeader(ResponsiveHelper responsive) {
    return Column(
      children: [
        Icon(
          Icons.person_add_alt_1,
          size: responsive.iconSize(80),
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: responsive.spacing(16)),
        Text(
          'Inviter des membres',
          style: AppTheme.headline2.copyWith(fontSize: responsive.fontSize(24)),
        ),
        SizedBox(height: responsive.spacing(8)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.value<double>(
              mobile: 0,
              tablet: 20,
              desktop: 40,
            ),
          ),
          child: Text(
            'Partagez ce code avec les personnes que vous souhaitez inviter dans votre communauté.',
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(14),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Carte du code d'invitation responsive
  Widget _buildInviteCodeCard(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(24)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsive.spacing(20)),
        boxShadow: [AppTheme.cardShadow],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: responsive.value<double>(mobile: 1.5, tablet: 2, desktop: 2.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Code d\'invitation',
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SelectableText(
              _inviteCode,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: responsive.value<double>(
                  mobile: 28,
                  tablet: 32,
                  desktop: 36,
                  largeDesktop: 40,
                ),
                fontWeight: FontWeight.bold,
                letterSpacing: responsive.value<double>(
                  mobile: 3,
                  tablet: 4,
                  desktop: 5,
                ),
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            'Ce code est unique à votre communauté',
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(12),
            ),
          ),
        ],
      ),
    );
  }

  /// Carte d'instructions responsive
  Widget _buildInstructionsCard(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment inviter des membres ?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: responsive.fontSize(15),
            ),
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildInstructionItem(
            '1. Partagez ce code avec les personnes à inviter',
            responsive,
          ),
          SizedBox(height: responsive.spacing(8)),
          _buildInstructionItem(
            '2. Les membres doivent saisir ce code dans "Rejoindre une communauté"',
            responsive,
          ),
          SizedBox(height: responsive.spacing(8)),
          _buildInstructionItem(
            '3. Ils auront accès à tous les projets de cette communauté',
            responsive,
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            'Note :',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: responsive.fontSize(14),
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          _buildInstructionItem(
            '• Seuls les ADMIN peuvent générer de nouveaux codes',
            responsive,
          ),
          SizedBox(height: responsive.spacing(4)),
          _buildInstructionItem(
            '• Un code est valable jusqu\'à ce qu\'un nouveau soit généré',
            responsive,
          ),
          SizedBox(height: responsive.spacing(4)),
          _buildInstructionItem(
            '• Vous pouvez générer un nouveau code à tout moment',
            responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text, ResponsiveHelper responsive) {
    return Text(text, style: TextStyle(fontSize: responsive.fontSize(13)));
  }

  /// Boutons d'action responsive
  Widget _buildActionButtons(ResponsiveHelper responsive) {
    // Sur desktop/tablette large, afficher les boutons côte à côte
    if (responsive.isDesktop ||
        (responsive.isTablet && responsive.screenWidth > 600)) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: responsive.value<double>(
                    mobile: 48,
                    tablet: 52,
                    desktop: 56,
                  ),
                  child: PrimaryButton(
                    text: 'Copier le code',
                    onPressed: _copyToClipboard,
                    fullWidth: true,
                    icon: Icons.content_copy,
                  ),
                ),
              ),
              SizedBox(width: responsive.spacing(16)),
              Expanded(
                child: SizedBox(
                  height: responsive.value<double>(
                    mobile: 48,
                    tablet: 52,
                    desktop: 56,
                  ),
                  child: SecondaryButton(
                    text: 'Partager',
                    onPressed: _shareInvite,
                    fullWidth: true,
                    icon: Icons.share,
                  ),
                ),
              ),
            ],
          ),
          if (_community.role == 'ADMIN') ...[
            SizedBox(height: responsive.spacing(16)),
            _buildGenerateButton(responsive),
          ],
        ],
      );
    }

    // Sur mobile, afficher les boutons en colonne
    return Column(
      children: [
        SizedBox(
          height: responsive.value<double>(mobile: 48, tablet: 52),
          child: PrimaryButton(
            text: 'Copier le code',
            onPressed: _copyToClipboard,
            fullWidth: true,
            icon: Icons.content_copy,
          ),
        ),
        SizedBox(height: responsive.spacing(16)),
        SizedBox(
          height: responsive.value<double>(mobile: 48, tablet: 52),
          child: SecondaryButton(
            text: 'Partager',
            onPressed: _shareInvite,
            fullWidth: true,
            icon: Icons.share,
          ),
        ),
        if (_community.role == 'ADMIN') ...[
          SizedBox(height: responsive.spacing(16)),
          _buildGenerateButton(responsive),
        ],
      ],
    );
  }

  Widget _buildGenerateButton(ResponsiveHelper responsive) {
    return SizedBox(
      height: responsive.value<double>(mobile: 48, tablet: 52, desktop: 56),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _generateNewCode,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: EdgeInsets.symmetric(vertical: responsive.spacing(12)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.spacing(8)),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: responsive.iconSize(20),
                height: responsive.iconSize(20),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                'Générer un nouveau code',
                style: TextStyle(fontSize: responsive.fontSize(14)),
              ),
      ),
    );
  }

  /// Note de sécurité responsive
  Widget _buildSecurityNote(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_outlined,
                size: responsive.iconSize(16),
                color: Colors.orange,
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Sécurité',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.fontSize(14),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(8)),
          Text(
            'Ne partagez ce code qu\'avec des personnes de confiance. Toute personne ayant ce code peut rejoindre votre communauté.',
            style: TextStyle(fontSize: responsive.fontSize(13)),
          ),
        ],
      ),
    );
  }
}
