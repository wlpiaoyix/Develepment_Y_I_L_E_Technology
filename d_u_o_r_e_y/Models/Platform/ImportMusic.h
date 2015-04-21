//
//  ImportMusic.h
//  Duorey
//
//  Created by lixu on 14/12/2.
//  Copyright (c) 2014年 www.yileapp.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistObj.h"

@interface ImportMusic : MTLModel<MTLJSONSerializing>

@property (strong, nonatomic) NSArray *musicArr;
@property (strong, nonatomic) PlaylistObj *playlist;

@end
