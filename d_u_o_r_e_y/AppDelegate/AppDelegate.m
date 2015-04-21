//
//  AppDelegate.m
//  Duorey
//
//  Created by xdy on 14/11/3.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <TwitterKit/TwitterKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ThirdpartyLoginViewController.h"
#import "UserAccount.h"
#import "PTUtilities.h"
#import "PTTheme.h"
#import <UALogger.h>
#import "YLAudioPlayer.h"
#import "Music.h"
#import <SCSoundCloud.h>
#import "AuthorizationViewController.h"
#import "PTConstant.h"
#import <UAAppReviewManager.h>
#import <AFNetworkActivityIndicatorManager.h>
#import "NetworkStatusRealTimeMonitor.h"
#import <iVersion.h>
#import "Flurry.h"
#import <Parse/Parse.h>
#import "ActivityViewController.h"
#import "PlaylistTableViewController.h"

static UIViewController * __originalRootViewController = nil;

@interface AppDelegate ()
@property (strong, nonatomic) UINavigationController *thirdpartyLoginVCNav;

@end

@implementation AppDelegate

@synthesize thirdpartyLoginVCNav = _thirdpartyLoginVCNav;

#pragma mark - app review

+ (void)setupUAAppReviewManager {
    [UAAppReviewManager setAppID:PHONTUNES_APPLE_ID];
    [UAAppReviewManager setDebug:NO];
    [UAAppReviewManager setOpensInStoreKit:NO];
    [UAAppReviewManager setDaysUntilPrompt:PHONTUNES_APPRATE_LIMITDAY];
    [UAAppReviewManager setUsesUntilPrompt:PHONTUNES_APPRATE_LIMITCOUNT];
}

+ (void)initialize{
    [AppDelegate setupUAAppReviewManager];
    [SCSoundCloud setClientID:SOUNDCLOUD_KEY secret:SOUNDCLOUD_SECRET redirectURL:[NSURL URLWithString:SOUNDCLOUD_CALLBACK_URL]];
}

#pragma mark - didLod
- (void)setThirdpartyAnalytics{
    [UAAppReviewManager showPromptIfNecessary];
    //    [[Twitter sharedInstance] startWithConsumerKey:TWITTER_CONSUMER_KEY
    //                                    consumerSecret:TWITTER_CONSUMER_SECRET];
    //    [Fabric with:@[[Twitter sharedInstance]]];
    [Fabric with:@[CrashlyticsKit]];
    //set Flurry Analytics
    [Flurry setCrashReportingEnabled:NO];
    [Flurry startSession:FLURRY_API_KEY];
    //更新提示
    [iVersion sharedInstance].applicationBundleID = PHONTUNES_BUNDLE_ID;
    //set parse
    [Parse setApplicationId:PARSE_APPLICATION_ID_KEY clientKey:PARSE_CLIENT_KEY];
    
    self.gaTracker = [[GAI sharedInstance] trackerWithName:@"Dourey_iOS" trackingId:GoogleAnalytics_Tracking_ID];
}

- (void)registerRemoteNotifications:(UIApplication *)application withOptions:(NSDictionary *)launchOptions{
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //开启锁屏控制
    [PTUtilities setNeedRefrshPlaylist:YES];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    addNotificationObserver(DuoreyDidLoginNotification, self, @selector(loginSuccess:), nil);
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[NetworkStatusRealTimeMonitor sharedNetworkMonitor] startMonitoring];
    [PTThemeManager customizeAppAppearance];
    SET_DEFAULTS(Bool, NoWifiPlaySettingCancel, NO);
    
    //第三方统计代码
    [self setThirdpartyAnalytics];
    
    //注册远程通知
    [self registerRemoteNotifications:application withOptions:launchOptions];
    
    UserAccount *user = [PTUtilities readLoginUser];
    if (!user) {
        [self showIntroductionView];
    }else{
        [[NetworkStatusRealTimeMonitor sharedNetworkMonitor] addReachabilityStatusNotification];
    }
    [self setRootDelegate];
    return YES; 
}

