//
//  JZTUNIAppDelegate.m
//  JZTUniBoost
//
//  Created by 8772037@qq.com on 03/01/2021.
//  Copyright (c) 2021 8772037@qq.com. All rights reserved.
//

#import "JZTUNIAppDelegate.h"
#import "JZTUniAppManager.h"
#import "DCUniMP.h"
#import "WeexSDK.h"
@implementation JZTUNIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:launchOptions];
   [options setObject:[NSNumber numberWithBool:YES] forKey:@"debug"];
   [DCUniMPSDKEngine initSDKEnvironmentWithLaunchOptions:options];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [DCUniMPSDKEngine applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [DCUniMPSDKEngine applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [DCUniMPSDKEngine applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [DCUniMPSDKEngine applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [DCUniMPSDKEngine destory];
}

@end
