//
//  PTUtilities.h
//  PhonTunes
//
//  Created by xdy on 13-12-20.
//  Copyright (c) 2013年 easeusiosapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PTEnum.h"
#import "NSString+Path.h"
#import "PTDefinitions.h"
#import <SVProgressHUD.h>
#import "PTConstant.h"
#import "UserAccount.h"
#import "SelfUserProfile.h"
#import "OtherUserProfile.h"
#import <AFNetworkReachabilityManager.h>
#import "AppDelegate.h"
#import "NSString+Additions.h"

void addNotificationObserver(NSString *serverName,id observer, SEL selector,id anObject);
void removeNotificationObserver(NSString *serverName,id observer,id anObject);
void postNotification(NSString *serverName,id anObject, NSDictionary *userInfo);

@interface PTUtilities : NSObject

#pragma mark - save local data

+ (id)unarchiveObjectWithName:(NSString *)name;

+ (void)archiveObject:(id)object withName:(NSString *)name;


+ (void)saveLoginUser:(UserAccount *)user;
+ (UserAccount *)readLoginUser;

+ (void)saveMyProfile:(SelfUserProfile *)profile;
+ (SelfUserProfile *)readMyProfile;

+ (void)saveOtherProfile:(OtherUserProfile *)otherProfile;
+ (OtherUserProfile *)readOtherProfile;

#pragma mark - alertMsg

+ (void)showAlertMessageWithTitle:(NSString *)title message:(NSString *)message okButtonTitle:(NSString *)buttonTitle;

#pragma mark - ga tracking

+ (void)sendGaTrackingWithScreenName:(NSString *)screenName category:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

+ (NSString *)humanizeFileSize:(unsigned long long)filesize;

#pragma mark - FileName ext

+ (NSString *)fileNameExtension:(NSString *)ext;

//iOS version check
+(BOOL)isVersion7;

//app current version
+ (NSString *)appCurrentVersion;

//check network connect
+ (BOOL)isNetWorkConnect;

#pragma mark - Date Calculations

+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

#pragma mark - screen height
+(BOOL)isTallPhone;
+(BOOL)isSmallPhone;
//在平台url中切图大图
+ (NSURL *)returnImageURLWithStr:(NSString *)urlStr
                         withKey:(NSString *)keyStr
                        withSize:(NSString *)sizeStr;

+ (NSString *)returnImageURLStrWithStr:(NSString *)urlStr
                               withKey:(NSString *)keyStr
                              withSize:(NSString *)sizeStr;

+(BOOL) isEmptyOrNull:(NSString *) str;
//返回json的字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
//替换单引号
+ (NSString *)returnStringHaveMark:(NSString *)str;

/**
 *  分享歌单或者歌曲，分享歌单  songID为nil 反之listID为nil
 *
 *  @param listID   歌单id
 *  @param songID   歌曲id
 *  @param controller    从哪个controller显示分享窗口
 *
 *  @return 
 */

+ (void)shareSongOrListWithID:(NSString *)listID songID:(NSString *)songID controller:(UIViewController *)controller;

//标示是否需要刷新歌单列表
+ (BOOL)shouldRefreshPlaylist;

//设置是否需要刷新歌单列表
+ (void)setNeedRefrshPlaylist:(BOOL)refresh;
@end
