
//  PTAppClientEngine.m
//  PhonTunes
//
//  Created by PhonTunes on 14-6-13.
//  Copyright (c) 2014年 easeusiosapp. All rights reserved.
//

#import "PTAppClientEngine.h"
#import "NSString+Additions.h"
#import "PlaylistDetail.h"
#import "NSDictionary+Additions.h"


//#ifdef DEBUG
//return NO;
//#else
//return YES;
//#endif
//static NSString * const AFAppDotNetAPIBaseURLString = @"http://app.duorey.com/v1/";
//static NSString * const AFAppDotNetAPIBaseURLString = @"http://192.168.1.221/v1/";
static NSString * const AFAppDotNetAPIBaseURLString = @"http://test.duorey.com/v2/";

@implementation PTAppClientEngine

+ (instancetype)sharedClient {
    static PTAppClientEngine *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PTAppClientEngine alloc] initWithBaseURL:[NSURL URLWithString:AFAppDotNetAPIBaseURLString]];
//        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

- (NSURLSessionDataTask *)thirdpartyLoginDuoreySystemWithUserId:(NSString *)userid
                                                       nickname:(NSString *)nickname
                                                 pImageLargeURL:(NSString *)pImageLargeURL
                                                       userType:(UserType)userType
                                                     completion:(void(^)(UserAccount *user,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userid forKey:@"user_ext_id"];
    [parameters setObject:nickname forKey:@"nick_name"];
    [parameters setObject:pImageLargeURL forKey:@"user_ico"];
    [parameters setObject:[NSNumber numberWithInt:userType] forKey:@"type"];
    
//#warning 供测试使用
//    if (userType == UserTypeTwitter) {
//        SET_DEFAULTS(Object, @"Twitter", parameters);
//    }else if(userType == UserTypeFacebook){
//        SET_DEFAULTS(Object, @"Facebook", parameters);
//    }
    
    return [self POST:@"user/create"
           parameters:parameters
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  UALog(@"thirdparty log...%@",responseObject);
                  if ([[responseObject objectForKey:@"success"] intValue] == HTTPResponseCodeSuccess) {
                      UserAccount *user = [MTLJSONAdapter modelOfClass:UserAccount.class fromJSONDictionary:[responseObject objectForKey:@"data"] error:nil];
                      user.tryUseApp = NO;
                      UserAccount *sysUser = [PTUtilities readLoginUser];
                      if (sysUser && [sysUser.userId intValue] == [user.userId intValue]){
                          user.spotifyAccount = sysUser.spotifyAccount;
                          user.rdioAccount = sysUser.rdioAccount;
                          user.soundCloudAccount = sysUser.soundCloudAccount;
                      }
                      [PTUtilities saveLoginUser:user];
                      
                      if (block) {
                          block(user,nil);
                      }
                  }else{
                      if (block) {
//                          block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                          block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"EmailLoginErrorMsgKey", nil)}]);
                      }
                  }
                  
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
//                    block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
                    block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
                }
            }];
}

