//
//  PTAppClientEngine.h
//  PhonTunes
//
//  Created by PhonTunes on 14-6-13.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AFHTTPSessionManager.h>
#import "UserAccount.h"
#import "PTUtilities.h"
#import "NSString+Hash.h"
#import "PTDefinitions.h"
#import <UALogger.h>
#import "PlaylistObj.h"
#import "OneListObj.h"
#import "MainViewObj.h"
#import "SelfUserProfile.h"
#import "OtherUserProfile.h"
#import "Music.h"
#import "ActivityObj.h"
#import "PubPlaylist.h"

typedef NS_ENUM (NSUInteger, UserFollowAct){
    UserFollowActAdd=1,
    UserFollowActDel
};

typedef NS_ENUM(NSInteger, HTPPResponseCode){
    HTTPResponseCodeError = 0,
    HTTPResponseCodeSuccess = 1,
    HTTPResponseCodeTokenExpire = 200
};

@interface PTAppClientEngine : AFHTTPSessionManager

+ (instancetype)sharedClient;

/**
 *  第三方帐号登录（注册）
 *
 *  @param userid         第三方用户id
 *  @param nickname       第三方昵称
 *  @param pImageLargeURL 第三方头像URL
 *  @param userType       UserType: UserTypeTwitter or UserTypeFacebook
 *  @param block          (void(^)(UserAccount *user,NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)thirdpartyLoginDuoreySystemWithUserId:(NSString *)userid
                                                       nickname:(NSString *)nickname
                                                 pImageLargeURL:(NSString *)pImageLargeURL
                                                       userType:(UserType)userType
                                                     completion:(void(^)(UserAccount *user,NSError *error))block;
/**
 *  Email登录
 *
 *  @param email    Email
 *  @param password 密码
 *  @param block    (void(^)(UserAccount *user,NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)emailLoginDuoreySystemWithEmail:(NSString *)email
                                                 password:(NSString *)password
                                               completion:(void(^)(UserAccount *user,NSError *error))block;
/**
 *  Email注册
 *
 *  @param email    email
 *  @param password 密码
 *  @param userType UserType: UserTypeSystem
 *  @param block    (void(^)(UserAccount *user,NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)emailSignupDuoreySystemWithEmail:(NSString *)email
                                                 password:(NSString *)password
                                                 userType:(UserType)userType
                                               completion:(void(^)(UserAccount *user,NSError *error))block;
/**
 *  Email忘记密码
 *
 *  @param email    用户Email
 *  @param userType UserType: UserTypeSystem
 *  @param block    (void(^)(NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)emailForgotPasswordWithEmail:(NSString *)email
                                              userType:(UserType)userType
                                            completion:(void(^)(NSError *error))block;

/**
 *  更新用户基本信息
 *
 *  @param userId   唯一用户编号
 *  @param token    token
 *  @param aImage   头像
 *  @param bImage   背景
 *  @param nickName 昵称
 *  @param desc     描述
 *  @param block    (void(^)(UserAccount *user,NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)updateUserProfileWithUserId:(NSNumber *)userId
                                                token:(NSString *)token
                                          avatarImage:(NSString *)aImage
                                      backgroundImage:(NSString *)bImage
                                             nickName:(NSString *)nickName
                                             userDesc:(NSString *)desc
                                           completion:(void(^)(UserAccount *user,NSError *error))block;

/**
 *  查找自己的首页信息
 *
 *  @param userId 自己的id
 *  @param token  duorey系统token
 *  @param block  (void(^)(SelfUserProfile *user,NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)findSelfProfileWithUserId:(NSNumber *)userId
                                              token:(NSString *)token
                                           completion:(void(^)(SelfUserProfile *user,NSError *error))block;

/**
 *  查找其他用户的Profile
 *
 *  @param userId 系统用户的userid
 *  @param token  duorey系统token
 *  @param otherUserId 查找用户的的userid
 *  @param block  (void(^)(OtherUserProfile *user,NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)findUserProfileWithUserId:(NSNumber *)userId
                                              token:(NSString *)token
                                        otherUserId:(NSNumber *)otherUserId
                                         completion:(void(^)(OtherUserProfile *user,NSError *error))block;

/**
 *  添加用户播放历史记录
 *
 *  @param userId    用户id
 *  @param token     token
 *  @param musicId   歌曲id
 *  @param musicName 歌曲名称
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)addUserRecentPlayWithUserId:(NSNumber *)userId
                                                token:(NSString *)token
                                              musicId:(NSNumber *)musicId
                                            musicName:(NSString *)musicName;

/**
 *  用户关注其他用户和取消用户操作
 *
 *  @param userId      sysUserId
 *  @param token       token
 *  @param otherUserId 关注用户的Id
 *  @param type        UserFollowAct,UserFollowActAdd执行add，UserFollowActDel执行取消关注
 *  @param block       (void(^)(NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)userFollowActWithUserId:(NSNumber *)userId
                                            token:(NSString *)token
                                      otherUserId:(NSNumber *)otherUserId
                                          actType:(UserFollowAct)type
                                         completion:(void(^)(NSError *error))block;

/**
 *  获取当前用户的follow用户列表
 *
 *  @param userId 当前用户id
 *  @param token  token，系统用户token
 *  @param page   页码，第一页为page=1，后续+1
 *  @param otherUserId,可为空，如果查看的是其他人，必须添加
 *  @param block  (void(^)(NSArray *follows,NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)fetchUserFollowUsersWithUserId:(NSNumber *)userId
                                                   token:(NSString *)token
                                                    page:(NSInteger)page
                                             otherUserId:(NSNumber *)otherUserId
                                              completion:(void(^)(NSArray *follows,NSError *error))block;

/**
 *  获取当前用户的followed用户列表
 *
 *  @param userId 当前用户id
 *  @param token  token，系统用户token
 *  @param page   页码，第一页为page=1，后续+1
 *  @param otherUserId,可为空，如果查看的是其他人，必须添加
 *  @param block  (void(^)(NSArray *followeds,NSError *error))block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)fetchUserFollowedUsersWithUserId:(NSNumber *)userId
                                                     token:(NSString *)token
                                                      page:(NSInteger)page
                                               otherUserId:(NSNumber *)otherUserId
                                                completion:(void(^)(NSArray *followeds,NSError *error))block;

//创建一个歌单
- (NSURLSessionDataTask *)creatPlaylistWithPlaylistName:(NSString *)playlistName
                                                 userId:(NSString *)userId
                                                  token:(NSString *)tokenStr
                                             completion:(void(^)(NSString *listId,NSError *error))block;
//获取自己关注的歌单
- (NSURLSessionDataTask *)getPlaylistAndFollowlistWithUserId:(NSString *)userId
                                                       token:(NSString *)tokenStr
                                                        page:(int)pageCount
                                                  completion:(void(^)(NSArray *playlists, NSError *error))block;
//获取其他人关注的歌单
- (NSURLSessionDataTask *)getOtherPlaylistAndFollowlistWithUserId:(NSString *)userId
                                                            token:(NSString *)tokenStr
                                                     targetUserId:(NSString *)targetUserId
                                                             page:(int)page
                                                       completion:(void(^)(NSArray *playlists,NSError *error))block;
//获取单个歌单里面所有内容
- (NSURLSessionDataTask *)getOneListWithUserId:(NSString *)userId
                                         token:(NSString *)tokenStr
                                        listId:(NSString *)listId
                                          page:(int)pageCount
                                    completion:(void(^)(PubPlaylist *pubPlaylistObj,NSError *error))block;

//添加一个歌曲到以存在的歌单里
- (NSURLSessionDataTask *)addOneMusicToHaveListWithMusicDic:(NSMutableDictionary *)musicDic
                                                 completion:(void(^)(NSError *error))block;
//在歌单中删除自己添加的歌曲
- (NSURLSessionDataTask *)deleteOneMusicWithMusicDic:(NSMutableDictionary *)musicDic
                                          completion:(void(^)(NSError *error))block;
//添加一个歌曲到新建歌单里
- (NSURLSessionDataTask *)addOneMusicToCreatListWithMusicDic:(NSMutableDictionary *)musicDic
                                                  completion:(void(^)(NSError *error))block;
//获取主页所有内容
- (NSURLSessionDataTask *)getMainViewListWithMusicWithUserId:(NSString *)userId
                                                       token:(NSString *)tokenStr
                                                        page:(int)pageCount
                                           completion:(void(^)(NSMutableDictionary *values, NSError *error))block;

//获取主页更多内容
- (NSURLSessionDataTask *)getMainViewListMoreWithMusicWithUserId:(NSString *)userId
                                                           token:(NSString *)tokenStr
                                                            type:(NSString *)typeStr
                                                            page:(int)pageCount
                                                      completion:(void(^)(NSArray *values, NSError *error))block;

//关注或取消关注歌单
- (NSURLSessionDataTask *)playlistFlowWithUserId:(NSString *)userId
                                          listId:(NSString *)listId
                                           token:(NSString *)tokenStr
                                          action:(NSString *)actStr
                                      completion:(void(^)(PlaylistObj *playlist,NSError *error))block;
//赞或取消赞歌单
- (NSURLSessionDataTask *)playlistPraiseWithUserId:(NSString *)userId
                                            listId:(NSString *)listId
                                             token:(NSString *)tokenStr
                                            action:(NSString *)actStr
                                        completion:(void(^)(PlaylistObj *playlist,NSError *error))block;
//搜索歌单
- (NSURLSessionDataTask *)searchListWitUserId:(NSString *)userId
                                    withToken:(NSString *)tokenStr
                                 withKeywords:(NSString *)keywords
                                   completion:(void(^)(NSArray *playlists,NSError *error))block;
/*
 获取用户动态
 */
