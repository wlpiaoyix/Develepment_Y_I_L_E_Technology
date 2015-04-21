//
//  OtherUserProfile.h
//  Duorey
//
//  Created by xdy on 14/11/25.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle.h>
#import "UserAccount.h"
#import "PlaylistObj.h"

@interface OtherUserProfile : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) UserAccount *userAccount;
@property (strong, nonatomic) NSArray *feedPlaylists;
@property (assign, nonatomic,getter=isFollowed) BOOL followed;
@end
