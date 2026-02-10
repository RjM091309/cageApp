import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../generated/app_localizations.dart';
import '../main.dart';
import '../models/types.dart';
import '../theme/app_theme.dart';
import '../constants/mock_data.dart';
import '../widgets/drawer_panel.dart';
import 'real_time_view.dart';
import 'daily_settlement_view.dart';
import 'monthly_view.dart';
import 'marker_view.dart';
import 'ranking_view.dart';

List<(ViewType, String, IconData)> navItems(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return [
    (ViewType.realTime, l10n.navRealTime, Icons.show_chart),
    (ViewType.daily, l10n.navDaily, Icons.calendar_today),
    (ViewType.monthly, l10n.navMonthly, Icons.bar_chart),
    (ViewType.marker, l10n.navMarker, Icons.description),
    (ViewType.ranking, l10n.navRanking, Icons.emoji_events),
  ];
}

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  ViewType _activeView = ViewType.realTime;
  bool _notificationOpen = false;
  bool _languageOpen = false;
  bool _profileOpen = false;

  Widget _buildContent() {
    switch (_activeView) {
      case ViewType.realTime:
        return const RealTimeView();
      case ViewType.daily:
        return const DailySettlementView();
      case ViewType.monthly:
        return const MonthlyView();
      case ViewType.marker:
        return const MarkerView();
      case ViewType.ranking:
        return const RankingView();
    }
  }

  String _viewLabel(BuildContext context) {
    final item = navItems(context).firstWhere((e) => e.$1 == _activeView);
    return item.$2;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                if (isWide) _buildSidebar(context),
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(context, isWide),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1280),
                              child: _buildContent(),
                            ),
                          ),
                        ),
                      ),
                      if (!isWide) const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
            if (!isWide)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomNav(context),
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
            if (_notificationOpen)
              Positioned.fill(
              child: DrawerPanel(
              title: AppLocalizations.of(context).notifications,
              onClose: () => setState(() => _notificationOpen = false),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...mockNotifications.map((n) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    n.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: n.type == 'urgent' ? roseAccent : cyanAccent,
                                    ),
                                  ),
                                  Text(n.time, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(n.message, style: TextStyle(fontSize: 13, color: Colors.grey[300])),
                            ],
                          ),
                        ),
                      )),
                  TextButton(
                    onPressed: () {},
                    child: Text(AppLocalizations.of(context).clearAllNotifications, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ),
                ],
                ),
              ),
              ),
            if (_profileOpen)
              Positioned.fill(
              child: DrawerPanel(
              title: AppLocalizations.of(context).executiveAccount,
              onClose: () => setState(() => _profileOpen = false),
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Column(
                    children: [
                      CircleAvatar(radius: 40, backgroundColor: cyanAccent, child: const Icon(Icons.person, size: 36, color: Colors.white)),
                      const SizedBox(height: 16),
                      Text(l10n.bossExecutive, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(l10n.adminAccessLevel1, style: TextStyle(fontSize: 12, color: emeraldAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      _profileTile(Icons.settings, l10n.systemSettings, l10n.preferencesConfig),
                      _profileTile(Icons.security, l10n.securityPrivacy, l10n.keysAuthorization),
                      _profileTile(Icons.history, l10n.auditLogs, l10n.sessionHistory),
                      _profileTile(Icons.help_outline, l10n.supportCenter, l10n.documentation),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white12),
                      ListTile(
                        leading: Icon(Icons.logout, color: roseAccent, size: 20),
                        title: Text(l10n.logOut, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text(l10n.terminateSession, style: TextStyle(fontSize: 10, color: roseAccent.withValues(alpha: 0.8))),
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: cyanAccent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.securityNote, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[300])),
                                  Text(l10n.lastLoginFromIp('192.168.1.45'), style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ),
          ],
        ),
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
            border: Border.all(color: isSelected ? cyanAccent : borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.check, size: 20, color: isSelected ? cyanAccent : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? cyanAccent : Colors.white)),
              ),
              const SizedBox(width: 12),
              Text(flag, style: const TextStyle(fontSize: 24, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String label, String sub) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: Colors.grey),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: appBarBackground.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            offset: const Offset(2, 0),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: cyanAccent, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: cyanAccent.withValues(alpha: 0.3), blurRadius: 12)]),
                  child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).appTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(AppLocalizations.of(context).executive, style: TextStyle(fontSize: 10, color: cyanAccent, fontWeight: FontWeight.w600, letterSpacing: 2)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context).mainMenu, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
            ),
          ),
          const SizedBox(height: 16),
          ...navItems(context).map((e) {
            final isActive = _activeView == e.$1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _activeView = e.$1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? cyanAccent.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isActive ? cyanAccent.withValues(alpha: 0.2) : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(e.$3, size: 20, color: isActive ? cyanAccent : Colors.grey),
                        const SizedBox(width: 12),
                        Text(e.$2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? cyanAccent : Colors.grey)),
                        if (isActive) const Spacer(),
                        if (isActive) Container(width: 6, height: 6, decoration: BoxDecoration(color: cyanAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: cyanAccent.withValues(alpha: 0.8), blurRadius: 8)])),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          InkWell(
            onTap: () => setState(() => _profileOpen = true),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: cyanAccent.withValues(alpha: 0.3), child: const Icon(Icons.person, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context).executiveBoss, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(AppLocalizations.of(context).administrator, style: TextStyle(fontSize: 10, color: emeraldAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isWide) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: appBarBackground.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          if (!isWide)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: cyanAccent, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.dashboard, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).appTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          if (!isWide) const Spacer(),
          if (isWide)
            Text(
              _viewLabel(context),
              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
            ),
          const Spacer(),
          if (isWide)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: emeraldAccent, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).systemStatusLive, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                ],
              ),
            ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: AppLocalizations.of(context).language,
            onPressed: () => setState(() => _languageOpen = true),
            icon: const Icon(Icons.language, color: Colors.grey, size: 24),
          ),
          IconButton(
            onPressed: () => setState(() => _notificationOpen = true),
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Colors.grey, size: 24),
                Positioned(top: 0, right: 0, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: roseAccent, shape: BoxShape.circle))),
              ],
            ),
          ),
          if (!isWide)
            IconButton(
              onPressed: () => setState(() => _profileOpen = true),
              icon: CircleAvatar(radius: 18, backgroundColor: cyanAccent, child: const Icon(Icons.person, size: 18, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: appBarBackground.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            offset: const Offset(0, -3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems(context).map((e) {
            final isActive = _activeView == e.$1;
            return InkWell(
              onTap: () => setState(() => _activeView = e.$1),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: isActive ? BoxDecoration(color: cyanAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)) : null,
                    child: Icon(e.$3, size: 22, color: isActive ? cyanAccent : Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.$2,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: isActive ? cyanAccent : Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
