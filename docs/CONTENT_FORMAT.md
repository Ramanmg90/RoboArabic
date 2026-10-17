# فرمت بستهٔ محتوا (Content Pack)

اپ هیچ درسی را در کد ندارد. همهٔ محتوا از `assets/content/` خوانده می‌شود:

- `index.json` : `version`, `isSample`, `sourceNote`, `lessons` (فهرست نام فایل‌ها)
- `lessons/<id>.json` : یک درس

## ساختار یک درس
```json
{
  "id": "l1", "order": 1, "title": "...", "subtitle": "...",
  "status": "verified | sample",
  "intro": "...",
  "text": {"arabic": "...", "persian": "..."},
  "vocabulary": [{"id": "l1-v1", "arabic": "...", "persian": "...", "example": ""}],
  "grammar": [{"id": "g-xxx", "title": "...", "difficulty": 1,
               "explanation": "...", "examples": [{"arabic": "...", "persian": "..."}]}],
  "examTips": ["..."],
  "questions": [{"id": "l1-q1", "topicId": "g-xxx | vocab | translation",
                 "type": "multipleChoice | fillBlank | translationSelf",
                 "prompt": "...", "options": [], "acceptedAnswers": ["..."],
                 "explanation": "...", "difficulty": 1}]
}
```

## قواعد
- شناسه‌ها یکتا و ثابت‌اند (پیشرفت دانش‌آموز به آن‌ها وابسته است؛ بعد از انتشار تغییرشان ندهید).
- `status: "verified"` فقط برای محتوایی که با کتاب رسمی تطبیق داده شده است.
- شناسهٔ مبحث گرامر با `g-` شروع شود تا در «چالش گرامر» بیاید.
- سؤال ترجمهٔ آزاد را `translationSelf` بگذارید؛ خودکار تصحیح نمی‌شود.
- بعد از هر تغییر: `flutter test` (آزمون `test/content_test.dart` یکپارچگی بسته را بررسی می‌کند).
- تمرین‌های واژگان خودکار از روی `vocabulary` ساخته می‌شوند.
