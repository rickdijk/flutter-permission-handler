import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'permission_handler_apple',
    dartOut: 'lib/src/pigeon/permission_handler_apple_api.g.dart',
    dartOptions: DartOptions(),
    objcHeaderOut:
        'ios/permission_handler_apple/Sources/permission_handler_apple/pigeon/PermissionHandlerAppleApi.h',
    objcSourceOut:
        'ios/permission_handler_apple/Sources/permission_handler_apple/pigeon/PermissionHandlerAppleApi.m',
    objcOptions: ObjcOptions(prefix: 'PH'),
  ),
)
@HostApi()
abstract class PermissionHandlerHostApi {
  int checkPermissionStatus(int permission);

  @async
  int checkServiceStatus(int permission);

  @async
  Map<int?, int?> requestPermissions(List<int?> permissions);

  @async
  bool openAppSettings();
}
