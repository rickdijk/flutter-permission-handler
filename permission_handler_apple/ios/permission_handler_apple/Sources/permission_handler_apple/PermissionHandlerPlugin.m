#import "PermissionHandlerPlugin.h"
#import "PermissionHandlerAppleApi.h"
#import "Codec.h"

@interface PermissionHandlerPlugin () <PHPermissionHandlerHostApi>
@end

@implementation PermissionHandlerPlugin {
    PermissionManager *_Nonnull _permissionManager;
    BOOL _permissionRequestInProgress;
}

- (instancetype)initWithPermissionManager:(PermissionManager *)permissionManager {
    self = [super init];
    if (self) {
        _permissionManager = permissionManager;
    }

    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    PermissionManager *permissionManager = [[PermissionManager alloc] initWithStrategyInstances];
    PermissionHandlerPlugin *instance = [[PermissionHandlerPlugin alloc] initWithPermissionManager:permissionManager];
    SetUpPHPermissionHandlerHostApi([registrar messenger], instance);
}

#pragma mark - PHPermissionHandlerHostApi

- (nullable NSNumber *)checkPermissionStatusPermission:(NSInteger)permission
                                                  error:(FlutterError *_Nullable *_Nonnull)error {
    __block NSNumber *statusResult = nil;
    [PermissionManager checkPermissionStatus:(PermissionGroup)permission
                                      result:^(id result) {
                                          statusResult = result;
                                      }];
    return statusResult;
}

- (void)checkServiceStatusPermission:(NSInteger)permission
                          completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
    [PermissionManager checkServiceStatus:(PermissionGroup)permission
                                   result:^(id result) {
                                       completion(result, nil);
                                   }];
}

- (void)requestPermissionsPermissions:(NSArray<NSNumber *> *)permissions
                           completion:(void (^)(NSDictionary<NSNumber *, NSNumber *> *_Nullable,
                                                FlutterError *_Nullable))completion {
    if (_permissionRequestInProgress) {
        completion(nil, [FlutterError
            errorWithCode:@"ERROR_ALREADY_REQUESTING_PERMISSIONS"
                  message:@"A request for permissions is already running, please wait for it to "
                          @"finish before doing another request (note that you can request "
                          @"multiple permissions at the same time)."
                  details:nil]);
        return;
    }

    _permissionRequestInProgress = YES;
    NSArray *permissionGroups = [Codec decodePermissionGroupsFrom:permissions];

    [_permissionManager
        requestPermissions:permissionGroups
                completion:^(NSDictionary *permissionRequestResults) {
                    self->_permissionRequestInProgress = NO;
                    completion(permissionRequestResults, nil);
                }
            errorHandler:^(NSString *errorCode, NSString *errorDescription) {
                self->_permissionRequestInProgress = NO;
                completion(nil, [FlutterError errorWithCode:errorCode
                                                    message:errorDescription
                                                    details:nil]);
            }];
}

- (void)openAppSettingsWithCompletion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
    [PermissionManager openAppSettings:^(id result) {
        completion(result, nil);
    }];
}

@end
