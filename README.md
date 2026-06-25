# Werdi (وردي)

تطبيق Flutter لحفظ ومراجعة وتلاوة القرآن الكريم — عربي أولاً (RTL) مع دعم إنجليزي كامل.

**المستودع:** [github.com/ahmedehab96-c/werdi](https://github.com/ahmedehab96-c/werdi)

## المميزات

| الميزة | الوصف |
| ------ | ----- |
| **الحفظ** | جلسات حفظ آية بآية مع تكرار وسرعة تشغيل |
| **التسميع** | اختبار صوتي مع تصحيح تلقائي وتمييز الأخطاء |
| **المراجعة** | قائمة مراجعة ذكية للآيات المحفوظة |
| **القرآن** | تصفح، بحث، تفسير، إشارات مرجعية، وضع تركيز |
| **الصوت** | قرّاء آية بآية: العفاسي، عبدالباسط، ماهر، الشريم، السديس |
| **المظهر** | وضع **نهاري / ليلي / تلقائي** + خلفيات بعلامة وردي |
| **الآيات** | عرض مصحفي (خط Amiri، إطار ذهبي) |
| **التجاوب** | يتكيف مع الهواتف الصغيرة والكبيرة والأجهزة اللوحية |
| **السحاب** | Supabase للمزامنة (اختياري) |

## البدء السريع

```bash
cd werdi
flutter pub get
flutter run
```

### Supabase (اختياري)

```bash
./scripts/run_with_supabase.sh
# أو
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

راجع `docs/SUPABASE_SETUP.md` لإعداد المشروع.

### بناء APK / AAB للنشر

```bash
./scripts/build_release_with_supabase.sh
# المخرجات:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

## الوضع النهاري والليلي

من **الإعدادات ← المظهر** اختر:

- **نهاري** — ثيم فاتح
- **ليلي** — ثيم داكن (أزرق داكن + ذهبي)
- **تلقائي** — يتبع إعدادات الجهاز

الاختيار يُحفظ تلقائياً.

## التجاوب (Responsive)

التطبيق يستخدم `flutter_screenutil` + `Responsive` (`lib/core/responsive/responsive.dart`):

| الحجم | العرض | السلوك |
| ----- | ----- | ------ |
| compact | &lt; 360px | هواتف صغيرة — padding أقل، خط آيات أصغر |
| medium | 360–600px | هواتف عادية |
| expanded | 600–900px | هواتف كبيرة / لوحي |
| wide | ≥ 900px | لوحي / سطح مكتب — عمود محتوى مركزي |

## البنية

```
lib/
├── app.dart              # MaterialApp + theme/locale
├── core/
│   ├── responsive/       # Responsive breakpoints
│   ├── theme/            # ألوان، خطوط، ثيم نهاري/ليلي
│   ├── widgets/          # AppScaffold, QuranAyahText, …
│   └── audio/            # تشغيل صوت مع fallback
├── features/             # splash, auth, home, quran, memorization, …
└── l10n/                 # ar + en
```

## الجودة والنشر

```bash
flutter analyze
flutter test
```

- **CI:** `.github/workflows/flutter_ci.yml` — analyze + test + APK/AAB artifacts
- **الخصوصية:** `PRIVACY.md` — مطلوب لـ Google Play
- **الإصدار الحالي:** 1.0.1+2

## Tech stack

Flutter (Material 3) · flutter_bloc · go_router · flutter_screenutil ·
google_fonts · supabase_flutter · drift · just_audio · speech_to_text

## Architecture (English)

Clean Architecture with feature folders (`data` / `domain` / `presentation`).
DI via `core/di/app_injector.dart`. State with Cubits, navigation with go_router.

---

**License:** Private — see repository owner for terms.
