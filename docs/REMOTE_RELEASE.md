# Werdi — ملف الجاهزية الكامل للرفع عن بُعد

**آخر تحديث:** 12 يوليو 2026  
**الحزمة:** `com.werdi.app`  
**الإصدار:** `1.0.1+11`  
**الغرض:** ملف واحد فيه كل ما تحتاج نسخه في Play Console + إعداد Supabase + أوامر البناء.

> المسارات النسبية من جذر المشروع: `werdi/`  
> إن وُجدت نسختان: فضّل `~/Developer/werdi` (خارج iCloud) للبناء.

---

## 0) قرار البناء (اختر واحداً)

| الخيار | متى | Data safety |
|--------|-----|-------------|
| **A — محلي فقط** | بدون حساب سحابي | لا تعلن بيانات حساب |
| **B — مع Supabase** | مزامنة + تسجيل دخول | أعلن بريد/حساب + مزامنة تقدم |

لا ترفع بناءً محلياً وتملأ Data safety كحساب سحابي (أو العكس).

---

## 1) روابط عامة (انسخ كما هي)

| الحقل | القيمة |
|-------|--------|
| اسم التطبيق | وردي |
| Package | `com.werdi.app` |
| الفئة | Education |
| اللغة الافتراضية | Arabic (ar) |
| لغة ثانوية | English (en-US) |
| سياسة الخصوصية | https://github.com/ahmedehab96-c/werdi/blob/main/PRIVACY.md |
| الدعم | https://github.com/ahmedehab96-c/werdi/issues |
| لوحة Supabase (مشروع وردي) | https://supabase.com/dashboard/project/rewgjxbpjoyyjmxtzwvk |

---

## 2) نصوص المتجر — عربي

### Short description (≤80)

```
رفيقك لحفظ القرآن ومراجعته وتسميعه بخطط يومية ذكية وتتبع تقدمك.
```

### Full description

```
وردي تطبيق عربي أولًا لحفظ القرآن ومراجعته وقراءته في المصحف، مع دعم كامل للإنجليزية.

المميزات:
• جلسات حفظ آية بآية مع تكرار وسرعة تشغيل قابلة للتعديل
• خطط مراجعة ذكية تركّز على الآيات الصعبة
• تسميع صوتي (اختياري) مع تقييم فوري
• تصفح المصحف حسب السورة والجزء، مع بحث وعلامات مرجعية
• تفسير وترجمة، مع إمكانية تنزيل التفسير للاستخدام دون إنترنت
• تلاوات قرّاء معتمدين، وتشغيل في الخلفية، وتحميل تلاوات دون اتصال
• أهداف يومية، سلسلة إنجاز، وشارات
• الوضع الفاتح والداكن، وتذكيرات يومية اختيارية

يمكنك البدء فورًا دون تسجيل دخول. المزامنة السحابية اختيارية عند تفعيلها.
```

### What’s new (1.0.1)

```
• خطط مراجعة ذكية حسب الآيات الضعيفة
• تحميل التلاوات والتفسير للاستخدام دون إنترنت
• تشغيل صوتي في الخلفية مع شاشة القفل
• تحسينات المزامنة والاستقرار
```

---

## 3) نصوص المتجر — English

### Short description (≤80)

```
Memorize, review, and self-test Quran with smart plans and progress tracking.
```

### Full description

```
Werdi is an Arabic-first Quran companion for daily memorization, revision, and Mushaf reading — with full English support.

Features:
• Ayah-by-ayah memorization with repeat and playback speed
• Smart review plans focused on difficult ayahs
• Optional voice self-test (Tasmee3) with instant feedback
• Browse by surah and juz, search, and bookmarks
• Tafsir and translation, with offline tafsir download
• Trusted reciters, background playback, and offline surah downloads
• Daily goals, streaks, and achievements
• Light/dark mode and optional daily reminders

Start immediately without an account. Cloud sync is optional when enabled.
```

### What’s new (1.0.1)

```
• Smart review plans for weak ayahs
• Offline recitation and tafsir downloads
• Background audio with lock-screen controls
• Sync and stability improvements
```

---

