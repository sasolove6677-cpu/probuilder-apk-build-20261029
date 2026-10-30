import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app_theme.dart';
import '../l10n/app_strings.dart';
import '../services/build_service.dart';
import '../widgets/glass_card.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  PlatformFile? _selectedHtml;
  PlatformFile? _selectedIcon;
  late final TextEditingController _outputNameController;
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    _outputNameController = TextEditingController();
  }

  @override
  void dispose() {
    _outputNameController.dispose();
    super.dispose();
  }

  Future<void> _pickHtml() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['html', 'htm'],
      withData: false,
    );
    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.size > 100 * 1024 * 1024) {
      _message(AppStrings.of(context).fileTooLarge);
      return;
    }
    if (file.path == null) {
      _message(AppStrings.of(context).chooseHtml);
      return;
    }
    setState(() {
      _selectedHtml = file;
      if (_outputNameController.text.trim().isEmpty) {
        _outputNameController.text = file.name.replaceFirst(RegExp(r'\.[^.]+$'), '');
      }
    });
  }

  Future<void> _pickIcon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null) {
      _message(AppStrings.of(context).chooseIcon);
      return;
    }
    setState(() => _selectedIcon = file);
  }

  Future<void> _startBuilding() async {
    final strings = AppStrings.of(context);
    final file = _selectedHtml;
    if (file?.path == null) {
      _message(strings.chooseFileFirst);
      return;
    }
    final extension = file!.extension?.toLowerCase();
    if (extension != 'html' && extension != 'htm') {
      _message(strings.chooseHtml);
      return;
    }
    final outputName = _outputNameController.text.trim();
    if (outputName.isEmpty) {
      _message(strings.enterOutputName);
      return;
    }

    setState(() => _isBuilding = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.neonBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                strings.building,
                style: appTextStyle(dialogContext),
              ),
            ),
          ],
        ),
      ),
    );

    BuildResult result;
    try {
      result = await BuildService().buildApk(
        htmlPath: file.path!,
        outputName: outputName,
        iconPath: _selectedIcon?.path,
      );
    } on PlatformException catch (error) {
      result = BuildResult(
        success: false,
        errorCode: error.code,
        message: error.message,
      );
    } catch (error) {
      result = BuildResult(
        success: false,
        errorCode: 'BUILD_ERROR',
        message: error.toString(),
      );
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _isBuilding = false);

    if (result.success) {
      _showBuildInfo(strings.projectReady, result.message ?? strings.apkBuildSuccess);
    } else {
      _showBuildInfo(strings.buildFailed, result.message ?? strings.buildUnavailable);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showBuildInfo(String title, String message) => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: appTextStyle(dialogContext)),
          content: Text(
            message,
            style: appTextStyle(dialogContext, const TextStyle(height: 1.45)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppStrings.of(dialogContext).ok),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.customizationStudio,
          style: appTextStyle(context, const TextStyle(fontWeight: FontWeight.w700)),
        ),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 30.h),
        children: [
          Text(
            strings.selectFile,
            style: appTextStyle(
              context,
              TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 10.h),
          GlassCard(
            onTap: _isBuilding ? null : _pickHtml,
            padding: EdgeInsets.all(20.w),
            glowColor: AppColors.neonBlue,
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: AppColors.neonBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: const Icon(
                    Icons.html_rounded,
                    color: AppColors.neonBlue,
                    size: 27,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedHtml?.name ?? strings.selectFile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appTextStyle(
                          context,
                          TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        strings.supportedFiles,
                        style: appTextStyle(
                          context,
                          TextStyle(fontSize: 10.sp, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          TextField(
            controller: _outputNameController,
            enabled: !_isBuilding,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: strings.outputFileName,
              hintText: strings.outputFileNameHint,
              prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded),
            ),
          ),
          SizedBox(height: 14.h),
          GlassCard(
            onTap: _isBuilding ? null : _pickIcon,
            padding: EdgeInsets.all(16.w),
            glowColor: AppColors.cyberGreen,
            child: Row(
              children: [
                const Icon(Icons.image_outlined, color: AppColors.cyberGreen),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _selectedIcon?.name ?? strings.chooseIcon,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyle(context),
                  ),
                ),
                const Icon(Icons.upload_rounded, color: AppColors.muted),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          SizedBox(
            height: 54.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonBlue.withValues(alpha: 0.22),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _isBuilding ? null : _startBuilding,
                icon: const Icon(Icons.bolt_rounded),
                label: Text(
                  strings.startBuilding,
                  style: appTextStyle(
                    context,
                    TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neonBlue,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
