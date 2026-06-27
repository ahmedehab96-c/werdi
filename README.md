# Werdi Quran App

## About

Werdi (وردي) is an Arabic-first Quran memorization and revision app (v1.0.1) with full English support. Open the app and start immediately — **no login required**. All progress is stored locally on the device, with optional Supabase sync.

Users can memorize ayah by ayah with repetition controls, run smart revision sessions, practice voice recitation (tasmee3) with feedback, browse the Mushaf with search, tafsir, and bookmarks, and listen to ayah-by-ayah audio from multiple reciters (Alafasy, Abdul Basit, Maher, Shuraim, Sudais).

The UI uses Material 3 with Mushaf-style ayah text, branded light/dark/system themes, achievements tracking, and a fully responsive layout for phones and tablets.

---

وردي (Werdi) هو تطبيق عربي أولاً لحفظ ومراجعة القرآن الكريم (الإصدار 1.0.1) مع دعم إنجليزي كامل. افتح التطبيق وابدأ مباشرة — **بدون تسجيل دخول**. كل التقدم يُحفظ محلياً على الجهاز مع مزامنة اختيارية عبر Supabase.

يمكن للمستخدم الحفظ آية بآية مع التحكم بالتكرار، وتشغيل جلسات مراجعة ذكية، والتسميع الصوتي (tasmee3)، وتصفح المصحف مع البحث والتفسير والإشارات، والاستماع لصوت الآيات من عدة قراء (العفاسي، عبدالباسط، ماهر، الشريم، السديس).

الواجهة Material 3 مع عرض آيات بأسلوب المصحف، ثيمات نهاري/ليلي/تلقائي، تتبع إنجازات، وتخطيط متجاوب للهواتف والأجهزة اللوحية.

## Features

- No account required — open and start memorizing locally
- Ayah-by-ayah memorization with repetition and playback speed
- Voice recitation (tasmee3) with automatic correction
- Smart revision list and achievements progress
- Mushaf-style ayah display with search, tafsir, and bookmarks
- Ayah-by-ayah audio with multiple reciters
- Material 3 light, dark, and system themes
- Responsive layout for phones and tablets
- Optional Supabase sync; offline-first with Drift

---

- بدون حساب — افتح التطبيق وابدأ الحفظ محلياً
- حفظ آية بآية مع التكرار وسرعة التشغيل
- التسميع الصوتي مع تصحيح تلقائي
- مراجعة ذكية وتتبع الإنجازات
- عرض آيات بأسلوب المصحف مع البحث والتفسير والإشارات
- صوت آية بآية مع عدة قراء
- ثيمات Material 3 نهاري وليلي وتلقائي
- تخطيط متجاوب للهواتف والأجهزة اللوحية
- مزامنة Supabase اختيارية مع تخزين محلي عبر Drift

## Tech Stack

Flutter · BLoC · go_router · Drift · Supabase · just_audio · flutter_screenutil

## Download & Install (Android)

### English
1. Open **[Releases](https://github.com/ahmedehab96-c/werdi/releases/tag/portfolio-apk-v1)** on your Android phone (Chrome).
2. Download **`app-release.apk`** (~150 MB) under **Assets** — works on all supported phones.
3. Wait until download is **100% complete**, then open from **Downloads** → **Install**.
4. If blocked: **Settings → Install unknown apps → Chrome → Allow**.
5. If *App not installed*: uninstall any older Werdi build, then retry.
6. Requires **Android 7.0+**. Current build: **v1.0.1**.

### العربية
1. افتح **[Releases](https://github.com/ahmedehab96-c/werdi/releases/tag/portfolio-apk-v1)** من جوال أندرويد (Chrome).
2. حمّل **`app-release.apk`** (~150 ميجا) من **Assets** — يعمل على كل الهواتف المدعومة.
3. انتظر اكتمال التحميل **100%** ثم افتح من **التنزيلات** → **تثبيت**.
4. إذا ظهر حظر: **الإعدادات → تثبيت تطبيقات غير معروفة → Chrome → السماح**.
5. إذا ظهر *لم يتم التثبيت*: احذف نسخة وردي القديمة ثم أعد المحاولة.
6. يتطلب **أندرويد 7.0+**. الإصدار الحالي: **1.0.1**.

## Development

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

CI builds release APK/AAB on every push to `main` (see Actions artifacts).