## 4) أصول الرسوم (ارفعها يدوياً)

**جاهزة في المستودع:** `docs/store_assets/`

| الأصل | الملف | المواصفات |
|-------|-------|-----------|
| High-res icon | `docs/store_assets/graphics/icon-512.png` | 512×512 PNG |
| Feature graphic | `docs/store_assets/graphics/feature-graphic.png` | 1024×500 PNG |
| Phone screenshots | `docs/store_assets/screenshots/01_*.png` … `08_*.png` | 8 لقطات عربية |
| نصوص المتجر | `docs/store_assets/copy/*.txt` | عربي + إنجليزي جاهز للنسخ |

### خطة اللقطات (بالترتيب)

1. الرئيسية  
2. المصحف  
3. الحفظ  
4. الأهداف  
5. حسابي  
6. المراجعة  
7. التسميع  
8. الإعدادات  

دليل الاستخدام: `docs/store_assets/README.md`

---

## 5) Data safety — إجابات جاهزة

### بيانات

| النوع | يُجمع؟ | أين | ملاحظة |
|-------|--------|-----|--------|
| تقدم / نشاط التطبيق | نعم | على الجهاز (+ سحابة إن كان البناء B) | حفظ، مراجعة، أهداف |
| ملفات صوتية | نعم | على الجهاز | تلاوات تنزّلها أنت |
| بيانات حساب (بريد) | فقط في البناء B | Supabase | اختياري |
| موقع تقريبي | لا | — | — |
| جهات اتصال / صور | لا | — | — |

### صلاحيات

| الصلاحية | السبب |
|----------|--------|
| Microphone | تسميع اختياري فقط |
| Notifications | تذكيرات يومية اختيارية |
| Internet | صوت، تفسير، مزامنة اختيارية |
| Foreground service (media) | تشغيل قرآن في الخلفية |

### أسئلة شائعة في Console

- **مشفّر أثناء النقل؟** نعم (HTTPS) للشبكات.  
- **يُباع؟** لا.  
- **إعلانات؟** لا.  
- **يمكن الحذف؟** إلغاء التثبيت يمسح المحلي؛ للحساب السحابي: Issues على GitHub / حذف الحساب إن وُجد.  
- **مطلوب للتطبيق؟** لا — الميكروفون والحساب اختياريان؛ الجوهر يعمل محلياً.

---

## 6) تصريحات محتوى التطبيق

| البند | الإجابة |
|-------|---------|
| Ads | No |
| In-app purchases | No |
| News app | No |
| Medical / COVID claims | No |
| Government app | No |
| Designed for children | No (تجنّب Kids policy) |
| Target age | 13+ أو حسب استبيان IARC |
| Category | Education / مرجع ديني تعليمي |

---

## 7) إعداد Supabase عن بُعد (للبناء B فقط)

### خطوات

1. افتح لوحة المشروع (الرابط أعلاه) أو أنشئ مشروعاً جديداً.  
2. SQL Editor → نفّذ محتوى الملف: `docs/supabase_schema.sql`  
   (جداول: `profiles`, `user_progress`, `bookmarks`, `achievements`, `review_items` + RLS).  
3. Authentication → فعّل Email.  
4. انسخ Project URL + anon key.  
5. على الجهاز المحلي (مرة واحدة):

```bash
cd ~/Developer/werdi   # أو مسار المشروع
chmod +x scripts/*.sh
./scripts/configure_supabase_remote.sh \
  "https://YOUR_REF.supabase.co" \
  "YOUR_ANON_KEY" \
  "YOUR_REF"
```

ينشئ (محلياً ومُتجاهَل من Git):

- `config/dart_defines.json`  
- `config/supabase.env`  

6. ادفع السكيما إن لزم:

```bash
./scripts/push_supabase_schema.sh
```

تفاصيل إضافية: `docs/SUPABASE_SETUP.md`

---

## 8) أوامر البناء عن بُعد / محلي

### تحقق قبل البناء

```bash
cd ~/Developer/werdi
flutter clean && flutter pub get
flutter analyze
flutter test
```

المتوقع: analyze بدون مشاكل، والاختبارات ناجحة.

