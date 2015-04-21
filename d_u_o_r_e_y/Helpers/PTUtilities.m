//
//  PTUtilities.m
//  PhonTunes
//
//  Created by xdy on 13-12-20.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import "PTUtilities.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "PTAppClientEngine.h"

void addNotificationObserver(NSString *serverName,id observer, SEL selector,id anObject){
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:serverName object:anObject];
}

void removeNotificationObserver(NSString *serverName,id observer,id anObject){
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:serverName object:anObject];
}

void postNotification(NSString *serverName,id anObject, NSDictionary *userInfo){
    [[NSNotificationCenter defaultCenter] postNotificationName:serverName object:anObject userInfo:userInfo];
}

@implementation PTUtilities

#pragma mark - userInfo archive and unarchive
+ (id)unarchiveObjectWithName:(NSString *)name{
    NSString *filePath = [[NSString dataDirectory] stringByAppendingPathComponent:name];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiverUserInfo = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id result = [unarchiverUserInfo decodeObject];
    [unarchiverUserInfo finishDecoding];
    return result;
}

+ (void)archiveObject:(id)object withName:(NSString *)name{
    NSString *filePath = [[NSString dataDirectory] stringByAppendingPathComponent:name];
    if (object) {
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiverUserInfo = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiverUserInfo encodeObject:object];
        [archiverUserInfo finishEncoding];
        
        [data writeToFile:filePath atomically:YES];
    }else{
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath]) {
            [fm removeItemAtPath:filePath error:nil];
        }
    }
}

+ (void)saveLoginUser:(UserAccount *)user{
    [PTUtilities archiveObject:user withName:@"me"];
}
+ (UserAccount *)readLoginUser{
    return [PTUtilities unarchiveObjectWithName:@"me"];
}

+ (void)saveMyProfile:(SelfUserProfile *)profile{
    [PTUtilities archiveObject:profile withName:@"myprofile"];
}
+ (SelfUserProfile *)readMyProfile{
    return [PTUtilities unarchiveObjectWithName:@"myprofile"];
}

+ (void)saveOtherProfile:(OtherUserProfile *)otherProfile{
    [PTUtilities archiveObject:otherProfile withName:@"otherProfile"];
}
+ (OtherUserProfile *)readOtherProfile{
    return [PTUtilities unarchiveObjectWithName:@"otherProfile"];
}

+ (void)showAlertMessageWithTitle:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)buttonTitle{
//#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
//                                                                             message:message
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *ok = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [alertController dismissViewControllerAnimated:YES completion:nil];
//    }];
//    [alertController addAction:ok];
//    [self presentViewController:alertController animated:YES completion:nil];
//#else
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:buttonTitle
                                              otherButtonTitles:nil, nil];
    [alertView show];
//#endif
}

+ (void)sendGaTrackingWithScreenName:(NSString *)screenName category:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    id<GAITracker> tracker = ((AppDelegate *)[UIApplication sharedApplication].delegate).gaTracker;
    if (![PTUtilities isEmptyOrNull:screenName]) {
        [tracker set:kGAIScreenName value:screenName];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
    
    NSNumber *eventValue = nil;
    if (value != nil) {
        eventValue = value;
    }
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:eventValue] build]];
    [tracker set:kGAIScreenName value:nil];
}

#pragma mark - filesSizeCapArray

+ (NSArray *)filesSizeCapArray{
    static NSArray *_filesSizeCapArray=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _filesSizeCapArray = @[ @"B", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB", @"ZB", @"YB" ];
    });
    
    return _filesSizeCapArray;
}

#pragma mark - humanize file size

+ (NSString *)humanizeFileSize:(unsigned long long)filesize{
    NSUInteger cap = floor(logl(filesize) / log(1024));
    if (cap > 8) {
        return UNKNOWN_STRING;
    }
    return [NSString stringWithFormat:@"%.2f%@", filesize/pow(1024, cap), [self filesSizeCapArray][cap]];
}

#pragma mark - filesSizeCapArray