- (NSURLSessionDataTask *)activityWithUserId:(NSString *)userId
                                       token:(NSString *)tokenStr
                                        page:(NSInteger)page
                                  completion:(void(^)(NSArray *activity,NSError *error))block;

//修改歌单信息
- (NSURLSessionDataTask *)editPlaylistInfoWithDic:(NSMutableDictionary *)playlistDic
                                       completion:(void(^)(NSError *error))block;

//导入soundCloud歌单
- (NSURLSessionDataTask *)importPlatlistWithDic:(NSMutableDictionary *)playlistDic
                                     completion:(void(^)(NSError *error))block;

//记录歌单播放次数
- (NSURLSessionDataTask *)recentPlaylistWithDic:(NSMutableDictionary *)playlistDic
                                     completion:(void(^)(NSError *error))block;

//获取赞歌单的所用用户
- (NSURLSessionDataTask *)getPlaylistLikersWithDic:(NSMutableDictionary *)playlistDic
                                        completion:(void(^)(NSArray *users,NSError *error))block;
//获取关注歌单的所用用户
- (NSURLSessionDataTask *)getPlaylistFeedersWithDic:(NSMutableDictionary *)playlistDic
                                         completion:(void(^)(NSArray *users,NSError *error))block;
/**
 *  增加歌单的播放次数
 *
 *  @param userId   user id
 *  @param tokenStr token
 *  @param lid      歌单id
 *  @param sid      歌曲id
 *  @param block    block结果
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)increasePlaylistPlayingCountWithUserId:(NSNumber *)userId token:(NSString *)tokenStr playlistId:(NSString *)lid songId:(NSString *)sid completionBlock:(void (^)(BOOL success, NSError *error))block;

//获取分享歌曲或歌单短地址
- (NSURLSessionDataTask *)getShareShortAddressWithString:(NSString *)shareOriginStr
                                         completion:(void(^)(NSString *shareShortURL,NSError *error))block;
@end
