//
//  ImportPlaylist.h
//  Duorey
//
//  Created by lixu on 14/12/2.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImportMusic.h"

@interface ImportPlaylist : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSArray *importMusics;
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) int source;

@end
