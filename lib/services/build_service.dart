import 'package:flutter/services.dart';

class BuildResult {
  const BuildResult({
    required this.success,
    this.apkPath,
    this.errorCode,
    this.message,
  });

  final bool success;
  final String? apkPath;
  final String? errorCode;
  final String? message;
}

class BuildService {
  static const MethodChannel _channel =
      MethodChannel('com.waelatef.probuilder/build_engine');

  Future<BuildResult> buildApk({
    required String htmlPath,
    required String outputName,
    String? iconPath,
  }) async {
    final raw = await _channel.invokeMapMethod<String, dynamic>('buildApk', {
      'htmlPath': htmlPath,
      'outputName': outputName,
      'iconPath': iconPath,
    });
    if (raw == null) {
      return const BuildResult(success: false, errorCode: 'EMPTY_RESULT');
    }
    return BuildResult(
      success: raw['success'] == true,
      apkPath: raw['apkPath'] as String?,
      errorCode: raw['errorCode'] as String?,
      message: raw['message'] as String?,
    );
  }
}
