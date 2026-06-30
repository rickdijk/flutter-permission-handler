import 'package:flutter/foundation.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:permission_handler_platform_interface/src/method_channel/utils/codec.dart';

import 'src/pigeon/permission_handler_apple_api.g.dart';

/// iOS implementation of [PermissionHandlerPlatform] using Pigeon.
class PermissionHandlerApple extends PermissionHandlerPlatform {
  /// Constructs a [PermissionHandlerApple].
  PermissionHandlerApple({PermissionHandlerHostApi? hostApi})
      : _hostApi = hostApi ?? PermissionHandlerHostApi();

  final PermissionHandlerHostApi _hostApi;

  /// Registers the iOS plugin implementation.
  static void registerWith() {
    PermissionHandlerPlatform.instance = PermissionHandlerApple();
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    final status = await _hostApi.checkPermissionStatus(permission.value);
    return decodePermissionStatus(status);
  }

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async {
    final status = await _hostApi.checkServiceStatus(permission.value);
    return decodeServiceStatus(status);
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    final data = encodePermissions(permissions);
    final status = await _hostApi.requestPermissions(data);
    return decodePermissionRequestResult(
      status.map((key, value) => MapEntry(key!, value!)),
    );
  }

  @override
  Future<bool> openAppSettings() async {
    return _hostApi.openAppSettings();
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async {
    return SynchronousFuture(false);
  }
}
