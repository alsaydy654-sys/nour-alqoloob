# نور القلوب — Nour Al-Qoloob

تطبيق Flutter إسلامي: الأذكار، الأدعية المأثورة، مواقيت الصلاة والتنبيهات، القرآن الكريم
مع التفسير الميسّر ووضع المساعدة على الحفظ، ومسبحة رقمية عائمة.

## التشغيل

```bash
flutter pub get
flutter run
```

## البنية

| الملف | الوظيفة |
| --- | --- |
| `lib/main.dart` | الشاشات وشريط التنقّل والمسبحة العائمة |
| `lib/quran_repository.dart` | قاعدة بيانات القرآن المحلية + البحث مع تطبيع النص العربي |
| `lib/content_repository.dart` | تحميل الأذكار والأدعية المترجمة من `assets/i18n` |
| `lib/locale_controller.dart` | اللغة المختارة يدوياً وحفظها |
| `lib/audio_service.dart` | مشغّل الصوت (بث التلاوات والأذان) |
| `lib/l10n/*.arb` | نصوص الواجهة لكل لغة |
| `assets/quran/quran.json` | النص العثماني (6236 آية) + التفسير الميسّر |
| `assets/i18n/content_*.json` | نصوص الأذكار والأدعية وترجماتها |

## التدويل (i18n)

- نصوص **الواجهة** في ملفات ARB داخل `lib/l10n/` وتُولَّد عبر `flutter gen-l10n`
  (تلقائياً مع `flutter pub get` لأن `generate: true` مُفعّل في `pubspec.yaml`).
- نصوص **المحتوى** (الأذكار والأدعية) في `assets/i18n/content_<lang>.json`، حيث
  يبقى نص الذِّكر العربي ثابتاً في كل اللغات (لأنه نص العبادة) ويتغيّر حقل `tr`
  (المعنى) والعناوين حسب اللغة.
- اللغات الحالية: العربية `ar`، الإنجليزية `en`، الفرنسية `fr`، الأوردو `ur`.
- الاتجاه (RTL/LTR) يُحدَّد تلقائياً من اللغة عبر `flutter_localizations`
  (العربية والأوردو من اليمين لليسار، الإنجليزية والفرنسية من اليسار لليمين).
- اللغة تُتبع من الجهاز افتراضياً، ويمكن اختيارها يدوياً من **الإعدادات** وتُحفَظ
  في `SharedPreferences`.

### كيف تُضيف لغة جديدة (مثال: التركية `tr`)

1. أنشئ `lib/l10n/app_tr.arb` بنسخ `lib/l10n/app_ar.arb` وترجمة القيم
   (احتفظ بنفس المفاتيح، ولا حاجة لتكرار حقول `@key`).
2. أنشئ `assets/i18n/content_tr.json` بنسخ `assets/i18n/content_en.json`
   وترجمة `title` و`tr` فقط، مع إبقاء `ar` و`count` كما هما.
3. أضف الأصل في `pubspec.yaml` تحت `assets:`:
   `- assets/i18n/content_tr.json`
4. أضف رمز اللغة إلى `ContentRepository.supported` في
   `lib/content_repository.dart`، وأضف `Locale('tr')` إلى `kSupportedLocales`
   في `lib/locale_controller.dart`.
5. أضف الاسم المحلي للغة إلى `_nativeNames` في شاشة الإعدادات (`lib/main.dart`).
6. نفّذ `flutter pub get` (أو `flutter gen-l10n`) ثم `flutter run`.

اللغة تظهر تلقائياً في قائمة الإعدادات، ويُضبط الاتجاه تلقائياً من بيانات اللغة.

## التحقّق

```bash
flutter analyze
flutter test
flutter build web --no-tree-shake-icons
```
