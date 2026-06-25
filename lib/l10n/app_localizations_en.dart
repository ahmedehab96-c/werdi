// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Werdi';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get noData => 'No data available';

  @override
  String get authWelcomeTitle => 'Welcome to Werdi';

  @override
  String get authWelcomeSubtitle =>
      'Sign in or create an account to start your memorization journey';

  @override
  String get loginTab => 'Login';

  @override
  String get registerTab => 'Register';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get nameLabel => 'Name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a reset link';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get loginError => 'Incorrect email or password';

  @override
  String get registerError => 'Could not create account, please try again';

  @override
  String homeGreeting(String name) {
    return 'Assalamu Alaikum, $name';
  }

  @override
  String get homeSubtitle =>
      'Today is a new chance to strengthen your memorization';

  @override
  String get quickActionsTitle => 'Quick actions';

  @override
  String get memorizeNow => 'Memorize now';

  @override
  String get memorizeSubtitle => 'Today\'s plan';

  @override
  String get reviewAction => 'Review';

  @override
  String get reviewSubtitle => 'Previous lesson';

  @override
  String get testYourself => 'Test yourself';

  @override
  String get testSubtitle => 'Listening session';

  @override
  String get openQuran => 'Open Quran';

  @override
  String get openQuranSubtitle => 'Surahs & Juz';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String ayahsRemaining(int count) {
    return '$count ayahs remaining';
  }

  @override
  String ayahsCompleted(int count) {
    return '$count ayahs completed';
  }

  @override
  String get overallProgress => 'Overall progress';

  @override
  String get currentSurah => 'Current surah';

  @override
  String get continueMemorization => 'Continue memorizing';

  @override
  String get reviewReminder => 'Review reminder';

  @override
  String reviewDue(int count) {
    return '$count reviews due';
  }

  @override
  String overdueReviews(int count) {
    return '$count overdue';
  }

  @override
  String get startReview => 'Start review';

  @override
  String get weeklyInsights => 'Weekly insights';

  @override
  String memorizedAyahs(int count) {
    return '$count ayahs memorized';
  }

  @override
  String reviewedAyahs(int count) {
    return '$count ayahs reviewed';
  }

  @override
  String sessions(int count) {
    return '$count sessions';
  }

  @override
  String streakDays(int count) {
    return '$count day streak';
  }

  @override
  String get yourAchievements => 'Your achievements';

  @override
  String get viewAll => 'View all';

  @override
  String get recommendedPlan => 'Recommended next step';

  @override
  String get progressOverview => 'Progress overview';

  @override
  String get total => 'Total';

  @override
  String get thisWeek => 'This week';

  @override
  String get continueJourney => 'Continue your journey';

  @override
  String get resumeFromLastPosition => 'Resume from last position';

  @override
  String get dailyMotivation => 'Daily motivation';

  @override
  String get motivationFooter =>
      'Keep going — every page you memorize brings you closer to your goal.';

  @override
  String get streakTitle => 'Streak';

  @override
  String get achievementsPreview => 'Achievements preview';

  @override
  String get memorizeLabel => 'Memorize';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get suggestedPlanToday => 'Suggested plan for today';

  @override
  String get continueMemorizing => 'Continue memorizing';

  @override
  String get preparingDashboard => 'Preparing today\'s dashboard...';

  @override
  String dailyGoalDescription(int count, String surah) {
    return 'Memorize $count ayahs from $surah';
  }

  @override
  String ayahsFraction(int completed, int target) {
    return '$completed / $target ayahs';
  }

  @override
  String ayahUnit(int count) {
    return '$count ayahs';
  }

  @override
  String lastReview(String context) {
    return 'Last review: $context';
  }

  @override
  String reviewDueToday(int count) {
    return 'You have $count reviews due today to keep your mastery';
  }

  @override
  String overdueShort(int count) {
    return 'Overdue $count';
  }

  @override
  String streakConsecutiveDays(int count) {
    return '$count consecutive days';
  }

  @override
  String milestoneProgress(int current, int next) {
    return '$current / $next ayahs to next milestone';
  }

  @override
  String get quranTitle => 'Quran';

  @override
  String get surahTab => 'Surahs';

  @override
  String get juzTab => 'Juz';

  @override
  String get searchQuranHint => 'Search by surah name, number, or juz';

  @override
  String get lastRead => 'Last read';

  @override
  String bookmarksCount(int count) {
    return '$count bookmarks';
  }

  @override
  String get backToSearch => 'Search results';

  @override
  String get enterFocusMode => 'Reading mode';

  @override
  String get exitFocusMode => 'Exit reading mode';

  @override
  String get focusFontSize => 'Font size';

  @override
  String get focusLineSpacing => 'Line spacing';

  @override
  String get sepiaMode => 'Sepia mode';

  @override
  String get resetReadingSettings => 'Reset reading settings';

  @override
  String get applyReadingSettingsToAllSurahs => 'Apply settings to all surahs';

  @override
  String get appliedReadingSettingsToAllSurahs =>
      'Reading settings applied to all surahs';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get noBookmarks => 'No bookmarks yet';

  @override
  String get noBookmarksSubtitle => 'Tap any ayah to add it as a bookmark';

  @override
  String get ayah => 'Ayah';

  @override
  String get ayahs => 'Ayahs';

  @override
  String get verses => 'Verses';

  @override
  String get juz => 'Juz';

  @override
  String get surah => 'Surah';

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String get loadingQuran => 'Loading surahs and juz...';

  @override
  String get searchSurahOrJuzHint => 'Search for a surah or juz...';

  @override
  String get noMatchingResults => 'No matching results';

  @override
  String get noMatchingResultsSubtitle =>
      'Try changing your search terms or filter.';

  @override
  String get noMatchingJuzSubtitle => 'No juz match the current filter.';

  @override
  String get viewAllBookmarks => 'View all bookmarks';

  @override
  String get viewAllBookmarksSubtitle =>
      'Saved ayahs, surahs, and last positions';

  @override
  String get searchQuranTitle => 'Search the Quran';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get noSearchHistory => 'No search history yet';

  @override
  String get noSearchHistorySubtitle =>
      'Start searching for a surah or juz and it will appear here.';

  @override
  String get surahResults => 'Surah results';

  @override
  String get ayahResults => 'Ayah results';

  @override
  String get noResultsSubtitle => 'Try a different word or surah number.';

  @override
  String get noAyahResults => 'No ayah results';

  @override
  String get noAyahResultsSubtitle =>
      'Try a more specific keyword or ayah fragment.';

  @override
  String get juzResults => 'Juz results';

  @override
  String get noJuzResults => 'No juz results';

  @override
  String get noJuzResultsSubtitle =>
      'Juz results appear when the query matches.';

  @override
  String get searchApiReady => 'Ready for API search';

  @override
  String get searchApiReadySubtitle =>
      'The search UI is built to connect to a backend later.';

  @override
  String juzNumber(int number) {
    return 'Juz $number';
  }

  @override
  String get open => 'Open';

  @override
  String get statusMemorized => 'Memorized';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusReview => 'Review';

  @override
  String get filterAll => 'All';

  @override
  String get filterReview => 'For review';

  @override
  String surahNamed(String name) {
    return 'Surah $name';
  }

  @override
  String get startMemorizing => 'Start memorizing';

  @override
  String get memorizationSegments => 'Memorization segments';

  @override
  String progressPercent(int percent) {
    return 'Progress: $percent%';
  }

  @override
  String rangeAyahs(int from, int to) {
    return 'Ayah $from – $to';
  }

  @override
  String get surahAyahs => 'Surah ayahs';

  @override
  String get versesLoadError => 'Could not load ayahs';

  @override
  String get versesLoadErrorSubtitle => 'Try opening the surah again.';

  @override
  String get chooseReciterBelow =>
      'Choose a reciter from the audio section below.';

  @override
  String get cannotPlayAyah => 'Could not play this ayah';

  @override
  String get reciterVoices => 'Reciter voices';

  @override
  String get recitersSource => 'Curated list from mp3quran.net';

  @override
  String get recitersLoadError => 'Could not load the reciters list.';

  @override
  String get chooseReciter => 'Choose a reciter';

  @override
  String reciterCountTapToSearch(int count) {
    return '$count reciters • tap to search';
  }

  @override
  String ayahNumbered(int number) {
    return 'Ayah $number';
  }

  @override
  String get ayahNumberLabel => 'Ayah number';

  @override
  String get checking => 'Checking...';

  @override
  String get checkReciterAvailability => 'Check reciter availability';

  @override
  String get notChecked => 'Not checked';

  @override
  String get available => 'Available ✓';

  @override
  String get unavailable => 'Unavailable ✗';

  @override
  String get stopAudio => 'Stop audio';

  @override
  String get playSelectedAyah => 'Play selected ayah';

  @override
  String get waitOrChooseReciter =>
      'Wait for reciters to load or choose a reciter.';

  @override
  String get cannotPlayAudio => 'Could not play audio right now';

  @override
  String get searchReciterHint => 'Search by reciter name…';

  @override
  String get ayahByAyah => 'Ayah by ayah';

  @override
  String get fullSurahFile => 'Full surah file';

  @override
  String get tafsirLinks => 'Tafsir links';

  @override
  String get tafsirWithTranslation => 'Ayah tafsir with translation';

  @override
  String get classicTafsirLibrary => 'Classic tafsir library';

  @override
  String get tafsirAndTranslation => 'Tafsir & translation';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get translation => 'Translation';

  @override
  String get tafsirSourceLabel => 'Tafsir source';

  @override
  String fromN(int n) {
    return 'From $n';
  }

  @override
  String toN(int n) {
    return 'To $n';
  }

  @override
  String get rangeStart => 'Start';

  @override
  String get rangeEnd => 'End';

  @override
  String get noTafsir => 'No tafsir';

  @override
  String get noTafsirSubtitle => 'Choose a range then tap refresh.';

  @override
  String get noTranslation => 'No translation';

  @override
  String get noTranslationSubtitle => 'Tap refresh to fetch the translation.';

  @override
  String translationLine(int number, String text) {
    return 'Ayah $number: $text';
  }

  @override
  String get translationLanguage => 'Translation language';

  @override
  String get refreshTafsir => 'Refresh tafsir';

  @override
  String get refreshTranslation => 'Refresh translation';

  @override
  String get savedSurahs => 'Saved surahs';

  @override
  String get savedAyahs => 'Saved ayahs';

  @override
  String get lastPositions => 'Last memorization positions';

  @override
  String get savedToBookmarks => 'Saved to bookmarks';

  @override
  String surahNumber(int id) {
    return 'Surah no. $id';
  }

  @override
  String fromAyahToAyah(int from, int to) {
    return 'From ayah $from to $to';
  }

  @override
  String get memorizationTitle => 'Memorization';

  @override
  String get memorizationSetup => 'Session setup';

  @override
  String get chooseSurah => 'Choose surah';

  @override
  String get ayahRange => 'Ayah range';

  @override
  String get fromAyah => 'From ayah';

  @override
  String get toAyah => 'To ayah';

  @override
  String ayahCount(int count) {
    return 'Ayah count: $count';
  }

  @override
  String get startSession => 'Start memorization session';

  @override
  String get audioControls => 'Audio controls';

  @override
  String get playbackSpeed => 'Speed';

  @override
  String get repeatAyah => 'Repeat ayah';

  @override
  String get markMemorized => 'Memorized';

  @override
  String get memorizedDone => 'Memorized ✓';

  @override
  String get markDifficult => 'Mark as difficult';

  @override
  String get markedDifficult => 'Difficult ⚑';

  @override
  String get showText => 'Show text';

  @override
  String get hideText => 'Hide text';

  @override
  String get tapToReveal => 'Tap to reveal ayah';

  @override
  String get preparingSession => 'Preparing...';

  @override
  String get loadingAyahs => 'Loading ayahs...';

  @override
  String get reviewTitle => 'Review';

  @override
  String get noReviewItems => 'No items to review';

  @override
  String get noReviewItemsSubtitle =>
      'Start memorizing ayahs to see them here in your review queue.';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get markReviewed => 'Review';

  @override
  String get repeat => 'Repeat';

  @override
  String get difficult => 'Difficult';

  @override
  String get difficultQuestion => 'Difficult?';

  @override
  String get showAyahs => 'Show ayahs';

  @override
  String get hideAyahs => 'Hide ayahs';

  @override
  String get highPriority => 'High priority';

  @override
  String get mediumPriority => 'Medium priority';

  @override
  String get lowPriority => 'Low priority';

  @override
  String get tasmee3Title => 'Self-test';

  @override
  String get tasmee3Setup => 'Test session setup';

  @override
  String get tasmee3Description =>
      'Choose a surah and range, then test your memorization ayah by ayah';

  @override
  String get speechRecitePrompt =>
      'Recite the ayah by voice, mistakes will be highlighted in red';

  @override
  String get startVoiceRecitation => 'Start voice recitation';

  @override
  String get stopListening => 'Stop listening';

  @override
  String get microphonePermissionRequired =>
      'Microphone permission is required for voice recitation';

  @override
  String get speechError => 'Could not recognize speech, please try again';

  @override
  String get speechNotAvailable =>
      'Speech recognition is not available on this device/simulator';

  @override
  String get playAudioTest => 'Play audio test';

  @override
  String get stopAudioTest => 'Stop audio test';

  @override
  String get audioTestFailed =>
      'Could not play test audio, check internet and volume';

  @override
  String get autoGradingHint =>
      'After recitation ends, your ayah is graded automatically and the next ayah starts';

  @override
  String get autoGradingActive =>
      'Auto grading is active based on your voice recitation';

  @override
  String voiceAccuracy(int percent) {
    return 'Matching accuracy: $percent%';
  }

  @override
  String get startTest => 'Start test';

  @override
  String get testProgress => 'Progress';

  @override
  String get revealAyah => 'Reveal ayah';

  @override
  String get hiddenAyah => 'Ayah hidden — do you know it?';

  @override
  String get iKnowIt => 'I know it';

  @override
  String get iHesitated => 'I hesitated';

  @override
  String get iForgot => 'I forgot';

  @override
  String get testSummary => 'Session summary';

  @override
  String get testScore => 'Score';

  @override
  String get ayahsToReview => 'Ayahs to review';

  @override
  String get retakeTest => 'Retake test';

  @override
  String get backToSetup => 'New setup';

  @override
  String get sessionHistory => 'Session history';

  @override
  String get noHistory => 'No history yet';

  @override
  String get noHistorySubtitle =>
      'Previous test session results will appear here';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get needsWork => 'Needs work';

  @override
  String get sessionDetails => 'Session details';

  @override
  String get knownAyahs => 'Known ayahs';

  @override
  String get hesitantAyahs => 'Hesitated';

  @override
  String get unknownAyahs => 'Forgotten';

  @override
  String scoreLabel(int score) {
    return 'Score: $score%';
  }

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get loadingAchievements => 'Loading achievements...';

  @override
  String get earnedBadges => 'Earned badges';

  @override
  String get upcomingGoals => 'Upcoming goals';

  @override
  String get noAchievements => 'No achievements yet';

  @override
  String get noAchievementsSubtitle =>
      'Start memorizing and reviewing to earn your first badge.';

  @override
  String get overallProgressLabel => 'Overall progress';

  @override
  String badgesProgress(int earned, int total) {
    return '$earned / $total badges';
  }

  @override
  String get allBadgesEarned => 'All badges earned! 🎉';

  @override
  String remainingBadges(int count) {
    return '$count badges remaining';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get memorizedAyahsCount => 'ayahs memorized';

  @override
  String get reviewSessionsCount => 'review sessions';

  @override
  String get streakLabel => 'day streak';

  @override
  String get yourBadges => 'Your badges';

  @override
  String get noBadges => 'No badges yet';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get signOutConfirmYes => 'Yes, sign out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get searchFocusModeTitle => 'Reading mode from search';

  @override
  String get searchFocusModeSubtitle =>
      'Open ayah search results directly in focused reading mode';

  @override
  String get unifiedReadingPrefsTitle => 'Unified reading settings';

  @override
  String get unifiedReadingPrefsSubtitle =>
      'Use one reading profile for all surahs instead of per-surah settings';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'Switch between light and dark theme';

  @override
  String get themeModeTitle => 'Appearance';

  @override
  String get themeModeSubtitle => 'Choose light, dark, or follow the system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'English';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSizeSubtitle => 'Adjust app font scaling';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersSubtitle => 'Daily memorization reminder at 8:00 AM';

  @override
  String get remindersDescription =>
      'When enabled, a daily notification is sent at 8:00 AM to remind you of your memorization.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Manage app alerts and daily reminders';

  @override
  String get notificationsDescription =>
      'You can enable/disable notifications and choose your daily reminder time.';

  @override
  String get notificationsTimeTitle => 'Daily reminder time';

  @override
  String notificationsTimeSubtitle(String time) {
    return 'Current time: $time';
  }

  @override
  String notificationsTimeHint(String hour, String minute) {
    return 'A reminder will be sent daily at $hour:$minute';
  }

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get resetLinkSent => 'Password reset link sent';

  @override
  String get orContinueWithEmail => 'Or continue with email';

  @override
  String get skip => 'Skip';

  @override
  String get startNow => 'Start now';

  @override
  String get next => 'Next';

  @override
  String get onboardingTitle1 => 'A smart, organized memorization journey';

  @override
  String get onboardingSubtitle1 =>
      'A flexible daily plan that fits your time and builds strong consistency.';

  @override
  String get onboardingTitle2 => 'Gradual review without pressure';

  @override
  String get onboardingSubtitle2 =>
      'A review system that helps you retain memorization for the long term.';

  @override
  String get onboardingTitle3 => 'Motivating recitation sessions';

  @override
  String get onboardingSubtitle3 =>
      'Track your performance and progress with visual feedback that boosts motivation.';

  @override
  String get onboardingTitle4 => 'Every achievement counts';

  @override
  String get onboardingSubtitle4 =>
      'An elegant progress dashboard that reflects your journey step by step.';

  @override
  String get guest => 'Guest';

  @override
  String get signInForFullFeatures => 'Sign in to unlock all features';

  @override
  String get currentGoals => 'Current goals';

  @override
  String get goalDone => 'Done! 🎉';

  @override
  String memorizeGoal(int count) {
    return 'Memorize $count ayahs';
  }

  @override
  String reviewSessionsGoal(int count) {
    return 'Complete $count review sessions';
  }

  @override
  String remainingSessions(int count) {
    return '$count sessions remaining';
  }

  @override
  String ayahProgress(int current, int total) {
    return 'Ayah $current / $total';
  }

  @override
  String get ayahBreakdown => 'Ayah breakdown';

  @override
  String get bubbleKnown => 'Memorized';

  @override
  String get bubbleHesitant => 'Stumbled';

  @override
  String get bubbleUnknown => 'Forgot';
}
