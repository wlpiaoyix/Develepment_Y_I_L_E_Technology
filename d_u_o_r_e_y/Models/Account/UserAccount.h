//
//  User.h
//  Duorey
//
//  Created by xdy on 14/11/6.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Mantle.h>
#import "MTLModel+DNullableScalar.h"
#import "PTEnum.h"
#import "SpotifyAccount.h"
#import "SoundCloudAccount.h"
#import "RdioAccount.h"

@interface UserAccount : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong, readonly) NSNumber *userId;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *userExtUserName;
@property (nonatomic, copy, readonly) NSString *userExtId;

@property (nonatomic, strong) NSNumber *userFolowCount;
@property (nonatomic, strong) NSNumber *userFolowedCount;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, strong) NSURL *userCoverURL;
@property (nonatomic, strong) NSURL *userAvatarImageURL;
@property (nonatomic, strong) NSURL *userAvatarImageMiniURL;
@property (nonatomic, strong) NSURL *userAvatarImageLargeURL;
@property (nonatomic, assign) UserType userType;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *interest;
@property (nonatomic, copy) NSString *userSig;
@property (nonatomic, copy) NSString *loveStar;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, assign, getter= isTryUseApp) BOOL tryUseApp;
@property (nonatomic, strong) SoundCloudAccount *soundCloudAccount;
@property (nonatomic, strong) SpotifyAccount *spotifyAccount;
@property (nonatomic, strong) RdioAccount *rdioAccount;
@end