+ (NSArray *)filesExtensionCapArray{
    static NSArray *_filesExtensionCapArray=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _filesExtensionCapArray = @[ @"mp3", @"m4a"];
    });

    return _filesExtensionCapArray;
}

#pragma mark - FileName ext

+ (NSString *)fileNameExtension:(NSString *)ext{
	NSString *currentExt = @"mp3";
    if ([[self filesExtensionCapArray] containsObject:ext]) {
        currentExt = ext;
    }

    return currentExt;
}

#pragma mark - iOS version check

+(BOOL)isVersion7{
    return floor(NSFoundationVersionNumber) >NSFoundationVersionNumber_iOS_6_1;
}

#pragma mark - Local
+ (void)localNotificationWithMessage:(NSString *)message time:(NSDate *)date{
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.alertBody = message;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertAction = PTNSLocalizedString(@"localNotificationOkBtnKey", nil);
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - app current version

+ (NSString *)appCurrentVersion{
    static NSString *_currentVersion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    });

    return _currentVersion;
}

#pragma mark - check network

+ (BOOL)isNetWorkConnect
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - Date Calculations

+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

#pragma mark - screen height
+(BOOL)isTallPhone {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (screenSize.height > 480.0f);
}

+(BOOL)isSmallPhone {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && (screenSize.height <= 480.0f);
}

#pragma mark image url str
//获取平台图片格式Url
+ (NSURL *)returnImageURLWithStr:(NSString *)urlStr
                         withKey:(NSString *)keyStr
                        withSize:(NSString *)sizeStr{
    NSString *aUrlStr = [urlStr stringByReplacingOccurrencesOfString:keyStr
                                                          withString:sizeStr];
    return [NSURL URLWithString:aUrlStr];
}

//获取平台图片格式Url String
+ (NSString *)returnImageURLStrWithStr:(NSString *)urlStr
                               withKey:(NSString *)keyStr
                              withSize:(NSString *)sizeStr{
    return [urlStr stringByReplacingOccurrencesOfString:keyStr
                                             withString:sizeStr];
}

//判断字符串为空
+(BOOL) isEmptyOrNull:(NSString *) str {
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!str || str==nil ||  str == NULL) {
        // null object
        return YES;
    } else {
        NSString *trimedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            // empty string
            return YES;
        } else {
            // is neither empty nor null
            return NO;
        }
    }
}

//返回json的字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+(NSString *)returnStringHaveMark:(NSString *)str{
    return [str stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
}

+ (void)shareSongOrListWithID:(NSString *)listID songID:(NSString *)songID controller:(UIViewController *)controller {
    [SVProgressHUD show];
    __weak typeof(controller) wSelf = controller;
    UserAccount *user = [self readLoginUser];
    NSString *shareString = nil;
    if (listID) {
        shareString = [NSString stringWithFormat:@"l/%@/d/ios/u/%@",listID,user.userId];
    } else {
        shareString = [NSString stringWithFormat:@"s/%@/d/ios/u/%@",songID,user.userId];
    }
    [[PTAppClientEngine sharedClient] getShareShortAddressWithString:shareString completion:^(NSString *shareShortURL, NSError *error) {
        if (!error) {
            __strong typeof(wSelf) sSelf = wSelf;
            UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[shareShortURL] applicationActivities:nil];
            activityView.excludedActivityTypes = @[UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList];
            activityView.completionHandler = ^(NSString *activityType, BOOL completed){
                
            };
            [sSelf presentViewController:activityView animated:YES completion:nil];
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
}

+ (BOOL)shouldRefreshPlaylist {
    NSUserDefaults *stand = [NSUserDefaults standardUserDefaults];
    if ([stand objectForKey:@"NeedRefreshPlaylist"]) {
        return [[stand objectForKey:@"NeedRefreshPlaylist"] boolValue];
    }
    return YES;
}

+ (void)setNeedRefrshPlaylist:(BOOL)refresh {
    NSUserDefaults *stand = [NSUserDefaults standardUserDefaults];
    [stand setValue:[NSNumber numberWithBool:refresh] forKey:@"NeedRefreshPlaylist"];
    [stand synchronize];
}
@end
