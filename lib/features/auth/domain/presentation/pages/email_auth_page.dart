import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mustard_seed/core/theme/app_colors.dart';
import 'package:mustard_seed/core/theme/app_text_styles.dart';
import 'package:mustard_seed/core/utils/responsive.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:mustard_seed/features/auth/data/event/auth_event.dart';
import 'package:mustard_seed/features/auth/data/state/auth_state.dart';



enum _EmailAuthMode { signIn, signUp }

/// Email + şifre ile giriş yapma / kayıt olma ekranı.
///
/// Form alanları (controller, obscure toggle, mod seçimi) bu widget'ın
/// kendi yerel (ephemeral) UI durumudur — bunlar iş mantığı değil, sadece
/// "kullanıcı henüz ne yazdı" bilgisi, bu yüzden Bloc'a taşınmadı.
/// Gerçek iş mantığı (submit sonucu, loading, hata mesajı) [AuthBloc]
/// üzerinden yönetiliyor — Apple/Google girişiyle aynı Bloc, aynı desen.
class EmailAuthPage extends StatefulWidget {
  const EmailAuthPage({super.key});

  @override
  State<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<EmailAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _EmailAuthMode _mode = _EmailAuthMode.signIn;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_mode == _EmailAuthMode.signIn) {
      context
          .read<AuthBloc>()
          .add(AuthEmailSignInRequested(email: email, password: password));
    } else {
      context
          .read<AuthBloc>()
          .add(AuthEmailSignUpRequested(email: email, password: password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.pop();
          } else if (state.status == AuthStatus.emailConfirmationRequired) {
            setState(() => _mode = _EmailAuthMode.signIn);
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text(
                  'E-postanı kontrol et',
                  style: AppTextStyles.headlineMd(),
                ),
                content: Text(
                  '${state.pendingEmail ?? 'E-posta adresine'} bir doğrulama '
                  'linki gönderdik. Hesabını aktifleştirmek için linke '
                  'tıkla, sonra buradan giriş yapabilirsin.',
                  style: AppTextStyles.bodyMd(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Tamam',
                      style: AppTextStyles.bodyMd(
                        color: AppColors.gold,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          } else if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalMargin,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _mode == _EmailAuthMode.signIn
                        ? 'Tekrar hoş geldin.'
                        : 'Hesap oluştur.',
                    style: AppTextStyles.headlineLg(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _mode == _EmailAuthMode.signIn
                        ? 'Devam etmek için giriş yap.'
                        : 'Birkaç adımda hesabını oluştur.',
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 32),
                  _ModeToggle(
                    mode: _mode,
                    onChanged: (mode) => setState(() => _mode = mode),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    style: AppTextStyles.bodyMd(color: AppColors.textPrimary),
                    decoration: _inputDecoration('E-posta'),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: _mode == _EmailAuthMode.signIn
                        ? TextInputAction.done
                        : TextInputAction.next,
                    style: AppTextStyles.bodyMd(color: AppColors.textPrimary),
                    decoration: _inputDecoration('Şifre').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  if (_mode == _EmailAuthMode.signUp) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      style:
                          AppTextStyles.bodyMd(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Şifre Tekrar').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                      ),
                      validator: _validateConfirmPassword,
                    ),
                  ],
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.isLoading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            disabledBackgroundColor: AppColors.gold,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(
                                  _mode == _EmailAuthMode.signIn
                                      ? 'Giriş Yap'
                                      : 'Kayıt Ol',
                                  style: AppTextStyles.bodyMd(
                                    color: Colors.white,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyMd(),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.goldBright),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta gerekli';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta gir';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _EmailAuthMode mode;
  final ValueChanged<_EmailAuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Giriş Yap',
              isActive: mode == _EmailAuthMode.signIn,
              onTap: () => onChanged(_EmailAuthMode.signIn),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Kayıt Ol',
              isActive: mode == _EmailAuthMode.signUp,
              onTap: () => onChanged(_EmailAuthMode.signUp),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd(
            color: isActive ? Colors.white : AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}