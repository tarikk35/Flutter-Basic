#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  FlutterViewController* controller=(FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel* batteryChannel = [FlutterMethodChannel methodChannelWithName:@"flutter-birds.com/battery" binaryMessenger: controller];
  [batteryChannel setMethodCallHandler: ^(FlutterMethodCall* call, FlutterResult result){
    if([@"getBatterLevel" isEqualToString:call.method]){
      int batteryLevel = [self getBatterLevel];
       if (batteryLevel == -1) {
        result([FlutterError errorWithCode:@"UNAVAILABLE" message:@"Battery info not available" details:nil]);
      } else {
        result(@(batteryLevel));
      }
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (int)getBatteryLevel {
  UIDevice* device = UIDevice.currentDevice;
  device.batteryMonitoringEnabled = YES;
  if (device.batteryState == UIDeviceBatteryStateUnknown) {
    return -1;
  } else {
    return (int)(device.batteryLevel * 100);
  }
}

@end
