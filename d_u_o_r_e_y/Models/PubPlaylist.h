//
//  PubPlaylist.h
//  Duorey
//
//  Created by lixu on 14/12/1.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel+DNullableScalar.h"
#import "PlaylistDetail.h"
#import "PlaylistObj.h"

@interface PubPlaylist : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSArray *allData;
@property (strong, nonatomic) PlaylistObj *playlistObj;
@property ( nonatomic) int isFlow;
@property ( nonatomic) int isDing;

@end