- (NSURLSessionDataTask *)emailLoginDuoreySystemWithEmail:(NSString *)email
                                                 password:(NSString *)password
                                               completion:(void(^)(UserAccount *user,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"user_email"];
    [parameters setObject:password forKey:@"user_pwd"];
    return [self POST:@"user/login" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"email login ...%@",responseObject);
        if ([[responseObject objectForKey:@"success"] intValue] == HTTPResponseCodeSuccess) {
            UserAccount *user = [MTLJSONAdapter modelOfClass:UserAccount.class fromJSONDictionary:[responseObject objectForKey:@"data"] error:nil];
            user.tryUseApp = NO;
            UserAccount *sysUser = [PTUtilities readLoginUser];
            if (sysUser && [sysUser.userId intValue]==[user.userId intValue]){
                user.spotifyAccount = sysUser.spotifyAccount;
                user.rdioAccount = sysUser.rdioAccount;
                user.soundCloudAccount = sysUser.soundCloudAccount;
            }
            [PTUtilities saveLoginUser:user];
            
            if (block) {
                block(user,nil);
            }
        }else{
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"EmailLoginErrorMsgKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)emailSignupDuoreySystemWithEmail:(NSString *)email
                                                  password:(NSString *)password
                                                  userType:(UserType)userType
                                                completion:(void(^)(UserAccount *user,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"user_email"];
    [parameters setObject:password forKey:@"user_pwd"];
    [parameters setObject:[NSNumber numberWithInt:userType] forKey:@"type"];
    return [self POST:@"user/create" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"email singup ...%@",responseObject);
        if ([[responseObject objectForKey:@"success"] intValue] == HTTPResponseCodeSuccess) {
            UserAccount *user = [MTLJSONAdapter modelOfClass:UserAccount.class fromJSONDictionary:[responseObject objectForKey:@"data"] error:nil];
            user.tryUseApp = NO;
            [PTUtilities saveLoginUser:user];
            
            if (block) {
                block(user,nil);
            }
        }else{
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"SigupErrorMsgKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}


- (NSURLSessionDataTask *)emailForgotPasswordWithEmail:(NSString *)email
                                              userType:(UserType)userType
                                            completion:(void(^)(NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:email forKey:@"user_email"];
    [parameters setObject:[NSNumber numberWithInt:userType] forKey:@"type"];
    return [self POST:@"user/forget" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"success"] intValue] == HTTPResponseCodeSuccess) {
            if (block) {
                 block(nil);
            }
        }else{
            if (block) {
//                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"forgetEmailErrorMsgKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)updateUserProfileWithUserId:(NSNumber *)userId
                                                token:(NSString *)token
                                          avatarImage:(NSString *)aImage
                                      backgroundImage:(NSString *)bImage
                                             nickName:(NSString *)nickName
                                             userDesc:(NSString *)desc
                                           completion:(void (^)(UserAccount *, NSError *))block{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:token forKey:@"token"];
    
    if (![aImage isEmpty]) {
        [parameters setObject:aImage forKey:@"user_ico"];
    }
    
    if (![aImage isEmpty]) {
        [parameters setObject:bImage forKey:@"user_back_img"];
    }
    
    if (![nickName isEmpty]) {
        [parameters setObject:nickName forKey:@"nick_name"];
    }
    
//    if (![desc isEmpty]) {
//        [parameters setObject:desc forKey:@"user_sig"];
//    }
    
    [parameters setObject:desc forKey:@"user_sig"];
    
    return [self POST:@"user/editprofile" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        int result = [[responseObject objectForKey:@"success"] intValue];
        if ( result == HTTPResponseCodeSuccess) {
            UserAccount *userAccount = [MTLJSONAdapter modelOfClass:UserAccount.class fromJSONDictionary:[responseObject objectForKey:@"data"] error:nil];
            UserAccount *saveUserAccount = [PTUtilities readLoginUser];
            saveUserAccount.nickname = userAccount.nickname;
            saveUserAccount.userAvatarImageLargeURL = userAccount.userAvatarImageLargeURL;
            saveUserAccount.userCoverURL = userAccount.userCoverURL;
            saveUserAccount.userSig = userAccount.userSig;
            
            [PTUtilities saveLoginUser:saveUserAccount];
            
            if (block) {
                block(saveUserAccount,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"登录失效，需要重新登录", nil)}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)findSelfProfileWithUserId:(NSNumber *)userId
                                              token:(NSString *)token
                                         completion:(void(^)(SelfUserProfile *user,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:token forKey:@"token"];
    
    return [self POST:@"user/myprofile" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSDictionary *nullsReplacedDictionary = [[NSDictionary dictionary] nestedDictionaryByReplacingNullsWithNil:[responseObject objectForKey:@"data"]];
            SelfUserProfile *userProfile = [MTLJSONAdapter modelOfClass:SelfUserProfile.class fromJSONDictionary:nullsReplacedDictionary error:nil];
            UserAccount *saveUserAccount = [PTUtilities readLoginUser];
            saveUserAccount.userFolowCount = userProfile.userAccount.userFolowCount;
            saveUserAccount.userFolowedCount = userProfile.userAccount.userFolowedCount;
            saveUserAccount.nickname = userProfile.userAccount.nickname;
            saveUserAccount.userCoverURL = userProfile.userAccount.userCoverURL;
            saveUserAccount.userAvatarImageURL = userProfile.userAccount.userAvatarImageURL;
            saveUserAccount.userAvatarImageMiniURL = userProfile.userAccount.userAvatarImageMiniURL;
            saveUserAccount.userAvatarImageLargeURL = userProfile.userAccount.userAvatarImageLargeURL;
            saveUserAccount.sex = userProfile.userAccount.sex;
            saveUserAccount.interest = userProfile.userAccount.interest;
            saveUserAccount.userSig = userProfile.userAccount.userSig;
            saveUserAccount.loveStar = userProfile.userAccount.loveStar;
            
            [PTUtilities saveLoginUser:saveUserAccount];
            
            [PTUtilities saveMyProfile:userProfile];
            
            if (block) {
                block(userProfile,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"登录失效，需要重新登录", nil)}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)findUserProfileWithUserId:(NSNumber *)userId
                                              token:(NSString *)token
                                        otherUserId:(NSNumber *)otherUserId
                                         completion:(void(^)(OtherUserProfile *user,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:otherUserId forKey:@"target_uid"];
    
    return [self POST:@"user/profile" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            OtherUserProfile *userProfile = [MTLJSONAdapter modelOfClass:OtherUserProfile.class fromJSONDictionary:[responseObject objectForKey:@"data"] error:nil];
            [PTUtilities saveOtherProfile:userProfile];
            if (block) {
                block(userProfile,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)addUserRecentPlayWithUserId:(NSNumber *)userId
                                                token:(NSString *)token
                                              musicId:(NSNumber *)musicId
                                            musicName:(NSString *)musicName{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:musicId forKey:@"sid"];
    [parameters setObject:musicName forKey:@"name"];
    
    return [self POST:@"music/recentplay" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        UALog(@"recentPlay...responseObject...%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UALog(@"recentPlay...%@",[error localizedDescription]);
    }];
}

- (NSURLSessionDataTask *)userFollowActWithUserId:(NSNumber *)userId
                                            token:(NSString *)token
                                      otherUserId:(NSNumber *)otherUserId
                                          actType:(UserFollowAct)type
                                       completion:(void(^)(NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:otherUserId forKey:@"target_uid"];
    if (type == UserFollowActAdd) {
        [parameters setObject:@"add" forKey:@"act"];
    }else{
        [parameters setObject:@"del" forKey:@"act"];
    }
    
    return [self POST:@"user/flowuser" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                 block(nil);
            }
        }else if(result == HTTPResponseCodeTokenExpire){
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserFollowActionFailedMsgKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)fetchUserFollowUsersWithUserId:(NSNumber *)userId
                                                   token:(NSString *)token
                                                    page:(NSInteger)page
                                             otherUserId:(NSNumber *)otherUserId
                                              completion:(void(^)(NSArray *follows,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    if (otherUserId != nil) {
        [parameters setObject:otherUserId forKey:@"target_uid"];
    }
    
    return [self POST:@"user/myflowuser" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *follows = [MTLJSONAdapter modelsOfClass:UserAccount.class fromJSONArray:[responseObject objectForKey:@"data"] error:nil];
            if (block) {
                block(follows,nil);
            }
        }else if(result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)fetchUserFollowedUsersWithUserId:(NSNumber *)userId
                                                     token:(NSString *)token
                                                      page:(NSInteger)page
                                               otherUserId:(NSNumber *)otherUserId
                                                completion:(void(^)(NSArray *followeds,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    if (otherUserId != nil) {
        [parameters setObject:otherUserId forKey:@"target_uid"];
    }
    
    return [self POST:@"user/myfloweduser" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *followeds = [MTLJSONAdapter modelsOfClass:UserAccount.class fromJSONArray:[responseObject objectForKey:@"data"] error:nil];
            if (block) {
                block(followeds,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
//                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
//            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

#pragma mark add playlist count number

- (NSURLSessionDataTask *)increasePlaylistPlayingCountWithUserId:(NSNumber *)userId token:(NSString *)tokenStr playlistId:(NSString *)lid songId:(NSString *)sid completionBlock:(void (^)(BOOL success, NSError *error))block {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:lid forKey:@"lid"];
    [parameters setObject:sid forKey:@"sid"];
    return [self POST:@"music/AddPlayNum" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        UALog(@"increase playlist playing count: %@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                block(YES, nil);
            }
        } else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(NO,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(NO,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(NO,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

#pragma mark new play list
- (NSURLSessionDataTask *)creatPlaylistWithPlaylistName:(NSString *)playlistName
                                                 userId:(NSString *)userId
                                                  token:(NSString *)tokenStr
                                             completion:(void(^)(NSString *listId, NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:playlistName forKey:@"list_name"];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    return [self POST:@"music/create" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"ceart play list ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                block([[responseObject objectForKey:@"data"] objectForKey:@"lid"],nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
//            block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//get play list
- (NSURLSessionDataTask *)getPlaylistAndFollowlistWithUserId:(NSString *)userId
                                                       token:(NSString *)tokenStr
                                                        page:(int)pageCount
                                                  completion:(void(^)(NSArray *playlists,NSError *error))block{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:[NSString stringWithFormat:@"%d",pageCount] forKey:@"page"];
    return [self POST:@"music/list" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"get play list ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *playlists = [MTLJSONAdapter modelsOfClass:PlaylistObj.class
                                                 fromJSONArray:[responseObject objectForKey:@"data"]
                                                         error:nil];
            if (block) {
                block(playlists,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
//            block(nil,[NSError errorWithDomain:@"Duorey" code:1000 userInfo:@{NSLocalizedDescriptionKey:[responseObject objectForKey:@"message"]}]);
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//get play list
- (NSURLSessionDataTask *)getOtherPlaylistAndFollowlistWithUserId:(NSString *)userId
                                                            token:(NSString *)tokenStr
                                                     targetUserId:(NSString *)targetUserId
                                                             page:(int)page
                                                  completion:(void(^)(NSArray *playlists,NSError *error))block{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:targetUserId forKey:@"target_uid"];
    [parameters setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    return [self POST:@"music/TargetUserList" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"get play list ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *playlists = [MTLJSONAdapter modelsOfClass:PlaylistObj.class
                                                 fromJSONArray:[responseObject objectForKey:@"data"]
                                                         error:nil];
            if (block) {
                block(playlists,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//get one list
- (NSURLSessionDataTask *)getOneListWithUserId:(NSString *)userId
                                         token:(NSString *)tokenStr
                                        listId:(NSString *)listId
                                          page:(int)pageCount
                                    completion:(void(^)(PubPlaylist *pubPlaylistObj,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:listId forKey:@"lid"];
//    [parameters setObject:[NSString stringWithFormat:@"%d",pageCount] forKey:@"page"];
    [parameters setObject:@"all" forKey:@"page"];

    return [self POST:@"music/listdesc" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"get one list ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            PubPlaylist *pubPlaylistObj = [MTLJSONAdapter modelOfClass:PubPlaylist.class
                                                    fromJSONDictionary:[responseObject objectForKey:@"data"]
                                                                 error:nil];
            if (block) {
                block(pubPlaylistObj,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
//        block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//add music to playlist
- (NSURLSessionDataTask *)addOneMusicToHaveListWithMusicDic:(NSMutableDictionary *)musicDic
                                                 completion:(void(^)(NSError *error))block{
    return [self POST:@"music/addlist" parameters:musicDic success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"add music to playlist ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                block(nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
//        block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:[error localizedDescription]}]);
        if (block) {
            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//add music to playlist
- (NSURLSessionDataTask *)addOneMusicToCreatListWithMusicDic:(NSMutableDictionary *)musicDic
                                                  completion:(void(^)(NSError *error))block{
    return [self POST:@"music/addnewlist" parameters:musicDic success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"add music to playlist ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                 block(nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//add music to playlist
- (NSURLSessionDataTask *)deleteOneMusicWithMusicDic:(NSMutableDictionary *)musicDic
                                          completion:(void(^)(NSError *error))block{
    return [self POST:@"music/del" parameters:musicDic success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"add music to playlist ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                 block(nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//add main view value
- (NSURLSessionDataTask *)getMainViewListWithMusicWithUserId:(NSString *)userId
                                                       token:(NSString *)tokenStr
                                                        page:(int)pageCount
                                                  completion:(void(^)(NSMutableDictionary *values, NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:[NSString stringWithFormat:@"%d",pageCount] forKey:@"page"];
    return [self POST:@"music/index" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"get main value ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSMutableDictionary *valueDic = [responseObject objectForKey:@"data"];
            if (block) {
                block(valueDic,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//add main view value
- (NSURLSessionDataTask *)getMainViewListMoreWithMusicWithUserId:(NSString *)userId
                                                           token:(NSString *)tokenStr
                                                            type:(NSString *)typeStr
                                                            page:(int)pageCount
                                                      completion:(void(^)(NSArray *values, NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:typeStr forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%d",pageCount] forKey:@"page"];
    return [self POST:@"music/gethnt" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"get main value ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *values = [MTLJSONAdapter modelsOfClass:MainViewObj.class fromJSONArray:[responseObject objectForKey:@"data"] error:nil];
            if (block) {
                block(values,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//do playlist Praise
- (NSURLSessionDataTask *)playlistFlowWithUserId:(NSString *)userId
                                            listId:(NSString *)listId
                                             token:(NSString *)tokenStr
                                            action:(NSString *)actStr
                                        completion:(void(^)(PlaylistObj *playlist,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:listId forKey:@"lid"];
    [parameters setObject:actStr forKey:@"act"];
    return [self POST:@"user/flowlist" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"do playlist Praise ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            PlaylistObj *playlist = [MTLJSONAdapter modelOfClass:[PlaylistObj class]
                                              fromJSONDictionary:[responseObject objectForKey:@"data"]
                                                           error:nil];
            if (block) {
                block(playlist,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//do playlist Praise
- (NSURLSessionDataTask *)playlistPraiseWithUserId:(NSString *)userId
                                            listId:(NSString *)listId
                                             token:(NSString *)tokenStr
                                            action:(NSString *)actStr
                                        completion:(void(^)(PlaylistObj *playlist,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:listId forKey:@"lid"];
    [parameters setObject:actStr forKey:@"act"];
    return [self POST:@"user/ding" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"user playlist Ding ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            PlaylistObj *playlist = [MTLJSONAdapter modelOfClass:[PlaylistObj class]
                                              fromJSONDictionary:[responseObject objectForKey:@"data"]
                                                           error:nil];
            if (block) {
                block(playlist,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//search  list
- (NSURLSessionDataTask *)searchListWitUserId:(NSString *)userId
                                    withToken:(NSString *)tokenStr
                                 withKeywords:(NSString *)keywords
                                   completion:(void(^)(NSArray *playlists,NSError *error))block{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:keywords forKey:@"keywords"];
    return [self POST:@"music/searchlist" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"do playlist Ding ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *playlists = [MTLJSONAdapter modelsOfClass:PlaylistObj.class
                                                 fromJSONArray:[responseObject objectForKey:@"data"]
                                                         error:nil];
            if (block) {
                block(playlists,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)activityWithUserId:(NSString *)userId
                                       token:(NSString *)tokenStr
                                        page:(NSInteger)page
                                  completion:(void(^)(NSArray *activity,NSError *error))block
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:tokenStr forKey:@"token"];
    [parameters setObject:userId forKey:@"uid"];
    [parameters setObject:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"page"];
    return [self POST:@"user/useractive" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        UALog(@"user active ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *array = [responseObject objectForKey:@"data"];
            NSMutableArray *activityArray = [NSMutableArray array];
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ActivityObj *activity = [MTLJSONAdapter modelOfClass:ActivityObj.class
                                                        fromJSONDictionary:obj
                                                                error:nil];
                if (activity)
                {
                    [activityArray addObject:activity];
                }
                
            }];
            
            if (block) {
                block(activityArray,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//add music to playlist
- (NSURLSessionDataTask *)editPlaylistInfoWithDic:(NSMutableDictionary *)playlistDic
                                        completion:(void(^)(NSError *error))block{
    return [self POST:@"music/editlist" parameters:playlistDic success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"add music to playlist ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                block(nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//add music to playlist
- (NSURLSessionDataTask *)importPlatlistWithDic:(NSMutableDictionary *)playlistDic
                                     completion:(void(^)(NSError *error))block{
    return [self POST:@"music/import" parameters:playlistDic success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"add music to playlist ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                block(nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}


// 歌单播放次数+1
- (NSURLSessionDataTask *)recentPlaylistWithDic:(NSMutableDictionary *)playlistDic
                                     completion:(void(^)(NSError *error))block{
    return [self POST:@"music/recentplaylist" parameters:playlistDic success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"歌单播放次数+1 ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            if (block) {
                block(nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block([NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block([NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//get playlist all liker
- (NSURLSessionDataTask *)getPlaylistLikersWithDic:(NSMutableDictionary *)playlistDic
                                        completion:(void(^)(NSArray *users,NSError *error))block{
    return [self POST:@"music/DingUserList" parameters:playlistDic success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"add music to playlist ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *users = [MTLJSONAdapter modelsOfClass:UserAccount.class
                                             fromJSONArray:[responseObject objectForKey:@"data"]
                                                     error:nil];
            if (block) {
                block(users,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

//get playlist all feeder
- (NSURLSessionDataTask *)getPlaylistFeedersWithDic:(NSMutableDictionary *)playlistDic
                                        completion:(void(^)(NSArray *users,NSError *error))block{
    return [self POST:@"music/FeedUserList" parameters:playlistDic success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        UALog(@"add music to playlist ...%@",responseObject);
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSArray *users = [MTLJSONAdapter modelsOfClass:UserAccount.class
                                             fromJSONArray:[responseObject objectForKey:@"data"]
                                                     error:nil];
            if (block) {
                block(users,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}

- (NSURLSessionDataTask *)getShareShortAddressWithString:(NSString *)shareOriginStr
                                              completion:(void(^)(NSString *shareShortURL,NSError *error))block {
    UserAccount *user = [PTUtilities readLoginUser];
    NSMutableDictionary *parameterDic = [NSMutableDictionary dictionary];
    [parameterDic setValue:user.userId forKey:@"uid"];
    [parameterDic setValue:shareOriginStr forKey:@"url"];
    [parameterDic setValue:user.userToken forKey:@"token"];
    return [self POST:@"music/shorturl" parameters:parameterDic success:^(NSURLSessionDataTask *task, id responseObject) {
        int result = [[responseObject objectForKey:@"success"] intValue];
        if (result == HTTPResponseCodeSuccess) {
            NSString *shortUrl = [responseObject objectForKey:@"message"];
            if (block) {
                block(shortUrl,nil);
            }
        }else if (result == HTTPResponseCodeTokenExpire){
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeTokenExpire userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"UserTokenChangeMsgKey", nil)}]);
            }
        }else{
            if (block) {
                block(nil,[NSError errorWithDomain:@"Duorey" code:HTTPResponseCodeError userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,[NSError errorWithDomain:@"Duorey" code:error.code userInfo:@{NSLocalizedDescriptionKey:PTNSLocalizedString(@"LoadDataErrorMskKey", nil)}]);
        }
    }];
}
@end
