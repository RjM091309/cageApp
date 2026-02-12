import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Infinity Cage X'**
  String get appTitle;

  /// No description provided for @executive.
  ///
  /// In en, this message translates to:
  /// **'EXECUTIVE'**
  String get executive;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'MAIN MENU'**
  String get mainMenu;

  /// No description provided for @navRealTime.
  ///
  /// In en, this message translates to:
  /// **'Real-Time'**
  String get navRealTime;

  /// No description provided for @navDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get navDaily;

  /// No description provided for @navMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get navMonthly;

  /// No description provided for @navMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get navMarker;

  /// No description provided for @navRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get navRanking;

  /// No description provided for @executiveBoss.
  ///
  /// In en, this message translates to:
  /// **'Executive Boss'**
  String get executiveBoss;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @systemStatusLive.
  ///
  /// In en, this message translates to:
  /// **'System Status: Live'**
  String get systemStatusLive;

  /// No description provided for @systemStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'System Status: Offline'**
  String get systemStatusOffline;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications'**
  String get clearAllNotifications;

  /// No description provided for @executiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Executive Account'**
  String get executiveAccount;

  /// No description provided for @bossExecutive.
  ///
  /// In en, this message translates to:
  /// **'Boss Executive'**
  String get bossExecutive;

  /// No description provided for @adminAccessLevel1.
  ///
  /// In en, this message translates to:
  /// **'Admin Access Level 1'**
  String get adminAccessLevel1;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @preferencesConfig.
  ///
  /// In en, this message translates to:
  /// **'Preferences & Config'**
  String get preferencesConfig;

  /// No description provided for @securityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityPrivacy;

  /// No description provided for @keysAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Keys & Authorization'**
  String get keysAuthorization;

  /// No description provided for @auditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get auditLogs;

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get sessionHistory;

  /// No description provided for @supportCenter.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get supportCenter;

  /// No description provided for @documentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get documentation;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @terminateSession.
  ///
  /// In en, this message translates to:
  /// **'Terminate Session'**
  String get terminateSession;

  /// No description provided for @securityNote.
  ///
  /// In en, this message translates to:
  /// **'Security Note'**
  String get securityNote;

  /// No description provided for @lastLoginFromIp.
  ///
  /// In en, this message translates to:
  /// **'Last login from IP: {ip}'**
  String lastLoginFromIp(String ip);

  /// No description provided for @monthlyAccumulatedWinLoss.
  ///
  /// In en, this message translates to:
  /// **'Monthly Accumulated Win Loss'**
  String get monthlyAccumulatedWinLoss;

  /// No description provided for @trendVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs Last Month'**
  String trendVsLastMonth(String percent);

  /// No description provided for @topMonthlyCommission.
  ///
  /// In en, this message translates to:
  /// **'Top Monthly Commission'**
  String get topMonthlyCommission;

  /// No description provided for @rankAgentDragon.
  ///
  /// In en, this message translates to:
  /// **'Rank #1 - Agent Dragon'**
  String get rankAgentDragon;

  /// No description provided for @accumulatedExpenses.
  ///
  /// In en, this message translates to:
  /// **'Accumulated Expenses'**
  String get accumulatedExpenses;

  /// No description provided for @mtdExpenditure.
  ///
  /// In en, this message translates to:
  /// **'MTD Expenditure'**
  String get mtdExpenditure;

  /// No description provided for @gamesRolling.
  ///
  /// In en, this message translates to:
  /// **'Games (Rolling)'**
  String get gamesRolling;

  /// No description provided for @totalRolling.
  ///
  /// In en, this message translates to:
  /// **'Total Rolling'**
  String get totalRolling;

  /// No description provided for @casinoIntegration.
  ///
  /// In en, this message translates to:
  /// **'Casino Integration'**
  String get casinoIntegration;

  /// No description provided for @monthlyAccumulatedRollingCasino.
  ///
  /// In en, this message translates to:
  /// **'Monthly Accumulated Rolling (Casino)'**
  String get monthlyAccumulatedRollingCasino;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @totalBuyIn.
  ///
  /// In en, this message translates to:
  /// **'Total Buy-In'**
  String get totalBuyIn;

  /// No description provided for @avgRolling.
  ///
  /// In en, this message translates to:
  /// **'Avg Rolling'**
  String get avgRolling;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// No description provided for @totalGames.
  ///
  /// In en, this message translates to:
  /// **'Total Games'**
  String get totalGames;

  /// No description provided for @numberOfGamesWinLoss.
  ///
  /// In en, this message translates to:
  /// **'Number of Games & Win/Loss'**
  String get numberOfGamesWinLoss;

  /// No description provided for @winLossTrend.
  ///
  /// In en, this message translates to:
  /// **'Win / Loss Trend'**
  String get winLossTrend;

  /// No description provided for @dailyCommission.
  ///
  /// In en, this message translates to:
  /// **'Daily Commission'**
  String get dailyCommission;

  /// No description provided for @junketExpenses.
  ///
  /// In en, this message translates to:
  /// **'Junket Expenses'**
  String get junketExpenses;

  /// No description provided for @realTimeMarker.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Marker'**
  String get realTimeMarker;

  /// No description provided for @activeBalance.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE BALANCE'**
  String get activeBalance;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'LIMIT'**
  String get limit;

  /// No description provided for @utilization.
  ///
  /// In en, this message translates to:
  /// **'UTILIZATION'**
  String get utilization;

  /// No description provided for @guestAgentRanking.
  ///
  /// In en, this message translates to:
  /// **'GUEST & AGENT RANKING'**
  String get guestAgentRanking;

  /// No description provided for @monthlyPerformanceReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Accumulated Performance Report'**
  String get monthlyPerformanceReport;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins: '**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses: '**
  String get losses;

  /// No description provided for @rollingVolume.
  ///
  /// In en, this message translates to:
  /// **'ROLLING VOLUME'**
  String get rollingVolume;

  /// No description provided for @winLoss.
  ///
  /// In en, this message translates to:
  /// **'WINLOSS'**
  String get winLoss;

  /// No description provided for @winRatio.
  ///
  /// In en, this message translates to:
  /// **'WIN RATIO'**
  String get winRatio;

  /// No description provided for @totalChips.
  ///
  /// In en, this message translates to:
  /// **'Total Chips'**
  String get totalChips;

  /// No description provided for @cashBalance.
  ///
  /// In en, this message translates to:
  /// **'Cash Balance'**
  String get cashBalance;

  /// No description provided for @guestBalance.
  ///
  /// In en, this message translates to:
  /// **'Guest Balance'**
  String get guestBalance;

  /// No description provided for @netJunketMoney.
  ///
  /// In en, this message translates to:
  /// **'Net Junket Money'**
  String get netJunketMoney;

  /// No description provided for @netJunketCash.
  ///
  /// In en, this message translates to:
  /// **'Net Junket Cash'**
  String get netJunketCash;

  /// No description provided for @ongoingGames.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Games'**
  String get ongoingGames;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @gameType.
  ///
  /// In en, this message translates to:
  /// **'Game type'**
  String get gameType;

  /// No description provided for @buyIn.
  ///
  /// In en, this message translates to:
  /// **'Buy-In'**
  String get buyIn;

  /// No description provided for @cashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash Out'**
  String get cashOut;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'On Game'**
  String get statusActive;

  /// No description provided for @statusSettling.
  ///
  /// In en, this message translates to:
  /// **'Settling'**
  String get statusSettling;

  /// No description provided for @noGamesToday.
  ///
  /// In en, this message translates to:
  /// **'No Games Today'**
  String get noGamesToday;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to stay connected.'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @saveLogin.
  ///
  /// In en, this message translates to:
  /// **'Save login'**
  String get saveLogin;

  /// No description provided for @errorEnterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter username and password'**
  String get errorEnterCredentials;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAdminOnlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Only administrators can access this app.'**
  String get errorAdminOnlyAccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
