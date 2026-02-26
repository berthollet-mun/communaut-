// ignore_for_file: deprecated_member_use

import 'package:community/core/utils/validators.dart';
import 'package:community/core/utils/responsive_helper.dart';
import 'package:community/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    if (GetPlatform.isWeb || GetPlatform.isDesktop) {
      _emailController.text = 'test@example.com';
      _passwordController.text = 'password123';
      setState(() {
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialiser le ResponsiveHelper
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              // Largeur responsive du contenu
              width: responsive.contentMaxWidth,
              padding: EdgeInsets.all(responsive.contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: responsive.spacing(40)),

                  // Logo et titre - Responsive
                  _buildHeader(responsive),

                  SizedBox(height: responsive.spacing(40)),

                  // Formulaire
                  _buildForm(responsive),

                  SizedBox(height: responsive.spacing(32)),

                  // Séparateur
                  _buildDivider(responsive),

                  SizedBox(height: responsive.spacing(32)),

                  // Bouton d'inscription
                  _buildRegisterButton(responsive),

                  SizedBox(height: responsive.spacing(24)),

                  // Lien découverte
                  _buildDiscoverLink(responsive),

                  // Affichage des erreurs
                  _buildErrorDisplay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header avec logo et titre
  Widget _buildHeader(ResponsiveHelper responsive) {
    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          size: responsive.iconSize(80),
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: responsive.spacing(16)),
        Text(
          'MarPro+',
          style: TextStyle(
            fontSize: responsive.fontSize(32),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        Text(
          'Connectez-vous à votre compte',
          textAlign: TextAlign.center,
          style: AppTheme.bodyText2.copyWith(
            fontSize: responsive.fontSize(14),
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// Formulaire de connexion
  Widget _buildForm(ResponsiveHelper responsive) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(
                Icons.email_outlined,
                size: responsive.iconSize(20),
              ),
              border: const OutlineInputBorder(),
              hintText: 'votre@email.com',
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.spacing(16),
                vertical: responsive.spacing(16),
              ),
            ),
            style: TextStyle(fontSize: responsive.fontSize(14)),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.validateEmail,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),

          SizedBox(height: responsive.spacing(20)),

          // Password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: Icon(
                Icons.lock_outline,
                size: responsive.iconSize(20),
              ),
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.spacing(16),
                vertical: responsive.spacing(16),
              ),
            ),
            style: TextStyle(fontSize: responsive.fontSize(14)),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: Validators.validatePassword,
            onFieldSubmitted: (_) => _login(),
          ),

          SizedBox(height: responsive.spacing(16)),

          // Remember me & Forgot password
          _buildRememberForgot(responsive),

          SizedBox(height: responsive.spacing(24)),

          // Login button
          _buildLoginButton(responsive),
        ],
      ),
    );
  }

  /// Remember me et mot de passe oublié
  Widget _buildRememberForgot(ResponsiveHelper responsive) {
    // Sur mobile, afficher en colonne si nécessaire
    if (responsive.isMobile && responsive.screenWidth < 350) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRememberMeCheckbox(responsive),
          _buildForgotPasswordButton(responsive),
        ],
      );
    }

    // Sur tablette/desktop, afficher en ligne
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: _buildRememberMeCheckbox(responsive)),
        Flexible(child: _buildForgotPasswordButton(responsive)),
      ],
    );
  }

  Widget _buildRememberMeCheckbox(ResponsiveHelper responsive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: responsive.value<double>(mobile: 24, tablet: 28, desktop: 32),
          height: responsive.value<double>(mobile: 24, tablet: 28, desktop: 32),
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
          ),
        ),
        SizedBox(width: responsive.spacing(4)),
        Text(
          'Se souvenir de moi',
          style: AppTheme.bodyText2.copyWith(fontSize: responsive.fontSize(13)),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton(ResponsiveHelper responsive) {
    return TextButton(
      onPressed: () {
        Get.snackbar(
          'Fonctionnalité à venir',
          'La récupération de mot de passe sera disponible bientôt.',
        );
      },
      child: Text(
        'Mot de passe oublié ?',
        style: TextStyle(
          fontSize: responsive.fontSize(13),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// Bouton de connexion
  Widget _buildLoginButton(ResponsiveHelper responsive) {
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
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: responsive.spacing(16)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
          ),
          child: Text(
            'Se connecter',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  /// Séparateur "Ou"
  Widget _buildDivider(ResponsiveHelper responsive) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.spacing(16)),
          child: Text(
            'Ou',
            style: AppTheme.bodyText2.copyWith(
              fontSize: responsive.fontSize(14),
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[400], thickness: 1)),
      ],
    );
  }

  /// Bouton d'inscription
  Widget _buildRegisterButton(ResponsiveHelper responsive) {
    return SizedBox(
      height: responsive.value<double>(mobile: 50, tablet: 54, desktop: 56),
      child: OutlinedButton(
        onPressed: () => Get.toNamed(AppRoutes.register),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: responsive.spacing(16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
        child: Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  /// Lien découverte
  Widget _buildDiscoverLink(ResponsiveHelper responsive) {
    return TextButton(
      onPressed: () => Get.toNamed(AppRoutes.features),
      child: Text(
        'Découvrir les fonctionnalités',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: responsive.fontSize(14),
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
        ),
      ),
    );
  }

  /// Affichage des erreurs
  Widget _buildErrorDisplay() {
    return Obx(() {
      if (_authController.error.value.isNotEmpty) {
        final responsive = ResponsiveHelper(context);

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

  // === Fonctions de logique conservées à l'identique ===
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        if (_rememberMe) {
          /* Logic saved */
        }
        Get.offAllNamed(AppRoutes.communitySelect);
        Get.snackbar(
          'Connexion réussie',
          'Bienvenue ${_authController.user.value?.prenom} !',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
