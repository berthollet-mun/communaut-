import 'package:community/controllers/auth_controller.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController _authController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: _buildAppBar(responsive),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: responsive.contentMaxWidth,
              padding: EdgeInsets.all(responsive.contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: responsive.spacing(20)),
                  _buildHeader(responsive),
                  SizedBox(height: responsive.spacing(32)),
                  _buildForm(responsive),
                  _buildErrorDisplay(responsive),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ResponsiveHelper responsive) {
    return AppBar(
      title: Text(
        'Créer un compte',
        style: TextStyle(fontSize: responsive.fontSize(18)),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: responsive.iconSize(24)),
        onPressed: () => Get.back(),
      ),
      toolbarHeight: responsive.value<double>(
        mobile: 56,
        tablet: 60,
        desktop: 64,
      ),
    );
  }

  Widget _buildHeader(ResponsiveHelper responsive) {
    return Column(
      children: [
        Icon(
          Icons.person_add_alt_1,
          size: responsive.iconSize(60),
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: responsive.spacing(16)),
        Text(
          'Rejoignez MarPro+',
          style: AppTheme.headline2.copyWith(fontSize: responsive.fontSize(24)),
        ),
        SizedBox(height: responsive.spacing(8)),
        Text(
          'Créez votre compte pour gérer vos projets collaboratifs',
          style: AppTheme.bodyText2.copyWith(
            fontSize: responsive.fontSize(14),
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(ResponsiveHelper responsive) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameFields(responsive),
          SizedBox(height: responsive.spacing(16)),
          _buildEmailField(responsive),
          SizedBox(height: responsive.spacing(16)),
          _buildPasswordField(responsive),
          SizedBox(height: responsive.spacing(16)),
          _buildConfirmPasswordField(responsive),
          SizedBox(height: responsive.spacing(24)),
          _buildTermsSection(responsive),
          SizedBox(height: responsive.spacing(24)),
          _buildRegisterButton(responsive),
          SizedBox(height: responsive.spacing(24)),
          _buildLoginLink(responsive),
        ],
      ),
    );
  }

  Widget _buildNameFields(ResponsiveHelper responsive) {
    if (responsive.isTablet || responsive.isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTextField(
              controller: _prenomController,
              label: 'Prénom *',
              hint: 'Jean',
              icon: Icons.person_outline,
              responsive: responsive,
              validator: (value) =>
                  Validators.validateRequired(value, 'Le prénom'),
            ),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: _buildTextField(
              controller: _nomController,
              label: 'Nom *',
              hint: 'Dupont',
              icon: Icons.person_outline,
              responsive: responsive,
              validator: (value) => Validators.validateRequired(value, 'Le nom'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTextField(
          controller: _prenomController,
          label: 'Prénom *',
          hint: 'Jean',
          icon: Icons.person_outline,
          responsive: responsive,
          validator: (value) => Validators.validateRequired(value, 'Le prénom'),
        ),
        SizedBox(height: responsive.spacing(16)),
        _buildTextField(
          controller: _nomController,
          label: 'Nom *',
          hint: 'Dupont',
          icon: Icons.person_outline,
          responsive: responsive,
          validator: (value) => Validators.validateRequired(value, 'Le nom'),
        ),
      ],
    );
  }

  Widget _buildEmailField(ResponsiveHelper responsive) {
    return _buildTextField(
      controller: _emailController,
      label: 'Email *',
      hint: 'votre@email.com',
      icon: Icons.email_outlined,
      responsive: responsive,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
    );
  }

  Widget _buildPasswordField(ResponsiveHelper responsive) {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Mot de passe *',
        prefixIcon: Icon(Icons.lock_outline, size: responsive.iconSize(20)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: responsive.iconSize(20),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
        hintText: '••••••••',
        helperText: 'Minimum 6 caractères',
        helperStyle: TextStyle(fontSize: responsive.fontSize(12)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(16),
        ),
      ),
      style: TextStyle(fontSize: responsive.fontSize(14)),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      validator: Validators.validatePassword,
      onChanged: (_) {
        if (_confirmPasswordController.text.isNotEmpty) {
          _formKey.currentState?.validate();
        }
      },
    );
  }

  Widget _buildConfirmPasswordField(ResponsiveHelper responsive) {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Confirmer le mot de passe *',
        prefixIcon: Icon(Icons.lock_outline, size: responsive.iconSize(20)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: responsive.iconSize(20),
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
        hintText: '••••••••',
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(16),
        ),
      ),
      style: TextStyle(fontSize: responsive.fontSize(14)),
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      validator: (value) =>
          Validators.validateConfirmPassword(value, _passwordController.text),
      onFieldSubmitted: (_) => _register(),
    );
  }

  Widget _buildTermsSection(ResponsiveHelper responsive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: responsive.value<double>(mobile: 24, tablet: 28, desktop: 32),
          height: responsive.value<double>(mobile: 24, tablet: 28, desktop: 32),
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
          ),
        ),
        SizedBox(width: responsive.spacing(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'J\'accepte les conditions d\'utilisation',
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: responsive.spacing(4)),
              _buildTermsLinks(responsive),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsLinks(ResponsiveHelper responsive) {
    if (responsive.screenWidth < 350) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTermsButton(
            'Conditions d\'utilisation',
            responsive,
            _showTermsDialog,
          ),
          _buildTermsButton(
            'Politique de confidentialité',
            responsive,
            _showPrivacyDialog,
          ),
        ],
      );
    }

    return Wrap(
      spacing: responsive.spacing(8),
      runSpacing: responsive.spacing(4),
      children: [
        _buildTermsButton(
          'Conditions d\'utilisation',
          responsive,
          _showTermsDialog,
        ),
        _buildTermsButton(
          'Politique de confidentialité',
          responsive,
          _showPrivacyDialog,
        ),
      ],
    );
  }

  Widget _buildTermsButton(
    String text,
    ResponsiveHelper responsive,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: responsive.fontSize(12),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _showTermsDialog() {
    final responsive = ResponsiveHelper(context);
    Get.defaultDialog(
      title: 'Conditions d\'utilisation',
      titleStyle: TextStyle(fontSize: responsive.fontSize(18)),
      content: Padding(
        padding: EdgeInsets.all(responsive.spacing(8)),
        child: Text(
          'En utilisant MarPro+, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité.',
          style: TextStyle(fontSize: responsive.fontSize(14)),
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    final responsive = ResponsiveHelper(context);
    Get.defaultDialog(
      title: 'Politique de confidentialité',
      titleStyle: TextStyle(fontSize: responsive.fontSize(18)),
      content: Padding(
        padding: EdgeInsets.all(responsive.spacing(8)),
        child: Text(
          'Nous respectons votre vie privée. Vos données sont sécurisées et utilisées uniquement pour le fonctionnement de l\'application.',
          style: TextStyle(fontSize: responsive.fontSize(14)),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(ResponsiveHelper responsive) {
    return Obx(() {
      if (_authController.isLoading.value) {
        return SizedBox(
          height: responsive.value<double>(mobile: 50, tablet: 54, desktop: 56),
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      }

      return SizedBox(
        height: responsive.value<double>(mobile: 50, tablet: 54, desktop: 56),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _acceptTerms ? _register : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: responsive.spacing(16)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
            backgroundColor: _acceptTerms
                ? Theme.of(context).primaryColor
                : Colors.grey[400],
          ),
          child: Text(
            'Créer mon compte',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLoginLink(ResponsiveHelper responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: AppTheme.bodyText2.copyWith(fontSize: responsive.fontSize(14)),
        ),
        TextButton(
          onPressed: () => Get.offNamed(AppRoutes.login),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
          ),
          child: Text(
            'Se connecter',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDisplay(ResponsiveHelper responsive) {
    return Obx(() {
      if (_authController.error.value.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: responsive.spacing(16)),
          child: Container(
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
                  color: Colors.red,
                  size: responsive.iconSize(20),
                ),
                SizedBox(width: responsive.spacing(8)),
                Expanded(
                  child: Text(
                    _authController.error.value,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: responsive.fontSize(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox();
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ResponsiveHelper responsive,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: responsive.iconSize(20)),
        border: const OutlineInputBorder(),
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(16),
        ),
      ),
      style: TextStyle(fontSize: responsive.fontSize(14)),
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      final result = await _authController.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
      );

      if (!mounted) return;

      if (result.success && result.isAuthenticated) {
        Get.offAllNamed(AppRoutes.communitySelect);
        Get.snackbar(
          'Inscription réussie',
          result.message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (result.success) {
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar(
          'Compte créé',
          result.message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } else if (!_acceptTerms) {
      Get.snackbar(
        'Conditions non acceptées',
        'Veuillez accepter les conditions d\'utilisation pour continuer.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
