import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../generated/app_localizations.dart';
import '../main.dart';
import '../models/types.dart';
import '../theme/app_theme.dart';
import '../services/server_status_service.dart';
import '../services/notification_service.dart';
import '../widgets/active_view_scope.dart';
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

class _LayoutScreenState extends State<LayoutScreen> with SingleTickerProviderStateMixin {
  ViewType _activeView = ViewType.realTime;
  /// When null = no transition. When set, we're animating from _previousView to _activeView.
  ViewType? _previousView;
  late final AnimationController _contentTransitionController;
  late Widget _cachedContent;
  Widget? _outgoingContent;
  bool _notificationOpen = false;
  bool _languageOpen = false;
  bool _profileOpen = false;
  bool _isServerOnline = true;
  StreamSubscription<bool>? _serverStatusSub;
  List<NotificationItem> _notifications = [];
  bool _notificationsLoading = false;

  @override
  void initState() {
    super.initState();
    _cachedContent = _buildView(_activeView);
    _isServerOnline = ServerStatusService.instance.isOnline;
    ServerStatusService.instance.start();
    _serverStatusSub = ServerStatusService.instance.isOnlineStream.listen((online) {
      if (mounted) setState(() => _isServerOnline = online);
    });
    NotificationService.onNotificationsChanged = () {
      if (mounted) _loadNotifications();
    };
    // Load notifications on start so red dot shows for unread without opening panel first
    _loadNotifications();
    _contentTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentTransitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _previousView = null;
            _outgoingContent = null;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    NotificationService.onNotificationsChanged = null;
    _serverStatusSub?.cancel();
    ServerStatusService.instance.stop();
    _contentTransitionController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => _notificationsLoading = true);
    final list = await NotificationService.instance.fetchNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = list;
      _notificationsLoading = false;
    });
  }

  Future<void> _clearAllNotifications() async {
    final ok = await NotificationService.instance.clearAll();
    if (!mounted) return;
    if (ok) setState(() => _notifications = []);
  }

  Future<void> _markNotificationAsRead(NotificationItem n) async {
    if (n.isRead) return;
    final ok = await NotificationService.instance.markAsRead(n.id);
    if (!mounted) return;
    if (ok) {
      setState(() {
        final i = _notifications.indexWhere((x) => x.id == n.id);
        if (i >= 0) _notifications[i] = n.copyWith(isRead: true);
      });
    }
  }

  void _setActiveView(ViewType view) {
    if (view == _activeView) return;
    final oldView = _activeView;
    setState(() {
      _previousView = oldView;
      _outgoingContent = _cachedContent;
      _activeView = view;
      _cachedContent = _buildView(view);
    });
    _contentTransitionController.forward(from: 0);
  }

  Widget _buildView(ViewType view) {
    switch (view) {
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

  /// Incoming only: slide in from right. Outgoing hidden (no fade).
  Widget _buildTransitionContent() {
    final inTransition = _previousView != null;

    return AnimatedBuilder(
      animation: _contentTransitionController,
      builder: (context, _) {
        final t = inTransition
            ? Curves.easeOutCubic.transform(_contentTransitionController.value)
            : 1.0;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Outgoing: hidden (no fade/slide effect)
            if (inTransition)
              IgnorePointer(
                child: Opacity(
                  opacity: 0,
                  child: _outgoingContent ?? const SizedBox.shrink(),
                ),
              ),
            // Incoming: slide from right + fade in
            RepaintBoundary(
              child: Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(40 * (1 - t), 0),
                  child: _cachedContent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: scaffoldGradient),
        child: SafeArea(
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
                        child: _activeView == ViewType.ranking
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 1280),
                                    child: ActiveViewScope(
                                      activeView: _activeView,
                                      child: _buildTransitionContent(),
                                    ),
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 1280),
                                    child: ActiveViewScope(
                                      activeView: _activeView,
                                      child: _buildTransitionContent(),
                                    ),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_notificationsLoading)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator(color: primaryIndigo)),
                    )
                  else ...[
                    if (_notifications.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ),
                      )
                    else
                      ..._notifications.map((n) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _markNotificationAsRead(n),
                                borderRadius: BorderRadius.circular(12),
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
                                          Row(
                                            children: [
                                              if (!n.isRead)
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8),
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: roseAccent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              Text(
                                                n.title,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _notificationTitleColor(n.type),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(n.time, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      _buildNotificationMessage(n.message),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                    if (_notifications.isNotEmpty)
                      TextButton(
                        onPressed: _clearAllNotifications,
                        child: Text(
                          AppLocalizations.of(context).clearAllNotifications,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ),
                  ],
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
                      CircleAvatar(radius: 40, backgroundColor: primaryIndigo, child: const Icon(Icons.person, size: 36, color: Colors.white)),
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
                            Icon(Icons.info_outline, color: primaryIndigo, size: 20),
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

  Color _notificationTitleColor(String type) {
    switch (type) {
      case 'urgent':
        return roseAccent;
      case 'success':
        return emeraldAccent;
      case 'warning':
        return amberAccent;
      default:
        return primaryIndigo;
    }
  }

  static const _winLossPrefix = ' – Win/Loss: ';

  Widget _buildNotificationMessage(String message) {
    final grey = TextStyle(fontSize: 13, color: Colors.grey[300]);
    final idx = message.indexOf(_winLossPrefix);
    if (idx < 0) {
      return Text(message, style: grey);
    }
    final before = message.substring(0, idx);
    final winLossPart = message.substring(idx + _winLossPrefix.length);
    final isNegative = winLossPart.trim().startsWith('-') || winLossPart.contains('−');
    final winLossColor = isNegative ? roseAccent : emeraldAccent;
    return RichText(
      text: TextSpan(
        style: grey,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: _winLossPrefix + winLossPart,
            style: TextStyle(fontSize: 13, color: winLossColor, fontWeight: FontWeight.w600),
          ),
        ],
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
        border: Border(
          right: BorderSide(color: borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            offset: const Offset(2, 0),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: primaryIndigo, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: primaryIndigo.withValues(alpha: 0.3), blurRadius: 12)]),
                  child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).appTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(AppLocalizations.of(context).executive, style: TextStyle(fontSize: 10, color: primaryIndigo, fontWeight: FontWeight.w600, letterSpacing: 2)),
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
                  onTap: () => _setActiveView(e.$1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? primaryIndigo.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isActive ? primaryIndigo.withValues(alpha: 0.2) : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(e.$3, size: 20, color: isActive ? primaryIndigo : Colors.grey),
                        const SizedBox(width: 12),
                        Text(e.$2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? primaryIndigo : Colors.grey)),
                        if (isActive) const Spacer(),
                        if (isActive) Container(width: 6, height: 6, decoration: BoxDecoration(color: primaryIndigo, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryIndigo.withValues(alpha: 0.8), blurRadius: 8)])),
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
                  CircleAvatar(radius: 20, backgroundColor: primaryIndigo.withValues(alpha: 0.3), child: const Icon(Icons.person, color: Colors.white, size: 20)),
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
          // sample.html .tabs-nav::before — vertical gradient line on right edge
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    primaryIndigo.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
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
                  decoration: BoxDecoration(color: primaryIndigo, borderRadius: BorderRadius.circular(8)),
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
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isServerOnline ? emeraldAccent : roseAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isServerOnline
                        ? AppLocalizations.of(context).systemStatusLive
                        : AppLocalizations.of(context).systemStatusOffline,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _isServerOnline ? Colors.grey : roseAccent,
                      letterSpacing: 1,
                    ),
                  ),
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
            onPressed: () {
              setState(() => _notificationOpen = true);
              _loadNotifications();
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Colors.grey, size: 24),
                if (_notifications.any((n) => !n.isRead))
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: roseAccent, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          if (!isWide)
            IconButton(
              onPressed: () => setState(() => _profileOpen = true),
              icon: CircleAvatar(radius: 18, backgroundColor: primaryIndigo, child: const Icon(Icons.person, size: 18, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final navBg = appBarBackground.withValues(alpha: 0.95);
    return Container(
      decoration: BoxDecoration(
        color: navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            offset: const Offset(0, -3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top border: same idea as sidebar right — color in center, fade left/right (transparent → indigo → transparent)
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  borderColor,
                  primaryIndigo.withValues(alpha: 0.5),
                  borderColor,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SafeArea(
              child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems(context).map((e) {
            final isActive = _activeView == e.$1;
            return InkWell(
              onTap: () => _setActiveView(e.$1),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: isActive ? BoxDecoration(color: primaryIndigo.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)) : null,
                    child: Icon(e.$3, size: 22, color: isActive ? primaryIndigo : Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.$2,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: isActive ? primaryIndigo : Colors.grey),
                  ),
                ],
              ),
            );
              }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
