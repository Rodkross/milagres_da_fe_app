import 'package:flutter/material.dart';

import '../main.dart' show AppColors, AppInfo;
import '../services/auth_service.dart';

/// Tela de autenticação: alterna entre os modos "Entrar" e "Criar conta".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTitle = 'Membro';

  final List<String> _titles = [
    'Membro',
    'Visitante',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistering) {
        await widget.authService.signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          ecclesiasticalTitle: _selectedTitle,
        );
      } else {
        await widget.authService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      // O AuthGate escuta o estado e troca a tela automaticamente.
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = AuthService.messageFor(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(
        () => _errorMessage = 'Informe seu e-mail para redefinir a senha.',
      );
      return;
    }
    try {
      await widget.authService.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviamos um link de redefinição para seu e-mail.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = AuthService.messageFor(error));
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Brand(),
                  const SizedBox(height: 28),
                  _FormCard(
                    formKey: _formKey,
                    isRegistering: _isRegistering,
                    isLoading: _isLoading,
                    obscurePassword: _obscurePassword,
                    errorMessage: _errorMessage,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    titles: _titles,
                    selectedTitle: _selectedTitle,
                    onTitleChanged: (value) => setState(() => _selectedTitle = value!),
                    onToggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
                    onForgotPassword: _resetPassword,
                  ),
                  const SizedBox(height: 20),
                  _ToggleModeButton(
                    isRegistering: _isRegistering,
                    onPressed: _isLoading ? null : _toggleMode,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo e nome da igreja exibidos no topo da tela.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: AppColors.gold, width: 1.6),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.goldBright,
            size: 40,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          AppInfo.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Acesse sua conta para continuar',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13),
        ),
      ],
    );
  }
}

/// Cartão branco com o formulário de login/cadastro.
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.isRegistering,
    required this.isLoading,
    required this.obscurePassword,
    required this.errorMessage,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.titles,
    required this.selectedTitle,
    required this.onTitleChanged,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final bool isRegistering;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final List<String> titles;
  final String selectedTitle;
  final ValueChanged<String?> onTitleChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isRegistering ? 'Criar conta' : 'Entrar',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            if (isRegistering) ...[
              _Field(
                controller: nameController,
                label: 'Nome completo',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Informe seu nome completo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTitle,
                decoration: InputDecoration(
                  labelText: 'Cargo na Igreja',
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.muted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold, width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
                items: titles.map((title) {
                  return DropdownMenuItem(value: title, child: Text(title));
                }).toList(),
                onChanged: onTitleChanged,
              ),
              const SizedBox(height: 16),
            ],
            _Field(
              controller: emailController,
              label: 'E-mail',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Informe seu e-mail.';
                if (!email.contains('@') || !email.contains('.')) {
                  return 'E-mail inválido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _Field(
              controller: passwordController,
              label: 'Senha',
              icon: Icons.lock_outline,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              suffix: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.muted,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'A senha deve ter ao menos 6 caracteres.';
                }
                return null;
              },
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDEC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3B7B7)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFC0392B),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFC0392B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            _SubmitButton(isLoading: isLoading, onSubmit: onSubmit),
            if (!isRegistering) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading ? null : onForgotPassword,
                child: const Text(
                  'Esqueci minha senha',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(color: AppColors.ink, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.muted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC0392B)),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onSubmit});

  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: isLoading ? null : onSubmit,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.goldBright,
                  ),
                ),
              )
            : const Text(
                'CONTINUAR',
                style: TextStyle(
                  color: AppColors.goldBright,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}

/// Alterna entre "Entrar" e "Criar conta".
class _ToggleModeButton extends StatelessWidget {
  const _ToggleModeButton({
    required this.isRegistering,
    required this.onPressed,
  });

  final bool isRegistering;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: isRegistering
                  ? 'Já tem uma conta? '
                  : 'Ainda não tem conta? ',
              style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13.5),
            ),
            TextSpan(
              text: isRegistering ? 'Entrar' : 'Criar conta',
              style: const TextStyle(
                color: AppColors.goldBright,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
