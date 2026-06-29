// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'وردي';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get back => 'رجوع';

  @override
  String get done => 'تم';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get error => 'حدث خطأ';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get authWelcomeTitle => 'مرحبًا بك في وردي';

  @override
  String get authWelcomeSubtitle => 'سجّل دخولك أو أنشئ حسابًا لبدء رحلة الحفظ';

  @override
  String get loginTab => 'تسجيل الدخول';

  @override
  String get registerTab => 'إنشاء حساب';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get sendResetLink => 'إرسال رابط الاستعادة';

  @override
  String get forgotPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط الاستعادة';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get registerButton => 'إنشاء حساب';

  @override
  String get loginError => 'البريد أو كلمة المرور غير صحيحة';

  @override
  String get registerError => 'تعذّر إنشاء الحساب، يرجى المحاولة مرة أخرى';

  @override
  String homeGreeting(String name) {
    return 'السلام عليكم، $name';
  }

  @override
  String get homeSubtitle => 'اليوم فرصة جديدة لتثبيت الحفظ بإتقان';

  @override
  String get quickActionsTitle => 'إجراءات سريعة';

  @override
  String get memorizeNow => 'احفظ الآن';

  @override
  String get memorizeSubtitle => 'خطة اليوم';

  @override
  String get memorizeAndTestSubtitle => 'حفظ وتسميع في صفحة واحدة';

  @override
  String get reviewAction => 'مراجعة';

  @override
  String get reviewSubtitle => 'المقرر السابق';

  @override
  String get testYourself => 'اختبر نفسك';

  @override
  String get testSubtitle => 'جلسة تسميع';

  @override
  String get openQuran => 'افتح المصحف';

  @override
  String get openQuranSubtitle => 'السور والأجزاء';

  @override
  String get dailyGoal => 'هدف اليوم';

  @override
  String ayahsRemaining(int count) {
    return '$count آيات متبقية';
  }

  @override
  String ayahsCompleted(int count) {
    return '$count آيات مكتملة';
  }

  @override
  String get overallProgress => 'التقدم الإجمالي';

  @override
  String get currentSurah => 'السورة الحالية';

  @override
  String get continueMemorization => 'أكمل الحفظ';

  @override
  String get reviewReminder => 'تذكير المراجعة';

  @override
  String reviewDue(int count) {
    return '$count مراجعات مستحقة';
  }

  @override
  String overdueReviews(int count) {
    return '$count متأخرة';
  }

  @override
  String get startReview => 'ابدأ المراجعة';

  @override
  String get weeklyInsights => 'إحصاءات الأسبوع';

  @override
  String memorizedAyahs(int count) {
    return '$count آية محفوظة';
  }

  @override
  String reviewedAyahs(int count) {
    return '$count آية مراجعة';
  }

  @override
  String sessions(int count) {
    return '$count جلسة';
  }

  @override
  String streakDays(int count) {
    return '$count يوم متواصل';
  }

  @override
  String get yourAchievements => 'إنجازاتك';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get recommendedPlan => 'الخطوة الموصى بها';

  @override
  String get progressOverview => 'نظرة على التقدم';

  @override
  String get total => 'الإجمالي';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get continueJourney => 'تابع رحلتك';

  @override
  String get resumeFromLastPosition => 'استكمال من آخر موضع';

  @override
  String get dailyMotivation => 'بطاقة التحفيز اليومية';

  @override
  String get motivationFooter => 'استمر، كل صفحة تحفظها تقرّبك من هدفك الكبير.';

  @override
  String get streakTitle => 'سلسلة الإنجاز';

  @override
  String get achievementsPreview => 'معاينة الإنجازات';

  @override
  String get memorizeLabel => 'حفظ';

  @override
  String get sessionsLabel => 'جلسات';

  @override
  String get suggestedPlanToday => 'خطة مقترحة لليوم';

  @override
  String get continueMemorizing => 'تابع الحفظ';

  @override
  String get preparingDashboard => 'جارٍ تجهيز لوحة اليوم...';

  @override
  String dailyGoalDescription(int count, String surah) {
    return 'حفظ $count آيات من $surah';
  }

  @override
  String ayahsFraction(int completed, int target) {
    return '$completed / $target آيات';
  }

  @override
  String ayahUnit(int count) {
    return '$count آية';
  }

  @override
  String lastReview(String context) {
    return 'آخر مراجعة: $context';
  }

  @override
  String reviewDueToday(int count) {
    return 'لديك $count ورد مراجعة اليوم للحفاظ على الإتقان';
  }

  @override
  String overdueShort(int count) {
    return 'متأخر $count';
  }

  @override
  String streakConsecutiveDays(int count) {
    return '$count يوم متتالي';
  }

  @override
  String get startStreakHint => 'ابدأ اليوم لبناء سلسلة إنجازك';

  @override
  String get streakPurposeHint =>
      'أيام متتالية من الحفظ أو المراجعة أو التسميع';

  @override
  String nextBadgeHint(String title) {
    return 'الشارة التالية: $title';
  }

  @override
  String milestoneProgress(int current, int next) {
    return '$current / $next آية نحو الإنجاز القادم';
  }

  @override
  String get quranTitle => 'القرآن الكريم';

  @override
  String get surahTab => 'السور';

  @override
  String get juzTab => 'الأجزاء';

  @override
  String get searchQuranHint => 'ابحث باسم السورة أو رقمها أو الجزء';

  @override
  String get lastRead => 'آخر قراءة';

  @override
  String bookmarksCount(int count) {
    return '$count إشارة';
  }

  @override
  String get backToSearch => 'نتائج البحث';

  @override
  String get enterFocusMode => 'وضع القراءة';

  @override
  String get exitFocusMode => 'إنهاء وضع القراءة';

  @override
  String get focusFontSize => 'حجم الخط';

  @override
  String get focusLineSpacing => 'تباعد الأسطر';

  @override
  String get sepiaMode => 'وضع سيبيا';

  @override
  String get resetReadingSettings => 'إعادة ضبط إعدادات القراءة';

  @override
  String get applyReadingSettingsToAllSurahs => 'تطبيق الإعدادات على كل السور';

  @override
  String get appliedReadingSettingsToAllSurahs =>
      'تم تطبيق إعدادات القراءة على جميع السور';

  @override
  String get bookmarks => 'الإشارات';

  @override
  String get noBookmarks => 'لا توجد إشارات بعد';

  @override
  String get noBookmarksSubtitle => 'اضغط على أي آية لإضافتها كإشارة';

  @override
  String get ayah => 'آية';

  @override
  String get ayahs => 'آيات';

  @override
  String get verses => 'آيات';

  @override
  String get juz => 'جزء';

  @override
  String get surah => 'سورة';

  @override
  String get meccan => 'مكية';

  @override
  String get medinan => 'مدنية';

  @override
  String get loadingQuran => 'جارٍ تحميل السور والأجزاء...';

  @override
  String get searchSurahOrJuzHint => 'ابحث عن سورة أو جزء...';

  @override
  String get noMatchingResults => 'لا توجد نتائج مطابقة';

  @override
  String get noMatchingResultsSubtitle => 'جرّب تغيير كلمات البحث أو الفلتر.';

  @override
  String get noMatchingJuzSubtitle => 'لا توجد أجزاء توافق الفلتر الحالي.';

  @override
  String get viewAllBookmarks => 'عرض شاشة الإشارات المرجعية الكاملة';

  @override
  String get viewAllBookmarksSubtitle =>
      'الآيات المحفوظة، السور، وآخر مواضع الحفظ';

  @override
  String get searchQuranTitle => 'البحث في القرآن';

  @override
  String get recentSearches => 'عمليات البحث الأخيرة';

  @override
  String get noSearchHistory => 'لا يوجد سجل بحث بعد';

  @override
  String get noSearchHistorySubtitle =>
      'ابدأ البحث عن سورة أو جزء وسيظهر هنا لاحقًا.';

  @override
  String get surahResults => 'نتائج السور';

  @override
  String get ayahResults => 'نتائج الآيات';

  @override
  String get noResultsSubtitle => 'جرّب كلمة مختلفة أو رقم سورة.';

  @override
  String get noAyahResults => 'لا توجد نتائج آيات';

  @override
  String get noAyahResultsSubtitle => 'جرّب كلمة أدق أو جزءًا من الآية.';

  @override
  String get juzResults => 'نتائج الأجزاء';

  @override
  String get noJuzResults => 'لا نتائج أجزاء';

  @override
  String get noJuzResultsSubtitle => 'نتائج الأجزاء ستظهر عند تطابق الاستعلام.';

  @override
  String get searchApiReady => 'جاهز للبحث عبر API';

  @override
  String get searchApiReadySubtitle =>
      'واجهة البحث مبنية بحيث يمكن توصيلها مباشرة مع Backend لاحقًا.';

  @override
  String juzNumber(int number) {
    return 'الجزء $number';
  }

  @override
  String get open => 'فتح';

  @override
  String get statusMemorized => 'محفوظ';

  @override
  String get statusInProgress => 'قيد الحفظ';

  @override
  String get statusReview => 'مراجعة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterReview => 'للمراجعة';

  @override
  String surahNamed(String name) {
    return 'سورة $name';
  }

  @override
  String get startMemorizing => 'ابدأ الحفظ';

  @override
  String get memorizationSegments => 'مقاطع الحفظ';

  @override
  String progressPercent(int percent) {
    return 'التقدم: $percent%';
  }

  @override
  String rangeAyahs(int from, int to) {
    return 'آية $from – $to';
  }

  @override
  String get surahAyahs => 'آيات السورة';

  @override
  String get versesLoadError => 'تعذر تحميل الآيات';

  @override
  String get versesLoadErrorSubtitle => 'حاول فتح السورة مرة أخرى.';

  @override
  String get chooseReciterBelow => 'اختر قارئًا من قسم الأصوات أدناه.';

  @override
  String get cannotPlayAyah => 'تعذر تشغيل هذه الآية';

  @override
  String get reciterVoices => 'أصوات القرّاء';

  @override
  String get recitersSource => 'قائمة مرتبة من mp3quran.net';

  @override
  String get recitersLoadError => 'تعذر تحميل قائمة القرّاء.';

  @override
  String get chooseReciter => 'اختر قارئًا';

  @override
  String reciterCountTapToSearch(int count) {
    return '$count قارئ • اضغط للبحث';
  }

  @override
  String ayahNumbered(int number) {
    return 'الآية $number';
  }

  @override
  String get ayahNumberLabel => 'رقم الآية';

  @override
  String get checking => 'جارٍ الفحص...';

  @override
  String get checkReciterAvailability => 'فحص توفر القارئ';

  @override
  String get notChecked => 'غير مفحوص';

  @override
  String get available => 'متاح ✓';

  @override
  String get unavailable => 'غير متاح ✗';

  @override
  String get stopAudio => 'إيقاف الصوت';

  @override
  String get playSelectedAyah => 'تشغيل الآية المحددة';

  @override
  String get waitOrChooseReciter => 'انتظر تحميل القرّاء أو اختر قارئًا.';

  @override
  String get cannotPlayAudio => 'تعذر تشغيل الصوت حاليًا';

  @override
  String get searchReciterHint => 'بحث باسم القارئ…';

  @override
  String get ayahByAyah => 'آية بآية';

  @override
  String get fullSurahFile => 'ملف السورة';

  @override
  String get tafsirLinks => 'روابط التفسير';

  @override
  String get tafsirWithTranslation => 'تفسير الآية مع ترجمة';

  @override
  String get classicTafsirLibrary => 'مكتبة تفاسير كلاسيكية';

  @override
  String get tafsirAndTranslation => 'التفسير والترجمة';

  @override
  String get tafsir => 'تفسير';

  @override
  String get translation => 'ترجمة';

  @override
  String get tafsirSourceLabel => 'مصدر التفسير';

  @override
  String fromN(int n) {
    return 'من $n';
  }

  @override
  String toN(int n) {
    return 'إلى $n';
  }

  @override
  String get rangeStart => 'بداية';

  @override
  String get rangeEnd => 'نهاية';

  @override
  String get noTafsir => 'لا يوجد تفسير';

  @override
  String get noTafsirSubtitle => 'اختر النطاق ثم اضغط تحديث.';

  @override
  String get noTranslation => 'لا توجد ترجمة';

  @override
  String get noTranslationSubtitle => 'اضغط تحديث لجلب الترجمة.';

  @override
  String translationLine(int number, String text) {
    return 'آية $number: $text';
  }

  @override
  String get translationLanguage => 'لغة الترجمة';

  @override
  String get refreshTafsir => 'تحديث التفسير';

  @override
  String get refreshTranslation => 'تحديث الترجمة';

  @override
  String get savedSurahs => 'السور المحفوظة';

  @override
  String get savedAyahs => 'الآيات المحفوظة';

  @override
  String get lastPositions => 'آخر مواضع الحفظ';

  @override
  String get savedToBookmarks => 'تم حفظها في الإشارات المرجعية';

  @override
  String surahNumber(int id) {
    return 'سورة رقم $id';
  }

  @override
  String fromAyahToAyah(int from, int to) {
    return 'من آية $from إلى $to';
  }

  @override
  String get memorizationTitle => 'الحفظ';

  @override
  String get memorizationSetup => 'إعداد الجلسة';

  @override
  String get chooseSurah => 'اختر السورة';

  @override
  String get ayahRange => 'نطاق الآيات';

  @override
  String get fromAyah => 'من آية';

  @override
  String get toAyah => 'إلى آية';

  @override
  String ayahCount(int count) {
    return 'عدد الآيات: $count';
  }

  @override
  String get startSession => 'ابدأ جلسة الحفظ';

  @override
  String get audioControls => 'التحكم الصوتي';

  @override
  String get playbackSpeed => 'السرعة';

  @override
  String get repeatAyah => 'تكرار الآية';

  @override
  String get markMemorized => 'حفظت';

  @override
  String get memorizedDone => 'تم الحفظ ✓';

  @override
  String get markDifficult => 'تمييز كصعبة';

  @override
  String get markedDifficult => 'صعبة ⚑';

  @override
  String get showText => 'إظهار النص';

  @override
  String get hideText => 'إخفاء النص';

  @override
  String get tapToReveal => 'اضغط لإظهار الآية';

  @override
  String get preparingSession => 'جارٍ التجهيز...';

  @override
  String get loadingAyahs => 'جارٍ تحميل الآيات...';

  @override
  String get reviewTitle => 'المراجعة';

  @override
  String get noReviewItems => 'لا توجد عناصر للمراجعة';

  @override
  String get noReviewItemsSubtitle =>
      'ابدأ بحفظ آيات لتظهر هنا في قائمة المراجعة.';

  @override
  String get reviewed => 'تمت المراجعة';

  @override
  String get markReviewed => 'مراجعة';

  @override
  String get repeat => 'إعادة';

  @override
  String get difficult => 'صعبة';

  @override
  String get difficultQuestion => 'صعبة؟';

  @override
  String get showAyahs => 'عرض الآيات';

  @override
  String get hideAyahs => 'إخفاء الآيات';

  @override
  String get highPriority => 'أولوية عالية';

  @override
  String get mediumPriority => 'أولوية متوسطة';

  @override
  String get lowPriority => 'أولوية منخفضة';

  @override
  String get tasmee3Title => 'التسميع';

  @override
  String get tasmee3Setup => 'إعداد جلسة التسميع';

  @override
  String get tasmee3Description =>
      'اختر السورة والنطاق، ثم سمّع الآيات بالمايكروفون وسيُصحّح لك التطبيق تلقائيًا';

  @override
  String get speechRecitePrompt =>
      'اقرأ الآية من حفظك في المايكروفون، ثم اضغط «إنهاء التسميع وتقييم الآية»';

  @override
  String get startVoiceRecitation => 'ابدأ التسميع الصوتي';

  @override
  String get finishedReciting => 'انتهيت من التسميع';

  @override
  String get tapWrongWordsHint =>
      'اضغط على الكلمات التي أخطأت فيها (الأحمر = خطأ)';

  @override
  String get stopListening => 'إيقاف الاستماع';

  @override
  String get microphonePermissionRequired =>
      'يلزم السماح بالمايكروفون للتسميع الصوتي';

  @override
  String get speechError => 'تعذر التعرف على الصوت، حاول مرة أخرى';

  @override
  String get speechNotAvailable =>
      'ميزة التعرف الصوتي غير متاحة على هذا الجهاز/المحاكي';

  @override
  String get speechTimeout => 'انتهى وقت الاستماع، اضغط للمحاولة مرة أخرى';

  @override
  String get wrongLanguage =>
      'لم يُتعرّف على العربية. ثبّت لغة العربية في إعدادات الجهاز وجرب مرة أخرى';

  @override
  String get arabicNotAvailable =>
      'لغة العربية غير متوفرة للتعرف الصوتي على هذا الجهاز';

  @override
  String get finishRecitation => 'إنهاء التسميع وتقييم الآية';

  @override
  String get nextAyah => 'التالي';

  @override
  String get retryRecitation => 'إعادة التسميع';

  @override
  String get ayahErrorsInText => 'الأخطاء في الآية (الأحمر = خطأ أو نسيان)';

  @override
  String get recordForReview => 'سجّل صوتك للاستماع';

  @override
  String get stopRecordForReview => 'إيقاف التسجيل';

  @override
  String get playAudioTest => 'تشغيل تجربة الصوت';

  @override
  String get stopAudioTest => 'إيقاف تجربة الصوت';

  @override
  String get audioTestFailed =>
      'تعذر تشغيل تجربة الصوت، تأكد من اتصال الإنترنت والصوت';

  @override
  String get autoGradingHint =>
      'بعد انتهاء التسميع سيتم تقييمك تلقائيًا والانتقال للآية التالية';

  @override
  String get autoGradingActive =>
      'يتم التقييم تلقائيًا بناءً على التسميع الصوتي';

  @override
  String voiceAccuracy(int percent) {
    return 'دقة المطابقة: $percent%';
  }

  @override
  String get playMyRecording => 'سماع تسجيلي';

  @override
  String get stopMyRecording => 'إيقاف تسجيلي';

  @override
  String get listenReciterAyah => 'سماع الشيخ';

  @override
  String get stopReciterAyah => 'إيقاف صوت الشيخ';

  @override
  String get startTest => 'ابدأ الاختبار';

  @override
  String get testProgress => 'التقدم';

  @override
  String get revealAyah => 'كشف الآية';

  @override
  String get hiddenAyah => 'الآية مخفية — ابدأ التسميع بالمايكروفون';

  @override
  String get blockRecitePrompt =>
      'ردّد كل الآيات المختارة دفعة واحدة في المايكروفون';

  @override
  String get iKnowIt => 'أحفظها';

  @override
  String get iHesitated => 'تعثّرت';

  @override
  String get iForgot => 'نسيتها';

  @override
  String get testSummary => 'ملخص الجلسة';

  @override
  String get testScore => 'النتيجة';

  @override
  String get ayahsToReview => 'آيات تحتاج مراجعة';

  @override
  String get retakeTest => 'إعادة الاختبار';

  @override
  String get backToSetup => 'إعداد جديد';

  @override
  String get sessionHistory => 'سجل الجلسات';

  @override
  String get noHistory => 'لا يوجد سجل بعد';

  @override
  String get noHistorySubtitle => 'ستظهر هنا نتائج جلسات التسميع السابقة';

  @override
  String get excellent => 'ممتاز';

  @override
  String get good => 'جيد';

  @override
  String get needsWork => 'يحتاج مراجعة';

  @override
  String get sessionDetails => 'تفاصيل الجلسة';

  @override
  String get knownAyahs => 'آيات محفوظة';

  @override
  String get hesitantAyahs => 'تعثّر فيها';

  @override
  String get unknownAyahs => 'لم يحفظها';

  @override
  String scoreLabel(int score) {
    return 'النتيجة: $score%';
  }

  @override
  String get achievementsTitle => 'الإنجازات';

  @override
  String get loadingAchievements => 'جارٍ تحميل الإنجازات...';

  @override
  String get earnedBadges => 'الشارات المكتسبة';

  @override
  String get upcomingGoals => 'الأهداف القادمة';

  @override
  String get noAchievements => 'لا توجد إنجازات بعد';

  @override
  String get noAchievementsSubtitle =>
      'ابدأ الحفظ والمراجعة لتحصل على أول شارة.';

  @override
  String get overallProgressLabel => 'التقدم العام';

  @override
  String badgesProgress(int earned, int total) {
    return '$earned / $total شارة';
  }

  @override
  String get allBadgesEarned => 'أحرزت جميع الشارات! 🎉';

  @override
  String remainingBadges(int count) {
    return 'متبقي $count شارة للاكتمال';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get memorizedAyahsCount => 'آية محفوظة';

  @override
  String get reviewSessionsCount => 'جلسة مراجعة';

  @override
  String get streakLabel => 'أيام متواصلة';

  @override
  String get yourBadges => 'شاراتك';

  @override
  String get noBadges => 'لا توجد شارات بعد';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get signOutConfirmYes => 'نعم، خروج';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get searchFocusModeTitle => 'وضع القراءة من نتائج البحث';

  @override
  String get searchFocusModeSubtitle =>
      'افتح الآيات من البحث في وضع القراءة المركّز تلقائيًا';

  @override
  String get unifiedReadingPrefsTitle => 'إعدادات قراءة موحدة';

  @override
  String get unifiedReadingPrefsSubtitle =>
      'استخدم نفس إعدادات القراءة لكل السور بدل الإعداد المنفصل لكل سورة';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get darkModeSubtitle => 'تبديل بين الثيم الفاتح والداكن';

  @override
  String get themeModeTitle => 'المظهر';

  @override
  String get themeModeSubtitle =>
      'اختر الوضع النهاري أو الليلي أو تلقائي حسب الجهاز';

  @override
  String get themeLight => 'نهاري';

  @override
  String get themeDark => 'ليلي';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get language => 'اللغة';

  @override
  String get languageSubtitle => 'العربية';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String get fontSizeSubtitle => 'تكبير/تصغير الخط داخل التطبيق';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get remindersSubtitle => 'تذكير يومي بالحفظ الساعة 8:00 صباحًا';

  @override
  String get remindersDescription =>
      'عند التفعيل يُرسَل إشعار يومي الساعة 8:00 صباحًا لتذكيرك بمتابعة حفظك.';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsSubtitle => 'إدارة تنبيهات التطبيق وتذكيرات الحفظ';

  @override
  String get notificationsDescription =>
      'يمكنك تفعيل/إيقاف الإشعارات وتحديد وقت التذكير اليومي.';

  @override
  String get notificationsTimeTitle => 'وقت التذكير اليومي';

  @override
  String notificationsTimeSubtitle(String time) {
    return 'الوقت الحالي: $time';
  }

  @override
  String notificationsTimeHint(String hour, String minute) {
    return 'سيتم إرسال التذكير يوميًا عند $hour:$minute';
  }

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get resetLinkSent => 'تم إرسال رابط استعادة كلمة المرور';

  @override
  String get orContinueWithEmail => 'أو المتابعة عبر البريد الإلكتروني';

  @override
  String get skip => 'تخطي';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get next => 'التالي';

  @override
  String get onboardingTitle1 => 'رحلة حفظ ذكية ومنظمة';

  @override
  String get onboardingSubtitle1 =>
      'خطة يومية مرنة تناسب وقتك وتبني استمرارية قوية.';

  @override
  String get onboardingTitle2 => 'مراجعة متدرجة بدون ضغط';

  @override
  String get onboardingSubtitle2 =>
      'نظام مراجعة يساعدك على تثبيت الحفظ على المدى الطويل.';

  @override
  String get onboardingTitle3 => 'جلسات تسميع محفزة';

  @override
  String get onboardingSubtitle3 =>
      'تتبع الأداء وتقدمك مع تفاعل بصري يرفع الحماس.';

  @override
  String get onboardingTitle4 => 'كل إنجاز محسوب';

  @override
  String get onboardingSubtitle4 => 'لوحة تقدم راقية تعكس رحلتك خطوة بخطوة.';

  @override
  String get guest => 'زائر';

  @override
  String get profileLocalSubtitle => 'تقدمك محفوظ على هذا الجهاز — بدون حساب';

  @override
  String get signInForFullFeatures => 'تسجيل الدخول للحصول على كامل الميزات';

  @override
  String get currentGoals => 'الأهداف الحالية';

  @override
  String get goalDone => 'تم! 🎉';

  @override
  String memorizeGoal(int count) {
    return 'حفظ $count آية';
  }

  @override
  String reviewSessionsGoal(int count) {
    return 'إتمام $count جلسة مراجعة';
  }

  @override
  String remainingSessions(int count) {
    return 'متبقي $count جلسة';
  }

  @override
  String ayahProgress(int current, int total) {
    return 'الآية $current / $total';
  }

  @override
  String get ayahBreakdown => 'تفصيل الآيات';

  @override
  String get bubbleKnown => 'أحفظها';

  @override
  String get bubbleHesitant => 'تعثرت';

  @override
  String get bubbleUnknown => 'نسيتها';
}
