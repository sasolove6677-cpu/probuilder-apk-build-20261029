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
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

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

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'appTitle': 'Pro Builder', 'dashboard': 'Home', 'projects': 'Projects',
      'settings': 'Settings', 'newProject': 'New Project', 'recentProjects': 'Recent projects',
      'seeAll': 'See all', 'noProjects': 'No projects yet',
      'customizationStudio': 'Customization Studio', 'selectFile': 'Choose a file',
      'supportedFiles': 'HTML, ZIP or PDF • up to 100 MB', 'appDetails': 'App details',
      'appName': 'App name', 'packageName': 'Package name', 'uploadIcon': 'App icon',
      'preview': 'Live preview', 'startBuilding': 'Start Building',
      'chooseFileFirst': 'Choose a file first.', 'building': 'Preparing build request…',
      'buildUnavailable': 'APK creation needs a desktop/hosted Android build service. The included template source can be built from a computer; this mobile app does not contain the Android SDK.',
      'chooseHtml': 'The template build currently supports HTML files only. ZIP and PDF can be selected, but are not packaged by this source template.',
      'language': 'Language', 'english': 'English', 'arabic': 'العربية',
      'outputDirectory': '/Downloads/ProBuilder', 'version': 'Version',
      'branding': 'Designed by', 'designer': 'Designer', 'projectReady': 'Ready',
      'projectStatusReady': 'Ready', 'projectStatusBuilding': 'Building',
      'projectStatusDraft': 'Draft', 'cancel': 'Cancel', 'ok': 'OK',
      'projectCount': '3 sample projects', 'dashboardSubtitle': 'Your next app starts here.',
      'chooseIcon': 'Choose icon', 'noIcon': 'No icon selected',
      'htmlOnlyForBuild': 'Select an HTML file to create a template APK.',
      'outputDirectoryLabel': 'Default output directory',
      'fileTooLarge': 'Maximum file size is 100 MB.',
      'invalidAppDetails': 'Enter an app name and a valid package name, e.g. com.example.app.',
      'buildTagline': 'BUILD • DEPLOY • REPEAT', 'builtLabel': 'Built',
    },
    'ar': {
      'appTitle': 'Pro Builder', 'dashboard': 'الرئيسية', 'projects': 'المشاريع',
      'settings': 'الإعدادات', 'newProject': 'مشروع جديد', 'recentProjects': 'المشاريع الأخيرة',
      'seeAll': 'عرض الكل', 'noProjects': 'لا توجد مشاريع بعد',
      'customizationStudio': 'استوديو التخصيص', 'selectFile': 'اختر ملفًا',
      'supportedFiles': 'HTML أو ZIP أو PDF • حتى 100 ميغابايت', 'appDetails': 'تفاصيل التطبيق',
      'appName': 'اسم التطبيق', 'packageName': 'معرّف الحزمة', 'uploadIcon': 'أيقونة التطبيق',
      'preview': 'معاينة مباشرة', 'startBuilding': 'بدء الإنشاء',
      'chooseFileFirst': 'اختر ملفًا أولًا.', 'building': 'جارٍ تجهيز طلب الإنشاء…',
      'buildUnavailable': 'إنشاء APK يحتاج إلى خدمة بناء Android على حاسوب أو خادم. يتضمن المشروع قالب المصدر لبنائه من الحاسوب؛ تطبيق الهاتف لا يحتوي على Android SDK.',
      'chooseHtml': 'قالب البناء يدعم حاليًا ملفات HTML فقط. يمكن اختيار ZIP وPDF، لكن لا يتم تضمينهما في APK بهذا القالب.',
      'language': 'اللغة', 'english': 'English', 'arabic': 'العربية',
      'outputDirectory': '/Downloads/ProBuilder', 'version': 'الإصدار',
      'branding': 'تصميم', 'designer': 'المصمم', 'projectReady': 'جاهز',
      'projectStatusReady': 'جاهز', 'projectStatusBuilding': 'قيد الإنشاء',
      'projectStatusDraft': 'مسودة', 'cancel': 'إلغاء', 'ok': 'حسنًا',
      'projectCount': '٣ مشاريع تجريبية', 'dashboardSubtitle': 'تطبيقك القادم يبدأ من هنا.',
      'chooseIcon': 'اختر أيقونة', 'noIcon': 'لم يتم اختيار أيقونة',
      'htmlOnlyForBuild': 'اختر ملف HTML لإنشاء APK من القالب.',
      'outputDirectoryLabel': 'مجلد الإخراج الافتراضي',
      'fileTooLarge': 'الحد الأقصى لحجم الملف ١٠٠ ميغابايت.',
      'invalidAppDetails': 'أدخل اسم التطبيق ومعرّف حزمة صحيحًا، مثل com.example.app.',
      'buildTagline': 'أنشئ • أطلق • كرر', 'builtLabel': 'تم إنشاؤه',
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
