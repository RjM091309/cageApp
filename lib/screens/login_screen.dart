import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart' show BiometricService, BiometricAuthResult;
import '../generated/app_localizations.dart';
import '../main.dart';
import '../widgets/drawer_panel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _rememberMe = false;
  bool _useFingerprint = false;
  bool _languageOpen = false;
  bool _biometricAvailable = false;
  bool _fingerprintEnabled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    final remember = await AuthService.instance.getRememberMe();
    final fingerprintOn = await AuthService.instance.getFingerprintEnabled();
    final username = await AuthService.instance.getSavedUsername();
    final password = await AuthService.instance.getSavedPassword();
    final hasSavedLogin = remember && username.isNotEmpty && password.isNotEmpty;
    // Use both checks: some devices report empty getAvailableBiometrics() even when
    // fingerprint is set up for lock screen; isDeviceSupported() helps on those.
    final hasEnrolled = await BiometricService.instance.hasBiometricEnrolled();
    final deviceSupported = await BiometricService.instance.isDeviceSupported();
    final hasBiometric = hasEnrolled || deviceSupported;
    if (!mounted) return;
    setState(() {
      _rememberMe = hasSavedLogin;
      _useFingerprint = fingerprintOn && hasBiometric;
      // Show fingerprint button when we have saved login and device supports biometric.
      _fingerprintEnabled = hasBiometric && hasSavedLogin;
      _biometricAvailable = hasBiometric;
      if (_rememberMe && username.isNotEmpty) _usernameController.text = username;
      if (_rememberMe && password.isNotEmpty) _passwordController.text = password;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithFingerprint() async {
    final username = await AuthService.instance.getSavedUsername();
    final password = await AuthService.instance.getSavedPassword();
    if (username.isEmpty || password.isEmpty) return;
    if (!mounted) return;
    setState(() => _errorMessage = null);
    final reason = AppLocalizations.of(context).fingerprintReason;
    // Give the activity time to be ready so Android BiometricPrompt can attach (same as main.dart flow)
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    // Wake up biometric stack on some devices before showing the prompt
    await BiometricService.instance.getAvailableBiometrics();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    final result = await BiometricService.instance.authenticate(
      reason: reason,
      biometricOnly: false,
    );
    if (!mounted) return;
    if (result != BiometricAuthResult.success) {
      if (result == BiometricAuthResult.cancelled) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _errorMessage = result == BiometricAuthResult.notAvailable
            ? l10n.fingerprintNotAvailable
            : l10n.fingerprintTryAgain;
      });
      return;
    }
    setState(() {
      _errorMessage = null;
      _loading = true;
    });
    final user = await AuthService.instance.login(username: username, password: password);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (user != null && user.permissions == 1) {
      widget.onLoginSuccess();
    } else {
      await AuthService.instance.clearRememberMe();
      setState(() {
        _errorMessage = user == null ? l10n.errorInvalidCredentials : l10n.errorAdminOnlyAccess;
        _loading = false;
        _fingerprintEnabled = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _loading = true;
    });
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).errorEnterCredentials;
        _loading = false;
      });
      return;
    }
    final user = await AuthService.instance.login(username: username, password: password);
    if (!mounted) return;
    if (user != null) {
      if (user.permissions != 1) {
        await AuthService.instance.logout();
        if (!mounted) return;
        setState(() {
          _errorMessage = AppLocalizations.of(context).errorAdminOnlyAccess;
          _loading = false;
        });
        return;
      }
      if (_rememberMe) {
        await AuthService.instance.saveRememberMe(username: username, password: password);
        await AuthService.instance.setFingerprintEnabled(_useFingerprint);
      } else {
        await AuthService.instance.clearRememberMe();
      }
      widget.onLoginSuccess();
    } else {
      setState(() {
        _errorMessage = AppLocalizations.of(context).errorInvalidCredentials;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(gradient: scaffoldGradient),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      // Logo
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Opacity(
                          opacity: 0.55,
                          child: Image.asset(
                            'assets/images/login.png',
                            height: 250,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(Icons.dashboard, size: 200, color: primaryIndigo),
                          ),
                        ),
                      ),
                   
                      // Sign In title + subtitle with language switcher
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 24, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).signIn,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppLocalizations.of(context).loginSubtitle,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, 6),
                              child: IconButton(
                                tooltip: AppLocalizations.of(context).language,
                                onPressed: () => setState(() => _languageOpen = true),
                                icon: const Icon(Icons.language, color: Colors.grey, size: 28),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: roseAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: roseAccent.withValues(alpha: 0.35)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, size: 20, color: roseAccent),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(fontSize: 13, color: roseAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (_fingerprintEnabled && !_loading) ...[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white.withValues(alpha: 0.08),
                                  border: Border.all(color: primaryIndigo.withValues(alpha: 0.5), width: 1.2),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _loginWithFingerprint,
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.fingerprint, size: 28, color: primaryIndigo),
                                          const SizedBox(width: 12),
                                          Text(
                                            AppLocalizations.of(context).signInWithFingerprint,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).username,
                                hintText: AppLocalizations.of(context).enterUsername,
                                prefixIcon: Icon(Icons.person_outline, size: 22, color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: primaryIndigo, width: 1.5),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).password,
                                hintText: AppLocalizations.of(context).enterPassword,
                                prefixIcon: Icon(Icons.lock_outline, size: 22, color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: primaryIndigo, width: 1.5),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: _loading
                                            ? null
                                            : (v) => setState(() => _rememberMe = v ?? false),
                                        activeColor: primaryIndigo,
                                        checkColor: Colors.white,
                                        fillColor: WidgetStateProperty.resolveWith((states) {
                                          if (states.contains(WidgetState.selected)) return primaryIndigo;
                                          return Colors.white.withValues(alpha: 0.2);
                                        }),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: _loading
                                          ? null
                                          : () => setState(() => _rememberMe = !_rememberMe),
                                      child: Text(
                                        AppLocalizations.of(context).saveLogin,
                                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_biometricAvailable && _rememberMe) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _useFingerprint,
                                          onChanged: _loading
                                              ? null
                                              : (v) => setState(() => _useFingerprint = v ?? false),
                                          activeColor: primaryIndigo,
                                          checkColor: Colors.white,
                                          fillColor: WidgetStateProperty.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) return primaryIndigo;
                                            return Colors.white.withValues(alpha: 0.2);
                                          }),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: _loading
                                            ? null
                                            : () => setState(() => _useFingerprint = !_useFingerprint),
                                        child: Text(
                                          AppLocalizations.of(context).useFingerprint,
                                          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white.withValues(alpha: 0.08),
                                      border: Border.all(color: primaryIndigo.withValues(alpha: 0.5), width: 1.2),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _loading ? null : () => _submit(),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                                          alignment: Alignment.center,
                                          child: _loading
                                              ? const SizedBox(
                                                  height: 22,
                                                  width: 22,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                )
                                              : Text(AppLocalizations.of(context).signIn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
          ),
          if (_languageOpen)
            Positioned.fill(
              child: DrawerPanel(
                title: AppLocalizations.of(context).language,
                onClose: () => setState(() => _languageOpen = false),
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    final scope = AppLocaleScope.of(context);
                    final current = scope.locale?.languageCode;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _languageOption(
                          context,
                          flag: '🇺🇸',
                          label: l10n.english,
                          isSelected: current == 'en',
                          onTap: () {
                            scope.setLocale(const Locale('en'));
                            setState(() => _languageOpen = false);
                          },
                        ),
                        const SizedBox(height: 12),
                        _languageOption(
                          context,
                          flag: '🇰🇷',
                          label: l10n.korean,
                          isSelected: current == 'ko',
                          onTap: () {
                            scope.setLocale(const Locale('ko'));
                            setState(() => _languageOpen = false);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _languageOption(BuildContext context, {required String flag, required String label, required bool isSelected, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryIndigo : borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.check, size: 20, color: isSelected ? primaryIndigo : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? primaryIndigo : Colors.white)),
              ),
              const SizedBox(width: 12),
              Text(flag, style: const TextStyle(fontSize: 24, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}
