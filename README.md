# RoboArabic (روبو عربی)

اپ آفلاین یادگیری عربی پایه نهم. **وضعیت: نسخهٔ اولیه (vertical slice)، هنوز تأیید نشده.**

## وضعیت و محدودیت‌ها
- محتوا **نمونه** است (`assets/content/sample_content.json`) و از کتاب رسمی نیست.
  برای محتوای واقعی همان فرمت JSON را با درس‌های کتاب پر کنید.
- کد روی ماشینی بدون Flutter نوشته شد؛ `format/analyze/test/build` هنوز اجرا نشده‌اند.
  اولین اجرای CI اولین بررسی واقعی است.
- APK نهایی با کلید debug امضا می‌شود، نه امضای انتشار.
- فونت فارسی اضافه نشده (فونت پیش‌فرض اندروید استفاده می‌شود). برای Vazirmatn، فایل فونت را
  در `assets/fonts/` بگذارید و در `pubspec.yaml` معرفی کنید (مجوز OFL).
- پیاده‌سازی‌شده: معرفی، داشبورد (مأموریت روزانه، استریک، ادامهٔ یادگیری)، نقشهٔ درس‌ها، مسیر ۷ مرحله‌ای هر درس،
  واژگان و صف مرور، آکادمی گرامر، مرکز بازی (۶ بازی)، مرکز آزمون (درس‌محور، ترکیبی، زمان‌دار، مرور اشتباهات)،
  داشبورد پیشرفت، پروفایل و تنظیمات.
- هنوز نیست: صدا، اعلان، فونت اختصاصی، و محتوای واقعی کتاب (راهنمای فرمت: `docs/CONTENT_FORMAT.md`).

## ساخت محلی
```bash
flutter create --platforms=android --project-name roboarabic --org ir.roboarabic .
rm -f test/widget_test.dart
flutter pub get
dart format .
flutter analyze && flutter test
flutter build apk --release
```

## GitHub و دریافت APK
```bash
git init && git add . && git commit -m "RoboArabic initial"
git branch -M main
git remote add origin https://github.com/<USER>/<REPO>.git
git push -u origin main
```
سپس در GitHub: تب **Actions → Android APK → Run workflow**. پس از موفقیت، فایل
`RoboArabic-Android-APK` را از بخش **Artifacts** دانلود کنید.

## نصب روی گوشی
فایل را به گوشی منتقل کنید، «نصب از منابع ناشناس» را برای برنامهٔ فایل‌منیجر فعال کنید و APK را باز کنید.

## رفع خطاهای رایج
- **Verify formatting fails:** `dart format .` را محلی اجرا و commit کنید.
- **analyze fails:** خروجی را بخوانید؛ معمولاً lint یا import اضافه است.
- **sqlite test fails on CI:** مرحلهٔ نصب `libsqlite3-dev` باید اجرا شده باشد.
