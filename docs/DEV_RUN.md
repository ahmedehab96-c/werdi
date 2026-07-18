# تشغيل Werdi بدون أخطاء iCloud / l10n

## المشكلة
1. مشروع Desktop داخل iCloud → فشل CodeSign عند Run على iOS.
2. وجود نسختين (`werdi` و `werdi 2`) → ملفات `app_localizations*.dart` تختفي من إحدى النسختين.

## الحل المثبت في المشروع
- `scripts/ensure_local_flutter_build.sh` يوجّه `build/` إلى `~/Library/Caches/werdi-flutter/build`.
- `scripts/strip_icloud_xattrs.sh` ينظّف xattrs قبل التوقيع (مربوط في Xcode Run Script / Thin Binary).
- `scripts/dev_prepare.sh` يولّد الترجمة ويعِد البيئة.
- `.vscode/tasks.json` + `launch.json`: قبل Run يتم تشغيل `werdi: prepare`.

## ماذا تفعل في Cursor
1. افتح مجلد المشروع `werdi 2` أو `~/Developer/werdi` (مفضّل).
2. اختر الجهاز: **iPhone 16 Pro**.
3. Run عبر إعداد **Werdi (iPhone Simulator)** أو الزر العادي (سيعمل `preLaunchTask` إن استخدمت إعدادات launch).
4. إذا ظهرت أخطاء حمراء لـ `AppLocalizations` مرة واحدة:
   ```bash
   bash scripts/dev_prepare.sh
   ```

## ملاحظة
لا تحذف `lib/l10n/app_localizations*.dart` يدوياً؛ هي جزء من المشروع بعد التوليد.
