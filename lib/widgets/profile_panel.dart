import 'package:flutter/material.dart';

import '../generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'drawer_panel.dart';

/// Profile / account side panel with user info, settings tiles, and fingerprint toggle.
class ProfilePanel extends StatefulWidget {
  const ProfilePanel({
    super.key,
    required this.onClose,
    required this.onLogout,
    this.currentUser,
  });

  final VoidCallback onClose;
  final VoidCallback onLogout;
  final AuthUser? currentUser;

  @override
  State<ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<ProfilePanel> {
  bool _fingerprintEnabled = false;
  bool _biometricAvailable = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadFingerprintState();
    _loadNotificationsState();
  }

  Future<void> _loadFingerprintState() async {
    final enabled = await AuthService.instance.getFingerprintEnabled();
    final available = await BiometricService.instance.hasBiometricEnrolled();
    if (!mounted) return;
    setState(() {
      _fingerprintEnabled = enabled;
      _biometricAvailable = available;
    });
  }

  Future<void> _loadNotificationsState() async {
    final enabled = await AuthService.instance.getNotificationsEnabled();
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _onFingerprintToggle(bool value) async {
    await AuthService.instance.setFingerprintEnabled(value);
    if (!mounted) return;
    setState(() => _fingerprintEnabled = value);
  }

  Future<void> _onNotificationsToggle(bool value) async {
    await AuthService.instance.setNotificationsEnabled(value);
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = widget.currentUser;

    final logoutTile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.logout, color: roseAccent, size: 20),
        title: Text(
          l10n.logOut,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          l10n.terminateSession,
          style: TextStyle(fontSize: 10, color: roseAccent.withValues(alpha: 0.8)),
        ),
        onTap: () async {
          final onLogout = widget.onLogout;
          final onClose = widget.onClose;
          await AuthService.instance.logout();
          onClose();
          onLogout();
        },
      ),
    );

    return DrawerPanel(
      title: l10n.executiveAccount,
      onClose: widget.onClose,
      bottomChild: logoutTile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: primaryIndigo,
                child: const Icon(Icons.person, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? l10n.bossExecutive,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                user?.permissions == 1 ? l10n.administrator : (user?.role ?? l10n.adminAccessLevel1),
                style: TextStyle(fontSize: 12, color: emeraldAccent, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.fingerprint, size: 22, color: primaryIndigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.useFingerprint,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (!_biometricAvailable) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.fingerprintNotAvailable,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.fingerprintSetupHint,
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: _fingerprintEnabled,
                  onChanged: _biometricAvailable ? _onFingerprintToggle : null,
                  activeTrackColor: primaryIndigo.withValues(alpha: 0.5),
                  activeThumbColor: primaryIndigo,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_outlined, size: 22, color: primaryIndigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.receiveNotifications,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _onNotificationsToggle,
                  activeTrackColor: primaryIndigo.withValues(alpha: 0.5),
                  activeThumbColor: primaryIndigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
