import 'dart:io';

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
  final _appName = TextEditingController(text: 'Pro App');
  final _packageName = TextEditingController(text: 'com.pro.app');
  PlatformFile? _selectedDocument;
  PlatformFile? _selectedIcon;
  bool _isBuilding = false;

  @override
  void initState() {
    super.initState();
    _appName.addListener(_refreshPreview);
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _appName.removeListener(_refreshPreview);
    _appName.dispose();
    _packageName.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['html', 'htm', 'zip', 'pdf'],
      withData: false,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.size > 100 * 1024 * 1024) {
      _message(AppStrings.of(context).fileTooLarge);
      return;
    }
    setState(() => _selectedDocument = file);
  }

  Future<void> _pickIcon() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      withData: false,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    setState(() => _selectedIcon = result.files.single);
  }

  Future<void> _startBuilding() async {
    final strings = AppStrings.of(context);
    final file = _selectedDocument;
    if (file == null || file.path == null) {
      _message(strings.chooseFileFirst);
      return;
    }
    final extension = file.extension?.toLowerCase();
    if (extension != 'html' && extension != 'htm') {
      _message(strings.chooseHtml);
      return;
    }
    if (_appName.text.trim().isEmpty || !_isValidPackage(_packageName.text.trim())) {
      _message(strings.invalidAppDetails);
      return;
    }

    setState(() => _isBuilding = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Row(children: [
          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.neonBlue)),
          const SizedBox(width: 16),
          Expanded(child: Text(strings.building, style: appTextStyle(dialogContext))),
        ]),
      ),
    );

    BuildResult result;
    try {
      result = await BuildService().buildApk(
        htmlPath: file.path!,
        appName: _appName.text.trim(),
        packageName: _packageName.text.trim(),
        iconPath: _selectedIcon?.path,
      );
    } on PlatformException catch (error) {
      result = BuildResult(success: false, errorCode: error.code, message: error.message);
    } catch (error) {
      result = BuildResult(success: false, errorCode: 'BUILD_ERROR', message: error.toString());
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _isBuilding = false);
    if (result.success) {
      _message(result.apkPath ?? strings.projectReady);
    } else {
      _showBuildInfo(result.errorCode == 'HOST_BUILDER_REQUIRED'
          ? strings.buildUnavailable
          : (result.message ?? strings.buildUnavailable));
    }
  }

  bool _isValidPackage(String value) =>
      RegExp(r'^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$').hasMatch(value);

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showBuildInfo(String text) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(AppStrings.of(context).startBuilding, style: appTextStyle(context)),
          content: Text(text, style: appTextStyle(context, const TextStyle(height: 1.45))),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.of(context).ok))],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.customizationStudio, style: appTextStyle(context, const TextStyle(fontWeight: FontWeight.w700))),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 30.h),
        children: [
          Text(strings.selectFile, style: appTextStyle(context, TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700))),
          SizedBox(height: 10.h),
          GlassCard(
            onTap: _pickDocument,
            padding: EdgeInsets.all(20.w),
            glowColor: AppColors.neonBlue,
            child: Row(children: [
              Container(
                width: 52.w, height: 52.w,
                decoration: BoxDecoration(color: AppColors.neonBlue.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(16.r)),
                child: const Icon(Icons.upload_file_rounded, color: AppColors.neonBlue, size: 27),
              ),
              SizedBox(width: 14.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_selectedDocument?.name ?? strings.selectFile, maxLines: 1, overflow: TextOverflow.ellipsis, style: appTextStyle(context, TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700))),
                SizedBox(height: 5.h),
                Text(strings.supportedFiles, style: appTextStyle(context, TextStyle(fontSize: 10.sp, color: AppColors.muted))),
              ])),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ]),
          ),
          SizedBox(height: 22.h),
          Text(strings.appDetails, style: appTextStyle(context, TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700))),
          SizedBox(height: 10.h),
          TextField(
            controller: _appName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: strings.appName, prefixIcon: const Icon(Icons.apps_rounded)),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _packageName,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(labelText: strings.packageName, prefixIcon: const Icon(Icons.tag_rounded)),
          ),
          SizedBox(height: 22.h),
          Text(strings.uploadIcon, style: appTextStyle(context, TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700))),
          SizedBox(height: 10.h),
          GlassCard(
            onTap: _pickIcon,
            padding: EdgeInsets.all(13.w),
            child: Row(children: [
              _IconPreview(path: _selectedIcon?.path, size: 52),
              SizedBox(width: 13.w),
              Expanded(child: Text(_selectedIcon?.name ?? strings.noIcon, maxLines: 1, overflow: TextOverflow.ellipsis, style: appTextStyle(context, TextStyle(fontSize: 13.sp, color: AppColors.muted)))),
              TextButton(onPressed: _pickIcon, child: Text(strings.chooseIcon, style: appTextStyle(context, const TextStyle(color: AppColors.neonBlue)))),
            ]),
          ),
          SizedBox(height: 22.h),
          Text(strings.preview, style: appTextStyle(context, TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700))),
          SizedBox(height: 10.h),
          Center(child: _PhonePreview(appName: _appName.text, iconPath: _selectedIcon?.path)),
          SizedBox(height: 22.h),
          SizedBox(
            height: 54.h,
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), boxShadow: [BoxShadow(color: AppColors.neonBlue.withValues(alpha: 0.22), blurRadius: 22, spreadRadius: 1)]),
              child: FilledButton.icon(
                onPressed: _isBuilding ? null : _startBuilding,
                icon: const Icon(Icons.bolt_rounded),
                label: Text(strings.startBuilding, style: appTextStyle(context, TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800))),
                style: FilledButton.styleFrom(backgroundColor: AppColors.neonBlue, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconPreview extends StatelessWidget {
  const _IconPreview({this.path, required this.size});
  final String? path;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size.w, height: size.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppColors.neonBlue.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(15.r), border: Border.all(color: Colors.white.withValues(alpha: 0.10))),
        child: path == null ? const Icon(Icons.image_outlined, color: AppColors.neonBlue) : Image.file(File(path!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.neonBlue)),
      );
}

class _PhonePreview extends StatelessWidget {
  const _PhonePreview({required this.appName, this.iconPath});
  final String appName;
  final String? iconPath;
  @override
  Widget build(BuildContext context) => Container(
        width: 180.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(color: const Color(0xFF171B22), borderRadius: BorderRadius.circular(29.r), border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 2), boxShadow: [BoxShadow(color: AppColors.cyberGreen.withValues(alpha: 0.09), blurRadius: 24)]),
        child: Column(children: [
          Container(width: 42.w, height: 4.h, margin: EdgeInsets.only(bottom: 16.h), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(5.r))),
          Container(height: 95.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF102B38), Color(0xFF102018)])), child: const Center(child: Icon(Icons.web_rounded, color: AppColors.neonBlue, size: 33))),
          SizedBox(height: 13.h),
          _IconPreview(path: iconPath, size: 52),
          SizedBox(height: 7.h),
          Text(appName.isEmpty ? 'Pro App' : appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: appTextStyle(context, const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
          SizedBox(height: 6.h),
        ]),
      );
}
