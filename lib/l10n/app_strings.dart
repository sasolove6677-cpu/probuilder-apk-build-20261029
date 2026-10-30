import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;
  static const supportedLocales = [Locale('en'), Locale('ar')];

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  bool get isArabic => locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  String _value(String key) => _strings[isArabic ? 'ar' : 'en']![key] ?? key;
  String get appTitle => _value('appTitle');
  String get dashboard => _value('dashboard');
  String get projects => _value('projects');
  String get settings => _value('settings');
  String get newProject => _value('newProject');
  String get recentProjects => _value('recentProjects');
  String get seeAll => _value('seeAll');
  String get noProjects => _value('noProjects');
  String get customizationStudio => _value('customizationStudio');
  String get selectFile => _value('selectFile');
  String get supportedFiles => _value('supportedFiles');
  String get appDetails => _value('appDetails');
  String get appName => _value('appName');
  String get packageName => _value('packageName');
  String get uploadIcon => _value('uploadIcon');
  String get preview => _value('preview');
  String get startBuilding => _value('startBuilding');
  String get chooseFileFirst => _value('chooseFileFirst');
  String get building => _value('building');
  String get buildUnavailable => _value('buildUnavailable');
  String get buildFailed => _value('buildFailed');
  String get apkBuildSuccess => _value('apkBuildSuccess');
  String get chooseHtml => _value('chooseHtml');
  String get language => _value('language');
  String get english => _value('english');
  String get arabic => _value('arabic');
  String get outputDirectory => _value('outputDirectory');
  String get version => _value('version');
  String get branding => _value('branding');
  String get designer => _value('designer');
  String get projectReady => _value('projectReady');
  String get projectStatusReady => _value('projectStatusReady');
  String get projectStatusBuilding => _value('projectStatusBuilding');
  String get projectStatusDraft => _value('projectStatusDraft');
  String get cancel => _value('cancel');
  String get ok => _value('ok');
  String get projectCount => _value('projectCount');
  String get dashboardSubtitle => _value('dashboardSubtitle');
  String get chooseIcon => _value('chooseIcon');
  String get noIcon => _value('noIcon');
  String get htmlOnlyForBuild => _value('htmlOnlyForBuild');
  String get outputDirectoryLabel => _value('outputDirectoryLabel');
  String get fileTooLarge => _value('fileTooLarge');
  String get invalidAppDetails => _value('invalidAppDetails');
  String get buildTagline => _value('buildTagline');
  String get builtLabel => _value('builtLabel');
  String get outputFileName => _value('outputFileName');
  String get outputFileNameHint => _value('outputFileNameHint');
  String get enterOutputName => _value('enterOutputName');

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'appTitle': 'Pro Builder', 'dashboard': 'Home', 'projects': 'Projects',
      'settings': 'Settings', 'newProject': 'New Project', 'recentProjects': 'Recent projects',
      'seeAll': 'See all', 'noProjects': 'No projects yet',
      'customizationStudio': 'HTML App Builder', 'selectFile': 'Choose an HTML file',
      'supportedFiles': 'HTML or HTM • up to 100 MB', 'appDetails': 'App details',
      'appName': 'App name', 'packageName': 'Package name', 'uploadIcon': 'App icon',
      'preview': 'Live preview', 'startBuilding': 'Build APK on this phone',
      'chooseFileFirst': 'Choose an HTML file first.', 'building': 'Creating and signing the APK on this phone…',
      'buildUnavailable': 'The APK could not be created. Check the selected HTML file and available storage, then try again.',
      'buildFailed': 'Build failed', 'apkBuildSuccess': 'The APK was created and saved to Downloads/ProBuilder.',
      'chooseHtml': 'Select a readable .html or .htm file.',
      'language': 'Language', 'english': 'English', 'arabic': 'العربية',
      'outputDirectory': '/Downloads/ProBuilder', 'version': 'Version',
      'branding': 'Designed by', 'designer': 'Designer', 'projectReady': 'APK created',
      'projectStatusReady': 'Ready', 'projectStatusBuilding': 'Building',
      'projectStatusDraft': 'Draft', 'cancel': 'Cancel', 'ok': 'OK',
      'projectCount': '3 sample projects', 'dashboardSubtitle': 'Your next app starts here.',
      'chooseIcon': 'Choose icon', 'noIcon': 'No icon selected',
      'htmlOnlyForBuild': 'Choose an HTML file to create a WebView APK.',
      'outputDirectoryLabel': 'Default output directory',
      'fileTooLarge': 'Maximum HTML size is 100 MB.',
      'invalidAppDetails': 'App metadata is fixed in this HTML wrapper.',
      'buildTagline': 'BUILD • DEPLOY • REPEAT', 'builtLabel': 'Built',
      'outputFileName': 'APK file name', 'outputFileNameHint': 'my_app',
      'enterOutputName': 'Enter a name for the APK file.',
    },
    'ar': {
      'appTitle': 'Pro Builder', 'dashboard': 'الرئيسية', 'projects': 'المشاريع',
      'settings': 'الإعدادات', 'newProject': 'مشروع جديد', 'recentProjects': 'المشاريع الأخيرة',
      'seeAll': 'عرض الكل', 'noProjects': 'لا توجد مشاريع بعد',
      'customizationStudio': 'منشئ تطبيقات HTML', 'selectFile': 'اختر ملف HTML',
      'supportedFiles': 'HTML أو HTM • حتى ١٠٠ ميغابايت', 'appDetails': 'تفاصيل التطبيق',
      'appName': 'اسم التطبيق', 'packageName': 'معرّف الحزمة', 'uploadIcon': 'أيقونة التطبيق',
      'preview': 'معاينة مباشرة', 'startBuilding': 'إنشاء APK على الهاتف',
      'chooseFileFirst': 'اختر ملف HTML أولًا.', 'building': 'جارٍ إنشاء ملف APK وتوقيعه على الهاتف…',
      'buildUnavailable': 'تعذر إنشاء APK. تحقق من ملف HTML المحدد والمساحة المتاحة ثم حاول مجددًا.',
      'buildFailed': 'فشل الإنشاء', 'apkBuildSuccess': 'تم إنشاء APK وحفظه في Downloads/ProBuilder.',
      'chooseHtml': 'اختر ملف .html أو .htm يمكن قراءته.',
      'language': 'اللغة', 'english': 'English', 'arabic': 'العربية',
      'outputDirectory': '/Downloads/ProBuilder', 'version': 'الإصدار',
      'branding': 'تصميم', 'designer': 'المصمم', 'projectReady': 'تم إنشاء APK',
      'projectStatusReady': 'جاهز', 'projectStatusBuilding': 'قيد الإنشاء',
      'projectStatusDraft': 'مسودة', 'cancel': 'إلغاء', 'ok': 'حسنًا',
      'projectCount': '٣ مشاريع تجريبية', 'dashboardSubtitle': 'تطبيقك القادم يبدأ من هنا.',
      'chooseIcon': 'اختر أيقونة', 'noIcon': 'لم يتم اختيار أيقونة',
      'htmlOnlyForBuild': 'اختر ملف HTML لإنشاء تطبيق WebView.',
      'outputDirectoryLabel': 'مجلد الإخراج الافتراضي',
      'fileTooLarge': 'الحد الأقصى لحجم HTML هو ١٠٠ ميغابايت.',
      'invalidAppDetails': 'بيانات التطبيق ثابتة في قالب HTML هذا.',
      'buildTagline': 'أنشئ • أطلق • كرر', 'builtLabel': 'تم إنشاؤه',
      'outputFileName': 'اسم ملف APK', 'outputFileNameHint': 'تطبيقي',
      'enterOutputName': 'أدخل اسمًا لملف APK.',
    },
  };
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales
      .any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture<AppStrings>(AppStrings(locale));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