- (void)showIntroductionView{
    [[NetworkStatusRealTimeMonitor sharedNetworkMonitor] removeReachabilityStatusNotification];
    __originalRootViewController = self.window.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.thirdpartyLoginVCNav = [storyboard instantiateViewControllerWithIdentifier:@"thirdpartyLoginVCNav"];
//    ThirdpartyLoginViewController *tloginvc = [[self.thirdpartyLoginVCNav viewControllers] firstObject];
//    tloginvc.delegate = self;
    self.window.rootViewController = self.thirdpartyLoginVCNav;
}

-(void)setRootDelegate
{
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *controller = (UITabBarController *)self.window.rootViewController;
        controller.delegate = self;
    }
}

#pragma mark - thirdparty login delegate
- (void)loginSuccess:(NSNotification *)notification{
    UserAccount *user = [notification object];
    if (user) {
        [[NetworkStatusRealTimeMonitor sharedNetworkMonitor] addReachabilityStatusNotification];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
        [self setRootDelegate];
    }
}

//- (void)thirdpartyLoginViewController:(ThirdpartyLoginViewController *)controller didLoginSuccess:(UserAccount *)user{
//    if (user) {
//        [[NetworkStatusRealTimeMonitor sharedNetworkMonitor] addReachabilityStatusNotification];
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
//        [self setRootDelegate];
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [UAAppReviewManager showPromptWithShouldPromptBlock:^BOOL(NSDictionary *trackingInfo) {
        return NO;
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActive];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    [application cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [FBSession.activeSession close];
    removeNotificationObserver(DuoreyDidLoginNotification, self, nil);
    [PTUtilities setNeedRefrshPlaylist:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *listIdStr = [userDefaults objectForKey:@"playlistDetailPageAllPlayListId"];
    if (listIdStr) {
        [userDefaults removeObjectForKey:listIdStr];
        [userDefaults removeObjectForKey:@"playlistDetailPageAllPlayListId"];
    }
    [userDefaults setObject:@"off" forKey:@"iTunesPlaylistAllPlay"];
    [userDefaults synchronize];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    UALog(@"url...%@,sourceApplication...%@",url,sourceApplication);
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark - remote notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    if (error.code == 3010) {
        UALog(@"Push notifications are not supported in the iOS Simulator.");
    }else{
        UALog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

#pragma mark - remote Control

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        int eventType = event.subtype;
        switch (eventType) {
            case UIEventSubtypeRemoteControlPlay:
                [[YLAudioPlayer sharedAudioPlayer] play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [[YLAudioPlayer sharedAudioPlayer] pause];
                break;
            case UIEventSubtypeRemoteControlStop:
                [[YLAudioPlayer sharedAudioPlayer] pause];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if ([YLAudioPlayer sharedAudioPlayer].isPlaying) {
                    [[YLAudioPlayer sharedAudioPlayer] pause];
                }else{
                    [[YLAudioPlayer sharedAudioPlayer] play];
                }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[YLAudioPlayer sharedAudioPlayer] next];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[YLAudioPlayer sharedAudioPlayer] previous];
                break;
        }
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([YLAudioPlayer sharedAudioPlayer].isPlaying) {
        postNotification(START_BALANCER_ANIMATION, [[YLAudioPlayer sharedAudioPlayer] currentPlayMusic], nil);
    }
    else
    {
       postNotification(STOP_BALANCER_ANIMATION, [[YLAudioPlayer sharedAudioPlayer] currentPlayMusic], nil);
    }
    if (tabBarController.selectedIndex == 1)
    {
        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *nav = (UINavigationController *)viewController;
            if([nav.viewControllers count] == 1)
            {
                if ([nav.topViewController isKindOfClass:[ActivityViewController class]]) {
                    ActivityViewController *activity = (ActivityViewController *)nav.topViewController;
                    [activity reloadActivityData];
                }
            }
        }
    }
    if (tabBarController.selectedIndex == 2)
    {
        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *nav = (UINavigationController *)viewController;
            if([nav.viewControllers count] == 1)
            {
                if ([nav.topViewController isKindOfClass:[PlaylistTableViewController class]]) {
                    PlaylistTableViewController *playlist = (PlaylistTableViewController *)nav.topViewController;
                    [playlist reloadPlaylistData];
                }
            }
        }
    }
}

@end
