import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Werdi'**
  String get appName;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Werdi'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account to start your memorization journey'**
  String get authWelcomeSubtitle;

  /// No description provided for @loginTab.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTab;

  /// No description provided for @registerTab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTab;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get loginError;

  /// No description provided for @registerError.
  ///
  /// In en, this message translates to:
  /// **'Could not create account, please try again'**
  String get registerError;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today is a new chance to strengthen your memorization'**
  String get homeSubtitle;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActionsTitle;

  /// No description provided for @memorizeNow.
  ///
  /// In en, this message translates to:
  /// **'Memorize now'**
  String get memorizeNow;

  /// No description provided for @memorizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get memorizeSubtitle;

  /// No description provided for @reviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewAction;

  /// No description provided for @reviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Previous lesson'**
  String get reviewSubtitle;

  /// No description provided for @testYourself.
  ///
  /// In en, this message translates to:
  /// **'Test yourself'**
  String get testYourself;

  /// No description provided for @testSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listening session'**
  String get testSubtitle;

  /// No description provided for @openQuran.
  ///
  /// In en, this message translates to:
  /// **'Open Quran'**
  String get openQuran;

  /// No description provided for @openQuranSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Surahs & Juz'**
  String get openQuranSubtitle;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @ayahsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs remaining'**
  String ayahsRemaining(int count);

  /// No description provided for @ayahsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs completed'**
  String ayahsCompleted(int count);

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get overallProgress;

  /// No description provided for @currentSurah.
  ///
  /// In en, this message translates to:
  /// **'Current surah'**
  String get currentSurah;

  /// No description provided for @continueMemorization.
  ///
  /// In en, this message translates to:
  /// **'Continue memorizing'**
  String get continueMemorization;

  /// No description provided for @reviewReminder.
  ///
  /// In en, this message translates to:
  /// **'Review reminder'**
  String get reviewReminder;

  /// No description provided for @reviewDue.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews due'**
  String reviewDue(int count);

  /// No description provided for @overdueReviews.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue'**
  String overdueReviews(int count);

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start review'**
  String get startReview;

  /// No description provided for @weeklyInsights.
  ///
  /// In en, this message translates to:
  /// **'Weekly insights'**
  String get weeklyInsights;

  /// No description provided for @memorizedAyahs.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs memorized'**
  String memorizedAyahs(int count);

  /// No description provided for @reviewedAyahs.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs reviewed'**
  String reviewedAyahs(int count);

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String sessions(int count);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String streakDays(int count);

  /// No description provided for @yourAchievements.
  ///
  /// In en, this message translates to:
  /// **'Your achievements'**
  String get yourAchievements;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @recommendedPlan.
  ///
  /// In en, this message translates to:
  /// **'Recommended next step'**
  String get recommendedPlan;

  /// No description provided for @progressOverview.
  ///
  /// In en, this message translates to:
  /// **'Progress overview'**
  String get progressOverview;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @continueJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue your journey'**
  String get continueJourney;

  /// No description provided for @resumeFromLastPosition.
  ///
  /// In en, this message translates to:
  /// **'Resume from last position'**
  String get resumeFromLastPosition;

  /// No description provided for @dailyMotivation.
  ///
  /// In en, this message translates to:
  /// **'Daily motivation'**
  String get dailyMotivation;

  /// No description provided for @motivationFooter.
  ///
  /// In en, this message translates to:
  /// **'Keep going — every page you memorize brings you closer to your goal.'**
  String get motivationFooter;

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakTitle;

  /// No description provided for @achievementsPreview.
  ///
  /// In en, this message translates to:
  /// **'Achievements preview'**
  String get achievementsPreview;

  /// No description provided for @memorizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Memorize'**
  String get memorizeLabel;

  /// No description provided for @sessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionsLabel;

  /// No description provided for @suggestedPlanToday.
  ///
  /// In en, this message translates to:
  /// **'Suggested plan for today'**
  String get suggestedPlanToday;

  /// No description provided for @continueMemorizing.
  ///
  /// In en, this message translates to:
  /// **'Continue memorizing'**
  String get continueMemorizing;

  /// No description provided for @preparingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Preparing today\'s dashboard...'**
  String get preparingDashboard;

  /// No description provided for @dailyGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'Memorize {count} ayahs from {surah}'**
  String dailyGoalDescription(int count, String surah);

  /// No description provided for @ayahsFraction.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {target} ayahs'**
  String ayahsFraction(int completed, int target);

  /// No description provided for @ayahUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs'**
  String ayahUnit(int count);

  /// No description provided for @lastReview.
  ///
  /// In en, this message translates to:
  /// **'Last review: {context}'**
  String lastReview(String context);

  /// No description provided for @reviewDueToday.
  ///
  /// In en, this message translates to:
  /// **'You have {count} reviews due today to keep your mastery'**
  String reviewDueToday(int count);

  /// No description provided for @overdueShort.
  ///
  /// In en, this message translates to:
  /// **'Overdue {count}'**
  String overdueShort(int count);

  /// No description provided for @streakConsecutiveDays.
  ///
  /// In en, this message translates to:
  /// **'{count} consecutive days'**
  String streakConsecutiveDays(int count);

  /// No description provided for @milestoneProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {next} ayahs to next milestone'**
  String milestoneProgress(int current, int next);

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// No description provided for @surahTab.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahTab;

  /// No description provided for @juzTab.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juzTab;

  /// No description provided for @searchQuranHint.
  ///
  /// In en, this message translates to:
  /// **'Search by surah name, number, or juz'**
  String get searchQuranHint;

  /// No description provided for @lastRead.
  ///
  /// In en, this message translates to:
  /// **'Last read'**
  String get lastRead;

  /// No description provided for @bookmarksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bookmarks'**
  String bookmarksCount(int count);

  /// No description provided for @backToSearch.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get backToSearch;

  /// No description provided for @enterFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Reading mode'**
  String get enterFocusMode;

  /// No description provided for @exitFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Exit reading mode'**
  String get exitFocusMode;

  /// No description provided for @focusFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get focusFontSize;

  /// No description provided for @focusLineSpacing.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get focusLineSpacing;

  /// No description provided for @sepiaMode.
  ///
  /// In en, this message translates to:
  /// **'Sepia mode'**
  String get sepiaMode;

  /// No description provided for @resetReadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset reading settings'**
  String get resetReadingSettings;

  /// No description provided for @applyReadingSettingsToAllSurahs.
  ///
  /// In en, this message translates to:
  /// **'Apply settings to all surahs'**
  String get applyReadingSettingsToAllSurahs;

  /// No description provided for @appliedReadingSettingsToAllSurahs.
  ///
  /// In en, this message translates to:
  /// **'Reading settings applied to all surahs'**
  String get appliedReadingSettingsToAllSurahs;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get noBookmarks;

  /// No description provided for @noBookmarksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any ayah to add it as a bookmark'**
  String get noBookmarksSubtitle;

  /// No description provided for @ayah.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get ayah;

  /// No description provided for @ayahs.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get ayahs;

  /// No description provided for @verses.
  ///
  /// In en, this message translates to:
  /// **'Verses'**
  String get verses;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @surah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surah;

  /// No description provided for @meccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get medinan;

  /// No description provided for @loadingQuran.
  ///
  /// In en, this message translates to:
  /// **'Loading surahs and juz...'**
  String get loadingQuran;

  /// No description provided for @searchSurahOrJuzHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a surah or juz...'**
  String get searchSurahOrJuzHint;

  /// No description provided for @noMatchingResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get noMatchingResults;

  /// No description provided for @noMatchingResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search terms or filter.'**
  String get noMatchingResultsSubtitle;

  /// No description provided for @noMatchingJuzSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No juz match the current filter.'**
  String get noMatchingJuzSubtitle;

  /// No description provided for @viewAllBookmarks.
  ///
  /// In en, this message translates to:
  /// **'View all bookmarks'**
  String get viewAllBookmarks;

  /// No description provided for @viewAllBookmarksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved ayahs, surahs, and last positions'**
  String get viewAllBookmarksSubtitle;

  /// No description provided for @searchQuranTitle.
  ///
  /// In en, this message translates to:
  /// **'Search the Quran'**
  String get searchQuranTitle;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @noSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'No search history yet'**
  String get noSearchHistory;

  /// No description provided for @noSearchHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start searching for a surah or juz and it will appear here.'**
  String get noSearchHistorySubtitle;

  /// No description provided for @surahResults.
  ///
  /// In en, this message translates to:
  /// **'Surah results'**
  String get surahResults;

  /// No description provided for @ayahResults.
  ///
  /// In en, this message translates to:
  /// **'Ayah results'**
  String get ayahResults;

  /// No description provided for @noResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different word or surah number.'**
  String get noResultsSubtitle;

  /// No description provided for @noAyahResults.
  ///
  /// In en, this message translates to:
  /// **'No ayah results'**
  String get noAyahResults;

  /// No description provided for @noAyahResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a more specific keyword or ayah fragment.'**
  String get noAyahResultsSubtitle;

  /// No description provided for @juzResults.
  ///
  /// In en, this message translates to:
  /// **'Juz results'**
  String get juzResults;

  /// No description provided for @noJuzResults.
  ///
  /// In en, this message translates to:
  /// **'No juz results'**
  String get noJuzResults;

  /// No description provided for @noJuzResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Juz results appear when the query matches.'**
  String get noJuzResultsSubtitle;

  /// No description provided for @searchApiReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for API search'**
  String get searchApiReady;

  /// No description provided for @searchApiReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'The search UI is built to connect to a backend later.'**
  String get searchApiReadySubtitle;

  /// No description provided for @juzNumber.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juzNumber(int number);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @statusMemorized.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get statusMemorized;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get statusReview;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterReview.
  ///
  /// In en, this message translates to:
  /// **'For review'**
  String get filterReview;

  /// No description provided for @surahNamed.
  ///
  /// In en, this message translates to:
  /// **'Surah {name}'**
  String surahNamed(String name);

  /// No description provided for @startMemorizing.
  ///
  /// In en, this message translates to:
  /// **'Start memorizing'**
  String get startMemorizing;

  /// No description provided for @memorizationSegments.
  ///
  /// In en, this message translates to:
  /// **'Memorization segments'**
  String get memorizationSegments;

  /// No description provided for @progressPercent.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String progressPercent(int percent);

  /// No description provided for @rangeAyahs.
  ///
  /// In en, this message translates to:
  /// **'Ayah {from} – {to}'**
  String rangeAyahs(int from, int to);

  /// No description provided for @surahAyahs.
  ///
  /// In en, this message translates to:
  /// **'Surah ayahs'**
  String get surahAyahs;

  /// No description provided for @versesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load ayahs'**
  String get versesLoadError;

  /// No description provided for @versesLoadErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try opening the surah again.'**
  String get versesLoadErrorSubtitle;

  /// No description provided for @chooseReciterBelow.
  ///
  /// In en, this message translates to:
  /// **'Choose a reciter from the audio section below.'**
  String get chooseReciterBelow;

  /// No description provided for @cannotPlayAyah.
  ///
  /// In en, this message translates to:
  /// **'Could not play this ayah'**
  String get cannotPlayAyah;

  /// No description provided for @reciterVoices.
  ///
  /// In en, this message translates to:
  /// **'Reciter voices'**
  String get reciterVoices;

  /// No description provided for @recitersSource.
  ///
  /// In en, this message translates to:
  /// **'Curated list from mp3quran.net'**
  String get recitersSource;

  /// No description provided for @recitersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the reciters list.'**
  String get recitersLoadError;

  /// No description provided for @chooseReciter.
  ///
  /// In en, this message translates to:
  /// **'Choose a reciter'**
  String get chooseReciter;

  /// No description provided for @reciterCountTapToSearch.
  ///
  /// In en, this message translates to:
  /// **'{count} reciters • tap to search'**
  String reciterCountTapToSearch(int count);

  /// No description provided for @ayahNumbered.
  ///
  /// In en, this message translates to:
  /// **'Ayah {number}'**
  String ayahNumbered(int number);

  /// No description provided for @ayahNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayah number'**
  String get ayahNumberLabel;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @checkReciterAvailability.
  ///
  /// In en, this message translates to:
  /// **'Check reciter availability'**
  String get checkReciterAvailability;

  /// No description provided for @notChecked.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get notChecked;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available ✓'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable ✗'**
  String get unavailable;

  /// No description provided for @stopAudio.
  ///
  /// In en, this message translates to:
  /// **'Stop audio'**
  String get stopAudio;

  /// No description provided for @playSelectedAyah.
  ///
  /// In en, this message translates to:
  /// **'Play selected ayah'**
  String get playSelectedAyah;

  /// No description provided for @waitOrChooseReciter.
  ///
  /// In en, this message translates to:
  /// **'Wait for reciters to load or choose a reciter.'**
  String get waitOrChooseReciter;

  /// No description provided for @cannotPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Could not play audio right now'**
  String get cannotPlayAudio;

  /// No description provided for @searchReciterHint.
  ///
  /// In en, this message translates to:
  /// **'Search by reciter name…'**
  String get searchReciterHint;

  /// No description provided for @ayahByAyah.
  ///
  /// In en, this message translates to:
  /// **'Ayah by ayah'**
  String get ayahByAyah;

  /// No description provided for @fullSurahFile.
  ///
  /// In en, this message translates to:
  /// **'Full surah file'**
  String get fullSurahFile;

  /// No description provided for @tafsirLinks.
  ///
  /// In en, this message translates to:
  /// **'Tafsir links'**
  String get tafsirLinks;

  /// No description provided for @tafsirWithTranslation.
  ///
  /// In en, this message translates to:
  /// **'Ayah tafsir with translation'**
  String get tafsirWithTranslation;

  /// No description provided for @classicTafsirLibrary.
  ///
  /// In en, this message translates to:
  /// **'Classic tafsir library'**
  String get classicTafsirLibrary;

  /// No description provided for @tafsirAndTranslation.
  ///
  /// In en, this message translates to:
  /// **'Tafsir & translation'**
  String get tafsirAndTranslation;

  /// No description provided for @tafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get tafsir;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @tafsirSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Tafsir source'**
  String get tafsirSourceLabel;

  /// No description provided for @fromN.
  ///
  /// In en, this message translates to:
  /// **'From {n}'**
  String fromN(int n);

  /// No description provided for @toN.
  ///
  /// In en, this message translates to:
  /// **'To {n}'**
  String toN(int n);

  /// No description provided for @rangeStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get rangeStart;

  /// No description provided for @rangeEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get rangeEnd;

  /// No description provided for @noTafsir.
  ///
  /// In en, this message translates to:
  /// **'No tafsir'**
  String get noTafsir;

  /// No description provided for @noTafsirSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a range then tap refresh.'**
  String get noTafsirSubtitle;

  /// No description provided for @noTranslation.
  ///
  /// In en, this message translates to:
  /// **'No translation'**
  String get noTranslation;

  /// No description provided for @noTranslationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap refresh to fetch the translation.'**
  String get noTranslationSubtitle;

  /// No description provided for @translationLine.
  ///
  /// In en, this message translates to:
  /// **'Ayah {number}: {text}'**
  String translationLine(int number, String text);

  /// No description provided for @translationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Translation language'**
  String get translationLanguage;

  /// No description provided for @refreshTafsir.
  ///
  /// In en, this message translates to:
  /// **'Refresh tafsir'**
  String get refreshTafsir;

  /// No description provided for @refreshTranslation.
  ///
  /// In en, this message translates to:
  /// **'Refresh translation'**
  String get refreshTranslation;

  /// No description provided for @savedSurahs.
  ///
  /// In en, this message translates to:
  /// **'Saved surahs'**
  String get savedSurahs;

  /// No description provided for @savedAyahs.
  ///
  /// In en, this message translates to:
  /// **'Saved ayahs'**
  String get savedAyahs;

  /// No description provided for @lastPositions.
  ///
  /// In en, this message translates to:
  /// **'Last memorization positions'**
  String get lastPositions;

  /// No description provided for @savedToBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Saved to bookmarks'**
  String get savedToBookmarks;

  /// No description provided for @surahNumber.
  ///
  /// In en, this message translates to:
  /// **'Surah no. {id}'**
  String surahNumber(int id);

  /// No description provided for @fromAyahToAyah.
  ///
  /// In en, this message translates to:
  /// **'From ayah {from} to {to}'**
  String fromAyahToAyah(int from, int to);

  /// No description provided for @memorizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Memorization'**
  String get memorizationTitle;

  /// No description provided for @memorizationSetup.
  ///
  /// In en, this message translates to:
  /// **'Session setup'**
  String get memorizationSetup;

  /// No description provided for @chooseSurah.
  ///
  /// In en, this message translates to:
  /// **'Choose surah'**
  String get chooseSurah;

  /// No description provided for @ayahRange.
  ///
  /// In en, this message translates to:
  /// **'Ayah range'**
  String get ayahRange;

  /// No description provided for @fromAyah.
  ///
  /// In en, this message translates to:
  /// **'From ayah'**
  String get fromAyah;

  /// No description provided for @toAyah.
  ///
  /// In en, this message translates to:
  /// **'To ayah'**
  String get toAyah;

  /// No description provided for @ayahCount.
  ///
  /// In en, this message translates to:
  /// **'Ayah count: {count}'**
  String ayahCount(int count);

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start memorization session'**
  String get startSession;

  /// No description provided for @audioControls.
  ///
  /// In en, this message translates to:
  /// **'Audio controls'**
  String get audioControls;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get playbackSpeed;

  /// No description provided for @repeatAyah.
  ///
  /// In en, this message translates to:
  /// **'Repeat ayah'**
  String get repeatAyah;

  /// No description provided for @markMemorized.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get markMemorized;

  /// No description provided for @memorizedDone.
  ///
  /// In en, this message translates to:
  /// **'Memorized ✓'**
  String get memorizedDone;

  /// No description provided for @markDifficult.
  ///
  /// In en, this message translates to:
  /// **'Mark as difficult'**
  String get markDifficult;

  /// No description provided for @markedDifficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult ⚑'**
  String get markedDifficult;

  /// No description provided for @showText.
  ///
  /// In en, this message translates to:
  /// **'Show text'**
  String get showText;

  /// No description provided for @hideText.
  ///
  /// In en, this message translates to:
  /// **'Hide text'**
  String get hideText;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal ayah'**
  String get tapToReveal;

  /// No description provided for @preparingSession.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparingSession;

  /// No description provided for @loadingAyahs.
  ///
  /// In en, this message translates to:
  /// **'Loading ayahs...'**
  String get loadingAyahs;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @noReviewItems.
  ///
  /// In en, this message translates to:
  /// **'No items to review'**
  String get noReviewItems;

  /// No description provided for @noReviewItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start memorizing ayahs to see them here in your review queue.'**
  String get noReviewItemsSubtitle;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @markReviewed.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get markReviewed;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @difficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get difficult;

  /// No description provided for @difficultQuestion.
  ///
  /// In en, this message translates to:
  /// **'Difficult?'**
  String get difficultQuestion;

  /// No description provided for @showAyahs.
  ///
  /// In en, this message translates to:
  /// **'Show ayahs'**
  String get showAyahs;

  /// No description provided for @hideAyahs.
  ///
  /// In en, this message translates to:
  /// **'Hide ayahs'**
  String get hideAyahs;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get highPriority;

  /// No description provided for @mediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium priority'**
  String get mediumPriority;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low priority'**
  String get lowPriority;

  /// No description provided for @tasmee3Title.
  ///
  /// In en, this message translates to:
  /// **'Self-test'**
  String get tasmee3Title;

  /// No description provided for @tasmee3Setup.
  ///
  /// In en, this message translates to:
  /// **'Test session setup'**
  String get tasmee3Setup;

  /// No description provided for @tasmee3Description.
  ///
  /// In en, this message translates to:
  /// **'Choose a surah and range, then test your memorization ayah by ayah'**
  String get tasmee3Description;

  /// No description provided for @speechRecitePrompt.
  ///
  /// In en, this message translates to:
  /// **'Recite the ayah by voice, mistakes will be highlighted in red'**
  String get speechRecitePrompt;

  /// No description provided for @startVoiceRecitation.
  ///
  /// In en, this message translates to:
  /// **'Start voice recitation'**
  String get startVoiceRecitation;

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get stopListening;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice recitation'**
  String get microphonePermissionRequired;

  /// No description provided for @speechError.
  ///
  /// In en, this message translates to:
  /// **'Could not recognize speech, please try again'**
  String get speechError;

  /// No description provided for @speechNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available on this device/simulator'**
  String get speechNotAvailable;

  /// No description provided for @speechTimeout.
  ///
  /// In en, this message translates to:
  /// **'Listening timed out, tap to try again'**
  String get speechTimeout;

  /// No description provided for @recordForReview.
  ///
  /// In en, this message translates to:
  /// **'Record your voice to listen'**
  String get recordForReview;

  /// No description provided for @stopRecordForReview.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecordForReview;

  /// No description provided for @playAudioTest.
  ///
  /// In en, this message translates to:
  /// **'Play audio test'**
  String get playAudioTest;

  /// No description provided for @stopAudioTest.
  ///
  /// In en, this message translates to:
  /// **'Stop audio test'**
  String get stopAudioTest;

  /// No description provided for @audioTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play test audio, check internet and volume'**
  String get audioTestFailed;

  /// No description provided for @autoGradingHint.
  ///
  /// In en, this message translates to:
  /// **'After recitation ends, your ayah is graded automatically and the next ayah starts'**
  String get autoGradingHint;

  /// No description provided for @autoGradingActive.
  ///
  /// In en, this message translates to:
  /// **'Auto grading is active based on your voice recitation'**
  String get autoGradingActive;

  /// No description provided for @voiceAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Matching accuracy: {percent}%'**
  String voiceAccuracy(int percent);

  /// No description provided for @playMyRecording.
  ///
  /// In en, this message translates to:
  /// **'Play my recording'**
  String get playMyRecording;

  /// No description provided for @stopMyRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop my recording'**
  String get stopMyRecording;

  /// No description provided for @listenReciterAyah.
  ///
  /// In en, this message translates to:
  /// **'Listen to reciter'**
  String get listenReciterAyah;

  /// No description provided for @stopReciterAyah.
  ///
  /// In en, this message translates to:
  /// **'Stop reciter'**
  String get stopReciterAyah;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get startTest;

  /// No description provided for @testProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get testProgress;

  /// No description provided for @revealAyah.
  ///
  /// In en, this message translates to:
  /// **'Reveal ayah'**
  String get revealAyah;

  /// No description provided for @hiddenAyah.
  ///
  /// In en, this message translates to:
  /// **'Ayah hidden — do you know it?'**
  String get hiddenAyah;

  /// No description provided for @iKnowIt.
  ///
  /// In en, this message translates to:
  /// **'I know it'**
  String get iKnowIt;

  /// No description provided for @iHesitated.
  ///
  /// In en, this message translates to:
  /// **'I hesitated'**
  String get iHesitated;

  /// No description provided for @iForgot.
  ///
  /// In en, this message translates to:
  /// **'I forgot'**
  String get iForgot;

  /// No description provided for @testSummary.
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get testSummary;

  /// No description provided for @testScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get testScore;

  /// No description provided for @ayahsToReview.
  ///
  /// In en, this message translates to:
  /// **'Ayahs to review'**
  String get ayahsToReview;

  /// No description provided for @retakeTest.
  ///
  /// In en, this message translates to:
  /// **'Retake test'**
  String get retakeTest;

  /// No description provided for @backToSetup.
  ///
  /// In en, this message translates to:
  /// **'New setup'**
  String get backToSetup;

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get sessionHistory;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistory;

  /// No description provided for @noHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Previous test session results will appear here'**
  String get noHistorySubtitle;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @needsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get needsWork;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session details'**
  String get sessionDetails;

  /// No description provided for @knownAyahs.
  ///
  /// In en, this message translates to:
  /// **'Known ayahs'**
  String get knownAyahs;

  /// No description provided for @hesitantAyahs.
  ///
  /// In en, this message translates to:
  /// **'Hesitated'**
  String get hesitantAyahs;

  /// No description provided for @unknownAyahs.
  ///
  /// In en, this message translates to:
  /// **'Forgotten'**
  String get unknownAyahs;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String scoreLabel(int score);

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @loadingAchievements.
  ///
  /// In en, this message translates to:
  /// **'Loading achievements...'**
  String get loadingAchievements;

  /// No description provided for @earnedBadges.
  ///
  /// In en, this message translates to:
  /// **'Earned badges'**
  String get earnedBadges;

  /// No description provided for @upcomingGoals.
  ///
  /// In en, this message translates to:
  /// **'Upcoming goals'**
  String get upcomingGoals;

  /// No description provided for @noAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get noAchievements;

  /// No description provided for @noAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start memorizing and reviewing to earn your first badge.'**
  String get noAchievementsSubtitle;

  /// No description provided for @overallProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get overallProgressLabel;

  /// No description provided for @badgesProgress.
  ///
  /// In en, this message translates to:
  /// **'{earned} / {total} badges'**
  String badgesProgress(int earned, int total);

  /// No description provided for @allBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'All badges earned! 🎉'**
  String get allBadgesEarned;

  /// No description provided for @remainingBadges.
  ///
  /// In en, this message translates to:
  /// **'{count} badges remaining'**
  String remainingBadges(int count);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @memorizedAyahsCount.
  ///
  /// In en, this message translates to:
  /// **'ayahs memorized'**
  String get memorizedAyahsCount;

  /// No description provided for @reviewSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'review sessions'**
  String get reviewSessionsCount;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get streakLabel;

  /// No description provided for @yourBadges.
  ///
  /// In en, this message translates to:
  /// **'Your badges'**
  String get yourBadges;

  /// No description provided for @noBadges.
  ///
  /// In en, this message translates to:
  /// **'No badges yet'**
  String get noBadges;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @signOutConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, sign out'**
  String get signOutConfirmYes;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @searchFocusModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading mode from search'**
  String get searchFocusModeTitle;

  /// No description provided for @searchFocusModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open ayah search results directly in focused reading mode'**
  String get searchFocusModeSubtitle;

  /// No description provided for @unifiedReadingPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unified reading settings'**
  String get unifiedReadingPrefsTitle;

  /// No description provided for @unifiedReadingPrefsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use one reading profile for all surahs instead of per-surah settings'**
  String get unifiedReadingPrefsSubtitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @themeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeModeTitle;

  /// No description provided for @themeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose light, dark, or follow the system'**
  String get themeModeSubtitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageSubtitle;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @fontSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust app font scaling'**
  String get fontSizeSubtitle;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily memorization reminder at 8:00 AM'**
  String get remindersSubtitle;

  /// No description provided for @remindersDescription.
  ///
  /// In en, this message translates to:
  /// **'When enabled, a daily notification is sent at 8:00 AM to remind you of your memorization.'**
  String get remindersDescription;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage app alerts and daily reminders'**
  String get notificationsSubtitle;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can enable/disable notifications and choose your daily reminder time.'**
  String get notificationsDescription;

  /// No description provided for @notificationsTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder time'**
  String get notificationsTimeTitle;

  /// No description provided for @notificationsTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current time: {time}'**
  String notificationsTimeSubtitle(String time);

  /// No description provided for @notificationsTimeHint.
  ///
  /// In en, this message translates to:
  /// **'A reminder will be sent daily at {hour}:{minute}'**
  String notificationsTimeHint(String hour, String minute);

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent'**
  String get resetLinkSent;

  /// No description provided for @orContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Or continue with email'**
  String get orContinueWithEmail;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get startNow;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'A smart, organized memorization journey'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'A flexible daily plan that fits your time and builds strong consistency.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Gradual review without pressure'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'A review system that helps you retain memorization for the long term.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Motivating recitation sessions'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Track your performance and progress with visual feedback that boosts motivation.'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Every achievement counts'**
  String get onboardingTitle4;

  /// No description provided for @onboardingSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'An elegant progress dashboard that reflects your journey step by step.'**
  String get onboardingSubtitle4;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @profileLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved on this device — no account needed'**
  String get profileLocalSubtitle;

  /// No description provided for @signInForFullFeatures.
  ///
  /// In en, this message translates to:
  /// **'Sign in to unlock all features'**
  String get signInForFullFeatures;

  /// No description provided for @currentGoals.
  ///
  /// In en, this message translates to:
  /// **'Current goals'**
  String get currentGoals;

  /// No description provided for @goalDone.
  ///
  /// In en, this message translates to:
  /// **'Done! 🎉'**
  String get goalDone;

  /// No description provided for @memorizeGoal.
  ///
  /// In en, this message translates to:
  /// **'Memorize {count} ayahs'**
  String memorizeGoal(int count);

  /// No description provided for @reviewSessionsGoal.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} review sessions'**
  String reviewSessionsGoal(int count);

  /// No description provided for @remainingSessions.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions remaining'**
  String remainingSessions(int count);

  /// No description provided for @ayahProgress.
  ///
  /// In en, this message translates to:
  /// **'Ayah {current} / {total}'**
  String ayahProgress(int current, int total);

  /// No description provided for @ayahBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Ayah breakdown'**
  String get ayahBreakdown;

  /// No description provided for @bubbleKnown.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get bubbleKnown;

  /// No description provided for @bubbleHesitant.
  ///
  /// In en, this message translates to:
  /// **'Stumbled'**
  String get bubbleHesitant;

  /// No description provided for @bubbleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get bubbleUnknown;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
