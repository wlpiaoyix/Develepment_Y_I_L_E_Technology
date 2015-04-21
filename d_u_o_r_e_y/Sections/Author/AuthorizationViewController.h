//
//  AuthorizationViewController.h
//  Duorey
//
//  Created by xdy on 14/11/13.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTEnum.h"
#import "UserAccount.h"

#define RDIO_KEY @"vek9gvq3a35h94cbcfpjysv7"
#define RDIO_SECRET @"Cbu5pwxn8Y"
#define RDIO_CALLBACK_URL @"duorey://rdio/callback"

#define SPOTIFY_KEY @"a286b79887964e5eb665d2a4f8e02ada"
#define SPOTIFY_SECRET @"6995e1efd91747a093c9fc6471e2334e"
#define SPOTIFY_CALLBACK_URL @"duorey://spotify/callback"

#define SOUNDCLOUD_KEY @"0f59b312672b4d4231dd9aafcb0ba44d"
#define SOUNDCLOUD_SECRET @"51394de472b3e20bb10f4d26591bc869"
#define SOUNDCLOUD_CALLBACK_URL @"duorey://soundcloud/callback"

#define CALL_BACK_URL @"http://www.duorey.com"


@class AuthorizationViewController;

@protocol AuthorizationViewControllerDelegate <NSObject>

- (void)authorizationDidfinished:(AuthorizationViewController *)controller success:(BOOL)status connectType:(ConnectService)type;

@end

@interface AuthorizationViewController : UIViewController


@property (assign, nonatomic) ConnectService connectType;
@property (weak, nonatomic) id<AuthorizationViewControllerDelegate> delegate;

+ (void)refreshSpotifyTokenWithRefreshToken:(UserAccount *)userAccount completion:(void(^)(UserAccount *user,NSError *error))block;
@end
