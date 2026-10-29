import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_theme.dart';
import '../l10n/app_strings.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNewProject, this.onSeeAll, this.showAllProjects = false});
  final VoidCallback onNewProject;
  final VoidCallback? onSeeAll;
  final bool showAllProjects;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final projects = [
      _Project('Portfolio Pro', 'com.wael.portfolio', AppColors.neonBlue, Icons.language_rounded, 'projectStatusReady'),
      _Project('Storefront', 'com.wael.storefront', AppColors.cyberGreen, Icons.storefront_rounded, 'projectStatusBuilding'),
      _Project('Landing Page', 'com.wael.landing', const Color(0xFF9B7CFF), Icons.web_rounded, 'projectStatusDraft'),
    ];
    final visible = showAllProjects ? projects : projects.take(2).toList();

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 104.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          gradient: const LinearGradient(colors: [AppColors.neonBlue, AppColors.cyberGreen]),
                        ),
                        child: const Icon(Icons.terminal_rounded, color: Colors.black, size: 27),
                      ),
                      SizedBox(width: 13.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.appTitle, style: appTextStyle(context, TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800, letterSpacing: 0.2))),
                            SizedBox(height: 2.h),
                            Text(s.dashboardSubtitle, style: appTextStyle(context, TextStyle(fontSize: 12.sp, color: AppColors.muted))),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(11.w),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 21),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  GlassCard(
                    padding: EdgeInsets.all(20.w),
                    glowColor: AppColors.neonBlue,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.buildTagline, style: appTextStyle(context, TextStyle(fontSize: 10.sp, letterSpacing: 1.6, color: AppColors.neonBlue, fontWeight: FontWeight.w700))),
                              SizedBox(height: 10.h),
                              Text(showAllProjects ? s.projects : s.dashboard, style: appTextStyle(context, TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w800))),
                              SizedBox(height: 7.h),
                              Text(s.projectCount, style: appTextStyle(context, TextStyle(fontSize: 12.sp, color: AppColors.muted))),
                            ],
                          ),
                        ),
                        Container(
                          width: 70.w,
                          height: 70.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neonBlue.withValues(alpha: 0.10),
                            boxShadow: [BoxShadow(color: AppColors.neonBlue.withValues(alpha: 0.14), blurRadius: 28)],
                          ),
                          child: const Icon(Icons.rocket_launch_rounded, color: AppColors.neonBlue, size: 34),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Row(
                    children: [
                      Expanded(child: Text(showAllProjects ? s.projects : s.recentProjects, style: appTextStyle(context, TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)))),
                      if (!showAllProjects)
                        TextButton(onPressed: onSeeAll, child: Text(s.seeAll, style: appTextStyle(context, const TextStyle(color: AppColors.neonBlue)))),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  if (visible.isEmpty)
                    GlassCard(child: Center(child: Text(s.noProjects, style: appTextStyle(context, TextStyle(color: AppColors.muted, fontSize: 14.sp)))))
                  else
                    ...visible.asMap().entries.map((entry) {
                      final index = entry.key;
                      final project = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: GlassCard(
                          padding: EdgeInsets.all(15.w),
                          glowColor: index == 0 ? project.color : null,
                          child: Row(
                            children: [
                              Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(color: project.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15.r)),
                                child: Icon(project.icon, color: project.color, size: 25),
                              ),
                              SizedBox(width: 13.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: appTextStyle(context, TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700))),
                                    SizedBox(height: 4.h),
                                    Text(project.packageName, maxLines: 1, overflow: TextOverflow.ellipsis, style: appTextStyle(context, TextStyle(fontSize: 10.sp, color: AppColors.muted))),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                                decoration: BoxDecoration(color: project.color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20.r)),
                                child: Text(_statusFor(s, project.status), style: appTextStyle(context, TextStyle(fontSize: 9.sp, color: project.color, fontWeight: FontWeight.w600))),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(child: GlassCard(padding: EdgeInsets.all(16.w), child: _StatTile(label: 'HTML', value: '12', icon: Icons.code_rounded, color: AppColors.neonBlue))),
                      SizedBox(width: 12.w),
                      Expanded(child: GlassCard(padding: EdgeInsets.all(16.w), child: _StatTile(label: s.builtLabel, value: '08', icon: Icons.check_circle_outline_rounded, color: AppColors.cyberGreen))),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
        Positioned(
          right: 20.w,
          bottom: 14.h,
          child: FloatingActionButton.extended(
            onPressed: onNewProject,
            backgroundColor: AppColors.neonBlue,
            foregroundColor: Colors.black,
            elevation: 12,
            icon: const Icon(Icons.add_rounded),
            label: Text(s.newProject, style: appTextStyle(context, const TextStyle(fontWeight: FontWeight.w800))),
          ),
        ),
      ],
    );
  }

  String _statusFor(AppStrings strings, String key) {
    switch (key) {
      case 'projectStatusReady': return strings.projectStatusReady;
      case 'projectStatusBuilding': return strings.projectStatusBuilding;
      default: return strings.projectStatusDraft;
    }
  }
}

class _Project {
  const _Project(this.name, this.packageName, this.color, this.icon, this.status);
  final String name;
  final String packageName;
  final Color color;
  final IconData icon;
  final String status;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: color, size: 21),
          SizedBox(width: 10.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: appTextStyle(context, TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800))),
            Text(label, style: appTextStyle(context, TextStyle(fontSize: 10.sp, color: AppColors.muted))),
          ]),
        ],
      );
}
