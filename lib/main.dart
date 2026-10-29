import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_locale.dart';
import 'app_theme.dart';
import 'l10n/app_strings.dart';
import 'screens/customization_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProBuilderApp());
}

class ProBuilderApp extends StatelessWidget {
  const ProBuilderApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Locale>(
        valueListenable: appLocale,
        builder: (context, locale, _) => ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            title: 'Pro Builder',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              AppStrings.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: buildAppTheme(isArabic: locale.languageCode == 'ar'),
            builder: (context, child) => Directionality(
              textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const _AppShell(),
          ),
        ),
      );
}

class _AppShell extends StatefulWidget {
  const _AppShell();
  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _selectedIndex = 0;

  Future<void> _openCustomization() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CustomizationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final pages = [
      DashboardScreen(onNewProject: _openCustomization, onSeeAll: () => setState(() => _selectedIndex = 1)),
      DashboardScreen(onNewProject: _openCustomization, showAllProjects: true, onSeeAll: () => setState(() => _selectedIndex = 1)),
      const SettingsScreen(),
    ];
    return Scaffold(
      extendBody: true,
      body: SafeArea(bottom: false, child: IndexedStack(index: _selectedIndex, children: pages)),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: NavigationBar(
              height: 66.h,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              backgroundColor: const Color(0xE612151A),
              indicatorColor: AppColors.neonBlue.withValues(alpha: 0.13),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded, color: AppColors.neonBlue), label: strings.dashboard),
                NavigationDestination(icon: const Icon(Icons.grid_view_outlined), selectedIcon: const Icon(Icons.grid_view_rounded, color: AppColors.neonBlue), label: strings.projects),
                NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings_rounded, color: AppColors.neonBlue), label: strings.settings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