### A — AAB محلي (بدون سحابة)

```bash
flutter build appbundle --release
```

المخرج: `build/app/outputs/bundle/release/app-release.aab`

### B — AAB مع Supabase

```bash
./scripts/build_release_with_supabase.sh
```

أو:

```bash
flutter build appbundle --release \
  --dart-define-from-file=config/dart_defines.json
```

### APK للتجربة الجانبية (اختياري)

```bash
flutter build apk --release
# أو مع Supabase عبر السكربت أعلاه
```

### iOS (لاحقاً / TestFlight)

```bash
./scripts/release_ios.sh
# أو: flutter build ipa --release
```

Bundle ID: `com.werdi.app`

---

## 9) قائمة تحقق Play Console (رتّب عليها)

### قبل الرفع

- [ ] حساب مطوّر Google Play نشط  
- [ ] Keystore محفوظ أوفلاين (`android/app/werdi-release.jks` + `android/key.properties`) — **لا ترفعهم لـ Git**  
- [ ] البناء A أو B محدد  
- [ ] `flutter analyze` + `flutter test` ناجحان  
- [ ] AAB مُنشأ وموقّع بمفتاح الرفع (ليس debug)

### إنشاء التطبيق

- [ ] Create app → وردي → Free  
- [ ] App signing by Google Play  
- [ ] رفع AAB إلى **Internal testing** أولاً  

### المتجر

- [ ] Short + Full (AR)  
- [ ] Short + Full (EN)  
- [ ] Icon 512 + Feature 1024×500  
- [ ] ≥2 لقطات هاتف  
- [ ] Privacy + Support URLs  

### الامتثال

- [ ] Data safety (يطابق البناء)  
- [ ] Content rating (IARC)  
- [ ] لا إعلانات / لا مشتريات  

### الإطلاق

- [ ] Internal → تثبيت من Play والتحقق  
- [ ] Closed/Open (اختياري)  
- [ ] Production → rollout تدريجي 20% → 100%  

---

## 10) QA سريع قبل Production

- [ ] تشغيل بارد → الرئيسية  
- [ ] مصحف: تصفح / بحث / إشارة  
- [ ] صوت أمامي + خلفية + شاشة القفل  
- [ ] حفظ + تعليم صعب  
- [ ] مراجعة ذكية  
- [ ] تسميع: سماح ورفض الميكروفون  
- [ ] تنزيل تلاوة أوفلاين  
- [ ] تنزيل تفسير أوفلاين + إلغاء  
- [ ] تذكيرات  
- [ ] عربي / إنجليزي + فاتح / داكن  
- [ ] تسجيل دخول (فقط إن كان البناء B)

---

## 11) ملفات مرجعية في المشروع

| الملف | المحتوى |
|-------|---------|
| **هذا الملف** `docs/REMOTE_RELEASE.md` | كل شيء للرفع عن بُعد |
| `docs/PLAY_STORE_LISTING.md` | نصوص المتجر مفصّلة |
| `docs/PLAY_CONSOLE_CHECKLIST.md` | خطوات Console |
| `PRIVACY.md` | سياسة الخصوصية العامة |
| `docs/SUPABASE_SETUP.md` | إعداد السحابة |
| `docs/supabase_schema.sql` | سكيما قاعدة البيانات |
| `RELEASE_CHECKLIST.md` | بوابة ما قبل الإصدار |
| `config/dart_defines.example.json` | قالب مفاتيح Supabase |
| `scripts/build_release_with_supabase.sh` | بناء release مع السحابة |
| `scripts/configure_supabase_remote.sh` | ربط المشروع بالسحابة |

---

## 12) عوائق معروفة (لا ترفع Production قبلها)

1. Feature graphic 1024×500 + لقطات حقيقية مرفوعة  
2. التحقق أن الـ AAB موقّع بمفتاح الرفع وليس debug  
3. Data safety مطابق لنوع البناء (A أو B)  
4. سياسة الخصوصية منشورة على الفرع العام `main`  

---

**بعد إكمال الأقسام 4 و 8 و 9:** التطبيق جاهز للرفع إلى Internal testing ثم Production.
