# Werdi Quran App

## About

Werdi (وردي) v1.0.1 is an Arabic-first Quran memorization and revision app with full English support. The latest release removes the login gate — open the app and start immediately. Progress is stored locally on the device, with optional Supabase sync.

Core flows: animated splash and onboarding, ayah-by-ayah memorization with repetition and playback speed, smart revision sessions, voice recitation (tasmee3) with recording and speech-to-text feedback, Mushaf browsing with search/tafsir/bookmarks, ayah-by-ayah audio (Alafasy, Abdul Basit, Maher, Shuraim, Sudais), achievements, and daily reminder notifications.

The UI uses Material 3 with Mushaf-style ayah text, branded backgrounds, custom page transitions, light/dark/system themes, and a responsive layout for phones and tablets.

---

وردي (Werdi) v1.0.1 تطبيق عربي أولاً لحفظ ومراجعة القرآن مع دعم إنجليزي كامل. الإصدار الأخير يزيل تسجيل الدخول — افتح التطبيق وابدأ مباشرة. التقدم يُحفظ محلياً مع مزامنة Supabase اختيارية.

يشمل: شاشة افتتاحية وonboarding متحركة، حفظ آية بآية مع التكرار وسرعة التشغيل، مراجعة ذكية، تسميع صوتي (tasmee3) مع تسجيل وتحويل كلام، تصفح المصحف مع البحث والتفسير والإشارات، صوت آية بآية بعدة قراء، إنجازات، وتذكيرات يومية.

الواجهة Material 3 مع عرض آيات بأسلوب المصحف وخلفيات مميزة وانتقالات صفحات مخصصة وثيمات نهاري/ليلي/تلقائي وتخطيط متجاوب.

## Features

- No login — splash → onboarding → home instantly
- Animated splash screen and polished onboarding flow
- Ayah-by-ayah memorization with repetition and playback speed
- Voice recitation (tasmee3) with recording and speech-to-text
- Smart revision list, achievements, and daily reminders
- Mushaf-style ayah display with search, tafsir, and bookmarks
- Ayah-by-ayah audio with multiple reciters
- Material 3 themes (light, dark, system) and custom page transitions
- Responsive layout for phones and tablets
- Offline-first with Drift; optional Supabase sync

---

- بدون تسجيل دخول — افتتاحية → onboarding → الرئيسية مباشرة
- شاشة افتتاحية متحركة وonboarding محسّن
- حفظ آية بآية مع التكرار وسرعة التشغيل
- تسميع صوتي مع تسجيل وتحويل كلام
- مراجعة ذكية وإنجازات وتذكيرات يومية
- عرض آيات بأسلوب المصحف مع البحث والتفسير والإشارات
- صوت آية بآية مع عدة قراء
- ثيمات Material 3 وانتقالات صفحات مخصصة
- تخطيط متجاوب للهواتف والأجهزة اللوحية
- تخزين محلي عبر Drift مع مزامنة Supabase اختيارية

## Tech Stack

Flutter · BLoC · go_router · Drift · Supabase · just_audio · flutter_screenutil

## Download & Install (Android)

### English
1. Open **[Releases](https://github.com/ahmedehab96-c/werdi/releases/tag/portfolio-apk-v1)** on your Android phone (Chrome).
2. Download **`app-release.apk`** (~150 MB) under **Assets** — works on all supported phones.
3. Wait until download is **100% complete**, then open from **Downloads** → **Install**.
4. If blocked: **Settings → Install unknown apps → Chrome → Allow**.
5. **Google Play Protect warning?** This is normal for apps outside the Play Store. Tap **Install anyway** (not OK). The app is safe — it is your developer's own build from GitHub.
6. If *App not installed*: uninstall any older Werdi build, then retry.
7. Requires **Android 7.0+**. Current build: **v1.0.1**.

### العربية
1. افتح **[Releases](https://github.com/ahmedehab96-c/werdi/releases/tag/portfolio-apk-v1)** من جوال أندرويد (Chrome).
2. حمّل **`app-release.apk`** (~150 ميجا) من **Assets** — يعمل على كل الهواتف المدعومة.
3. انتظر اكتمال التحميل **100%** ثم افتح من **التنزيلات** → **تثبيت**.
4. إذا ظهر حظر: **الإعدادات → تثبيت تطبيقات غير معروفة → Chrome → السماح**.
5. **ظهرت رسالة Google Play Protect؟** هذا طبيعي للتطبيقات خارج متجر Google Play. اضغط **التثبيت على أي حال** (Install anyway) وليس **موافق** (OK). التطبيق آمن — نسخة المطوّر من GitHub.
6. إذا ظهر *لم يتم التثبيت*: احذف نسخة وردي القديمة ثم أعد المحاولة.
7. يتطلب **أندرويد 7.0+**. الإصدار الحالي: **1.0.1**.

## Development

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

CI builds release APK/AAB on every push to `main` (see Actions artifacts).
