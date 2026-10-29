import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_locale.dart';
import '../app_theme.dart';
import '../l10n/app_strings.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final current = appLocale.value.languageCode;
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 120.h),
      children: [
        Text(strings.settings, style: appTextStyle(context, TextStyle(fontSize: 27.sp, fontWeight: FontWeight.w800))),
        SizedBox(height: 6.h),
        Text(strings.language, style: appTextStyle(context, TextStyle(color: AppColors.muted, fontSize: 13.sp))),
        SizedBox(height: 22.h),
        GlassCard(
          padding: EdgeInsets.all(8.w),
          child: Column(children: [
            _LanguageTile(title: strings.english, code: 'en', selected: current == 'en'),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            _LanguageTile(title: strings.arabic, code: 'ar', selected: current == 'ar'),
          ]),
        ),
        SizedBox(height: 18.h),
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SettingRow(icon: Icons.folder_open_rounded, title: strings.outputDirectory, subtitle: strings.outputDirectoryLabel),
            SizedBox(height: 20.h),
            _SettingRow(icon: Icons.info_outline_rounded, title: 'v1.0.0', subtitle: strings.version),
          ]),
        ),
        SizedBox(height: 26.h),
        Text(strings.branding, style: appTextStyle(context, TextStyle(fontSize: 12.sp, color: AppColors.muted, letterSpacing: 0.6))),
        SizedBox(height: 10.h),
        GlassCard(
          glowColor: AppColors.cyberGreen,
          padding: EdgeInsets.all(20.w),
          child: Row(children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyberGreen.withValues(alpha: 0.10),
                border: Border.all(color: AppColors.cyberGreen.withValues(alpha: 0.32)),
              ),
              child: const Icon(Icons.design_services_rounded, color: AppColors.neonBlue, size: 27),
            ),
            SizedBox(width: 15.w),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Wael Atef Centre', style: appTextStyle(context, TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppColors.neonBlue))),
              SizedBox(height: 3.h),
              Text(strings.designer, style: appTextStyle(context, TextStyle(fontSize: 12.sp, color: AppColors.muted))),
            ]),
          ]),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.title, required this.code, required this.selected});
  final String title;
  final String code;
  final bool selected;
  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () => appLocale.value = Locale(code),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
        leading: Icon(code == 'ar' ? Icons.translate_rounded : Icons.language_rounded, color: selected ? AppColors.neonBlue : AppColors.muted),
        title: Text(title, style: appTextStyle(context, TextStyle(fontSize: 14.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w400))),
        trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.cyberGreen) : null,
      );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: AppColors.neonBlue, size: 23),
        SizedBox(width: 13.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(subtitle, style: appTextStyle(context, TextStyle(fontSize: 11.sp, color: AppColors.muted))),
          SizedBox(height: 4.h),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: appTextStyle(context, TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
        ])),
      ]);
}
